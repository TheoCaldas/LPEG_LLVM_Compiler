@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define i32 @main() {
  %T0 = mul i32 4, 4
  %T1 = sext i32 %T0 to i64
  %T2 = call ptr @malloc(i64 %T1)
  %T3 = alloca ptr
  store ptr %T2, ptr %T3
  %T4 = alloca i32
  store i32 3, ptr %T4
  %T5 = load i32, ptr %T4
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T5)
  ret i32 0
}

