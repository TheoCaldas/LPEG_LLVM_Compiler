@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define i32 @main() {
  %T0 = alloca double
  store double 1.230000000000000e+00, ptr %T0
  %T1 = alloca double
  store double 2.240000000000000e+00, ptr %T1
  %T2 = alloca i32
  store i32 9, ptr %T2
  %T3 = load double, ptr %T0
  %T4 = load double, ptr %T1
  %T5 = fadd double %T3, %T4
  %T6 = load double, ptr %T0
  %T7 = sitofp i32 3 to double
  %T8 = fmul double %T6, %T7
  %T9 = fadd double %T8, 3.400000000000000e+00
  %T10 = load i32, ptr %T2
  %T11 = sitofp i32 %T10 to double
  %T12 = fdiv double %T9, %T11
  %T13 = fadd double %T5, %T12
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T13)
  ret i32 0
}

