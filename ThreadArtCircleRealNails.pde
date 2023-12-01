PImage img;
Float widthFactor;
Float heightFactor;
int maxNails = 300;
ArrayList<Nail> nails = new ArrayList<Nail>();
int index = 0;
int lastNail = 0;
ArrayList<int[]> allPoints = new ArrayList<int[]>();
ArrayList<Nail> lines = new ArrayList<Nail>();
int iterations = 1300;
int lightness = 50;

//these variables for outputting (could probably create another class but lazy)
int imgW = 1; //this is a default value
int imgH = 1; //this is a default value
Float lastx = 0.0;
Float lasty = 0.0;
BufferedReader reader;
int count = 0;
int stop = 2600; //high number to not stop early, max is 2x iterations

//processing function that runs on startup
void setup() {
  surface.setResizable(true);
  //currently assumes the image is square
  img = loadImage("giraffe.jpg");
  img.filter(GRAY);
  size(1, 1);
  surface.setSize(int(img.width+1), int(img.height+1));
  noLoop();

  placeNails();
}

//instantiate the nails in a circle
void placeNails(){
  //width is assumed to be higher or equal
  //so aspectRatio is >= 1
  //nails are placed in circle
  Float nailRadianStep = TWO_PI / maxNails;
  Float currentRadian = 0.0;
  float centerX = img.width/2;
  float centerY = img.height/2;
  
  Float x = centerX;
  Float y = 0.0;
  
  int counter = 0;
  
  Float nailWidth = .009; //this is nail width in radians
  for(int i = 0; i < maxNails; i++){
    //add left side of nail
    x = centerX * cos(currentRadian - nailWidth/2) + centerX;
    y = centerY * sin(currentRadian - nailWidth/2) + centerY;
    nails.add(new Nail(x, y, nailWidth, counter));
    counter++;
    //add right ride of nail
    x = centerX * cos(currentRadian + nailWidth/2) + centerX;
    y = centerY * sin(currentRadian + nailWidth/2) + centerY;
    nails.add(new Nail(x, y, nailWidth, counter));
    counter++;
    //increase by the radian step
    currentRadian += nailRadianStep;
    //println("Placed nail at (" + x + ", " + y +")");
  }
  //println("There are " + nails.size() + " nails");
}

//looks at all possible lines from the lastLine and adds the best to the list
void findNextLine(){
  int bestNail = 0;
  float bestScore = 0;
  for(int i = 0; i < nails.size(); i++){
    //only look at nails outside of x spaces (50 is 25 real nails)
    if(abs(i - lastNail) > 50){      
      //evaluate a line
      float score = getScore(nails.get(lastNail), nails.get(i));
      
      //save results if better
      if(score > bestScore){
        bestScore = score;
        bestNail = i;
      }
    }
  }
  
  //add the other side of the last best nail to the list of lines (this line could probably go after checking sides)
  lines.add(nails.get(lastNail));
  //draw the line onto the image for further processing
  drawLine(nails.get(lastNail), nails.get(bestNail));
  println("best nail = " + bestNail + " with a score of " + bestScore);
  lastNail = bestNail;
  //add the current best nail to the list of lines
  lines.add(nails.get(lastNail));
  //check if odd or even and switch sides of the nail
  if(lastNail%2==1){
    lastNail--;
  }else{
    lastNail++;
  }
}

//draws a line onto the image for calculations
void drawLine(Nail nail1, Nail nail2){
  //get all the points for a possible line
  ArrayList<int[]> points = getPixels(nail1.getX(), nail1.getY(), nail2.getX(), nail2.getY());
  //println("Found line has : " + points.size() + " distance   " + nail1 + " " + nail2);
  
  //loop through each point and add 50/255? pigment to it
  for(int i=0; i < points.size(); i++){
    allPoints.add(points.get(i));
    int imgW = img.width+1;
    pixels[points.get(i)[0] + ((points.get(i)[1]) * imgW)] = round(blue(pixels[points.get(i)[0] + ((points.get(i)[1]) * imgW)])+50);
    updatePixels();
  }
}

//gets a given score for a line
float getScore(Nail nail1, Nail nail2){
  ArrayList<int[]> points = getPixels(nail1.getX(), nail1.getY(), nail2.getX(), nail2.getY());
  float sum = 0;
  for(int i=3; i < points.size()-3; i++){
    //look at each pixels color and average along the line
    int imgW = img.width+1;
    color pixelColor = pixels[points.get(i)[0] + ((points.get(i)[1]) * imgW)];
    sum += red(pixelColor);
  }
  
  float avg = sum/points.size();
  return avg;
}

//returns a list of the pixel locations given 2 points
ArrayList<int[]> getPixels(float x1,float y1,float x2,float y2){
  ArrayList<int[]> points=new ArrayList<int[]>();
  float theta=atan2(y2-y1,x2-x1);
  PVector p=new PVector(x1,y1);
  float d=dist(x1,y1,x2,y2);
  for(int r=0;r<d;r++){
    p.add(cos(theta),sin(theta));
    points.add(new int[]{int(p.x),int(p.y)});
  }
  return points;
}

//helper function to read text file info
void parseFile() {
  // Open the file from the createWriter() example
  String line = null;

  try {
    reader = createReader("positions.txt");
    imgW = int(reader.readLine());
    imgH = int(reader.readLine());
    surface.setSize(imgW, imgH);    
    String[] pieces1 = split(reader.readLine(), " ");
    lastx = float(pieces1[1]);
    lasty = float(pieces1[3]);
  } catch (IOException e) {
    e.printStackTrace();
  }
}

//draw the lines from the generated file
void drawLinesFromFile(){
  try{
    parseFile();
    String line = reader.readLine();
    while(line != null){
      String[] pieces = split(line, " ");
      println(line);
      Float x = float(pieces[1]);
      Float y = float(pieces[3]);
      stroke(255,255,255,30);
      line(lastx, lasty, x, y);
      lastx = x;
      lasty = y;
      line = reader.readLine();
      if(count == stop){
       line = null;
       noLoop();
       reader.close();
       save("output.jpg");
      }
      count ++;
    }
    noLoop();
    reader.close();
    save("output.jpg");
  } catch( IOException e) {
    e.printStackTrace();
  }
}

//exports the locations of each line's endpoint
void export(){
  PrintWriter output = createWriter("positions.txt");
  output.println(img.width+1);
  output.println(img.height+1);
  for(int i=0; i < lines.size(); i++){
    output.println(lines.get(i));
  }
  output.flush();
  output.close();
}

//main driver in processing
void draw(){
  image(img,0,0);
  loadPixels();
  //select a random nail to start the image from -- Maybe want to select a few options for the first line eventually?
  lastNail = round(random(1) * (nails.size()-1));
  //find the next best line until iterations satisfied
  for(int i = 0; i < iterations; i++){
    findNextLine();
    println("Drawing line# " + i + " Last Nail was " + lastNail);
  }
  export();
  println("exported");

  surface.setSize(imgW, imgH);
  background(0); //make background black
  drawLinesFromFile();
  println("Done");
}
