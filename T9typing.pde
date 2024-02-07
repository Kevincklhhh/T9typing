import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 295; //500 for debugging 295 for LG K31 you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

// MAY NEED TO TWEAK THESE

final int displayTextChars = 20;
final int entryHeight = 50;
final int subButtonHeight = 100;
final int buttonSpacing = 6;
final int buttonWidth = (int)sizeOfInputArea / 3;
final int buttonHeight = ((int)sizeOfInputArea - entryHeight) / 3+3;


String[] sections = {"space-delete", "abc", "def", "ghi", "jkl", "mnop", "qrs", "tuv", "wxyz"};

int buttonState = 0;

PImage watch;
PImage T9keypad;
PImage finger;

PImage subKeypad;

PFont font;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  //noCursor();
  T9keypad = loadImage("T9_Layout.png");
  watch = loadImage("watchhand3smaller.png");
  //finger = loadImage("pngeggSmaller.png"); //not using this
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

  orientation(PORTRAIT); //can also be PORTRAIT - sets orientation on android device
  size(1520, 720); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  //fullScreen(); //Alternatively, set the size to fullscreen.
  int displayDensity = 1;
  font = createFont("NotoSans-Regular.ttf", 14 * displayDensity);
  textFont(font); //set the font to Noto Sans 14 pt. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  //System.out.println(mouseX + " " + mouseY);
  background(255); //clear background

  //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!", 400, 200); //output
    text("Total time taken: " + (finishTime - startTime)/1000 + "s", 400, 230); //output
    text("Total letters entered: " + lettersEnteredTotal, 400, 260); //output
    text("Total letters expected: " + lettersExpectedTotal, 400, 290); //output
    text("Total errors entered: " + errorsTotal, 400, 320); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm, 400, 350); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors, 1, 3), 400, 380); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty, 400, 410);
    text("WPM w/ penalty: " + (wpm-penalty), 400, 440); //yes, minus, because higher WPM is better
    return;
  }

  drawWatch(); //draw watch background
  drawKeypad();
  if (buttonState != 0)
  {
    if (mouseX >= (width/2 - sizeOfInputArea/2) && mouseX <= (width/2 + sizeOfInputArea/2) && mouseY >= (height/2 - subButtonHeight/2) && mouseY <= (height/2 + subButtonHeight/2))
    {
      String group = sections[buttonState - 1];
      if (group.length() == 3) 
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/3)
        {
          //System.out.println("1");
          drawSubKeypad(group.charAt(0) + ".png");
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/3)*2)
        {
          //System.out.println("2");
          drawSubKeypad(group.charAt(1) + ".png");
        }
        else
        {
          //System.out.println("3");
          drawSubKeypad(group.charAt(2) + ".png");
        }
      } 
      else if (group.length() == 4)
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/4)
        {
          //System.out.println("1");
          drawSubKeypad(group.charAt(0) + ".png");
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*2)
        {
          //System.out.println("2");
          drawSubKeypad(group.charAt(1) + ".png");
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*3)
        {
          //System.out.println("3");
          drawSubKeypad(group.charAt(2) + ".png");
        }
        else
        {
          //System.out.println("4");
          drawSubKeypad(group.charAt(3) + ".png");
        }
      }
      else
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/2)
        {
          //System.out.println("1");
          drawSubKeypad("space.png");
        }
        else
        {
          //System.out.println("2");
          drawSubKeypad("delete.png");
        }
        
      }
    }
    else
    {
      drawSubKeypad(sections[buttonState - 1] + ".png");
    }
    
    
  }
  
  //fill(100);
  // Note: width and height are variables defined by the Processing library. For
  // more information, please refer to Processing's reference.
  //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"


  //Note: mousePressed here is a variable defined by the Processing library. For
  //more information, please refer to Processing's reference.
  if (startTime==0 && !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 && mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string

    //draw very basic next button
    fill(255, 0, 0);
    rect(width-200, height-200, 200, 200); //draw next button
    
    //Debugging button areas
    /*rect(width/2-sizeOfInputArea/2-buttonSpacing, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2+buttonSpacing + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    
    
    rect(width/2-sizeOfInputArea/2-buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2+buttonSpacing + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    
    rect(width/2-sizeOfInputArea/2-buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2+buttonSpacing + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight);  */
    
    
    /*rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight);
    
    
    rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight);
    
    rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight);
    rect(width/2-sizeOfInputArea/2 + buttonWidth*2, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight); */
    
    
    fill(255);
    text("NEXT > ", width-150, height-150); //draw next label

    //example design draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    //The entered text should be put inside the 1"x1" square. You can specify a
    //smaller text size here. 1pt is 1/72 inch, so the following formula
    //converts point size to pixel size.
    fill(0);
    textFont(font, (6 * DPIofYourDeviceScreen) / 72);
    
    
    
    if (currentTyped.length() <= displayTextChars)
    {
      text(currentTyped +"|", width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/4); //draw what the user has entered thus far 
    }
    else
    {
      text(currentTyped.substring(currentTyped.length()-20) + "|", width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/4); //draw last 20 characters
    }
    
    textAlign(CENTER);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
    textFont(font); //Reset font size
  }


  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
