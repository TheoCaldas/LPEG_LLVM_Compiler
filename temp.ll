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

define double @fsqrt(double %T12) {
  %T13 = alloca double
  store double %T12, double* %T13
  %T14 = load double, double* %T13
  %T15 = alloca double
  store double %T14, double* %T15
  %T16 = alloca double
  store double 0.000000, double* %T16
  br label %L17
  L17:
  %T20 = load double, double* %T13
  %T21 = load double, double* %T15
  %T22 = load double, double* %T15
  %T23 = fmul double %T21, %T22
  %T24 = fsub double %T20, %T23
  %T25 = call double @fabs(double %T24)
  %T26 = load double, double* %T16
  %T27 = fcmp ogt double %T25, %T26
  %T28 = zext i1 %T27 to i32
  %T29 = icmp ne i32 %T28, 0
  br i1 %T29, label %L18, label %L19
  L18:
  %T30 = load double, double* %T15
  %T31 = load double, double* %T13
  %T32 = load double, double* %T15
  %T33 = fdiv double %T31, %T32
  %T34 = fadd double %T30, %T33
  %T35 = fdiv double %T34, 2.000000
  store double %T35, double* %T15
  br label %L17
  L19:
  %T36 = load double, double* %T15
  ret double %T36
}

define i32 @main() {
  %T37 = call double @fsqrt(double 4.000000)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T37)
  %T38 = call double @fsqrt(double 9.000000)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T38)
  %T39 = call double @fsqrt(double 16.000000)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T39)
  %T40 = call double @fsqrt(double 25.000000)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T40)
  %T41 = call double @fsqrt(double 1244.214124)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T41)
  ret i32 0
}

