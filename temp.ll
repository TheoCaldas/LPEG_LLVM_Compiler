@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define double @fabs(double %T0) {
  %T1 = alloca double
  store double %T0, double* %T1
  %T5 = load double, double* %T1
  %T6 = fcmp olt double %T5, 0.000000
  %T7 = zext i1 %T6 to i32
  %T8 = icmp ne i32 %T7, 0
  br i1 %T8, label %L2, label %L3
  L2:
  %T9 = load double, double* %T1
  %T10 = fneg double %T9
  ret double %T10
  br label %L3
  L3:
  %T11 = load double, double* %T1
  ret double %T11
}
define i32 @main() {
  %T12 = fneg double 3.400000
  %T13 = call double @fabs(double %T12)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T13)
  ret i32 0
}
