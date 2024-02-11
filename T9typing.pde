import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import java.util.*;

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

HashMap<String, Queue<String>> T9dictionary = new LinkedHashMap<String, Queue<String>>();
String sequence = "";
String response = "";
String old_sequence = "";
int count = 0;
// MAY NEED TO TWEAK THESE

final int displayTextChars = 17;
final int entryHeight = 50;
final int subButtonHeight = 100;
final int buttonSpacing = 6;
final int buttonWidth = (int)sizeOfInputArea / 3;
final int buttonHeight = ((int)sizeOfInputArea - entryHeight) / 3+3;
final int deleteWidth = 45;


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
  T9keypad = loadImage("T9_Layout_Autocomplete.png");
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
  makeDictionary();
  String[] testQueries = {"78433"};
  int[] cycleCounts = {0, 1, 2, 3, 4, 5};
  
  // Run tests
  for (String query : testQueries) {
    for (int count : cycleCounts) {
      String result = cycleWord(query, count);
      println("Query: " + query + ", Count: " + count + ", Result: " + result);
    }
    println("-----"); // Separator for readability
  }
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
        //if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/3)
        //{
        //  //System.out.println("1");
        //  drawSubKeypad(group.charAt(0) + ".png");
        //}
        //else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/3)*2)
        //{
        //  //System.out.println("2");
        //  drawSubKeypad(group.charAt(1) + ".png");
        //}
        //else
        //{
        //  //System.out.println("3");
        //  drawSubKeypad(group.charAt(2) + ".png");
        //}
      } 
      else if (group.length() == 4)
      {
        //if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/4)
        //{
        //  //System.out.println("1");
        //  drawSubKeypad(group.charAt(0) + ".png");
        //}
        //else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*2)
        //{
        //  //System.out.println("2");
        //  drawSubKeypad(group.charAt(1) + ".png");
        //}
        //else if (mouseX <= (width/2-sizeOfInputArea/2) + (sizeOfInputArea/4)*3)
        //{
        //  //System.out.println("3");
        //  drawSubKeypad(group.charAt(2) + ".png");
        //}
        //else
        //{
        //  //System.out.println("4");
        //  drawSubKeypad(group.charAt(3) + ".png");
        //}
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
      //drawSubKeypad(sections[buttonState - 1] + ".png");
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
    
    //rect(width/2-sizeOfInputArea/2 - buttonSpacing, height/2-sizeOfInputArea/2 - 4, sizeOfInputArea - 45, entryHeight);
    
    
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
      text(currentTyped.substring(currentTyped.length()-displayTextChars) + "|", width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/4); //draw last characters
    }
    
    textFont(font, (6 * DPIofYourDeviceScreen) / 144);
    text(sequence, width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2 + entryHeight/2 + 5, sizeOfInputArea, sizeOfInputArea/4);
    
    textFont(font, (6 * DPIofYourDeviceScreen) / 72);
    textAlign(CENTER);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
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
   if (!sequence.equals("")){
      System.out.println("submit");
      sequence = "";
      response = ""; 
      currentTyped += " ";
    }else{
      currentTyped += " ";
    }
   //buttonState = 1;
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
  if (didMouseClick(width/2-sizeOfInputArea/2 - buttonSpacing, height/2-sizeOfInputArea/2 - 4, sizeOfInputArea - deleteWidth, entryHeight)) {
    //click on textbox, cycle through
    if (!sequence.equals("")) {
      count++;
      response = cycleWord(sequence, count); // Cycle the word based on 'sequence'
      System.out.println(str(count)+ " th possible: " + response);
      int lastSpaceIndex = currentTyped.lastIndexOf(" ");
      if (lastSpaceIndex != -1) {
        currentTyped = currentTyped.substring(0, lastSpaceIndex) + " " + response; // Replace the last word
    } else {
      currentTyped = response; // If no previous words, just set 'currentTyped' to the response
    }
    }
  }
  
  if (didMouseClick(width/2-sizeOfInputArea/2 - buttonSpacing + (sizeOfInputArea - deleteWidth), height/2-sizeOfInputArea/2 - 4, deleteWidth, entryHeight))
  {
    System.out.println("delete");
    int lastSpaceIndex = currentTyped.lastIndexOf(" ");
    if (!sequence.equals("")){//entering sequence
       sequence = sequence.substring(0, sequence.length() - 1);
       response = cycleWord(sequence, count);
          if (lastSpaceIndex != -1) {
            currentTyped = currentTyped.substring(0, lastSpaceIndex) + " " + response; // Replace the last word
        } else {
          currentTyped = response; // If no previous words, just set 'currentTyped' to the response
        }
    }else if (currentTyped.length() > 0) {//no sequence enterance, delete whole last word
      if (lastSpaceIndex != -1) {
    // If there's a space, remove everything after the last space
    currentTyped = currentTyped.substring(0, lastSpaceIndex);
} else {
    // If there's no space, clear 'currentTyped' as it contains only one word
    currentTyped = "";
}
    }
  }
  
  if (buttonState >= 2 && buttonState <= 9) {
    sequence += str(buttonState); // Convert buttonState to string and append to sequence. button 1 is not used for inputting letters.
    response = cycleWord(sequence, count);
    int lastSpaceIndex = currentTyped.lastIndexOf(" ");
      if (lastSpaceIndex != -1) {
        currentTyped = currentTyped.substring(0, lastSpaceIndex) + " " + response; // Replace the last word
    } else {
      currentTyped = response; // If no previous words, just set 'currentTyped' to the response
    }
  }
  System.out.println("Current sequence: " + sequence);
  

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(width-200, height-200, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased() {
  /*if (buttonState == 1){
    if (mouseX >= (width/2 - sizeOfInputArea/2) && mouseX <= (width/2 + sizeOfInputArea/2) && mouseY >= (height/2 - subButtonHeight/2) && mouseY <= (height/2 + subButtonHeight/2))
    {
      //System.out.println("A KEY HAS BEEN PRESSED!");
      //Submit
      if (mouseX <= (width/2-sizeOfInputArea/2) + sizeOfInputArea/2)
        {
          if (!sequence.equals("")){
            System.out.println("submit");
            sequence = "";
            response = ""; 
            currentTyped += " ";
          }else{
            currentTyped += " ";
          }
        }
        else
        {//deletion of currenttyped or deletion of sequence
        //Delete
          System.out.println("delete");
          if (!sequence.equals("")){
             sequence = sequence.substring(0, sequence.length() - 1);
             response = cycleWord(sequence, count);
              int lastSpaceIndex = currentTyped.lastIndexOf(" ");
                if (lastSpaceIndex != -1) {
                  currentTyped = currentTyped.substring(0, lastSpaceIndex) + " " + response; // Replace the last word
              } else {
                currentTyped = response; // If no previous words, just set 'currentTyped' to the response
              }
          }else if (currentTyped.length() > 0) {
             currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
          }
      } 
    } 
}*/
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
  
  sequence = "";
  response = ""; 
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

//void makeDictionary() {
//  String[] lines = loadStrings("dictionary.txt");
//  for (String line : lines) {
//    StringTokenizer st = new StringTokenizer(line);
//    while (st.hasMoreTokens()) {
//      String word = st.nextToken();
//      String sequence = generateSeq(word.toLowerCase());
//      insert(sequence, word.toLowerCase());
//    }
//  }
//}
String getResponse(String query) {
  Queue<String> wordQueue = getWordQueue(query);
  if (wordQueue != null && !wordQueue.isEmpty()) {
    return wordQueue.peek().substring(0, Math.min(query.length(), wordQueue.peek().length()));
  } else {
    return ""; // Return an empty string if no words are found
  }
}

String getResponseFull(String query) {
  Queue<String> wordQueue = getWordQueue(query);
  if (wordQueue != null && !wordQueue.isEmpty()) {
    return wordQueue.toString();
  } else {
    return "[]"; // Return an empty queue representation if no words are found
  }
}

Queue<String> getWordQueue(String query) {
  if (T9dictionary.containsKey(query)) {
    return T9dictionary.get(query);
  } else {
    //creat a new queue
    Queue<String> wordQueue = new PriorityQueue<String>();
    for (String eachKey : T9dictionary.keySet()) {
      if (eachKey.startsWith(query)) {
        println("in loop: " + eachKey);
        wordQueue.addAll(T9dictionary.get(eachKey));
        // return T9dictionary.get(eachKey);
      }
    }
    return wordQueue;
  }
  //return new LinkedList<String>(); // Return an empty queue if no matching sequence is found
}

String cycleWord(String query, int count) {
  String allOptions = getResponseFull(query);
  allOptions = allOptions.substring(1, allOptions.length() - 1); // Remove brackets

  String[] options = allOptions.split(",");
  for (int i = 0; i < options.length; i++) {
    options[i] = options[i].trim(); // Remove leading and trailing spaces
  }

  if (options.length == 0 || options[0].isEmpty()) {
    return ""; // Return an empty string if no options are available
  }

  int index = count % options.length;
  return options[index];
}

void makeDictionary() {
  // Specify the path to your dictionary file
  String dictionaryPath = "dictionary.txt"; // Update this path
  String[] lines = loadStrings(dictionaryPath);
  
  println("Starting to make the dictionary...");
  int wordCount = 0; // Keep track of how many words are added
  
  for (String line : lines) {
    String[] words = line.split("\\s+"); // Assuming words are separated by whitespace
    for (String word : words) {
      if (!word.isEmpty()) { // Check to ensure the word is not empty
        String sequence = generateSeq(word.toLowerCase());
        insert(sequence, word.toLowerCase());
        wordCount++;
      }
    }
  }
  
  //println("Dictionary made with " + wordCount + " words.");
  //println("Sample content from the dictionary:");
  
  //// Print a sample from the dictionary to verify its contents
  //int sampleCount = 0;
  //for (Map.Entry<String, Queue<String>> entry : T9dictionary.entrySet()) {
  //  println("Key (Digit Sequence): " + entry.getKey() + " - Words: " + entry.getValue());
  //  sampleCount++;
  //  if (sampleCount == 10) break; // Limit the sample output to 5 entries
  //}
}


void insert(String sequence, String word) {
  if (T9dictionary.containsKey(sequence)) {
    Queue<String> wordQueue = T9dictionary.get(sequence);
    if (wordQueue.contains(word)) {
      String toUpdate = removeWord(wordQueue, word);
      wordQueue.add(toUpdate);
    } else {
      String ne = word;
      wordQueue.add(ne);
    }
  } else {
    Queue<String> wordQueue = new PriorityQueue<String>(new Comparator<String>() {
  @Override
  public int compare(String o1, String o2) {
    return o1.compareTo(o2);
  }
});
    wordQueue.add(word);
    T9dictionary.put(sequence, wordQueue);
  }
}

String removeWord(Queue<String> wordQueue, String word) {
  // Iterate through the Queue to find and remove the specified word
  Iterator<String> iterator = wordQueue.iterator();
  while (iterator.hasNext()) {
    String eachWordIn = iterator.next();
    if (eachWordIn.equals(word)) {
      iterator.remove(); // Use Iterator's remove method to avoid ConcurrentModificationException
      return eachWordIn;
    }
  }
  return null; // Return null if the word was not found
}

String generateSeq(String word) {
  String sequence = "";
  for (int i = 0; i < word.length(); i++) {
    sequence += getDigit(word.charAt(i));
  }
  return sequence;
}

char getDigit(char alphabet) {
  if (alphabet >= '0' && alphabet <= '9') {
    return alphabet;
  }
  switch (alphabet) {
    case 'a': case 'b': case 'c': return '2';
    case 'd': case 'e': case 'f': return '3';
    case 'g': case 'h': case 'i': return '4';
    case 'j': case 'k': case 'l': return '5';
    case 'm': case 'n': case 'o': case 'p' : return '6';
    case 'q': case 'r': case 's': return '7';
    case 't': case 'u': case 'v': return '8';
    case 'w': case 'x': case 'y': case 'z': return '9';
    default: return '1';  // Assuming '1' is used for characters that do not map to any digit
  }
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
