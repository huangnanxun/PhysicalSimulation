class Water_Box {
  float box_x;
  float box_z;
  float velX;
  float velZ;
  float accX;
  float accZ;
  float eta;
  float veleta;
  
  Water_Box(float pos_x, float pos_z) {   
    box_x = pos_x;
    box_z = pos_z;   
    velX = 0;
    velZ = 0;
    eta = eta_init;
    veleta = 0;
    accX = 0;
    accZ = 0;
  } 
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0,  10 , 0);
    int vel_int = 2 * random_int+1;
    velocity = new PVector(random(-vel_int, vel_int), random(-15-10*vel_int, -25), random(-vel_int, vel_int));
    position = l.copy();
    lifespan = 10.0;
  }

  void run() {
    update();
    display();
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  void display() {
    stroke(color(0,0,255));
    fill(color(0,0,255));
    translate(position.x, position.y, position.z);
    sphere(6);
    translate(-position.x, -position.y, -position.z);
    //ellipse(position.x, position.y, 8, 8);
  }

  boolean isDead() {
    if (position.y>500) {
      return true;
    } else {
      return false;
    }
  }
}



int water_long = 100; 
int water_width = 100;
int eta_init = 20;

Water_Box[][] Water_Box;

color bgcolor;

float gravity = 10;
float damp = 0.1;
PShape fish1;
PShape fish2;
PShape fish3;
PShape stone;
ParticleSystem ps;

Camera camera;

int fishx;
int fishz;

String projectTitle = "shallow_water";


void setup() {
  size(400, 500, P3D);
  background(255);
  noStroke();
  camera = new Camera();
  Water_Box = new Water_Box[water_long][water_width];
  fish1 = loadShape("Fish1.obj");
  fish2 = loadShape("Fish3.obj");
  fish3 = loadShape("Fish2.obj");
  stone = loadShape("Stone.obj");
  stone.scale(0.15);
  ps = new ParticleSystem(new PVector(500,500,500));
  set_init_condition(fishx,fishz);
  //println(fishx,fishz);
}

void set_init_condition(int posx,int posz){
  
  //int mid_x = water_long/2;
  //int mid_z = water_width/2;
  int mid_x = posx;
  int mid_z = posz;
  for(int k=0;k<water_long;k++){
    for(int j=0;j<water_width;j++){
      Water_Box[k][j]=new Water_Box(0,0);
      Water_Box[k][j].box_x = k*10;
      Water_Box[k][j].box_z = j*10;
      int dis_to_ori = (k - mid_x)*(k - mid_x) + (j-mid_z)*(j-mid_z);
      if (dis_to_ori<100){
        Water_Box[k][j].eta = (1+random_int) * eta_init;
      }
    }
  }
}

void update_partical_origin(int x,int z){
  ps.origin = new PVector(x*10,500,z*10);
}

void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

boolean time_counter = false;
int random_int = 0;
PShape fish;

void mouseClicked(MouseEvent evt) {
  time_counter = true;
  fish_h = -200;
  random_int = int(random(1,5));
  if(random_int == 1){
    fish = fish1;
  }
  if(random_int == 2){
    fish = fish2;
  }
  if(random_int == 3){
    fish = fish3;
  }
  if(random_int == 4){
    fish = stone;
  }
}



int time_delay_counter = 0;
float fish_h = -200;

void time_delay_event(){
  if(time_counter){
    time_delay_counter += 1;
    fish_h = fish_h + 40;
    draw_fish();
    update_partical_origin(fishx,fishz);
  }
  if (time_delay_counter >= 18){
    for(int i = 0; i< 50; i++){
      ps.addParticle();
    }
  }
  if (time_delay_counter >= 20){
    time_delay_counter =0;
    time_counter = false;
    set_init_condition(fishx,fishz);
  }
  //print(random_int);
}


