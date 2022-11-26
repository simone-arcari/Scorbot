float[] theta_d =new float[5];
float sign_d = 1;    // gomito alto/basso

float rad(float degrees) {
  return degrees * PI/180.0;
}


float deg(float radians) {
  return radians * 180.0/PI;
}

float[] invKinematic(float x_d, float y_d, float z_d, float B_d, float W_d) {
  
  theta_d[0] = atan2(y_d, x_d);
  
  float A1 = x_d*cos(theta_d[0]) + y_d*sin(theta_d[0]) -d5*sin(PI/2 - B_d);
  float A2 = z_d + d5*cos(PI/2 - B_d) - d1;
  
  float num = pow(A1, 2) + pow(A2, 2) - pow(l2, 2) - pow(l3, 2);
  float den = 2*l2*l3;
  theta_d[2] = sign_d*acos(num/den);
  
   
  
  
  return theta_d;
    
}
