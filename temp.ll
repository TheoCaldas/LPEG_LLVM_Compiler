@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define double @foo(i32 %T0, i32 %T1) {
  %T2 = alloca i32
  store i32 %T0, i32* %T2
  %T3 = alloca i32
  store i32 %T1, i32* %T3
  %T4 = load i32, i32* %T2
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T4)
  %T5 = load i32, i32* %T3
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T5)
  ret double 3.400000
}
define i32 @main() {
  %T6 = alloca i32
  store i32 3, i32* %T6
  %T7 = alloca i32
  store i32 4, i32* %T7
  %T8 = load i32, i32* %T6
  %T9 = load i32, i32* %T7
  %T10 = call double @foo(i32 %T8, i32 %T9)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T10)
  ret i32 0
}