//Note: void mousePressed() is a callback function defined by the Processing
//library, and it is *different from* the mousePressed variable occurred in the
//draw() function.
void mousePressed()
{
  /*if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  {
    currentLetter --;
    if (currentLetter<'_') //wrap around to z
      currentLetter = 'z';
  }

  if (didMouseClick(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  {
    currentLetter ++;
    if (currentLetter>'z') //wrap back to space (aka underscore)
      currentLetter = '_';
  }

  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  {
    if (currentLetter=='_') //if underscore, consider that a space bar
      currentTyped+=" ";
    else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
      currentTyped+=currentLetter;
  } */
  
  
  
  if (didMouseClick(width/2-sizeOfInputArea/2 - buttonSpacing, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 1!"); 
   
   buttonState = 1;
  }
  if (didMouseClick(width/2-sizeOfInputArea/2 + buttonWidth, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 2!"); 
   buttonState = 2;
  }
  if (didMouseClick(width/2-sizeOfInputArea/2 + buttonWidth*2 + buttonSpacing, height/2-sizeOfInputArea/2+entryHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 3!"); 
   buttonState = 3; 
  }
  
  if (didMouseClick(width/2-sizeOfInputArea/2 - buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 4!"); 
   buttonState = 4; 
  }
  
  if (didMouseClick(width/2-sizeOfInputArea/2+buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 5!"); 
   buttonState = 5; 
  }
  if (didMouseClick(width/2-sizeOfInputArea/2+buttonWidth*2 + buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 6!"); 
   buttonState = 6; 
  }
  
  if (didMouseClick(width/2-sizeOfInputArea/2 - buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 7!"); 
   buttonState = 7; 
  }
  
  if (didMouseClick(width/2-sizeOfInputArea/2+buttonWidth, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 8!"); 
   buttonState = 8;
  }
  if (didMouseClick(width/2-sizeOfInputArea/2+buttonWidth*2 + buttonSpacing, height/2-sizeOfInputArea/2+entryHeight+buttonHeight*2, buttonWidth, buttonHeight))
  {
   //System.out.println(mouseX + " " + mouseY);
   //System.out.println("CLICKED 9!"); 
   buttonState = 9; 
  } 
  
  

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(width-200, height-200, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased() {
  if (buttonState != 0)
  {
    String group = sections[buttonState - 1];
    
    if (mouseX >= (width/2 - sizeOfInputArea/2) && mouseX <= (width/2 + sizeOfInputArea/2) && mouseY >= (height/2 - subButtonHeight/2) && mouseY <= (height/2 + subButtonHeight/2))
    {
      //System.out.println("A KEY HAS BEEN PRESSED!");
      if (group.length() == 3) 
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/3)
        {
          //System.out.println("1");
          currentTyped += group.charAt(0);
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/3)*2)
        {
          //System.out.println("2");
          currentTyped += group.charAt(1);
        }
        else
        {
          //System.out.println("3");
          currentTyped += group.charAt(2);
        }
      } 
      else if (group.length() == 4)
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/4)
        {
          //System.out.println("1");
          currentTyped += group.charAt(0);
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*2)
        {
          //System.out.println("2");
          currentTyped += group.charAt(1);
        }
        else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*3)
        {
          //System.out.println("3");
          currentTyped += group.charAt(2);
        }
        else
        {
          //System.out.println("4");
          currentTyped += group.charAt(3);
        }
      }
      else
      {
        if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/2)
        {
          //System.out.println("1");
          currentTyped += " ";
        }
        else
        {
          //System.out.println("2");
          StringBuilder sb = new StringBuilder(currentTyped);
          sb.deleteCharAt(currentTyped.length() - 1);
          currentTyped = sb.toString();
        }
        
      }
    }
    
    
    
  }
  
  
  
  
  
  
  buttonState = 0;
  
  
  
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)/1000 + "s"); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

void drawKeypad()
{
  float keypadScale = DPIofYourDeviceScreen/276.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(keypadScale);
  imageMode(CENTER); // Use corner mode for easier positioning
  image(T9keypad, 0,0, sizeOfInputArea, sizeOfInputArea);
  popMatrix();
}

void drawSubKeypad(String imgName)
{
  
  float subKeypadScale = DPIofYourDeviceScreen / 276.0;
  subKeypad = loadImage(imgName);
  pushMatrix();
  translate(width/2, height/2);
  scale(subKeypadScale);
  imageMode(CENTER);
  image(subKeypad, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger, 52, 341);
  if (mousePressed)
    fill(0);
  else
    fill(255);
  ellipse(0, 0, 5, 5);

  popMatrix();
}


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
