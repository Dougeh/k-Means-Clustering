//Doug Wilklow
//Dr. William Hendrix - University of South Florida
//COT4521 - Computational Geometry
//Spring 2022 (4/8/2022)

//// Final Project - K-Means Clustering
//Allows the user to place data points, randomly select several starting points for centroids, and then
//  press Enter to watch an animation of K-Means clustering on their data points.
    //CONTROLS:
    //Left or Right click - place 1 or 10 data points 
        //(Head down to mouseReleased() to change number of points placed by box)
    //[' and ']' - increase or decrease number of points to place with right-click
        //Makes for a lot of fun testing conditions
    //Arrow Keys - Change 10-point box size
        //This can totally go negative or out of bounds of the window and will still place datapoints in those spaces.
    //1-9 keys - randomly select starting centroids (Reset with 0)
        //Sometimes I like to just fill up the whole window with tons of dots and press 9 over and over to procrastinate :^)
    //Enter - step through animation (Hold to play animation to completion)
        //Removed delay between steps because I couldn't figure out how to get it to draw between recursions
    //R - clear all points
        //Completely resets all lists associated with point storage, miraculously doesn't (seem to) break anything!
        
  //The algorithm I used for k-means is modeled after the algorithm used in a similar program made by Robert Andrew Martin in 2019
  //  (though I really just used it and the in-class Lecture 19 slides as a road map for algorithm steps):
  //  https://reasonabledeviations.com/2019/10/02/k-means-in-cpp/#assigning-points-to-a-cluster
  //Everything else was found on the Processing resources site.

ArrayList<PVector> points = new ArrayList<PVector>();   //List of data points
IntList colors = new IntList();                           //List of each data point's color
IntList numpoints = new IntList(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);      //Number of points belonging to each cluster (including default black for debug purposes)
ArrayList<PVector>centroids = new ArrayList<PVector>(); //List of 1 to 9 centroids
IntList palette = new IntList();                          //List of 1 to 9 colors for these centroids 


//Box size, can be changed with arrow keys
int boxX = 100;
int boxY = 100;
int boxpoints = 10;  //Number of points to be placed within the box when right-clicking
String words = "Left or Right click - place 1 or " + boxpoints + " data points\n'[' and ']' - increase or decrease number of points to place with right-click\nArrow Keys - Change " + boxpoints + "-point box size\n1-9 keys - randomly select starting centroids (Reset with 0)\nEnter - play animation";;

//false = LEFT, true = RIGHT
boolean leftright = false; //This is for detecting mouse clicks, initialize to left (Check out mouseReleased())
boolean running = false;  //Hides "user controls" text in the top-right, doubles as the recursive break flag

void setup()
{
  surface.setTitle("Doug Wilklow - K-Means Clustering");
  size(900, 750);  //Sizing the window
  background(255);
  textAlign(LEFT);
  palette = new IntList();
  palette.append(color(0, 0, 0));
}

void draw()
{ 
  background(255);  //Clears the window each frame
  
  if (mousePressed && (mouseButton == LEFT))
  {
    leftright = false;
    noStroke(); //No outline
    fill(0); //Black fill
    circle(mouseX, mouseY, 4);  //Draws a lil circle for preview purposes
  }
  if (mousePressed && (mouseButton == RIGHT))
  {
    leftright = true;
    stroke(0);  //Black outline
    fill(255);  //White fill (transparent)
    //Draws a bounding box where (n = boxpoints) points will be added randomly inside
    rect(mouseX - (boxX / 2), mouseY - (boxY / 2), boxX, boxY);
  }
  
  //Drawing every point in points
  for (int i = 0; i < points.size() && i < colors.size(); i++)
  {
    noStroke();
    fill(palette.get(colors.get(i)));
    circle(points.get(i).x, points.get(i).y, 6);
  }
  //Drawing centroids
  for (int i = 0; i < centroids.size() && i < palette.size(); i++)
  {
    stroke(0);
    fill(palette.get(i + 1));  //REMEMBER TO DO i+1 ON PALETTE SINCE 0 IS ALWAYS BLACK
    circle(centroids.get(i).x, centroids.get(i).y, 14);
  }
  
  if (running == false)
  {
    text(words, 10, 20);  //Displaying either instructions or the "Convergence reached" success message
  }
}

