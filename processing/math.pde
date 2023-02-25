int DOF = 5;
float[] theta_d = new float[DOF];
float sign_d = -1;    // gomito alto(-1)/basso(+1)

int TITLE_COLOR = #CB0808;
int THETA_COLOR = #F2E442;
int VAR_COLOR = #C1C1B9;
int POS_COLOR = #2279F0;

float[] tempDenHart = new float[DOF];
float[] thetaDenHartOld = new float[DOF];
float[] thetaDenavitHartenberg = new float[DOF];

float[] inverseKinematic(float x_d, float y_d, float z_d, float B_d, float W_d) {
  //******************************************************************************/
  // La cinematica è stata ricavata per un robot Scorbot con una 
  // struttura diversa da quella dello Scorbot classico.
  // Siccome la diferenza strutturale era relativa unicamente al montaggio 
  // dell'ultima estremità del braccio, formata dal motore 5 e 6 (si veda il 
  // disegno del robot su processing per osservarne la forma) la cinematica 
  // è stata interamente riprogettata
  /******************************************************************************/

     //<>//
  // Calcolo theta 1
  float theta1_primo = atan2(y_d, x_d);
  theta_d[0] = atan2(y_d + d4*cos(theta1_primo), x_d - d4*sin(theta1_primo));
  
  // Calcolo A1 e A2
  float A1 = x_d*cos(theta_d[0]) + y_d*sin(theta_d[0]) - a4*sin(B_d) - d5*cos(B_d);
  float A2 = z_d - a4*cos(B_d) + d5*sin(B_d) - d1;  
  
  // Calcolo theta 3
  float num = pow(A1, 2) + pow(A2, 2) - pow(l2, 2) - pow(l3, 2);
  float den = 2*l2*l3;
  theta_d[2] = sign_d*acos(num/den);
  
  // Calcolo theta 2
  float S_2 = (l2 + l3*cos(theta_d[2]))*A2 - l3*sin(theta_d[2])*A1;
  float C_2 = (l2 + l3*cos(theta_d[2]))*A1 + l3*sin(theta_d[2])*A2;
  
  theta_d[1] = atan2(S_2, C_2);
  
  // Calcolo theta 4
  theta_d[3] = PI/2 - theta_d[1] - theta_d[2] - B_d;
  
  // Calcolo theta 5
  theta_d[4] = W_d;
  
  
  fill(TITLE_COLOR);
  textSize(30);
  text("INPUT", 780, 25);
  textSize(25);
  fill(POS_COLOR);
  text("x_d: " + nf(x_d, 0, 2), 780, 50);
  text("y_d: " + nf(y_d, 0, 2), 780, 75);
  text("z_d: " + nf(z_d, 0, 2), 780, 100);
  fill(VAR_COLOR);
  text("B_d: " + nf(deg(B_d), 0, 2), 780, 125);
  text("W_d: " + nf(deg(W_d), 0, 2), 780, 150);
  text("d1: "  + nf(d1,0, 2), 780, 175);
  text("l2: "  + nf(l2,0, 2), 780, 200);
  text("l3: "  + nf(l3,0, 2), 780, 225);
  text("d5: "  + nf(d5,0, 2), 780, 250);
  
  
  fill(TITLE_COLOR);
  textSize(30);
  text("OUTPUT(I.K.)", 920, 25);
  textSize(25);
  fill(THETA_COLOR);
  text("theta_1: " + nf(deg(theta_d[0]), 0, 2), 920, 50);
  fill(VAR_COLOR);
  text("A1: " + nf(A1, 0, 2), 920, 75);
  text("A2: " + nf(A2, 0, 2), 920, 100);
  text("num: " + nf(num, 0, 2), 920, 125);
  text("den: " + nf(den, 0, 2), 920, 150);
  text("num/den: " + nf(num/den, 0, 2), 920, 175);
  fill(THETA_COLOR);
  text("theta_3: " + nf(deg(theta_d[2]), 0, 2), 920, 200);
  fill(VAR_COLOR);
  text("S_2: " + nf(S_2, 0, 2), 920, 225);
  text("C_2: " + nf(C_2, 0, 2), 920, 250);
  fill(THETA_COLOR);
  text("theta_2: " + nf(deg(theta_d[1]), 0, 2), 920, 275);
  text("theta_4: " + nf(deg(theta_d[3]), 0, 2), 920, 300);
  text("theta_5: " + nf(deg(theta_d[4]), 0, 2), 920, 325);
  
  
  // calcolo cinematica diretta per verifica
  float c1 = cos(theta_d[0]);
  float c2 = cos(theta_d[1]);
  float c23 = cos(theta_d[1]+theta_d[2]);
  float c234 = cos(theta_d[1]+theta_d[2]+theta_d[3]);
  
  float s1 = sin(theta_d[0]);
  float s2 = sin(theta_d[1]);
  float s23 = sin(theta_d[1]+theta_d[2]);
  float s234 = sin(theta_d[1]+theta_d[2]+theta_d[3]);
  
  float Xd = c1*( a4*c234 + l3*c23 + l2*c2 +d5*s234 ) + d4*s1;
  float Yd = s1*( a4*c234 + l3*c23 + l2*c2 +d5*s234 ) - d4*c1;
  float Zd = a4*s234 + l3*s23 +l2*s2 + d1 - d5*c234;
  
  //float Xd = cos(theta_d[0])*(  d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  //float Yd = sin(theta_d[0])*(  d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  //float Zd = -d5*cos(theta_d[1]+theta_d[2]+theta_d[3]) + l3*sin(+theta_d[1]+theta_d[2]) + l2*sin(theta_d[1]) + d1;

  fill(TITLE_COLOR);
  textSize(30);
  text("CHECK(D.K.)", 1120, 25);
  textSize(25);
  fill(POS_COLOR);
  text("Xd: " + nf(Xd, 0, 2), 1120, 50);
  text("Yd: " + nf(Yd, 0, 2), 1120, 75);
  text("Zd: " + nf(Zd, 0, 2), 1120, 100);
  
  
  return theta_d; 
}


float rad(float degrees) {
  return degrees * PI/180.0;
}


float deg(float radians) {
  return radians * 180.0/PI;
}
