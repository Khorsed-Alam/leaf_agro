# AgriCare AI — Troubleshooting Guide

## 1. Frequently Encountered Issues

| Issue / Symptom | Possible Cause | Recommended Solution |
| :--- | :--- | :--- |
| **"Camera shows black screen or fails to open"** | Camera permission was denied in Android settings. | Go to your phone's Settings > Apps > AgriCare AI > Permissions > Camera, and select "Allow while using the app". |
| **"Low confidence or 'Unrecognized Leaf' warning"** | Image is blurry, shot in dim light, or the crop is not one of the 5 trained crops. | Retake the photo in daylight, steady your phone, and make sure the leaf belongs to Rice, Potato, Tomato, Mango, or Jute. |
| **"Photos take a long time to upload to cloud"** | Slow 2G/3G mobile data connection in rural area. | Do not worry. All diagnosis runs offline immediately and results are saved on your phone. Cloud sync will finish automatically when you reach better connectivity. |
| **"App says 'Storage full' when taking photos"** | Your phone has insufficient free disk storage. | Go to Settings > Storage & Cache inside the app, and tap "Clear Temporary Cache" to free up storage space. |
| **"Bengali characters appear broken or distorted"** | Missing Unicode Bengali rendering on very old Android versions. | Ensure the app is updated to version 1.0.0+1, which bundles the Google Fonts `Noto Sans Bengali` font directly in the application. |
| **"Forgot password email didn't arrive"** | Email sent to spam folder or email typed incorrectly. | Check your Spam/Junk folder in your email app. Ensure you entered the exact email address used during registration. |

