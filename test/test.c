#include <stdio.h>

double add(double a, double b){return a + b;}
double sub(double a, double b){return a - b;}
double mul(double a, double b){return a * b;}
double div(double a, double b){return a / b;}

void p(double a){printf("%f\n", a);}
int main(){
    p(3.3);
    return 0;
}