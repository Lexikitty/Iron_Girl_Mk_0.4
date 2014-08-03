This sketch runs with Processing; v2.2.1 is the version I'm using. 

To use the serial data functions, you'll need Adafruit's 10-DOF sensor, found here:
http://www.adafruit.com/products/1604

So far, I'm using the unmodified AHRS sketch from their 10-DOF library. If I modify it, it will be added to this repository. The library can be found here:
https://github.com/adafruit/Adafruit_10DOF

IMPORTANT NOTES:
1. There is a variable called CameraSelection in the top of the program. You will need to change this variable to select which resolution settings and/or camera you want to use. 
Cameras will list all of the available modes in the console section of Processing; you may have to fiddle around with this to get the setting you want. 

2. You may also have to switch COM ports depending on which ones your Arduino's picked up.

3. This is still a pretty rough version of the code, I'll clean it up as the project goes more and more public. 

All code I wrote is released under the MIT license. Adafruit code belongs to Adafruit. 

Cheers, 
~Lexikitty
