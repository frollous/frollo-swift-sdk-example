# Frollo iOS SDK Example

## Cloning
**This example project uses the [Frollo iOS SDK](https://bitbucket.org/frollo1/frollo-ios-sdk/src/master/) project as a submodule so developers are able to update the SDK whilst running this example project.**

To clone the repository including the submodule, use the following command:
```
git clone git@bitbucket.org:frollo1/frollo-ios-sdk-example.git --recurse-submodules
```

## Bootstrapping environment

To get a new environment working for Frollo iOS use the following steps:


1. Install Homebrew - https://brew.sh/
2. Install Carthage using brew - `brew install carthage`
3. Bootstrap the dependencies (slow!) - `carthage bootstrap --platform iOS --no-use-binaries`
4. Install RVM - https://rvm.io/
5. Using Terminal in the root project directory active RVM - `rvm use .`
6. Install bundler - `gem install bundler`
7. Setup the bundled gems - `bundle install`
8. Bootstrap the local environment for code signing etc - `fastlane bootstrap --env frollo`
9. (Optional) Bootstrap any other vendor certificates as needed - `fastlane bootstrap --env pioneer`
10. Passwords for the above can be found in 1Password as *Match Password* and *Apple ci@frollo.us*
11. Build! 👷‍♂️

## Issues
If you're experiencing some problems maybe clearing the Carthage cache might fix it. You can do that by executing:

```
rm -rf ~/Library/Caches/org.carthage.CarthageKit
```
