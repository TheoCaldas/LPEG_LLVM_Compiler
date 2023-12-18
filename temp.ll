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
  %T4 = load ptr, ptr %T3
  %T6 = sext i32 0 to i64
  %T5 = getelementptr inbounds i32, ptr %T4, i64 %T6
  store i32 3, ptr %T5
  %T7 = load ptr, ptr %T3
  %T9 = sext i32 1 to i64
  %T8 = getelementptr inbounds i32, ptr %T7, i64 %T9
  store i32 2, ptr %T8
  %T10 = load ptr, ptr %T3
  %T12 = sext i32 2 to i64
  %T11 = getelementptr inbounds i32, ptr %T10, i64 %T12
  store i32 1, ptr %T11
  %T13 = load ptr, ptr %T3
  %T15 = sext i32 0 to i64
  %T14 = getelementptr inbounds i32, ptr %T13, i64 %T15
  %T16 = load i32, ptr %T14
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T16)
  %T17 = load ptr, ptr %T3
  %T19 = sext i32 1 to i64
  %T18 = getelementptr inbounds i32, ptr %T17, i64 %T19
  %T20 = load i32, ptr %T18
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T20)
  %T21 = load ptr, ptr %T3
  %T23 = sext i32 2 to i64
  %T22 = getelementptr inbounds i32, ptr %T21, i64 %T23
  %T24 = load i32, ptr %T22
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T24)
  ret i32 0
}

