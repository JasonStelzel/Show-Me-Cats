# Show-Me-Cats
A demo slide show app in Swift that uses the cataas.com API to serve up images to a SwiftUI front end.

The app features a load-ahead buffer with user-configurable buffer that determines how many images to preload in the background while the slide show plays. Simply tap the screen once to bring up the on-screen controls. Tap again to dismiss.

The app will begin downloading images in the background immediately upon moving from the opening screen to the loading screen. Upon loading the first image, it will be displayed and then continue to grow its buffer. You can change the size of the buffer at any time without interrupting the show and it will seemlessly grow the size of the show. Additional controls allow for setting the smoothness of the transitions from image to image as well as the delay between transitions. These settings as well as the show's image count are saved in UserDefaults so that they will be maintained between app launches.  Additionally, an image counter shows the image being shown so that you can track where you are as the buffer is grown should you decide to change the size of the show after it starts.
