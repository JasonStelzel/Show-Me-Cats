![Image 12-8-22 at 9 58 AM](https://user-images.githubusercontent.com/4708080/206788390-cf6f207b-49eb-4004-b414-1500e7b8c7db.JPG)
# Show-Me-Cats
A demo slide show app in Swift that uses the cataas.com API to serve up images to a SwiftUI front end.

The app features a load-ahead buffer with user-configurable size that determines how many images to preload in the background while the slide show plays. Simply tap the screen once to bring up the on-screen controls. Tap again to dismiss.

The app will begin downloading images in the background immediately upon moving from the opening screen to the show screen. Upon loading the first image, it will be displayed and then continue to grow its buffer. You can change the size of the buffer at any time without interrupting the show and it will seemlessly grow the size of the show (note that it will not reduce the size of a show that has already grown beyond the size of a shortened buffer until resetting the show by returning to the opening screen and initiating a new show). Additional controls allow for setting the smoothness of the transitions from image to image as well as the delay between transitions. These settings as well as the show's image count are saved in UserDefaults so that they will be maintained between shows as well as app launches.  Setting either the Fade Time or the Wait Time to zero will reset it to its default setting upon the next viewing of this screen (by either visiting the home screen and returning or exiting the app and initiating a new show).  Additionally, an image counter shows the image being shown so that you can track where you are as the buffer is grown should you decide to change the size of the show after it starts (and this helps to watch the size of each iteration of the show as it grows through each presentation).
