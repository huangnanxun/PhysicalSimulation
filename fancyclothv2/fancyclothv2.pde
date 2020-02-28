Camera camera; //<>//

class Ball {
  PVector pos;
  PVector vel;
  PVector acc;
  float m =1.5;
  ArrayList<Ball> adjacent;
  PVector v0;
  Ball() {
    pos = new PVector(0,0,0);
    vel = new PVector(0,0,0);
    acc = new PVector(0,9.8,0);
    v0=vel;
    adjacent = new ArrayList<Ball>();
  }
}


  int col = 30;
  int row = 30;
  float l0 =6;//rest length
  float ks =800; //spring
  float kd =2;//damping
  Ball Balls[][];

 
  void UpdatePhysics(float dt){
    ArrayList<Ball>  remove = new ArrayList<Ball>();
    for(int q=0;q<3;++q){
    for(int i=0;i<col;++i){
      for(int j=0;j<row;++j){
       Balls[i][j].v0=Balls[i][j].vel;
      }
    }    
    
    for(int i=0;i<col;++i){
      for(int j=0;j<row;++j){    
          PVector a= PVector.mult(Balls[i][j].v0,dt);
          a.add(PVector.mult(g,0.5*dt*dt));
          Balls[i][j].pos.add(a);
          PVector b = PVector.mult(g,dt);
          Balls[i][j].vel.add(b);   
          
          for(Ball p1:Balls[i][j].adjacent){
            PVector e=PVector.sub(p1.pos,Balls[i][j].pos);
            float l = e.mag();
            e.normalize();
            
            if (l > 15)
              remove.add(p1);
          
            float v1= e.dot(Balls[i][j].v0);
            float v2= e.dot(p1.v0);
            float f=-ks*(l0-l)-kd*(v1-v2);  

            PVector a_change = PVector.mult(e,f/Balls[i][j].m);
            Balls[i][j].vel.add(PVector.mult(a_change,dt));
            Balls[i][j].pos.add(PVector.mult(a_change,0.5*dt*dt));
            p1.vel.sub(PVector.mult(a_change,dt));
            p1.pos.sub(PVector.mult(a_change,0.5*dt*dt));
        if(Balls[i][j].pos.y>floor){
          Balls[i][j].pos.y = floor;
          PVector normal=new PVector(0,-1,0);
          PVector vNorm=PVector.mult(normal,PVector.dot(Balls[i][j].vel,normal));
          Balls[i][j].vel.sub(vNorm);
          Balls[i][j].vel.sub(vNorm.mult(0.7));
        }
        float d=PVector.sub(pball1,Balls[i][j].pos).mag();       
        if(d<radius){
          PVector norm = PVector.sub(Balls[i][j].pos, pball1);
          norm.normalize();
          float as = radius*1.01;
          PVector bs = PVector.mult(norm,as);
          Balls[i][j].pos = PVector.add(pball1,bs);
          float c = PVector.dot(norm,Balls[i][j].vel);
          PVector vnorm = PVector.mult(norm,c);
          Balls[i][j].vel.sub(vnorm); 
          Balls[i][j].vel.sub(vnorm.mult(1.0));         
        }
        
        }
        if(tear){
          for (Ball rem : remove) {
              Balls[i][j].adjacent.remove(rem);
        }
        remove.clear();
        }
      }
    }
    
    
    ///air force
    for(int i=0;i<col-1;++i){
      for(int j=0;j<row-1;++j){    
          PVector aero=new PVector(0,0,0); 
          if(Balls[i][j].adjacent.size()>1){
          Ball p1=Balls[i][j].adjacent.get(0);
          Ball p2=Balls[i][j].adjacent.get(1);
          PVector r1=PVector.sub(p1.pos,Balls[i][j].pos);
          PVector r2=PVector.sub(p2.pos,Balls[i][j].pos);
          PVector norm=new PVector(0,0,0);
          PVector.cross(r2,r1,norm);        
          PVector vel = new PVector(0, 0, 0);
          vel.add(Balls[i][j].v0); 
          vel.add(p1.v0); 
          vel.add(p2.v0);
          vel.div(3);
          vel.sub(Vair);
          float m = vel.mag();
          float norm_m =norm.mag();
          float aa = m/(2*norm_m);
          float coef=aa*PVector.dot(vel,norm);
          aero=PVector.mult(norm,-0.5*0.1*coef*0.002); 
          aero.mult(1/(p1.m*3));
          
          Balls[i][j].vel.add(PVector.mult(aero,dt));
          Balls[i][j].pos.add(PVector.mult(aero,0.5*dt*dt));
          }
        if(Balls[i][j].pos.y>floor){
          Balls[i][j].pos.y = floor;
          PVector normal=new PVector(0,-1,0);
          PVector vNorm=PVector.mult(normal,PVector.dot(Balls[i][j].vel,normal));
          Balls[i][j].vel.sub(vNorm);
          Balls[i][j].vel.sub(vNorm.mult(0.7));
        }
      
        float d=PVector.sub(pball1,Balls[i][j].pos).mag();       
        if(d<radius){
          PVector norms = PVector.sub(Balls[i][j].pos, pball1);
          norms.normalize();
          float a = radius*1.01;
          PVector b = PVector.mult(norms,a);
          Balls[i][j].pos = PVector.add(pball1,b);
          float c = PVector.dot(norms,Balls[i][j].vel);
          PVector vnorm = PVector.mult(norms,c);
          Balls[i][j].vel.sub(vnorm); 
          Balls[i][j].vel.sub(vnorm.mult(1.0));           
        }     
      } // update
      if(!drop){
        for(int j=0;j<row;++j){
          Balls[0][j].vel= new PVector(0,0,0);
          Balls[0][j].pos= new PVector(anchor_x ,anchor_y, anchor_z-j* l0);  
        }       
      }
   }
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
    acceleration = new PVector(0,  0 , 0);
    velocity = new PVector(random(-2, 2), random(-2, 2), random(-2, 2));
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
    stroke(color(255,0,0));
    fill(color(255,0,0));
    translate(position.x, position.y, position.z);
    box(2);
    translate(-position.x, -position.y, -position.z);
    //ellipse(position.x, position.y, 8, 8);
    fill(255);
  }

  boolean isDead() {
    if (lifespan<0) {
      return true;
    } else {
      return false;
    }
  }
}


