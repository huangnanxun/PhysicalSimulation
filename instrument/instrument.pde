
import processing.sound.*;
Sound s;

void setup() {
  size(800, 800);
  surface.setTitle("Instrument");
  s = new Sound(this);
  pos_x = width/2;
  pos_y = height/2;
}

//line(width/2, height*0.15, width/2, height*0.85);

float pos_x;
float pos_y;
float velx = 0;
float vely = 0;
float restLen = height*0.7;
float k = 3;
float kv = 10;

void draw_line(){
  strokeWeight(4);
  line(width/2, height*0.15, pos_x, pos_y);
  line(pos_x, pos_y, width/2, height*0.85);
  
}
boolean is_drag = false;
boolean is_relased = false;

float mouse_click_x;
float mouse_click_y;

void mousePressed() {
  mouse_click_x = mouseX;
  mouse_click_y = mouseY;
  is_relased = false;
  print(mouse_click_x,mouse_click_y);
}

void mouseDragged() {
  if (mouse_click_x>width/2-15 && mouse_click_x<width/2+15 && mouse_click_y>height*0.15 && mouse_click_y<height*0.85){
    is_drag = true;
  }
}

float relase_pos_x;
float relase_pos_y;
SinOsc sin = new SinOsc(this);

void mouseReleased() {
  is_drag = false;
  is_relased = true;
  relase_pos_x = mouseX;
  float sin_freq = height- abs(mouse_click_y-height*0.15);
  float sin_amp = map(abs(relase_pos_x-width/2),0,width/2,0.1,0.8);
  sin.play(sin_freq, sin_amp);
}
  
void update(float dt){
  if (is_drag){
  pos_x = mouseX;
  pos_y = mouseY;
  }
  if (is_relased){
    float sx1 = (pos_x - width/2);
    float sy1 = (pos_y - height*0.15);
    float stringLen1 = sqrt(sx1*sx1 + sy1*sy1);
    float sx2 = (pos_x - width/2);
    float sy2 = (pos_y - height*0.85);
    float stringLen2 = sqrt(sx2*sx2 + sy2*sy2);    
    float restLen1 = restLen*stringLen1/(stringLen1+stringLen2);
    float restLen2 = restLen*stringLen2/(stringLen1+stringLen2);
    float stringF1 = -k*(stringLen1 - restLen1);
    float stringF2 = -k*(stringLen2 - restLen2);
    float dirX1 = sx1/stringLen1;
    float dirY1 = sy1/stringLen1;
    float dirX2 = sx2/stringLen2;
    float dirY2 = sy2/stringLen2;    
    float projVel1 = velx*dirX1 + vely*dirY1;
    float projVel2 = velx*dirX2 + vely*dirY2;
    float dampF1 = -kv*(projVel1 - 0);
    float dampF2 = -kv*(projVel2 - 0);
    float springForceX = (stringF1+dampF1)*dirX1 + (stringF2+dampF2)*dirX2;
    float springForceY = (stringF1+dampF1)*dirY1 + (stringF2+dampF2)*dirY2;
    if (velx*(velx+springForceX*dt)<=0){
      springForceX*=0.85;
      springForceY*=0.85;
    }
    velx += springForceX*dt;
    vely += springForceY*dt;
    if (abs(velx)<=20){
      velx*=0.85;
    }
    if (abs(vely)<=0.0005 || abs(velx)<=0.0005){
      sin.stop();
    }
    pos_x += velx*dt;
    pos_y += vely*dt;
    //println(velx,vely);
  }
}

void draw() {
  float startFrame = millis();
  background(255);
  update(0.1);
  float endPhysics = millis();
  draw_line();
  float endFrame = millis();
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-endFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle("instrument"+ "  -  " +runtimeReport);
}


//import processing.sound.*;
//Sound s;

//void setup() {
//  size(600, 600);

//  // Play two sine oscillators with slightly different frequencies for a nice "beat".
//  SinOsc sin = new SinOsc(this);
//  sin.play(200, 0.2);
//  sin = new SinOsc(this);
//  sin.play(400, 0.2);

//  // Create a Sound object for globally controlling the output volume.
//  s = new Sound(this);
//}

//void draw() {
//  // Map vertical mouse position to volume.
//  float amplitude = map(mouseY, 0, height, 0.4, 0.0);

//  // Instead of setting the volume for every oscillator individually, we can just
//  // control the overall output volume of the whole Sound library.
//  s.volume(amplitude);
//}





//import processing.sound.*;

//TriOsc triOsc;
//Env env;

//float attackTime = 0.001;
//float sustainTime = 0.004;
//float sustainLevel = 0.3;
//float releaseTime = 0.4;

//void setup() {
//  size(640, 360);
//  background(255);
  
//  // Create triangle wave
//  triOsc = new TriOsc(this);

//  // Create the envelope 
//  env  = new Env(this); 
 
//}      

//void draw() {
//}

//void mousePressed() {
//  triOsc.play();
//  env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
//}
