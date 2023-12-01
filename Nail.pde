class Nail { 
  float xpos, ypos, size; 
  int id;
  Nail (float x, float y, float size, int id) {  
    xpos = x; 
    ypos = y;
    this.size = size;
    this.id = id;
  }
  
  float getX(){
    return this.xpos;
  }
  
  float getY(){
    return this.ypos;
  }
  
  void display() { 
    circle(xpos, ypos, this.size); 
  } 
  
  String toString(){
    String realIdDirection = "";
    if(this.id%2==1){
      realIdDirection = "Left";
    }else{
      realIdDirection = "Right";
    }
    String realId = String.valueOf(this.id/2);
    return("X: " + this.xpos + " Y: " + this.ypos + " Nail: " + realId + " " + realIdDirection);
  }
} 
