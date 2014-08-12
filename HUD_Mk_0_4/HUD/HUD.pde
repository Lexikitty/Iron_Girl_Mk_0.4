import processing.serial.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import processing.opengl.*;
//import saito.objloader.*;
import processing.video.*;

/*Color references - just made it easier for me to verify I was using the same colors - should be a variable at some point. 
 stroke(0,174,231); - Light blue
 stroke(255,255,0); - Yellow
 */

//USER OPTTIONS:

//Variable to select which USB camera/mode to use. 
int CameraSelection = 17; 

//Use this variable to select your COM port from the index.
int ComSelection = 0;  

//BEGIN CODE

//Images to be loaded
PFont font; 
PImage bg; 
PImage HUDOutline; 
PImage HUDHorizon;
PImage HUDCrosshair; 
PImage HelmetHeading; 
PImage BodyHeading;

//Camera variables
Capture cam;
int NoCam = 0; //Allows the HUD to run without a camera present
PImage VFU; 

//Mode images 
/*Not currently used.
 PImage AttackLit; 
 PImage NavLit; 
 PImage CommLit; 
 PImage RTLit; 
 PImage FlightLit; 
 */

//Repulsor power variables
int RepRPower = 0; //Add real data
int RepLPower = 0; //Add real data

//Graph mapping variables
float RepRMap; 
float RepLMap; 
float HelmMap; 
float BodyMap; 

//10-DOF variables
float roll  = 0.0F;
float pitch = 0.0F;
float yaw   = 0.0F;
float temp  = 0.0F;
float alt   = 0.0F;

//OBJModel model; //no longer used

//Serial stream setup
Serial   port;
String   buffer = "";

//Variable for camera info
String CameraSettings; 

//Timers
int lastMillis1 = 0;
int lastMillis2 = 0;
int lastMillis3 = 0;
int lastMillis4 = 0;



void setup()
{
  size(1280, 720, P3D);
  frameRate(60);
  font = loadFont("ISL_Andvari-Regular-20.vlw"); 
  textFont(font); 
  smooth(); 
  // ToDo: Check for errors, this will fail with no serial device present
  print("Serial ports available: ");
  println(Serial.list()); 
  String ttyPort = Serial.list()[ComSelection];
  port = new Serial(this, ttyPort, 115200);
  port.bufferUntil('\n');

  //Check for cameras
  String[] cameras = Capture.list();

  VFU = loadImage("Video_Feed_Unavailable.png");
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    NoCam = 1;
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[CameraSelection]);
    println("Using camera settings: ", cameras[CameraSelection]);
    CameraSettings = cameras[CameraSelection];  
    cam.start();
  }

  //Load HUD image files:
  HUDOutline = loadImage("HUD-G-BluePNG.png"); 
  HUDHorizon = loadImage("HUDHorizon_Blue.png");
  HUDCrosshair = loadImage("HUDCrosshair_Blue.png"); 
  //AttackLit = loadImage("AttackLit.png"); 
  RepRPower = 0;
}


void draw()
{
  if (NoCam == 0){
      CamFeed();
  }
  else{
    image(VFU,0, 0, 1280, 720);
    HUDInfo();  
  }
}


void CamFeed()
{
  if (cam.available() == true) {
    cam.read(); 
    background(0, 0, 0);
    image(cam, 0, 0, 1280, 720);
    HUDInfo(); 
  }
}


