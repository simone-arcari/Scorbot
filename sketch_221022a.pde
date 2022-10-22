float xBase;
float yBase;
float zBase;

float xFloor = 580;    // 58cm
float yFloor = 10;     // 1cm
float zFloor = 410;    // 41cm


float eyeY = 0;
float eyeX = 0;

void setup(){
    size(626,626,P3D);
    stroke(255);
    strokeWeight(2);
    smooth();
   
    xBase = width/2;
    yBase = 5*(height/6);
    zBase = -180;
    
    
}

void draw(){
    background(0);
    lights();
    
    camera((width/2.0) - eyeX, height/2 - eyeY, (height/2.0) / tan(PI*60.0 / 360.0), width/2.0, height/2.0, 0, 0, 1, 0);
    
    if (keyPressed) {
        // movimento camera
        if (keyCode == DOWN) {
            eyeY -= 5;
        }
        if (keyCode == UP) {
            eyeY += 5;
        }
        if (keyCode == LEFT) {
            eyeX -= 5;
        }
        if (keyCode == RIGHT) {
            eyeX += 5;
        }
    }
    
    
    textSize(25);

    fill(0,255,0);  
    text("coordinata y vista = ",10,25); 
    text(eyeY,250,25);
    text("coordinata x vista = ",10,50); 
    text(eyeX,250,50);
  
  
    fill(#C4C0C0); // Colore del robot
    translate(xBase,yBase,zBase);
    box(xFloor,yFloor,zFloor);
}
