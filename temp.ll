@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define i32 @main() {
  %T1 = mul i32 4, 4
  %T2 = sext i32 %T1 to i64
  %T0 = call ptr @malloc(i64 %T2)
  %T3 = alloca ptr
  store ptr %T0, ptr %T3
  %T5 = mul i32 4, 4
  %T6 = sext i32 %T5 to i64
  %T4 = call ptr @malloc(i64 %T6)
  %T7 = alloca ptr
  store ptr %T4, ptr %T7
  %T8 = alloca i32
  store i32 4, ptr %T8
  %T9 = sitofp i32 3 to double
  %T10 = sitofp i32 2 to double
  %T11 = fmul double %T9, %T10
  %T12 = alloca double
  store double %T11, ptr %T12
  %T13 = load double, double* %T12
  %T14 = load nil, nil* %T8
  %T15 = sitofp i32 %T14 to double
  %T16 = fadd double %T13, %T15
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T16)
  ret i32 0
}

