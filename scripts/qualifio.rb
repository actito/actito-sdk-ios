# frozen_string_literal: true

# Switches the Qualifio SDK package used by the Sample app between the remote repository and a local checkout.
#
#   ruby scripts/qualifio.rb local              # use the local qualifio-sdk-ios checkout
#   ruby scripts/qualifio.rb remote [version]   # use the remote repository (default: the committed requirement)
#   ruby scripts/qualifio.rb status             # show which package the Sample app uses
#
# The local checkout is found next to this repository, in its grandparent folder,
# or in any folder inside the grandparent (e.g. ~/Developer/qualifio/qualifio-sdk-ios).
#
# The local checkout must point its Package.swift to a local build (`ruby scripts/spm.rb local` in qualifio-sdk-ios),
# otherwise the Sample app still uses the released binary.
# Never commit the Sample project while it points to a local checkout.

require 'json'
require 'open3'
require 'pathname'

$stdout.sync = true
Encoding.default_external = Encoding::UTF_8

ROOT = File.expand_path('..', __dir__)
PROJECT_DIR = File.join(ROOT, 'Sample')
PBXPROJ_PATH = 'Sample/Sample.xcodeproj/project.pbxproj'
PBXPROJ = File.join(ROOT, PBXPROJ_PATH)
RESOLVED_PATH = 'Actito.xcworkspace/xcshareddata/swiftpm/Package.resolved'
RESOLVED = File.join(ROOT, RESOLVED_PATH)
REPOSITORY_URL = 'https://github.com/qualifio/qualifio-sdk-ios'
PACKAGE_NAME = 'qualifio-sdk-ios'
PRODUCT_NAME = 'QualifioKit'
LOCAL_PACKAGE_OBJECT_VERSION = 60

def info(message)
  puts "\e[36m▸ #{message}\e[0m"
end

def success(message)
  puts "\e[32m✔ #{message}\e[0m"
end

def warning(message)
  puts "\e[33m! #{message}\e[0m"
end

def fail!(message)
  warn "\e[31m✘ #{message}\e[0m"
  exit 1
end

# Project parsing

# Every object in the project, as { id:, comment:, body:, text: }.
def objects(project)
  project.to_enum(:scan, %r{^\t\t(?<id>[0-9A-F]{24}) /\* (?<comment>.*?) \*/ = \{\n(?<body>.*?)^\t\t\};\n}m).map do
    match = Regexp.last_match
    { id: match[:id], comment: match[:comment], body: match[:body], text: match[0] }
  end
end

