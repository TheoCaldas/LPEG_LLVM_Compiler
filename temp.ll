@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define i32 @main() {
  %T0 = sitofp i32 1 to double
  %T1 = fmul double %T0, 3.900000000000000e+00
  %T2 = fadd double 2.500000000000000e+00, %T1
  %T3 = sitofp i32 5 to double
  %T4 = fadd double %T2, %T3
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T4)
  %T5 = sitofp i32 1 to double
  %T6 = fadd double %T5, 4.500000000000000e+00
  %T7 = alloca double
  store double %T6, double* %T7
  %T8 = alloca i32
  store i32 1, i32* %T8
  %T9 = load double, double* %T7
  %T10 = sitofp i32 3 to double
  %T11 = fadd double %T9, %T10
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T11)
  %T12 = load double, double* %T7
  %T13 = fptosi double %T12 to i32
  %T14 = load i32, i32* %T8
  %T15 = sitofp i32 %T14 to double
  %T16 = sitofp i32 %T13 to double
  %T17 = fadd double %T16, %T15
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T17)
  ret i32 0
}

