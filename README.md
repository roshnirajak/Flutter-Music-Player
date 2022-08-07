
# Flutter Music Player 

This app plays offline music present on your device.


## Permission
To access local storage of your device for:
### Android
Add this permission in AndroidManifest.xml    
Path: android/app/src/main/AndroidManifest.xml
```bash
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.project">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.CALL_PHONE"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
 <application>...
```
### IOS
Add this permission in Info.plist  
Path: ios/Runner/Info.plist
```bash
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires to save your images user gallery</string>
```

