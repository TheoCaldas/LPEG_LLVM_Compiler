@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define i32 @main() {
  %T0 = alloca double
  store double 0.100000, double* %T0
  br label %L1
  L1:
  %T4 = load double, double* %T0
  %T5 = fsub double %T4, 1.000000
  %T6 = fmul double 10.000000, 2.000000
  %T7 = fcmp olt double %T5, %T6
  %T8 = zext i1 %T7 to i32
  %T9 = icmp ne i32 %T8, 0
  br i1 %T9, label %L2, label %L3
  L2:
  %T10 = load double, double* %T0
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T10)
  %T11 = load double, double* %T0
  %T12 = fadd double %T11, 1.300000
  store double %T12, double* %T0
  br label %L1
  L3:
  ret i32 0
}
