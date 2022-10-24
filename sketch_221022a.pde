float xBase;
float yBase;
float zBase;

// motore(parte 1) : corpo principale
float motorHeight = 40;  // 4cm
float motorWidth = 40;   // 4cm
float motorDepth = 25;   // 2.5cm

// motore(parte 2) : ingranaggio
float gearHeight = 12;  // 1.2cm
float gearWidth = 8;    // 0.8cm
float gearDepth = 8;    // 0.8cm
float gearOffset = 10;  // 1cm

// pavimento
float xFloor = 580;      // 58cm
float yFloor = 10;       // 1cm
float zFloor = 410;      // 41cm

// base(parte 1)
float xBlock1 = 90;      // 9cm
float yBlock1 = 28;      // 2.8cm
float zBlock1 = 90;      // 9cm
float xOffsetB1 = 95;    // 9.5cm
float zOffsetB1 = 70;    // 7cm

// base(parte 2)
float xBlock2 = 25;      // 2.5cm
float yBlock2 = 42;      // 4.2cm
float zBlock2 = 90;      // 9cm
float xOffsetB2 = 95;    // 9.5cm
float zOffsetB2 = 70;    // 7cm

float yOffsetM1 = 17;    // 1.7cm

// gabbia motore1(parte 1)
float xBlock3 = 62;      // 6.2cm
float yBlock3 = 2;       // 0.2cm
float zBlock3 = 25;      // 2.5cm

// gabbia motore1(parte 2)
float xBlock4 = 2;       // 0.2cm
float yBlock4 = 54;      // 5.4cm
float zBlock4 = 25;      // 2.5cm

// gabbia motore1(parte 3)
float xBlock5 = 70;      // 7cm
float yBlock5 = 2;       // 0.2cm
float zBlock5 = 25;      // 2.5cm

float xOffsetM2 = 4.5;   // 0.45cm

// gabbia motore2(parte 1)
float xBlock6 = 62;      // 6.2cm
float yBlock6 = 25;      // 2.5cm
float zBlock6 = 2;       // 0.2cm

// gabbia motore2(parte 2)
float xBlock7 = 2;       // 0.2cm
float yBlock7 = 25;      // 2.5cm
float zBlock7 = 54;      // 5.4cm

// gabbia motore2(parte 3)
float xBlock8 = 62;      // 6.2cm
float yBlock8 = 25;      // 2.5cm
float zBlock8 = 2;       // 0.2cm

// gabbia motore3(parte 1)
float xBlock9 = 62;      // 6.2cm
float yBlock9 = 25;      // 2.5cm
float zBlock9 = 2;       // 0.2cm

// gabbia motore3(parte 2)
float xBlock10 = 2;       // 0.2cm
float yBlock10 = 25;      // 2.5cm
float zBlock10 = 54;      // 5.4cm

// gabbia motore3(parte 3)
float xBlock11 = 62;      // 6.2cm
float yBlock11 = 25;      // 2.5cm
float zBlock11 = 2;       // 0.2cm

// gabbia motore4(parte 1)
float xBlock12 = 55;      // 5.5cm
float yBlock12 = 2;       // 0.2cm
float zBlock12 = 25;      // 2.5cm

// gabbia motore4(parte 2)
float xBlock13 = 2;       // 0.2cm
float yBlock13 = 27;      // 2.7cm
float zBlock13 = 25;      // 2.5cm

// gabbia motore4(parte 3)
float xBlock14 = 2;       // 0.2cm
float yBlock14 = 25;      // 2.5cm
float zBlock14 = 54;      // 5.4cm

// gabbia motore4(parte 4)
float xBlock15 = 62;      // 6.2cm
float yBlock15 = 25;      // 2.5cm
float zBlock15 = 2;       // 0.2cm

// gabbia motore4(parte 5)
float xBlock16 = 62;      // 6.2cm
float yBlock16 = 25;      // 2.5cm
float zBlock16 = 2;       // 0.2cm

float eyeY = 0;
float eyeX = 0;

float alpha = 0;
float[] thetaFictitious = new float[4];
float[] theta = new float[4];

boolean direction = true;