void HUDInfo()
{
  //HUD Outline
  image(HUDOutline,0, 0, 1280, 720);
    
  //Value inversion for hemlet POV
  float rollInv = 0 - roll; 
  float yawInv = 0 - yaw; 
  float pitchInv = 0 - pitch; 

  //Implement smoothing averagers 

  //Get string values for debug
  String rollStr = roll+"";
  String pitchStr = pitch+"";
  String yawStr = yaw+""; 
  String tempStr = temp+"";
  String altStr = alt+"";

  //2D Horizon:
  pushMatrix(); 
  translate(640, 360); 
  imageMode(CENTER); 
  image(HUDCrosshair, 0, 0); 
  rotate(radians(pitch)); 
  image(HUDHorizon, 0, (rollInv*4-200));
  imageMode(CORNER); 
  popMatrix(); 

  //Display debug values
  noFill(); 
  pushMatrix(); 
  translate(120, 520, 60);   
  rotateX(radians(5)); //Flip towards the viewer, 70, 30, -20 worked well
  rotateY(radians(0)); 
  rotateZ(radians(7)); //Flare out or in 
  textSize(11); 
  textAlign(LEFT);
  stroke(0, 174, 231);
  //fill(0,174,231, 30);  
  rect(-7, 10, 100, 113); //Border rectangle
  stroke(0, 174, 231); 
  fill(255); 
  text("Roll: " + rollStr, 0, 30);
  text("Pitch: " + pitchStr, 0, 50); 
  text("Hdg: " + yawStr, 0, 70); 
  text("Tmp: " + tempStr + " C", 0, 90);
  text("Alt: " + altStr, 0, 110); 
  noFill(); 
  popMatrix(); 

  //Top Helmet Heading
  noFill(); 
  pushMatrix(); 
  translate(640, 20, 60);   
  rotateX(radians(-10)); 
  textSize(13); 
  textAlign(LEFT);
  text("HDG: " + yawStr, -10, 30); 
  //Magnetometer to compass bearing
  if (yaw<22.5 && yaw>-22.5) {
    fill(255, 0, 0); 
    text("N", -60, 30);
    fill(255);
  } else if (yaw>=22.5 && yaw<67.5) {
    text("NE", -60, 30);
  } else if (yaw>=67.5 && yaw<112.5) {
    text("E", -60, 30);
  } else if (yaw>=112.5 && yaw<157.5) {
    text("SE", -60, 30);
  } else if (yaw>=157.5 && yaw<=180) {
    text("S", -60, 30);
  } else if (yaw>=-180 && yaw<-157.5) {
    text("S", -60, 30);
  } else if (yaw>=-157.5 && yaw<-112.5) {
    text("SW", -60, 30);
  } else if (yaw>=-112.5 && yaw<-67.5) {
    text("W", -60, 30);
  } else if (yaw>=-67.5 && yaw<-22.5) {
    text("NW", -60, 30);
  }
  noFill();    
  popMatrix(); 

  //Upper Right Info Panel - Time/Date/Uptime
  pushMatrix(); 
  translate(1070, 30, 60);   
  rotateX(radians(-5)); //Flip towards the viewer, 70, 30, -20 worked well
  rotateY(radians(-10)); 
  rotateZ(radians(14)); //Flare out or in 
  textAlign(LEFT);
  textSize(9); 
  text("Uptime: "+millis()+"ms", 0, 25);  
  textSize(17);  
  text(hour()+":"+minute()+":"+second(), 0, 45); 
  popMatrix(); 

  //Left Info Panel
  pushMatrix(); 
  translate(240, 560, 60); 
  rotateX(radians(30)); //Flip towards the viewer, 70, 30, -20 worked well
  rotateY(radians(10)); 
  rotateZ(radians(4.3)); //Flare out or in
  rect(0, 0, 375, 75); //Border rectangle
  textSize(10); 
  text("HTMP: " + temp, 10, 14); 
  text("BTMP: N/A", 10, 24); //Add data
  text("EXTMP: N/A", 10, 34); //Add data  

  text("REP-R: " + RepRPower, 10, 55); //Add data
  //Repulsor Warm-Up Animation (Test)
  int delay1 = 20; 
  if (lastMillis1==0 || millis() > (lastMillis1+delay1))
  {
    if (RepRPower <100) {
      RepRPower++; 
      lastMillis1= millis();
    } else {
      //RepRPower = 0; //Loop animation
      lastMillis1 = millis();
    }
  }    

  RepRMap = map(RepRPower, 0, 100, 90, 300); 
  if (RepRPower>30 && RepRPower<65) {
    stroke(255, 255, 0);
  } else if (RepRPower<30) {
    stroke(255, 0, 0);
  } else {
    stroke(0, 174, 231);
  }
  line(90, 55, RepRMap, 55); //Initial line
  line(RepRMap, 55, RepRMap, 47); //Raised edge
  stroke(0, 174, 231);//Reset stroke

  text("REP-L: " + RepLPower, 10, 65); //Add data
  int delay2 = 40; 
  if (lastMillis2==0 || millis() > (lastMillis2+delay2))
  {
    if (RepLPower <100) {
      RepLPower++; 
      lastMillis2= millis();
    } else {
      //RepLPower = 0; //Loop animation
      lastMillis2 = millis();
    }
  } 

  RepLMap = map(RepLPower, 0, 100, 90, 300); 
  if (RepLPower>30 && RepLPower<65) {
    stroke(255, 255, 0);
  } else if (RepLPower<30) {
    stroke(255, 0, 0);
  } else {
    stroke(0, 174, 231);
  }
  line(90, 65, RepLMap, 65); 
  line(RepLMap, 65, RepLMap, 57);
  stroke(0, 174, 231);//Reset stroke 
  popMatrix(); 

  //Right info panel
  pushMatrix(); 
  translate(1040, 560, 60);
  rotateX(radians(30+180)); //Flip towards the viewer, 70, 30, -20 worked well
  rotateY(radians(10+180)); 
  rotateZ(radians(-4.3+180)); //Flare out or in 
  stroke(0, 174, 231);
  rect(0, 0, -375, 75); //Border rectangle
  stroke(255); 
  text("CAM: "+CameraSettings, -370, 14 ); 

  //Data gathering communications
  text("COMM AUX1:", -370, 24); 
  fill(0, 255, 0); 
  text("[ OK ]", -280, 24); 
  fill(255);

  text("COMM AUX2:", -370, 34); 
  fill(255, 0, 0); 
  text("[ ERR ]", -280, 34);
  fill(255);

  text("SRV CONT:", -370, 44); 
  fill(255, 0, 0); 
  text("[ ERR ]", -280, 44); 
  fill(255); 

  noFill();  
  popMatrix(); 

  //Far right display panel
  pushMatrix(); 
  translate(1160, 520, 60); 
  rotateX(radians(185)); //Flip towards the viewer, 70, 30, -20 worked well
  rotateY(radians(0)); 
  rotateZ(radians(187)); //Flare out or in 
  textSize(13); 
  textAlign(LEFT); 
  stroke(0, 174, 231);
  rect(-7, 10, 100, 113); //Border rectangle
  stroke(255); 
  popMatrix(); 

  /* 3D Horizon (no longer used, but may come in handy later)
   // Set a new co-ordinate space
   pushMatrix();
   
   // Turn the lights on
   lights();
   
   // Displace objects from 0,0
   translate(640, 360, 30);
   
   // Rotate shapes around the X/Y/Z axis (values in radians, 0..Pi*2)
   rotateX(radians(roll));
   rotateZ(radians(pitch));
   //rotateY(radians((yaw + 270)/2));
   
   pushMatrix();
   noStroke();
   model.draw();
   
   //Horizon Lock
   translate(0, 0, 0);
   if (roll < 8 & roll > -8 & pitch < 8 & pitch > -8){
   fill(200,0,0); 
   textAlign(CENTER); 
   textSize(36); 
   text("HORIZON LOCK", 0, 0); 
   }   
   popMatrix();
   popMatrix();
   */
}


void serialEvent(Serial p) 
{
  String incoming = p.readString();
  if ((incoming.length() > 8))
  {
    String[] list = split(incoming, " ");
    if ( (list.length > 0) && (list[0].equals("Orientation:")) ) 
    {
      roll  = float(list[1]);
      pitch = float(list[2]);
      yaw   = float(list[3]);
      buffer = incoming;
    }
    if ( (list.length > 0) && (list[0].equals("Alt:")) ) 
    {
      alt  = float(list[1]);
      buffer = incoming;
    }
    if ( (list.length > 0) && (list[0].equals("Temp:")) ) 
    {
      temp  = float(list[1]);
      buffer = incoming;
    }
  }
}