void keyPressed() 
{
  //Showing instructions
  textSize(14);
  words = "Left or Right click - place 1 or " + boxpoints + " data points\n'[' and ']' - increase or decrease number of points to place with right-click\nArrow Keys - Change " + boxpoints + "-point box size (" + boxX + "x" + boxY + ")\n1-9 keys - randomly select starting centroids (Reset with 0)\nEnter - step through animation (Hold to play animation to completion)\nR - clear all points";
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      boxY += 10;
    }
    else if (keyCode == DOWN) 
    {
      boxY -= 10;
    }
    else if (keyCode == LEFT) 
    {
      boxX -= 10;
    } 
    else if (keyCode == RIGHT) 
    {
      boxX += 10;
    }
  }
  else if (keyCode == ENTER || keyCode == RETURN)
  {
    //println("hi :^)"); //DEBUG
    //running = true;
    kMeans();
  }
  else if (keyCode == 'R')
  {    //Resets everything to be empty
    points = new ArrayList<PVector>();
    colors = new IntList();           
    numpoints = new IntList(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    centroids = new ArrayList<PVector>();
    palette = new IntList(); 
    palette.append(color(0, 0, 0));
  }
  else if (keyCode == '0')
  {
    initCentroids(0);  //Clears the centroids list
    //Resets all datapoints to black, no centroids or clusters
    for (int i = 0; i < points.size() && i < colors.size(); i++)
    {
      colors.set(i, 0);
      circle(points.get(i).x, points.get(i).y, 6);
    }
  }
  //One if statement for each digit
  else if (keyCode == '1')
  {
    initCentroids(1);
  }
  else if (keyCode == '2')
  {
    initCentroids(2);
  }
  else if (keyCode == '3')
  {
    initCentroids(3);
  }
  else if (keyCode == '4')
  {
    initCentroids(4);
  }
  else if (keyCode == '5')
  {
    initCentroids(5);
  }
  else if (keyCode == '6')
  {
    initCentroids(6);
  }
  else if (keyCode == '7')
  {
    initCentroids(7);
  }
  else if (keyCode == '8')
  {
    initCentroids(8);
  }
  else if (keyCode == '9')
  {
    initCentroids(9);
  }
  else if (keyCode == ']')
  {
    boxpoints += 5;
  }
  else if (keyCode == '[')
  {
    if (boxpoints >= 5)
      boxpoints -= 5;
  }
}

void mouseReleased()
{
  //Showing instructions
  textSize(14);
  words = "Left or Right click - place 1 or " + boxpoints + " data points\n'[' and ']' - increase or decrease number of points to place with right-click\nArrow Keys - Change " + boxpoints + "-point box size (" + boxX + "x" + boxY + ")\n1-9 keys - randomly select starting centroids (Reset with 0)\nEnter - step through animation (Hold to play animation to completion)\nR - clear all points";
  
  if (leftright == false)  //When left-clicking
  {
    PVector newpoint = new PVector(mouseX, mouseY);
    points.add(newpoint);  //Adds it to the points list
    colors.append(0);
  }
  else if (leftright == true)  //When right-clicking
  {
    for (int i = 0; i < boxpoints; i++)  //Adding n (n = boxpoints) points randomly within the box
    {
      PVector newpoint = new PVector(random(boxX) + mouseX - boxX/2, random(boxY) + mouseY - boxY/2);
      points.add(newpoint);  //Adds it to the points list
      colors.append(0);
    }
  }
}