void setup(){
    size(626,626,P3D);
    stroke(255);
    strokeWeight(2);
    smooth();
   
    xBase = width/2;
    yBase = 5*(height/6);
    zBase = -180;
    
    thetaFictitious[0] = PI/2;
    thetaFictitious[1] = 0;
    thetaFictitious[2] = PI/2;
    thetaFictitious[3] = PI/2;
    
    theta[0] = 0;
    theta[1] = 0;
    theta[2] = 0;
    theta[2] = 0;
}

void draw(){
    background(0);
    lights();
    
    camera((width/2.0) - eyeX, height/2 - eyeY, (height/2.0) / tan(PI*60.0 / 360.0), width/2.0, height/2.0, 0, 0, 1, 0);
    
    if (keyPressed) {
        // movimento camera
        if (key == 's') {
            eyeY -= 5;
        }
        if (key == 'w') {
            eyeY += 5;
        }
        if (key == 'a') {
            eyeX -= 5;
        }
        if (key == 'd') {
            eyeX += 5;
        }
        
        // rotazionesu intorno asse verticale
        if(keyCode == RIGHT) {
            alpha += PI/180;
        }
        if (keyCode == LEFT) {
            alpha -= PI/180;
        }
        
        // movimento lungo asse z
        if (keyCode == UP) {
            zBase+=15;
        }
        if (keyCode == DOWN) {
            zBase-=5;
        }
        
        // verso rotazione motori
        if (key == 'q') {
            direction = !direction;
            delay(500);
        }
        
        // rotazione motore1
        if (key == '1') {
            if (direction == true && theta[0] < PI/2) {
                theta[0]+= PI/180;
            }
            if (direction == false && theta[0] > -PI/2) {
                theta[0]-= PI/180;
            }
        }
        
        // rotazione motore2
        if (key == '2') {
            if (direction == true && theta[1] < 0) {
                theta[1]+= PI/180;
            }
            if (direction == false && theta[1] > -PI) {
                theta[1]-= PI/180;
            }
        }
        
        // rotazione motore3
        if (key == '3') {
            if (direction == true && theta[2] < PI/2) {
                theta[2]+= PI/180;
            }
            if (direction == false && theta[2] > -PI/2) {
                theta[2]-= PI/180;
            }
        }
        
        // rotazione motore3
        if (key == '4') {
            if (direction == true && theta[3] < PI/2) {
                theta[3]+= PI/180;
            }
            if (direction == false && theta[3] > -PI/2) {
                theta[3]-= PI/180;
            }
        }
    }
    
    if(mousePressed){
        xBase = mouseX;
        yBase = mouseY;
    }
    
    // parametri stampati su schermo
    textSize(25);
    fill(#00FF00); // colore parametri camera 
    text("coordinata y vista:",10,25); 
    text(eyeY,250,25);
    text("coordinata x vista:",10,50); 
    text(eyeX,250,50);
    fill(#FF9100); // colore parametri theta
    text("theta[0]:",10,75);
    text(int(180*(theta[0]+thetaFictitious[0])/PI) + "°",250,75);
    text("theta[1]:",10,100);
    text(int(180*(theta[1])/PI) + "°",250,100);
    text("theta[2]:",10,125);
    text(int(180*(theta[2]+thetaFictitious[2])/PI) + "°",250,125);
    text("theta[3]:",10,150);
    text(int(180*(theta[3]+thetaFictitious[3])/PI) + "°",250,150);
  
    // pavimento
    fill(#E5E06D);  // colore del pavimento
    translate(xBase,yBase,zBase);
    rotateY(alpha);
    box(xFloor,yFloor,zFloor);
    
    // base
    fill(#C4C0C0);  // colore del robot
    translate(-xFloor/2+xBlock1/2+xOffsetB1,-(yFloor/2+yBlock1/2),-zFloor/2+zBlock1/2+zOffsetB1);
    box(xBlock1,yBlock1,zBlock1);  
    translate(-xBlock1/2+xBlock2/2,-(yBlock1/2+yBlock2/2),0);
    box(xBlock2,yBlock2,zBlock2);
    
    //motore1
    fill(#000000);  // colore motore
    translate(xBlock2/2+motorDepth/2,-yOffsetM1,0);
    box(motorDepth,motorHeight,motorWidth);
    fill(#A09908);  // colore ingranaggio
    translate(0,-(motorHeight/2+gearHeight/2),gearOffset);
    rotateY(theta[0]);  // asse rotazione motore1
    box(gearDepth,gearHeight,gearWidth);
      
    // gabbia motore1
    fill(#C4C0C0);  // colore del robot
    translate(xBlock3/2-motorDepth/2,motorHeight+yBlock3/2+gearHeight/2,0);
    box(xBlock3,yBlock3,zBlock3);    
    translate(xBlock3/2-xBlock4/2,-yBlock4/2+yBlock3/2,0);
    box(xBlock4,yBlock4,zBlock4);    
    translate(-xBlock5/2+xBlock4/2,-yBlock4/2+yBlock5/2,0);
    box(xBlock5,yBlock5,zBlock5);
    
    //motore2
    fill(#000000);  // colore motore
    translate(-xOffsetM2,-(motorDepth/2+yBlock5/2),-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
    fill(#A09908);  // colore ingranaggio
    translate(-gearOffset,0,motorHeight/2+gearHeight/2);
    rotateZ(theta[1]);  // asse rotazione motore2
    box(gearWidth,gearDepth,gearHeight);
    
    // gabbia motore2
    fill(#C4C0C0);  // colore del robot
    translate(xBlock6/2-motorDepth/2,0,gearHeight/2-zBlock6/2);
    box(xBlock6,yBlock6,zBlock6);    
    translate(xBlock6/2-xBlock7/2,0,-zBlock7/2+zBlock6/2);
    box(xBlock7,yBlock7,zBlock7);    
    translate(-xBlock8/2+xBlock7/2,0,-zBlock7/2+zBlock8/2);
    box(xBlock8,yBlock8,zBlock8);
    
    // gabbia motore3
    translate(xBlock8,0,0);
    box(xBlock9,yBlock9,zBlock9);
    translate(-xBlock9/2+xBlock10/2,0,zBlock10/2-zBlock9/2);
    box(xBlock10,yBlock10,zBlock10);
    pushMatrix(); // memorizzo il sistema attuale
    translate(xBlock11/2+xBlock10/2,0,zBlock10/2-zBlock11/2);
    box(xBlock11,yBlock11,zBlock11);
    popMatrix();  // Ritorno al sistema di riferimento memorizzato
    
    // motore3
    fill(#A09908);  // colore ingranaggio
    translate(xBlock11-motorDepth/2,0,zBlock10/2-gearHeight/2);
    rotateZ(theta[2]);  // asse rotazione motore3
    box(gearWidth,gearDepth,gearHeight);
    fill(#000000);  // colore motore
    translate(gearOffset,0,-motorHeight/2-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
    
    //gabbia motore4
    fill(#C4C0C0);  // colore del robot
    translate((xBlock12-motorWidth)/2,motorDepth/2+yBlock12/2, (gearHeight-zBlock11)/2);
    box(xBlock12,yBlock12,zBlock12);
    translate(xBlock12/2-xBlock13/2,-yBlock13/2+yBlock12/2,0);
    box(xBlock13,yBlock13,zBlock13);
    translate(xBlock13,-yBlock12/2,0);
    box(xBlock14,yBlock14,zBlock14);
    /*pushmatrix sta alcentro quindi mi è comodo per dopo*/
    pushMatrix();
    translate(xBlock15/2-xBlock14/2,0,-zBlock14/2+zBlock15/2);
    box(xBlock15,yBlock15,zBlock15);
    translate(0,0,zBlock14-zBlock16);
    box(xBlock16,yBlock16,zBlock16);
    popMatrix();
    
    // motore4
    fill(#A09908);  // colore ingranaggio
    translate(xBlock16-motorDepth/2,0,zBlock14/2-gearHeight/2);
    rotateZ(theta[3]);  // asse rotazione motore4
    box(gearWidth,gearDepth,gearHeight);
    fill(#000000);  // colore motore
    translate(gearOffset,0,-motorHeight/2-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
}