float anchor_y = 325;
float anchor_z = 50;
float anchor_x = 416;
PVector Vair=new PVector(0,0,0);
PVector g=new PVector(0,9.8,0);
PImage img;
float radius = 50;
PVector pball1;
float floor;
boolean tear =false;
boolean handball =false;
boolean drop = false;
boolean texture = false;

boolean burn = false;
int burn_delay = 0;
boolean cloth_burn = false;
int cloth_burn_row_num = col-1;
int cloth_burn_slower = 0;

int part_num = 180;
ParticleSystem[] parray = new ParticleSystem[part_num];
ParticleSystem[] cloth_parray = new ParticleSystem[row*6];

PImage b;
PShape ball;
PShape cloth_b;
PImage c_b;
void setup(){
  size(1000, 750, P3D);
  surface.setTitle("Cloth simulation");
  camera = new Camera();
  img = loadImage("cloth_texture.jpeg");
  b = loadImage("blanket.jpg");
  c_b = loadImage("sea.jpg");
  pball1= new PVector(450,550,-40);
   noStroke();   
  noFill();   
    cloth_b = createShape(SPHERE,2);
    cloth_b.setTexture(c_b);
  
  noStroke();   
  noFill();  
  ball = createShape(SPHERE,radius);
  ball.setTexture(b);
  floor = 570;
      Balls =new Ball[col][row];
    for(int i=0;i<col;++i){
      for(int j=0;j<row;j++){
        Balls[i][j]=new Ball();
        Balls[i][j].pos = new PVector(anchor_x + i*l0,anchor_y, anchor_z-j* l0);
      }
    }
    for (int i = 0; i < col; i++){
      for (int j = 0; j < row; j++){
        if(i!=col-1){
          Balls[i][j].adjacent.add(Balls[i+1][j]);
        }
        if(j!=row-1){
          Balls[i][j].adjacent.add(Balls[i][j+1]); 
        } 
      }
    }
  Vair=new PVector(0,0,0);
  noStroke();
  for (int i=0; i<180;i++){
    parray[i] = new ParticleSystem(new PVector(anchor_x,anchor_y,anchor_z-i));
  }
  
}

