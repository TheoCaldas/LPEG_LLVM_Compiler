@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define double @foo(double %T0, double %T1, i32 %T2) {
  %T3 = alloca double
  store double %T0, double* %T3
  %T4 = alloca double
  store double %T1, double* %T4
  %T5 = alloca i32
  store i32 %T2, i32* %T5
  %T6 = load i32, i32* %T5
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T6)
  %T7 = load double, double* %T3
  %T8 = load double, double* %T4
  %T9 = fadd double %T7, %T8
  ret double %T9
}

define i32 @main() {
  %T10 = fneg double 2.352352300000000e+02
  %T11 = alloca double
  store double %T10, double* %T11
