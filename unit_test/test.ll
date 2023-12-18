@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define double @step(i32 %T0) {
  %T1 = alloca i32
  store i32 %T0, ptr %T1
  %T2 = load i32, ptr %T1
  %T3 = sitofp i32 %T2 to double
  %T4 = mul i32 %T3, 2.400000000000000e+00
  ret double %T4
}

define i32 @main() {
  %T5 = alloca double
  %T6 = sitofp i32 3 to double
  %T7 = mul i32 %T6, 4.300000000000000e+00
  store double %T7, ptr %T5