void draw(){
  float startFrame = millis();
  background(250);
  lights();
  camera.Update( 1.0/frameRate );
  UpdatePhysics(0.03);
  float endPhysics = millis();
  if(handball){
    pball1.x = mouseX;
    pball1.y = mouseY;
  }
  if(pball1.y+radius>floor){
     pball1.y=floor-radius;
  }
  
  
  push();
  translate(pball1.x,pball1.y,pball1.z);
  noStroke();   
  noFill(); 
  lights();
  shape(ball);
  pop();
  
  for (int i=0; i<row*6;i++){
    int row_num = int(i/6);
    int modo = i%6;
    cloth_parray[i] = new ParticleSystem(new PVector(Balls[cloth_burn_row_num][row_num].pos.x,Balls[cloth_burn_row_num][row_num].pos.y,Balls[cloth_burn_row_num][row_num].pos.z+modo));
  }
  
  if(drop & (!burn)){
    burn_delay += 1;
    for (int i=0; i<180;i++){
      parray[i].addParticle();
    }
    if(burn_delay>30){
      burn = true;
    }
  }
  
  if(tear&&cloth_burn){
    cloth_burn_slower +=1;
    for (int i=0; i<row*6;i++){
      cloth_parray[i].addParticle();
      Balls[cloth_burn_row_num][i/6].adjacent.clear();
    }
    if (cloth_burn_row_num>0 && cloth_burn_slower%5 == 0){
      cloth_burn_row_num = cloth_burn_row_num -1;
    }
  }
  
  if (!burn){
    fill(color(217,95,14));
    translate(anchor_x,anchor_y,anchor_z-90);
    box(5,5,180);
    translate(-anchor_x,-anchor_y,-anchor_z+90);
    fill(255);
  }
  
  for (int i=0; i<180;i++){
    parray[i].run();
  }
  for (int i=0; i<row*6;i++){
    cloth_parray[i].run();
  }
    
  if(!tear){
  pushMatrix();
  noFill();
  noStroke();   
  noFill(); 
  textureMode(NORMAL);
  lights();
  for(int j=0;j<row-1;j++){
    beginShape(TRIANGLE_STRIP);//triangles
    texture(img);
    noStroke();   
    noFill();  
    for(int i=0;i<col-1;++i){

      float u = map(i, 0, col-1, 0, 1);
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
  if(tear){
    stroke(0, 0, 255, 255);
    noFill();
    for(int i=0;i<col-1;++i){
      for(int j=0;j<row-1;++j){   
        
          if(texture){
            push();
            translate(Balls[i][j].pos.x, Balls[i][j].pos.y,Balls[i][j].pos.z);
            noStroke();   
            noFill(); 
            lights();
            shape(cloth_b);
            pop();
          }
          else{
            for(Ball b: Balls[i][j].adjacent){
              line(Balls[i][j].pos.x,Balls[i][j].pos.y,Balls[i][j].pos.z,b.pos.x,b.pos.y,b.pos.z);
            }
          }
            
        }
        }
      }
   
    
  float endFrame = millis();
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-endFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle("fancycloth"+ "  -  " +runtimeReport);
}

void keyPressed()
{
  camera.HandleKeyPressed();
  if ( key == 'b' ) Vair.x += 20;
  else if ( key == 'n' ) Vair.x -= 20;
  else  if ( key == 'g' ) Vair.z += 20;
  else if ( key == 'h' ) Vair.z -= 20;
  else  if ( key == 'p'&& !handball ) handball = true;
  else  if ( key == 'p'&& handball ) {
    handball = false;
    pball1= new PVector(450,550,-40);
  }
  else  if ( key == 't'&& !tear ) tear = true;
  else  if ( key == 't'&& tear ) {
    tear = false;

  }
  else  if ( key == 'x'&& !texture ) texture = true;
  else  if ( key == 'x'&& texture ) {
    texture = false;

  }
  else  if ( key == 'z') {
    cloth_burn = true;
  }
  else if (key =='r'){
    setup();
    tear =false;
    handball =false;
    drop = false;
    burn = false;
    burn_delay = 0;
  }
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
    handball = false;
  }
} 
void mouseDragged() {
  for (int i=0;i<col;i++) {
    for (int j=0;j<row;j++) {
      if (mouseButton == LEFT&&Math.abs(mouseX - Balls[i][j].pos.x) < 20 && Math.abs(mouseY - Balls[i][j].pos.y) < 20) {
          Balls[i][j].vel.add(new PVector(3*(mouseX - pmouseX), 3*(mouseY-pmouseY), 0));
      }
      else if (mouseButton == RIGHT&&Math.abs(mouseX - Balls[i][j].pos.x) < 15 && Math.abs(mouseY - Balls[i][j].pos.y) < 15) {
          Balls[i][j].adjacent.clear();
      }
    }
  }
}
  
class Camera
{
  Camera()
  {
    position      = new PVector(600,432,500); // initial position
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
