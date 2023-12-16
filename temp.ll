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
  ret i32 0
}

