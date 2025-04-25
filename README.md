<p align="center">
  <img align="center" src="Media/swift-challenge-distinguished-winner-light.png#gh-light-mode-only" width=275px>
  <img align="center" src="Media/swift-challenge-distinguished-winner-dark.png#gh-dark-mode-only" width=275px>
</p>

<p align="center">
  <img src="Media/AppIcon.png" alt="Logo" width="110" height="110">
  <h2 align="center">
    Findy
  </h2>
</p>

<img src="https://github.com/matt-novoselov/matt-novoselov/blob/fda0d85176e30230c06d6bc9e3178399440205d8/Files/SVGs/Badges/Platforms/ios18.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/43737e69c9b80e3fdcebcf497c033a061f51aea8/Files/SVGs/Badges/Frameworks/ARKit.svg" alt="" style="height: 30px">  <img src="https://github.com/matt-novoselov/matt-novoselov/blob/43737e69c9b80e3fdcebcf497c033a061f51aea8/Files/SVGs/Badges/Frameworks/Vision.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/58a1be3d03d2558b81e787a0a13927faf3465be2/Files/SVGs/Badges/Frameworks/RealityKit.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/43737e69c9b80e3fdcebcf497c033a061f51aea8/Files/SVGs/Badges/Frameworks/Image%20Playground.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/43737e69c9b80e3fdcebcf497c033a061f51aea8/Files/SVGs/Badges/Frameworks/Create%20ML.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/58a1be3d03d2558b81e787a0a13927faf3465be2/Files/SVGs/Badges/Frameworks/CoreML.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/58a1be3d03d2558b81e787a0a13927faf3465be2/Files/SVGs/Badges/Frameworks/AVFoundation.svg" alt="" style="height: 30px">  <img src="https://github.com/matt-novoselov/matt-novoselov/blob/58a1be3d03d2558b81e787a0a13927faf3465be2/Files/SVGs/Badges/Frameworks/SwiftUI.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/58a1be3d03d2558b81e787a0a13927faf3465be2/Files/SVGs/Badges/Frameworks/UIKit.svg" alt="" style="height: 30px"> <img src="https://github.com/matt-novoselov/matt-novoselov/blob/43737e69c9b80e3fdcebcf497c033a061f51aea8/Files/SVGs/Badges/Frameworks/TipKit.svg" alt="" style="height: 30px">

Findy helps people with low vision to independently locate everyday items (like keys or TV remote) by training an on-device personalized AI model with photos of their belongings, and then guiding users with real-time voice directions and AR cues to the item’s real-time location through the device’s camera.

<a href="https://youtu.be/2LPPNqYNvL0" target="_blank">
  <img src="https://github.com/user-attachments/assets/496bfe10-fd5e-49a8-8752-b9de4f2a57a8" alt="GIF" width="1920">
</a>


[![](https://github.com/matt-novoselov/matt-novoselov/blob/34555effedede5dd5aa24ae675218d989e976cf6/Files/YouTube_Badge.svg)](https://youtu.be/2LPPNqYNvL0)


## Features

### Save and recognize objects  
Findy allows users to save objects by taking six photos, providing a comprehensive view for accurate recognition.

### On-device AI training  
Using Create ML, Findy trains a custom AI model entirely on the user’s device, ensuring privacy and personalization.

### Enhanced image processing  
The Vision framework improves image data by separating backgrounds, isolating objects, and generating relevant tags for better AI training.

### Live object detection  
With CoreML, Findy analyzes the live camera feed to identify saved objects in real time.

### 3D navigation assistance  
ARKit converts 2D object coordinates into 3D spatial data, and RealityKit renders an arrow pointing to the item’s location.

### Spatial audio guidance  
Using AVFoundation and RealityKit, Findy provides voice instructions and spatial audio cues to guide users toward their objects.

### AI-powered image enhancement  
Users can leverage Apple Intelligence via Image Playground to generate high-quality preview images of saved objects.

<br>

Findy incorporates accessibility features to assist our users, including support for VoiceOver.

![](Media/BentoGrid.png)

## Requirements
- iOS 18.2+
- Xcode 16.0+

## Installation
1. Open Xcode.
2. Click on **"Clone Git Repository"**.
3. Paste the following URL: `https://github.com/matt-novoselov/Findy`
4. Click **"Clone"**.
5. Build and run the project in Xcode.

<br>

## Credits
Required attribution for YOLOv8:
- Author: Ultralytics
- License: GNU Affero General Public License v3.0 (AGPL-3.0)
- Copyright: © Ultralytics
- Source Code: https://github.com/ultralytics/ultralytics
- License Text: https://github.com/ultralytics/ultralytics/blob/main/LICENSE

For compliance, the full AGPL-3.0 license text along with the credits is included in the app’s legal section (settings).

<br>

Distributed under the MIT license. See **LICENSE** for more information.

Developed with ❤️ by Matt Novoselov
