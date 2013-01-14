# Introduction
This sample demonstrates the situation when an user logs in into your app using the native login on iOS 6 and alters/removes the application from the ApplicationCetner on facebook.com or has expired token. 

FBRequest class automatically requests a new access token when there is an error communicating with Facebook. If you don't use FBRequest, you've got to handle this situation yourself.
# Example
- Select login and accept the permissions
- Try test and test 2
- Go to your AppCenter on facebook.com and delete **PetrPavlikIOSTest**
- Try test 2
- Select login again