void update(float dt){
  for (int q = 0; q<5; q++){
    for(int k=0;k<water_long;k++){
      for(int j=0;j<water_width;j++){
        int up_index_x = k+1;
        if (up_index_x>=water_long){
          up_index_x = 0;
        }
        int up_index_z = j+1;
        if (up_index_z>=water_width){
          up_index_z = 0;
        }
        int down_index_x = k-1;
        if (down_index_x<0){
          down_index_x = water_long-1;
        }
        int down_index_z = j-1;
        if (down_index_z<0){
          down_index_z = water_width-1;
        }
        
        float eta_dis_x = (Water_Box[up_index_x][j].eta - Water_Box[down_index_x][j].eta)/2;
        float eta_dis_z = (Water_Box[k][up_index_z].eta - Water_Box[k][down_index_z].eta)/2;
        float damp = 0.5;
        
        Water_Box[k][j].accX = -gravity * eta_dis_x - damp*Water_Box[k][j].velX;
        Water_Box[k][j].accZ = -gravity * eta_dis_z - damp*Water_Box[k][j].velZ;
        
        float eta_dis_ueta = (Water_Box[up_index_x][j].velX*Water_Box[up_index_x][j].eta - Water_Box[down_index_x][j].velX*Water_Box[down_index_x][j].eta)/2;
        float eta_dis_veta = (Water_Box[k][up_index_z].velZ*Water_Box[k][up_index_z].eta - Water_Box[k][down_index_z].velZ*Water_Box[k][down_index_z].eta)/2;
        
        Water_Box[k][j].veleta = -eta_dis_ueta-eta_dis_veta;
      }
    }
    
    for(int k=1;k<water_long-1;k++){
      for(int j=1;j<water_width-1;j++){
        Water_Box[k][j].eta  = Water_Box[k][j].eta + Water_Box[k][j].veleta * dt;
        Water_Box[k][j].velX  = Water_Box[k][j].velX + Water_Box[k][j].accX * dt;
        Water_Box[k][j].velZ  = Water_Box[k][j].velZ + Water_Box[k][j].accZ * dt;
        
      }
    }
    
    for(int k=0;k<water_long;k++){
      for(int j=0;j<water_width;j++){
        Water_Box[k][j].veleta  *= 0.996;
        Water_Box[k][j].velX *= 0.996;
        Water_Box[k][j].velZ *= 0.996;
        
      }
    }
    
  }
 

  //print("veleta for point [50,50] is " + Water_Box[50][50].veleta +"\n");
  //print("accX for point [50,50] is " + Water_Box[50][50].accX +"\n");
  //print("velX for point [50,50] is " + Water_Box[50][50].velX +"\n");
  //print("eta for point [50,50] is " + Water_Box[50][50].eta +"\n");

}

void draw_water(){
  textureMode(NORMAL);
  for(int k=0;k<water_long;k++){
    for(int j=0;j<water_width;j++){
      translate(Water_Box[k][j].box_x, 500-Water_Box[k][j].eta/2, Water_Box[k][j].box_z);
      stroke(0, 100, 255); 
      fill(0,0,255);
      box(10,Water_Box[k][j].eta,10);
      translate(-Water_Box[k][j].box_x, -500+Water_Box[k][j].eta/2, -Water_Box[k][j].box_z);
    }
  }
}

void draw_fish(){
  translate(fishx*10,fish_h,fishz*10);
  scale(20);
  rotateX(-PI/2);
  rotateZ(-PI);
  shape(fish);
  translate(-fishx*10,-fish_h,-fishx*10);
}

void draw_mouse_ball(){
  translate(fishx*10,-200,fishz*10);
  noStroke();
  fill(color(255,0,0));
  noStroke();
  sphere(20);
  translate(-fishx*10,200,-fishz*10);
}

void draw() {
  float startFrame = millis();
  background(255);
  lights();
  camera.Update( 1.0/frameRate );
  fishx = int(mouseX*100/width);
  fishz = int(mouseY*100/height);
  float startPhysics = millis();
  draw_mouse_ball();
  draw_water();
  time_delay_event();
  update(.002);
  ps.run();
  float endFrame = millis();
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endFrame-startPhysics)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
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
