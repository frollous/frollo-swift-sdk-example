fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios bootstrap
```
fastlane ios bootstrap
```
Bootstraps the environment with carthage dependencies (from cache if possible) and match certificates
### ios dependencies
```
fastlane ios dependencies
```
Bootstraps just dependencies for carthage
### ios update_dependencies
```
fastlane ios update_dependencies
```
Update and publish carthage dependencies
### ios deploy
```
fastlane ios deploy
```
Deploy to AppCenter

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