//Initializes centroids and finds the nearest centroid of each user-placed datapoint
void initCentroids(int c)
{   
    //The algorithm I used for k-means is modeled after the algorithm used in a similar program made by Robert Andrew Martin in 2019
    //  (though I really just used it and the in-class Lecture 19 slides as a road map for algorithm steps):
    //  https://reasonabledeviations.com/2019/10/02/k-means-in-cpp/#assigning-points-to-a-cluster
    //Everything else was found on the Processing resources site.
    
    palette = new IntList();
    palette.append(color(0, 0, 0));
    for (int i = 1; i < 10; i++)  //Initializing the palette of colors randomly for funsies
    {
      palette.append(color(random(255), random(255), random(255)));  //Makes random colors for each centroid
    }
    centroids = new ArrayList<PVector>();
    for (int i = 0; i < c; i++)
    {
      //Place centroids randomly around image
      PVector newcent = new PVector(random(900), random(750));
      centroids.add(newcent);  //Adds it to the centroids list
    }
    //Assigning each data point to a cluster
    for (int i = 0; i < points.size(); i++)
    {
      float mindist = 900 * 750;  //float 2big4box
      for (int j = 0; j < centroids.size(); j++)
      {
        float d = points.get(i).dist(centroids.get(j));  //Distance between point and centroid
        if (d < mindist)
        {
          mindist = d;
          numpoints.sub(colors.get(i), 1);  //Removing a count of this color from numpoints
          colors.set(i, j + 1);  //Sets the point to the color of the nearest centroid
          numpoints.add(j + 1, 1);    //Adding a count of the new color to numpoints
        }
      }
    }
}

//Runs a step of the k-Means clustering algoritm on the user-provided datapoints.
void kMeans()
{
  //The algorithm I used for k-means is modeled after the algorithm used in a similar program made by Robert Andrew Martin in 2019
  //  (though I really just used it and the in-class Lecture 19 slides as a road map for algorithm steps):
  //  https://reasonabledeviations.com/2019/10/02/k-means-in-cpp/#assigning-points-to-a-cluster
  //Everything else was found on the Processing resources site.
  
  //The idea here is to:
  //1. Make an arraylist of one PVector for each color
  //2. Add the color-matched coords together 
  //3. Divide by number of points of that color, which should give the new average distance
  //4. Detect changes from previous centroid positions, success message shows if no changes
  
  //List of copies centroids to compare later for convergence testing
  ArrayList<PVector>centroidscopy = new ArrayList<PVector>();
  for (int i = 0; i < centroids.size(); i++)
    centroidscopy.add(centroids.get(i));
  
  //1. Make an arraylist of one PVector for each color
  float[] sumX = new float[10];
  float[] sumY = new float[10];
  //for (int i = 0; i < 10; i ++)
  //    temperinos.add(new PVector(0, 0));
  for (int i = 0; i < points.size() && i < colors.size(); i++)
  {
    sumX[colors.get(i)] += points.get(i).x;
    sumY[colors.get(i)] += points.get(i).y;
  }
  
  //3. Divide by number of points of that color, which should give the new average distance 
  for (int i = 0; i < centroids.size(); i++)
  {
    sumX[i+1] = sumX[i+1] / numpoints.get(i+1);
    sumY[i+1] = sumY[i+1] / numpoints.get(i+1);
    if (sumX[i+1] > 0 && sumY[i+1] > 0)
      centroids.set(i, new PVector(sumX[i+1], sumY[i+1]));
  }
  //print("HI"); //DEBUG
  
  //delay(300);  //Pausing a half-second between steps
      //Assigning each data point to a cluster
  for (int i = 0; i < points.size(); i++)
  {
    float mindist = 900 * 750;  //float 2big4box
    for (int j = 0; j < centroids.size(); j++)
    {
      float d = points.get(i).dist(centroids.get(j));  //Distance between point and centroid
      if (d < mindist)
      {
        mindist = d;
        numpoints.sub(colors.get(i), 1);  //Removing a count of this color from numpoints
        colors.set(i, j + 1);  //Sets the point to the color of the nearest centroid
        numpoints.add(j + 1, 1);    //Adding a count of the new color to numpoints
      }
    }
  }
  
  //Detecting changes by comparing the centroid list's positons before and after this iteration
  running = false;
  for (int i = 0; i < centroids.size(); i++)
  {
    //print("\n" + centroids.get(i).x + " " + centroidscopy.get(i).x);  //  DEBUG
    if ((int)centroids.get(i).x != (int)centroidscopy.get(i).x && (int)centroids.get(i).y != (int)centroidscopy.get(i).y)
      running = true;
  }
  if (running == false)   //If nothing's changed since the last run and it's done
  {
    //print("HELLO");  //DEBUG
    textSize(30);  //Makin' it yuge
    stroke(0);
    words = "Convergence reached!";
    return;
  }
}
