float xBase;
float yBase;
float zBase;

float motorHeight = 50;  // 5cm
float motorWidth = 40;   // 4cm
float motorDepth = 25;   // 2.5cm

float xFloor = 580;      // 58cm
float yFloor = 10;       // 1cm
float zFloor = 410;      // 41cm

float xBlock1 = 90;      // 9cm
float yBlock1 = 28;      // 2.8cm
float zBlock1 = 90;      // 9cm
float xOffsetB1 = 95;    // 9.5cm
float zOffsetB1 = 70;    // 7cm

float xBlock2 = 25;      // 2.5cm
float zBlock2 = 90;      // 9cm
float yBlock2 = 42;      // 4.2cm
float xOffsetB2 = 95;    // 9.5cm
float zOffsetB2 = 70;    // 7cm

float yOffsetM1 = 17;    // 1.7cm


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
  
  
    fill(#C4C0C0);  // colore del pavimento
    translate(xBase,yBase,zBase);
    box(xFloor,yFloor,zFloor);
    
    fill(#65D34D);  // colore del robot
    translate(-xFloor/2+xBlock1/2+xOffsetB1,-(yFloor/2+yBlock1/2),-zFloor/2+zBlock1/2+zOffsetB1);
    box(xBlock1,yBlock1,zBlock1);
    
    translate(-xBlock1/2+xBlock2/2,-(yBlock1/2+yBlock2/2),0);
    box(xBlock2,yBlock2,zBlock2);
    
    fill(#000000);  // colore motore
    translate(xBlock2/2+motorDepth/2,-yOffsetM1,0);
    box(motorDepth,motorHeight,motorWidth); 
}
