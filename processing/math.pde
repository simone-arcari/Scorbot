int DOF = 5;
float[] theta_d = new float[DOF];
float sign_d = -1;    // gomito alto(-1)/basso(+1)

int THETA_COLOR = #F2E442;
int VAR_COLOR = #C1C1B9;


float[] inverseKinematic(float x_d, float y_d, float z_d, float B_d, float W_d) {
  //DEBUG-->
  //float d1 = 30; //<>//
  //float l2 = 20;
  //float l3 = 20;
  //float d5 = 10;
  
  // Calcolo theta 1
  theta_d[0] = atan2(y_d, x_d);
  
  // Calcolo A1 e A2
  float A1 = x_d*cos(theta_d[0]) + y_d*sin(theta_d[0]) - d5*cos(B_d);
  float A2 = z_d + d5*sin(B_d) - d1;
  //float A1 = x_d*cos(theta_d[0]) + y_d*sin(theta_d[0]) - d5*cos(B_d);
  //float A2 = d1 - z_d + - d5*sin(B_d);
  
  
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
  //theta_d[3] = B_d - theta_d[1] - theta_d[2] - PI/2;
  
  // Calcolo theta 5
  theta_d[4] = W_d;
  
  text("x_d: " + x_d, 800, 25);
  text("y_d: " + y_d, 800, 50);
  text("z_d: " + z_d, 800, 75);
  text("B_d: " + deg(B_d), 800, 100);
  text("W_d: " + deg(W_d), 800, 125);
  text("d1: " + d1, 800, 150);
  text("l2: " + l2, 800, 175);
  text("l2: " + l3, 800, 200);
  text("d5: " + d5, 800, 225);
  
  
  
  
  fill(THETA_COLOR);
  text("theta_1: " + deg(theta_d[0]), 1000, 25);
  fill(VAR_COLOR);
  text("A1: " + A1, 1000, 50);
  text("A2: " + A2, 1000, 75);
  text("num: " + num, 1000, 100);
  text("den: " + den, 1000, 125);
  text("num/den: " + num/den, 1000, 150);
  fill(THETA_COLOR);
  text("theta_3: " + deg(theta_d[2]), 1000, 175);
  fill(VAR_COLOR);
  text("S_2: " + S_2, 1000, 200);
  text("C_2: " + C_2, 1000, 225);
  fill(THETA_COLOR);
  text("theta_2: " + deg(theta_d[1]), 1000, 250);
  text("theta_4: " + deg(theta_d[3]), 1000, 275);
  text("theta_5: " + deg(theta_d[4]), 1000, 300);
  
  
  
  float Xd = cos(theta_d[0])*(  d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  float Yd = sin(theta_d[0])*(  d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  float Zd = -d5*cos(theta_d[1]+theta_d[2]+theta_d[3]) + l3*sin(+theta_d[1]+theta_d[2]) + l2*sin(theta_d[1]) + d1;
  //float Xd = cos(theta_d[0])*(  -d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  //float Yd = sin(theta_d[0])*(  -d5*sin(theta_d[1]+theta_d[2]+theta_d[3]) + l3*cos(theta_d[1]+theta_d[2]) + l2*cos(theta_d[1])  );
  //float Zd = -d5*cos(theta_d[1]+theta_d[2]+theta_d[3]) - l3*sin(theta_d[1]+theta_d[2]) - l2*sin(theta_d[1]) + d1;
  
  fill(#FA0F0F);
  text("Xd: " + round(Xd), 1000, 325);
  text("Yd: " + round(Yd), 1000, 350);
  text("Zd: " + round(Zd), 1000, 375);
  
  
  
  return theta_d; 
}


float rad(float degrees) {
  return degrees * PI/180.0;
}


float deg(float radians) {
  return radians * 180.0/PI;
}
