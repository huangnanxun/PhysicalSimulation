int numV = 40;
int numD = 30;
boolean settle =false;

int start_x=200;
int start_y = 20;

int cur_x;
int cur_y;
float[] posX = new float[numV];
float[] posY = new float[numV];
float[] velX = new float[numV];
float[] velY = new float[numV];
float[] accX = new float[numV];
float[] accY = new float[numV];

color bgcolor;

float gravity = 10;
float radius = 10;
float restLen = 5;
float mass = 20;
float k = 200;
float kv = 200;
PImage blanket;
PShape b;
Camera camera;

boolean drop = false;

void setup() {
  size(400, 500, P3D);
  //bgcolor = color(0, 0, 0);
  background(255);
  blanket = loadImage("blanket.jpg");
  noStroke();
  //b = createShape(SPHERE,10);
  //b.setTexture(blanket);
  surface.setTitle("Cloth");
  camera = new Camera();
  clothCreator(numV,start_x, start_y);
}

void clothCreator(int rows,int x, int y){ 
    cur_x=x;
    cur_y=y+120;
    posX[0] = x;
    posY[0] = y;
    velX[0] = 20;
    velY[0] = 0;
    accX[0] = 0;
    accY[0] = 0;
    for(int i = 1; i < rows; i++){
      posX[i] = posX[i-1]+4;
      posY[i] = posY[i-1]+3;
      velX[i] = 20;
      velY[i] = 0;
      accX[i] = 0;
      accY[i] = 0;
  }
}

void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}
void mouseClicked(MouseEvent evt) {
  if (evt.getCount() == 2) doubleClicked();
}
void doubleClicked() {
  if (!drop) {
    drop = true;
  }
}

void add_wind(){
  float xoff = 0;
  for (int i = 0; i < numD; i++) {
    float yoff = 0;
    for (int j = 1; j < numV; j++) {
      float n = noise(xoff, yoff);
      //particles[i][j].display();
      float windx = map(noise(xoff, yoff, zoff), 0, 1, 0, 3);
      float windy = map(noise(xoff+500, yoff+500, zoff), 0, 1, -0.5, 0);
      float windz = map(noise(xoff+300, yoff+300, zoff), 0, 1, -1, 1);
      posX[j] += windx;
      posY[j] += windy;
      yoff += 0.1;
    }
    xoff += 0.1;
  }
  zoff += 0.1;
}

void update(float dt){
  
  for (int q = 0; q<10; q++){
    for (int i = 0; i < numV; i++){
      accX[i] = 0; accY[i] = 0;
    }
    for (int i = 0; i < numV-1; i++){
      float xlen = posX[i+1]-posX[i];
      float ylen = posY[i+1]-posY[i];
      float leng = sqrt(xlen*xlen + ylen*ylen);
      float StringF = k*(leng - restLen);
      float dirX = xlen/leng;
      float dirY = ylen/leng;
      float projVel = (velX[i+1] - velX[i])*dirX + (velY[i+1] - velY[i])*dirY;
      float dampF = kv*projVel;
      float springForceX = (StringF+dampF)*dirX;
      float springForceY = (StringF+dampF)*dirY;
      float aX = springForceX/mass;
      float aY = springForceY/mass;
      
      accX[i] += aX/2;
      accY[i] += aY/2 + gravity/mass;
      accX[i+1] += -aX/2;
      accY[i+1] += -aY/2 + gravity/mass;
    }
    
    int drop_contorl;
    if (drop){
      drop_contorl = 0;
    }else{
      drop_contorl =1;
    }
      
    for (int i = drop_contorl; i < numV; i++){
      velX[i] += accX[i] * dt;
      velY[i] += accY[i] * dt;
      posX[i] += velX[i] * dt;
      posY[i] += velY[i] * dt;
      if (posY[i]>=800){
        posY[i] = 800;
        velY[i] += 0;
        velX[i] = 0.85*velX[i];
      }
    }
  }
}

void draw_cloth(){
  textureMode(NORMAL);
  for (int k = 0;k<numV-1;k++){
    beginShape(TRIANGLE_STRIP);
    texture(blanket);
    for(int i = 0; i < numD; i++){
      float x1 = i*10;
      float y1 = posY[k];
      float z1 = posX[k];
      float u = map(i, 0, numD-1, 0, 1);
      float v1 = map(k, 0, numV-1, 0, 1);
      vertex(x1, y1, z1, u, v1);
      float x2 = i*10;
      float y2 = posY[k+1];
      float z2 = posX[k+1];
      float v2 = map(k+1, 0, numV-1, 0, 1);
      vertex(x2, y2, z2, u, v2);
    }
    endShape();
  }
}


//Draw the scene: one sphere per mass, one line connecting each pair
float zoff = 0;
void draw() {
  //bgcolor = color(random(255), 150, 255);
  background(255);
  lights();
  camera.Update( 1.0/frameRate );
  noStroke();
  if(!settle){
    clothCreator(numV,mouseX, mouseY);
    draw_cloth();
    if(mousePressed) settle=true;
  }
  else{
    draw_cloth();
  }
  update(.1); 
}



class Camera
{
  Camera()
  {
    position      = new PVector( 300, 200, 1200 ); // initial position
    theta         = 0.2; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
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
