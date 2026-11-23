# Development guide

## Getting started

### Configuring auto registration

You have the option to set up a static user for automatic registration on your device. This feature helps the process of targeting your devices during development across various app installations. Create a `SampleUser.plist` on the Sample App directory with the properties `userId` and `userName`



### Git hooks

To ensure correct linting, formatting, and that the commit messages are up to convention, 2 git hooks are present in the .hooks folder.
To install them, please run the following command in root folder:

```shell
git config core.hooksPath .hooks
```

### Qualifio SDK

The Sample app depends on the Qualifio SDK through Swift Package Manager. To test unreleased changes in the Qualifio SDK, use `scripts/qualifio.rb` to switch the Sample project between the remote package and a local `qualifio-sdk-ios` checkout.

```shell
# Use the local qualifio-sdk-ios checkout.
ruby scripts/qualifio.rb local

# Go back to the remote package. Pass a version to change the one in use.
ruby scripts/qualifio.rb remote [version]

# Show which package the Sample app uses.
ruby scripts/qualifio.rb status
```

The script looks for `qualifio-sdk-ios` next to this repository, in its grandparent folder, or in any folder inside the grandparent (e.g. `~/Developer/qualifio/qualifio-sdk-ios`). The local checkout must also point to a local build of the SDK. Run `ruby scripts/spm.rb local` in `qualifio-sdk-ios` first (see its `DEVELOPMENT.md`).

Never commit the Sample project or `Package.resolved` while they point to a local checkout. Run `ruby scripts/qualifio.rb remote` first.

#### Secure token

The Sample app signs a Qualifio secure token that prefills the campaign form with sample data. To enable it, create a `QualifioSecrets.plist` on the Sample App directory with the property `secureTokenSecret`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>secureTokenSecret</key>
	<string>your-secret</string>
</dict>
</plist>
```

Without it, campaigns load without a token.
