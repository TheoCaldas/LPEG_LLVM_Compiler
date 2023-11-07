@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define i32 @main() {
  %T0 = add i32 4, 3
  %T1 = sitofp i32 1 to double
  %T2 = fdiv double %T1, 3.000000000000000e+00
  %T3 = sub i32 0, 5
  %T4 = sitofp i32 %T3 to double
  %T5 = fmul double %T2, %T4
  %T6 = fmul double %T5, 3.420000000000000e+01
  %T7 = sitofp i32 %T0 to double
  %T8 = fadd double %T7, %T6
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T8)
  %T9 = mul i32 78, 13
  %T10 = fneg double 3.140000000000000e+00
  %T11 = fmul double 9.414000000000000e+00, %T10
  %T12 = sitofp i32 1 to double
  %T13 = fadd double %T12, %T11
  %T14 = sitofp i32 %T9 to double
  %T15 = fdiv double %T14, %T13
  %T16 = sitofp i32 99 to double
  %T17 = fmul double 4.212421400000000e+01, %T16
  %T18 = fadd double 8.400000000000000e+00, %T17
  %T19 = sitofp i32 31 to double
  %T20 = fsub double %T18, %T19
  %T21 = fcmp oge double %T15, %T20
  %T22 = zext i1 %T21 to i32
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T22)
  ret i32 0
}

