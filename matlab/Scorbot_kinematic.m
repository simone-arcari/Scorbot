%% Inizializzazione
clear all
close all
clc

%% Parametri strutturali Scorbot
d1 = 30;
l2 = 20;
l3 = 20;
a4 = 30;
d5 = 10;

%% Posizione e orientamento desiderati
x_d = -20;
y_d = 30;
z_d = 20;

gomito = 1;

beta_d = 40*pi/180;
omega_d = 10*pi/180;

%% Calcolo cinematica inversa

% calcolo theta1
theta1 = atan2(y_d, x_d);

% calcolo A1 e A2
A1 = x_d*cos(theta1) + y_d*sin(theta1) - a4*sin(beta_d) - d5*cos(beta_d);
A2 = z_d - a4*cos(beta_d) + d5*sin(beta_d) - d1;

% calcolo theta3
num = A1^2 + A2^2 - l2^2 - l3^2;
den = 2*l2*l3;
theta3 = gomito*acos(num/den);

% calcolo theta2
S_2 = (l2 + l3*cos(theta3))*A2 - l3*sin(theta3)*A1;
C_2 = (l2 + l3*cos(theta3))*A1 + l3*sin(theta3)*A2;
theta2 = atan2(S_2, C_2);

% calcolo theta4
theta4 = pi/2 - theta2 - theta3 - beta_d;

%calcolo theta5
theta5 = omega_d;

%% Stampa dei risultati in gradi

fprintf("---> theta1 = %f\n\n", theta1*180/pi);
fprintf("---> theta2 = %f\n\n", theta2*180/pi);
fprintf("---> theta3 = %f\n\n", theta3*180/pi);
fprintf("---> theta4 = %f\n\n", theta4*180/pi);
fprintf("---> theta5 = %f\n\n", theta5*180/pi);

%% Calcolo della cinematica diretta per verifica

% variabili ausiliarie
c1 = cos(theta1);
c2 = cos(theta2);
c23 = cos(theta2 + theta3);
c234 = cos(theta2 + theta3 + theta4);
  
s1 = sin(theta1);
s2 = sin(theta2);
s23 = sin(theta2 + theta3);
s234 = sin(theta2 + theta3 + theta4);

% calcolo effettivo cinematica diretta
Xd = c1*( a4*c234 + l3*c23 + l2*c2 + d5*s234 );
Yd = s1*( a4*c234 + l3*c23 + l2*c2 + d5*s234 );
Zd = a4*s234 + l3*s23 +l2*s2 + d1 - d5*c234;

%% Comparazione dei risulati

fprintf("x_d(inizile) = %f || Xd(cinematica diretta) = %f\n\n", x_d, Xd)
fprintf("y_d(inizile) = %f || Yd(cinematica diretta) = %f\n\n", y_d, Yd)
fprintf("z_d(inizile) = %f || Zd(cinematica diretta) = %f\n\n", z_d, Zd)

%% Sezione EXTRA

c1 = cos(theta1);
c2 = cos(theta2);
c3 = cos(theta3);
c4 = cos(theta4);
c5 = cos(theta4);

s1 = sin(theta1);
s2 = sin(theta2);
s3 = sin(theta3);
s4 = sin(theta4);
s5 = sin(theta4);

T01 = [c1 0 s1 0; s1 0 -c1 0; 0 1 0 d1; 0 0 0 1];

T12 = [c2 -s2 0 l2*c2; s2 c2 0 l2*s2; 0 0 1 0; 0 0 0 1];

T23 = [c3 -s3 0 l3*c3; s3 c3 0 l3*s3; 0 0 1 0; 0 0 0 1];

T34 = [c4 0 s4 a4*c4; s4 0 -c4 a4*s4; 0 1 0 0; 0 0 0 1];

T45 = [c5 -s5 0 0; s5 c5 0 0; 0 0 1 d5; 0 0 0 1];

% matrice del cambiamento delle coordinate da O_0 a O_5
fprintf("La matrice del cambiamneto delle coordinate risulta:\n")
T05 = T01*T12*T23*T34*T45
