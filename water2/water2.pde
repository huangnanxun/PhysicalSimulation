class Ball {
  PVector pos;
  PVector vel;
  PVector acc;  
  ArrayList<Ball> adjacent;
  Ball(PVector ps) {
    pos = ps;
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    adjacent = new ArrayList<Ball>();
  }  
} 
Ball[][] Balls; 
int row =100;
int col = 100;
boolean texture = false;
PVector[] dirs = new PVector[8];
PImage img;
Camera camera;

void setup() {
  size(1000, 750, P3D);
  background(255);
  noStroke();
  camera = new Camera();
  background(0);
  frameRate(60);
  img = loadImage("S-W.jpg");
  Balls = new Ball[100][100]; 
  dirs[0]=new PVector(-1,-1);
  dirs[1]=new PVector(0,-1);
  dirs[2]=new PVector(-1,1);
  dirs[3]=new PVector(0,-1);
  dirs[4]=new PVector(0,1);
  dirs[5]=new PVector(1,-1);
  dirs[6]=new PVector(1,0);
  dirs[7]=new PVector(1,1);
    for(int i = 0; i < row; i++) {
      for(int j = 0; j < col; j++) {
        Balls[i][j] = new Ball(new PVector(5+ 10 * i, 5 + 10 * j, 0));
      }
    }
    for (int i = 0; i < row; i++){
      for (int j = 0; j < col; j++){
        if(i!=0){
          Balls[i][j].adjacent.add(Balls[i-1][j]);
        }
        if(i!=row-1){
          Balls[i][j].adjacent.add(Balls[i+1][j]);
        }
        if(j!=col-1){
          Balls[i][j].adjacent.add(Balls[i][j+1]); 
        } 
        if(j!=0){
          Balls[i][j].adjacent.add(Balls[i][j-1]); 
        } 
        
        //for(int k=0;k<8;++k){
        //  Ball p = Balls[i][j];
        //  int m = i+(int)dirs[k].x;
        //  println(dirs[k].x);////
          
        //  int n = j+(int)dirs[k].y;
        //  println(dirs[k].x);
        //  if(m>=0&&m<row&&n>=0&&n<col){
        //    Ball q = Balls[m][n];
        //    //float z = q.pos.z - p.pos.z;
        //    //PVector force = new PVector(0, 0, z);
        //    //force.mult(0.01);    
        //    //p.acc.add(force);
        //    p.adjacent.add(q);

        //  }       
   
      }
    }
} 
  
void draw() {
   float startFrame;
  if(texture){
     startFrame = millis();
    lights();
    camera.Update(1.0/frameRate);
    translate(0, 300,-800);
    rotateX(PI/3);
    background(0);    
    pushMatrix();
    noFill();
    noStroke();   
    noFill(); 
    textureMode(NORMAL);
    lights();
    for(int j=0;j<row-1;j++){
      beginShape(TRIANGLE_STRIP);//triangles
      texture(img);
      //noStroke();   
      //noFill();  
      for(int i=0;i<row-1;++i){
        float u = map(i, 0, row-1, 0, 1);
        float v1 = map(j, 0, row-1, 0, 1);
        float v2 = map(j+1, 0, row-1, 0, 1);
        
        float x1 = Balls[i][j].pos.x;
        float y1 = Balls[i][j].pos.y;
        float z1 = Balls[i][j].pos.z;
        vertex(x1,y1,z1,u,v1);
        
        float x2 = Balls[i][j+1].pos.x;
        float y2 = Balls[i][j+1].pos.y;
        float z2 = Balls[i][j+1].pos.z;
        vertex(x2,y2,z2,u,v2);
      }
      endShape(CLOSE);//
    }
    popMatrix();  
  }
else {
  startFrame = millis();
  background(0);
  lights();
  camera.Update(1.0/frameRate);
  translate(0, 300,-800);
  rotateX(PI/3);
  fill(0, 100, 255);
  noStroke();
  for(int i = 0; i < row - 1; i++) {
    beginShape(TRIANGLE_STRIP);
    texture(img);
    noStroke();   
    noFill();  
    for(int j = 0; j < col; j++) {
      Ball b1 = Balls[i][j];
      Ball b2 = Balls[i + 1][j];
      vertex(b1.pos.x, b1.pos.y, b1.pos.z);
      vertex(b2.pos.x, b2.pos.y, b2.pos.z);
    }
    endShape();
  }
}
  for(int i = 0; i <row; i++) {
    for(int j = 0; j < col; j++) {         
      Ball p0 = Balls[i][j];
      for(Ball p1:Balls[i][j].adjacent){
          PVector f = new PVector(0, 0, p1.pos.z - p0.pos.z);             
          p0.acc.add(f.mult(0.1));
      }
    }
  }     
  float endPhysics = millis();
  for(int i = 0; i < row; i++) {
      for(int j = 0; j < col; j++) {
        Ball p = Balls[i][j];
        p.vel.add(p.acc);
        p.pos.add(p.vel);    
        p.vel.mult(0.994);    
        p.acc.mult(0);
     }
  }    

  float endFrame = millis();
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
      " Physics: "+ str(endPhysics-endFrame)+"ms,"+
      " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle("Water2"+ "  -  " +runtimeReport);
}
void mouseClicked(MouseEvent evt) {
    int i =  int(map(mouseX, 0, width, 0, 100));
    int j = int(map(mouseY, 0, width, 0, 100));
    Balls[i][j].pos.z+=150;  
}
void keyPressed()
{
  camera.HandleKeyPressed();
  if(key=='t'&&!texture){
    texture = true;
  }
  else if(key=='t'&&texture){
    texture = false;
  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
}
class Camera
{
  Camera()
  {
    position      = new PVector( 500, 400, 600 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 200;
    turnSpeed     = 1.57; // radians/sec
    
    // dont need to change these
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 10000;
  }
  
  void Update( float dt )
  {
    theta += turnSpeed * (negativeTurn.x + positiveTurn.x) * dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' ) positiveMovement.z = 1;
    if ( key == 's' ) negativeMovement.z = -1;
    if ( key == 'a' ) negativeMovement.x = -1;
    if ( key == 'd' ) positiveMovement.x = 1;
    if ( key == 'q' ) positiveMovement.y = 1;
    if ( key == 'e' ) negativeMovement.y = -1;
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -1;
    if ( keyCode == UP )    positiveTurn.y = 1;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' ) positiveMovement.z = 0;
    if ( key == 'q' ) positiveMovement.y = 0;
    if ( key == 'd' ) positiveMovement.x = 0;
    if ( key == 'a' ) negativeMovement.x = 0;
    if ( key == 's' ) negativeMovement.z = 0;
    if ( key == 'e' ) negativeMovement.y = 0;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector negativeTurn;
  PVector positiveTurn;
};
