int DOF = 5;
float[] theta_d = new float[DOF];
float sign_d = -1;    // gomito alto(-1)/basso(+1)

int THETA_COLOR = #F2E442;
int VAR_COLOR = #C1C1B9;


float[] inverseKinematic(float x_d, float y_d, float z_d, float B_d, float W_d) {
  //DEBUG-->
  float d1 = 30; //<>//
  float l2 = 20;
  float l3 = 20;
  float d5 = 10;
  
  // Calcolo theta 1
  theta_d[0] = atan2(y_d, x_d);
  
  // Calcolo A1 e A2
  float A1 = x_d*cos(theta_d[0]) + y_d*sin(theta_d[0]) -d5*sin(PI/2 - B_d);
  float A2 = z_d + d5*cos(PI/2 - B_d) - d1;
  
  // Calcolo theta 3
  float num = pow(A1, 2) + pow(A2, 2) - pow(l2, 2) - pow(l3, 2);
  float den = 2*l2*l3;
  theta_d[2] = sign_d*acos(num/den);
  
  // Calcolo theta 2
  float S = (l2 + l3*cos(theta_d[2]))*A2 - l3*sin(theta_d[2])*A1;
  float C = (l2 + l3*sin(theta_d[2]))*A1 + l3*sin(theta_d[2])*A2;
  theta_d[1] = atan2(S, C);
  
  // Calcolo theta 4
  theta_d[3] = PI/2 - theta_d[1] - theta_d[2] - B_d;
  
  // Calcolo theta 5
  theta_d[4] = W_d;
  
  
  fill(THETA_COLOR);
  text("theta_1: " + deg(theta_d[0]), 1000, 25);
  fill(VAR_COLOR);
  text("A1: " + A1, 1000, 50);
  text("A2: " + A2, 1000, 75);
  text("num: " + num, 1000, 100);
  text("den: " + den, 1000, 125);
  text("den/num: " + num/den, 1000, 150);
  fill(THETA_COLOR);
  text("theta_3: " + deg(theta_d[2]), 1000, 175);
  fill(VAR_COLOR);
  text("S: " + S, 1000, 200);
  text("C: " + C, 1000, 225);
  fill(THETA_COLOR);
  text("theta_2: " + deg(theta_d[1]), 1000, 250);
  text("theta_4: " + deg(theta_d[3]), 1000, 275);
  text("theta_5: " + deg(theta_d[4]), 1000, 300);
  
  
  return theta_d; 
}


float rad(float degrees) {
  return degrees * PI/180.0;
}


float deg(float radians) {
  return radians * 180.0/PI;
}
