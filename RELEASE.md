# Release process

1. Update the `MARKETING_VERSION` in each module.
2. Update the `ACTITO_VERSION` in `ActitoKit/Sources/Internals/Version.swift`.
3. Update the `CHANGELOG.md`.
4. Run `ruby build.rb NEW_VERSION_HERE`.
5. Push the generated changes to the repo.
6. Upload the contents of `.build/outputs` to the CDN.
7. Create a GitHub release with the contents of the `CHANGELOG.md`. 
8. Run `pod trunk push Actito.podspec` to update the CocoaPods CDN.
