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
  %T8 = call double @step(i32 4)
  %T9 = fadd double %T8, 4.200000000000000e+00
  br label %L10
  L10:
  %T13 = load double, ptr %T5
  %T14 = fcmp ole double %T13, 8.009999999999999e+01
  %T15 = zext i1 %T14 to i32
  %T16 = icmp ne i32 %T15, 0
  br i1 %T16, label %L11, label %L12
    L11:
  %T17 = load double, ptr %T5
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T17)
  %T18 = load double, ptr %T5
  %T19 = fadd double %T18, %T9
  store double %T19, ptr %T5
  br label %L10
  L12:
  ret i32 0
}

