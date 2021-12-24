boolean forceMovieMode = false;

// Global vars used to access video frames from either a live camera or a prerecorded movie file
import processing.video.*;
//Random imported to use Match.random()
import java.util.Random;
String[] cameraModes;
Capture cameraDevice;
Movie inputMovie;

boolean initialized = false;
boolean debugging = false;


// Both modes of input (live camera and movie) will update this same variable with the lastest
// pixel data each frame.  Use this variable to access the new pixel data each frame!
PImage inputImage;
//For mirroring the image
PImage flippedImage;

//The words that will be used for our text rain
String inputString = "According to all known laws of aviation there is no way a bee should be able to fly";

//width of the display
int width = 1280;
//height of the display
int height = 720;
//what we are setting the threshold to
int threshold = 128;

//new TextRain class array
TextRain[] words = new TextRain[inputString.length()];
//new character array 
char[] letters = new char[inputString.length()];

void setup() {
  size(1280, 720);  
  PFont font = loadFont("TimesNewRomanPSMT-25.vlw");
  textFont(font, 24);
  int x = 0;
  
  for(int i = 0; i<inputString.length(); i++){
    //filling out character array
    letters[i] = inputString.charAt(i);
    //creating a temp of our class to extract the letters
    TextRain temp = new TextRain(letters[i]);
    
    //filling out TextRain array with the words in our sentence
    words[i] = temp;
    temp.x = x;
    x = x + 1280/inputString.length();
    //resetting our x value
    if(x >= width-(1280/inputString.length())){
      x=0;
    }
  }
  inputImage = createImage(width, height, RGB);
  
  if (!forceMovieMode) {
    println("Querying avaialble camera modes.");
    cameraModes = Capture.list();
    println("Found " + cameraModes.length + " camera modes.");
    for (int i=0; i<cameraModes.length; i++) {
      println(" " + i + ". " + cameraModes[i]); 
    }
    // if no cameras were detected, then run in offline mode
    if (cameraModes.length == 0) {
      println("Starting movie mode automatically since no cameras were detected.");
      initializeMovieMode(); 
    }
    else {
      println("Press a number key in the Processing window to select the desired camera mode.");
    }
  }
}

//Created a new class called TextRain, which will be used for the words that drop and how it will interact with the video for its intended purposes
class TextRain{
  int x;
  int y;
  char letter;
  
  TextRain(char letter){
    this.x = (int) random(1281);
    this.y = 0;
    this.letter = letter;
  }
  //fall the loop
  void start(){
    fill(204, 102, 0, 255);
    text(letter, x, y);
    falling();
  }
  //When it comes across a pixel that is greater than the threshold, it will start bouncing upwards
  void bouncing() {
    //if it's still on the screen
    if (y >= 5){
      y = y - 5;
    }
    //if it's off the screen it will loop 
    else{
      y=0;
    }
  } 
  //For when the letters are falling down
  void falling(){
      color pixel = flippedImage.get(x,y);
      //if it hits a pixel that is less than the threshold, it will react with it and start bouncing
      if (brightness(pixel)<threshold){
        bouncing();
      }
      //if it's greater than threshold, it means the background is "white", so it will continue moving downwards 5 pixels
      else{
        y+=5;
      }
      //If it reaches the end of the screen, it will continue looping
      if (y ==720){
        y = 0;
      }
  }  
}

// Called automatically by Processing, once per frame
void draw() {
  // start each frame by clearing the screen
  background(0);
    
  if (!initialized) {
    // IF NOT INITIALIZED, DRAW THE INPUT SELECTION MENU
    drawMenuScreen();      
  }
  else {
    // IF WE REACH THIS POINT, WE'RE PAST THE MENU AND THE INPUT MODE HAS BEEN INITIALIZED


    // GET THE NEXT FRAME OF INPUT DATA FROM LIVE CAMERA OR MOVIE  
    if ((cameraDevice != null) && (cameraDevice.available())) {
      // Get image data from cameara and copy it over to the inputImage variable
      cameraDevice.read();
      inputImage.copy(cameraDevice, 0,0,cameraDevice.width,cameraDevice.height, 0,0,inputImage.width,inputImage.height);
    }
    else if ((inputMovie != null) && (inputMovie.available())) {
      // Get image data from the movie file and copy it over to the inputImage variable
      inputMovie.read();
      inputImage.copy(inputMovie, 0,0,inputMovie.width,inputMovie.height, 0,0,inputImage.width,inputImage.height);
    }


    // DRAW THE INPUTIMAGE ACROSS THE ENTIRE SCREEN
    // Note, this is like clearing the screen with an image.  It will cover up anything drawn before this point.
    // So, draw your text rain after this!
    set(0, 0, inputImage);


    // DRAW THE TEXT RAIN, ETC.
    // TODO: Much of your implementation code should go here.  At this point, the latest pixel data from the
    // live camera or movie file will have been copied over to the inputImage variable.  So, if you access
    // the pixel data from the inputImage variable, your code should always work, no matter which mode you run in.
    
    //Initialize global variable
    flippedImage = createImage(1280,720,RGB);
    inputImage.loadPixels();
    
    //Mirror the image
    for(int i = 0; i<1280; i++){
      for(int j = 0; j<720;j++){  
        flippedImage.set(inputImage.width-i-1,j,inputImage.get(i,j));
      }
    }
    flippedImage.updatePixels();
    
    //When debugging, it will create a black and white copy of flippedImage
    PImage debuggingImage = flippedImage.copy();
    debuggingImage.filter(THRESHOLD);
    //Debugging will be called from whether space bar pressed or not
    if(debugging){
      set(0,0, debuggingImage);
    }
    else{
      set(0,0,flippedImage);
    }
    //Will start the textrain
    for(int i = 0; i <inputString.length(); i++){
      words[i].start();
    }  
  }
}


// Called automatically by Processing once per frame
void keyPressed() {
  if (!initialized) {
    // CHECK FOR A NUMBER KEY PRESS ON THE MENU SCREEN    
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        initializeMovieMode();
      }
      else if ((input >= 1) && (input <= 9)) {
        initializeLiveCameraMode(input);
      }
    }
  }
  else {
    // CHECK FOR KEYPRESSES DURING NORMAL OPERATION
    // TODO: Fill in your code to handle keypresses here..
    if (key == CODED) {
      if (keyCode == UP) {
        // up arrow key pressed
          threshold +=5;      
      }
      else if (keyCode == DOWN) {
        // down arrow key pressed
          threshold -=5;
      }
    }
    else if (key == ' ') {
      // spacebar pressed
      debugging = !debugging;
    } 
  }
}



// Loads a movie from a file to simulate camera input.
void initializeMovieMode() {
  String movieFile = "TextRainInput.mov";
  println("Simulating camera input using movie file: " + movieFile);
  inputMovie = new Movie(this, movieFile);
  inputMovie.loop();
  initialized = true;
}


// Starts up a webcam to use for input.
void initializeLiveCameraMode(int cameraMode) {
  println("Activating camera mode #" + cameraMode + ": " + cameraModes[cameraMode-1]);
  cameraDevice = new Capture(this, cameraModes[cameraMode-1]);
  cameraDevice.start();
  initialized = true;
}


// Draws a quick text-based menu to the screen
void drawMenuScreen() {
  int y=10;
  text("Press a number key to select an input mode", 20, y);
  y += 40;
  text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
  y += 40; 
  for (int i = 0; i < min(9,cameraModes.length); i++) {
    text(i+1 + ": " + cameraModes[i], 20, y);
    y += 40;
  }  
}
