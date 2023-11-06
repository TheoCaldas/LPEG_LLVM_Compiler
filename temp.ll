@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define i32 @main() {
  %T0 = sitofp i32 1 to double
  %T1 = fadd double 2.500000000000000e+00, %T0
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T1)
  %T2 = add i32 1, 3
  %T3 = sitofp i32 %T2 to double
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T3)
  %T4 = fptosi double 1.500000000000000e+00 to i32
  %T5 = add i32 2, %T4
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T5)
  %T6 = fadd double 1.300000000000000e+00, 3.400000000000000e+00
  %T7 = fptosi double %T6 to i32
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T7)
  ret i32 0
}