def remote_reference(project)
  objects(project).find do |object|
    object[:body].include?('isa = XCRemoteSwiftPackageReference;') &&
      object[:body].match?(%r{repositoryURL = "[^"]*/#{PACKAGE_NAME}(\.git)?";})
  end
end

def local_reference(project)
  objects(project).find do |object|
    object[:body].include?('isa = XCLocalSwiftPackageReference;') &&
      object[:body].match?(%r{relativePath = "?[^;]*#{PACKAGE_NAME}"?;})
  end
end

def product_dependency(project)
  objects(project).find do |object|
    object[:body].include?('isa = XCSwiftPackageProductDependency;') &&
      object[:body].include?("productName = #{PRODUCT_NAME};")
  end
end

# Quotes a value the way Xcode writes it in project files.
def quote(value)
  value.match?(%r{\A[A-Za-z0-9_./]+\z}) ? value : "\"#{value}\""
end

# Formats an object the way Xcode writes it, with the body lines indented one level deeper.
def object_text(id, comment, body)
  "\t\t#{id} /* #{comment} */ = {\n#{body.map { |line| "\t\t\t#{line}\n" }.join}\t\t};\n"
end

def section_name(isa)
  "/* Begin #{isa} section */"
end

# Inserts an object into its section, keeping the objects sorted by id like Xcode does.
# Creates the section before `before_section` when it does not exist yet.
def insert_object(project, isa, id, text, before_section:)
  begin_marker = section_name(isa)
  end_marker = "/* End #{isa} section */"

  unless project.include?(begin_marker)
    anchor = section_name(before_section)
    fail!("Unable to find the #{before_section} section in #{PBXPROJ_PATH}.") unless project.include?(anchor)

    project = project.sub(anchor, "#{begin_marker}\n#{end_marker}\n\n#{anchor}")
  end

  section_start = project.index(begin_marker) + begin_marker.length + 1
  section_end = project.index(end_marker)
  following = objects(project[section_start...section_end]).find { |object| object[:id] > id }
  position = following ? project.index(following[:text], section_start) : section_end

  project.dup.insert(position, text)
end

# Removes an object, along with its section when it becomes empty.
def remove_object(project, isa, object)
  project = project.sub(object[:text], '')
  project.sub("#{section_name(isa)}\n/* End #{isa} section */\n\n", '')
end

def object_version(project)
  project[/^\tobjectVersion = (\d+);$/, 1].to_i
end

def set_object_version(project, version)
  project.sub(/^\tobjectVersion = \d+;$/, "\tobjectVersion = #{version};")
end

def committed_project
  output, status = Open3.capture2e('git', 'show', "HEAD:#{PBXPROJ_PATH}", chdir: ROOT)
  status.success? ? output : nil
end

# Local

def qualifio_sdk_path(root)
  File.join(root, PACKAGE_NAME)
end

# Looks for the qualifio-sdk-ios checkout next to this repository, in its grandparent folder,
# and in every folder inside the grandparent (e.g. ~/Developer/qualifio/qualifio-sdk-ios).
def find_qualifio_sdk
  repo_parent = File.expand_path('..', ROOT)
  repo_grandparent = File.expand_path('..', repo_parent)

  checked_paths = []

  [repo_parent, repo_grandparent].each do |root|
    candidate = qualifio_sdk_path(root)
    checked_paths << candidate
    return candidate if File.file?(File.join(candidate, 'Package.swift'))
  end

  Dir.children(repo_grandparent).sort.each do |child|
    next if child.start_with?('.')

    child_path = File.join(repo_grandparent, child)
    next unless File.directory?(child_path)

    candidate = qualifio_sdk_path(child_path)
    next if checked_paths.include?(candidate)

    checked_paths << candidate
    return candidate if File.file?(File.join(candidate, 'Package.swift'))
  end

  fail!(<<~MESSAGE.strip)
    Could not find #{PACKAGE_NAME}.

    Checked:
    #{checked_paths.map { |path| "    - #{path}" }.join("\n")}
  MESSAGE
end

def use_local
  checkout = find_qualifio_sdk
  info "Using #{checkout}"

  project = File.read(PBXPROJ)
  relative_path = Pathname.new(checkout).relative_path_from(Pathname.new(PROJECT_DIR)).to_s

  if (local = local_reference(project))
    project = remove_object(project, 'XCLocalSwiftPackageReference', local)
    id = local[:id]
    reference_comment = local[:comment]
  elsif (remote = remote_reference(project))
    project = remove_object(project, 'XCRemoteSwiftPackageReference', remote)
    id = remote[:id]
    reference_comment = remote[:comment]
  else
    fail!("Unable to find the #{PACKAGE_NAME} package in #{PBXPROJ_PATH}. Add it in Xcode first.")
  end

  comment = "XCLocalSwiftPackageReference \"#{relative_path}\""
  text = object_text(id, comment, ['isa = XCLocalSwiftPackageReference;', "relativePath = #{quote(relative_path)};"])
  project = insert_object(project, 'XCLocalSwiftPackageReference', id, text, before_section: 'XCRemoteSwiftPackageReference')

  project = project.gsub("#{id} /* #{reference_comment} */", "#{id} /* #{comment} */")
  project = project.gsub(/^\t\t\tpackage = #{id} .*;\n/, '')
  project = set_object_version(project, LOCAL_PACKAGE_OBJECT_VERSION) if object_version(project) < LOCAL_PACKAGE_OBJECT_VERSION

  File.write(PBXPROJ, project)
  success "Sample now uses the local checkout at #{checkout}."

  manifest = File.read(File.join(checkout, 'Package.swift'))
  warning 'Its Package.swift points to the released binary. Run `ruby scripts/spm.rb local` in that checkout.' unless manifest.include?('path:')

  resolve_packages
end

# Remote

def remote_requirement(version)
  return "kind = exactVersion;\nversion = #{quote(version)};" if version

  committed = committed_project
  remote = committed && remote_reference(committed)
  fail!('The committed project does not use the remote package. Pass the version to use.') unless remote

  remote[:body][/^\t\t\trequirement = \{\n(.*?)^\t\t\t\};\n/m, 1].strip
end

# Turns a requirement such as `kind = exactVersion; version = "1.0.0-beta.1";` into `exactVersion 1.0.0-beta.1`.
def describe_requirement(requirement)
  values = requirement.scan(/(\w+) = "?([^";]+)"?;/).to_h
  [values.delete('kind'), *values.values].compact.join(' ')
end

def use_remote(version)
  project = File.read(PBXPROJ)
  requirement = remote_requirement(version)

  if (remote = remote_reference(project))
    project = remove_object(project, 'XCRemoteSwiftPackageReference', remote)
    id = remote[:id]
    reference_comment = remote[:comment]
  elsif (local = local_reference(project))
    project = remove_object(project, 'XCLocalSwiftPackageReference', local)
    id = local[:id]
    reference_comment = local[:comment]
  else
    fail!("Unable to find the #{PACKAGE_NAME} package in #{PBXPROJ_PATH}. Add it in Xcode first.")
  end

  comment = "XCRemoteSwiftPackageReference \"#{PACKAGE_NAME}\""
  text = object_text(id, comment, [
    'isa = XCRemoteSwiftPackageReference;',
    "repositoryURL = \"#{REPOSITORY_URL}\";",
    'requirement = {',
    *requirement.lines.map { |line| "\t#{line.strip}" },
    '};',
  ])
  project = insert_object(project, 'XCRemoteSwiftPackageReference', id, text, before_section: 'XCSwiftPackageProductDependency')

  project = project.gsub("#{id} /* #{reference_comment} */", "#{id} /* #{comment} */")

  product = product_dependency(project)
  fail!("Unable to find the #{PRODUCT_NAME} product dependency in #{PBXPROJ_PATH}.") unless product
  unless product[:body].include?("package = #{id} ")
    updated = product[:text].sub("isa = XCSwiftPackageProductDependency;\n", "isa = XCSwiftPackageProductDependency;\n\t\t\tpackage = #{id} /* #{comment} */;\n")
    project = project.sub(product[:text], updated)
  end

  # Restore the committed object version, unless another local package still needs the newer one.
  committed_version = committed_project.then { |committed| committed && object_version(committed) }
  if committed_version && committed_version < object_version(project) && !project.include?('isa = XCLocalSwiftPackageReference;')
    project = set_object_version(project, committed_version)
  end

  File.write(PBXPROJ, project)
  success "Sample now uses #{REPOSITORY_URL} (#{describe_requirement(requirement)})."

  resolve_packages
end

# Package resolution

def resolve_packages
  info 'Resolving packages to update Package.resolved'

  output, status = Open3.capture2e(
    'xcodebuild', '-resolvePackageDependencies',
    '-workspace', 'Actito.xcworkspace',
    '-scheme', 'Sample-Test',
    chdir: ROOT
  )

  fail!("Unable to resolve the packages.\n#{output}") unless status.success?
  restore_committed_resolved
  success 'Packages resolved.'
end

# xcodebuild and Xcode can write a different originHash for the same pins.
# When the pins match the committed ones, keep the committed file to avoid a meaningless diff.
def restore_committed_resolved
  committed, status = Open3.capture2e('git', 'show', "HEAD:#{RESOLVED_PATH}", chdir: ROOT)
  return unless status.success?

  current = File.read(RESOLVED)
  return if current == committed

  File.write(RESOLVED, committed) if JSON.parse(current)['pins'] == JSON.parse(committed)['pins']
rescue JSON::ParserError
  nil
end

# Status

def status
  project = File.read(PBXPROJ)

  if (local = local_reference(project))
    path = local[:body][/relativePath = "?([^";]+)"?;/, 1]
    puts "Local checkout: #{File.expand_path(path, PROJECT_DIR)}"
  elsif (remote = remote_reference(project))
    requirement = remote[:body][/requirement = \{\n(.*?)^\t\t\t\};/m, 1].to_s
    puts "Remote: #{REPOSITORY_URL} (#{describe_requirement(requirement)})"
  else
    puts "The Sample app does not use the #{PACKAGE_NAME} package."
  end
end

# Entry point

def usage
  puts File.read(__FILE__).lines.drop(2).take_while { |line| line.start_with?('#') }.map { |line| line.sub(/^# ?/, '') }
  exit 1
end

command, argument = ARGV
case command
when 'local' then use_local
when 'remote' then use_remote(argument)
when 'status' then status
else usage
end
