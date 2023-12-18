@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define i32 @main() {
  %T0 = mul i32 8, 2
  %T1 = sext i32 %T0 to i64
  %T2 = call ptr @malloc(i64 %T1)
  %T3 = alloca ptr
  store ptr %T2, ptr %T3
  %T4 = mul i32 4, 2
  %T5 = sext i32 %T4 to i64
  %T6 = call ptr @malloc(i64 %T5)
  %T7 = load ptr, ptr %T3
  %T9 = sext i32 0 to i64
  %T8 = getelementptr inbounds ptr, ptr %T7, i64 %T9
  store ptr %T6, ptr %T8
  %T10 = mul i32 4, 2
  %T11 = sext i32 %T10 to i64
  %T12 = call ptr @malloc(i64 %T11)
  %T13 = load ptr, ptr %T3
  %T15 = sext i32 1 to i64
  %T14 = getelementptr inbounds ptr, ptr %T13, i64 %T15
  store ptr %T12, ptr %T14
  %T16 = load ptr, ptr %T3
  %T18 = sext i32 0 to i64
  %T17 = getelementptr inbounds ptr, ptr %T16, i64 %T18
  %T19 = load ptr, ptr %T17
  %T21 = sext i32 0 to i64
  %T20 = getelementptr inbounds i32, ptr %T19, i64 %T21
  store i32 1, ptr %T20
  %T22 = load ptr, ptr %T3
  %T24 = sext i32 0 to i64
  %T23 = getelementptr inbounds ptr, ptr %T22, i64 %T24
  %T25 = load ptr, ptr %T23
  %T27 = sext i32 1 to i64
  %T26 = getelementptr inbounds i32, ptr %T25, i64 %T27
  store i32 2, ptr %T26
  %T28 = load ptr, ptr %T3
  %T30 = sext i32 1 to i64
  %T29 = getelementptr inbounds ptr, ptr %T28, i64 %T30
  %T31 = load ptr, ptr %T29
  %T33 = sext i32 0 to i64
  %T32 = getelementptr inbounds i32, ptr %T31, i64 %T33
  store i32 3, ptr %T32
  %T34 = load ptr, ptr %T3
  %T36 = sext i32 1 to i64
  %T35 = getelementptr inbounds ptr, ptr %T34, i64 %T36
  %T37 = load ptr, ptr %T35
  %T39 = sext i32 1 to i64
  %T38 = getelementptr inbounds i32, ptr %T37, i64 %T39
  store i32 4, ptr %T38
  %T40 = load ptr, ptr %T3
  %T42 = sext i32 0 to i64
  %T41 = getelementptr inbounds ptr, ptr %T40, i64 %T42
  %T43 = load ptr, ptr %T41
  %T45 = sext i32 1 to i64
  %T44 = getelementptr inbounds i32, ptr %T43, i64 %T45
  %T46 = load i32, ptr %T44
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T46)
  %T47 = mul i32 4, 2
  %T48 = sext i32 %T47 to i64
  %T49 = call ptr @malloc(i64 %T48)
  %T50 = alloca ptr
  store ptr %T49, ptr %T50
  %T51 = load ptr, ptr %T3
  %T53 = sext i32 0 to i64
  %T52 = getelementptr inbounds ptr, ptr %T51, i64 %T53
  %T54 = load ptr, ptr %T52
  store ptr %T54, ptr %T50
  %T55 = load ptr, ptr %T50
  %T57 = sext i32 0 to i64
  %T56 = getelementptr inbounds i32, ptr %T55, i64 %T57
  %T58 = load i32, ptr %T56
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T58)
  %T59 = load ptr, ptr %T50
  %T61 = sext i32 0 to i64
  %T60 = getelementptr inbounds i32, ptr %T59, i64 %T61
  store i32 20, ptr %T60
  %T62 = load ptr, ptr %T50
  %T64 = sext i32 0 to i64
  %T63 = getelementptr inbounds i32, ptr %T62, i64 %T64
  %T65 = load i32, ptr %T63
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T65)
  %T66 = load ptr, ptr %T3
  %T68 = sext i32 0 to i64
  %T67 = getelementptr inbounds ptr, ptr %T66, i64 %T68
  %T69 = load ptr, ptr %T67
  %T71 = sext i32 0 to i64
  %T70 = getelementptr inbounds i32, ptr %T69, i64 %T71
  %T72 = load i32, ptr %T70
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T72)
  %T73 = load ptr, ptr %T3
  %T75 = sext i32 0 to i64
  %T74 = getelementptr inbounds ptr, ptr %T73, i64 %T75
  %T76 = load ptr, ptr %T74
  %T78 = sext i32 0 to i64
  %T77 = getelementptr inbounds i32, ptr %T76, i64 %T78
  store i32 23, ptr %T77
  %T79 = load ptr, ptr %T50
  %T81 = sext i32 0 to i64
  %T80 = getelementptr inbounds i32, ptr %T79, i64 %T81
  %T82 = load i32, ptr %T80
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T82)
  %T83 = load ptr, ptr %T3
  %T85 = sext i32 0 to i64
  %T84 = getelementptr inbounds ptr, ptr %T83, i64 %T85
  %T86 = load ptr, ptr %T84
  %T88 = sext i32 0 to i64
  %T87 = getelementptr inbounds i32, ptr %T86, i64 %T88
  %T89 = load i32, ptr %T87
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T89)
  ret i32 0
}

