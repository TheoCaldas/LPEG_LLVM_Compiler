@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define double @foo() {
  ret double 3.400000
}
define i32 @main() {
  %T0 = call double @foo()
  %T1 = call double @foo()
  %T2 = fadd double %T0, %T1
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T2)
  ret i32 0
}
