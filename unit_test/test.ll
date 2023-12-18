@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

declare ptr @malloc(i64)

define void @printArray(ptr %T0, i32 %T1) {
  %T2 = alloca ptr
  store ptr %T0, ptr %T2
  %T3 = alloca i32
  store i32 %T1, ptr %T3
  %T4 = alloca double
  %T5 = sitofp i32 0 to double
  store double %T5, ptr %T4
  %T6 = load i32, ptr %T3
  %T7 = sub i32 %T6, 1
  %T8 = sitofp i32 %T7 to double
  br label %L9
  L9:
  %T12 = load double, ptr %T4
  %T13 = fcmp ole double %T12, %T8
  %T14 = zext i1 %T13 to i32
  %T15 = icmp ne i32 %T14, 0
  br i1 %T15, label %L10, label %L11
    L10:
  %T16 = load ptr, ptr %T2
  %T17 = load double, ptr %T4
  %T18 = fptosi double %T17 to i32
  %T20 = sext i32 %T18 to i64
  %T19 = getelementptr inbounds i32, ptr %T16, i64 %T20
  %T21 = load i32, ptr %T19
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strI, i64 0, i64 0), i32 %T21)
  %T22 = load double, ptr %T4
  %T23 = fadd double %T22, 1.000000000000000e+00
  store double %T23, ptr %T4
  br label %L9
  L11:
  ret void
}

define void @fillWith(ptr %T24, i32 %T25, double %T26) {
  %T27 = alloca ptr
  store ptr %T24, ptr %T27
  %T28 = alloca i32
  store i32 %T25, ptr %T28
  %T29 = alloca double
  store double %T26, ptr %T29
  %T30 = alloca double
  %T31 = sitofp i32 0 to double
  store double %T31, ptr %T30
  %T32 = load i32, ptr %T28
  %T33 = sub i32 %T32, 1
  %T34 = sitofp i32 %T33 to double
  br label %L35
  L35:
  %T38 = load double, ptr %T30
  %T39 = fcmp ole double %T38, %T34
  %T40 = zext i1 %T39 to i32
  %T41 = icmp ne i32 %T40, 0
  br i1 %T41, label %L36, label %L37
    L36:
  %T42 = load double, ptr %T29
  %T43 = load ptr, ptr %T27
  %T44 = load double, ptr %T30
  %T45 = fptosi double %T44 to i32
  %T47 = sext i32 %T45 to i64
  %T46 = getelementptr inbounds double, ptr %T43, i64 %T47
  store double %T42, ptr %T46
  %T48 = load double, ptr %T30
  %T49 = fadd double %T48, 1.000000000000000e+00
  store double %T49, ptr %T30
  br label %L35
  L37:
  ret void
}

define ptr @zeroMatrix(i32 %T50, i32 %T51) {
  %T52 = alloca i32
  store i32 %T50, ptr %T52
  %T53 = alloca i32
  store i32 %T51, ptr %T53
  %T54 = load i32, ptr %T52
  %T55 = mul i32 8, %T54
  %T56 = sext i32 %T55 to i64
  %T57 = call ptr @malloc(i64 %T56)
  %T58 = alloca ptr
  store ptr %T57, ptr %T58
  %T59 = alloca double
  %T60 = sitofp i32 0 to double
  store double %T60, ptr %T59
  %T61 = load i32, ptr %T52
  %T62 = sub i32 %T61, 1
  %T63 = sitofp i32 %T62 to double
  br label %L64
  L64:
  %T67 = load double, ptr %T59
  %T68 = fcmp ole double %T67, %T63
  %T69 = zext i1 %T68 to i32
  %T70 = icmp ne i32 %T69, 0
  br i1 %T70, label %L65, label %L66
    L65:
  %T71 = load i32, ptr %T53
  %T72 = mul i32 8, %T71
  %T73 = sext i32 %T72 to i64
  %T74 = call ptr @malloc(i64 %T73)
  %T75 = load ptr, ptr %T58
  %T76 = load double, ptr %T59
  %T77 = fptosi double %T76 to i32
  %T79 = sext i32 %T77 to i64
  %T78 = getelementptr inbounds ptr, ptr %T75, i64 %T79
  store ptr %T74, ptr %T78
  %T80 = alloca double
  %T81 = sitofp i32 0 to double
  store double %T81, ptr %T80
  %T82 = load i32, ptr %T53
  %T83 = sub i32 %T82, 1
  %T84 = sitofp i32 %T83 to double
  br label %L85
  L85:
  %T88 = load double, ptr %T80
  %T89 = fcmp ole double %T88, %T84
  %T90 = zext i1 %T89 to i32
  %T91 = icmp ne i32 %T90, 0
  br i1 %T91, label %L86, label %L87
    L86:
  %T92 = load ptr, ptr %T58
  %T93 = load double, ptr %T59
  %T94 = fptosi double %T93 to i32
  %T96 = sext i32 %T94 to i64
  %T95 = getelementptr inbounds ptr, ptr %T92, i64 %T96
  %T97 = load ptr, ptr %T95
  %T98 = load double, ptr %T80
  %T99 = fptosi double %T98 to i32
  %T101 = sext i32 %T99 to i64
  %T100 = getelementptr inbounds double, ptr %T97, i64 %T101
  store double 0.000000000000000e+00, ptr %T100
  %T102 = load double, ptr %T80
  %T103 = fadd double %T102, 1.000000000000000e+00
  store double %T103, ptr %T80
  br label %L85
  L87:
  %T104 = load double, ptr %T59
  %T105 = fadd double %T104, 1.000000000000000e+00
  store double %T105, ptr %T59
  br label %L64
  L66:
  %T106 = load ptr, ptr %T58
  ret ptr %T106
}

define i32 @main() {
  %T107 = alloca ptr
  %T108 = mul i32 4, 10
  %T109 = sext i32 %T108 to i64
  %T110 = call ptr @malloc(i64 %T109)
  store ptr %T110, ptr %T107
  %T111 = load ptr, ptr %T107
  %T113 = sext i32 0 to i64
  %T112 = getelementptr inbounds i32, ptr %T111, i64 %T113
  store i32 1, ptr %T112
  %T114 = load ptr, ptr %T107
  %T116 = sext i32 1 to i64
  %T115 = getelementptr inbounds i32, ptr %T114, i64 %T116
  store i32 2, ptr %T115
  %T117 = load ptr, ptr %T107
  %T119 = sext i32 2 to i64
  %T118 = getelementptr inbounds i32, ptr %T117, i64 %T119
  store i32 3, ptr %T118
  %T120 = load ptr, ptr %T107
  %T122 = sext i32 3 to i64
  %T121 = getelementptr inbounds i32, ptr %T120, i64 %T122
  store i32 4, ptr %T121
  %T123 = load ptr, ptr %T107
  %T125 = sext i32 4 to i64
  %T124 = getelementptr inbounds i32, ptr %T123, i64 %T125
  store i32 5, ptr %T124
  %T126 = load ptr, ptr %T107
  %T128 = sext i32 5 to i64
  %T127 = getelementptr inbounds i32, ptr %T126, i64 %T128
  store i32 6, ptr %T127
  %T129 = load ptr, ptr %T107
  %T131 = sext i32 6 to i64
  %T130 = getelementptr inbounds i32, ptr %T129, i64 %T131
  store i32 7, ptr %T130
  %T132 = load ptr, ptr %T107
  %T134 = sext i32 7 to i64
  %T133 = getelementptr inbounds i32, ptr %T132, i64 %T134
  store i32 8, ptr %T133
  %T135 = load ptr, ptr %T107
  %T137 = sext i32 8 to i64
  %T136 = getelementptr inbounds i32, ptr %T135, i64 %T137
  store i32 9, ptr %T136
  %T138 = load ptr, ptr %T107
  %T140 = sext i32 9 to i64
  %T139 = getelementptr inbounds i32, ptr %T138, i64 %T140
  store i32 10, ptr %T139
  %T141 = load ptr, ptr %T107
  call void @printArray(ptr %T141, i32 10)
  %T143 = alloca ptr
  %T144 = alloca i32
  store i32 4, ptr %T144
  %T145 = load i32, ptr %T144
  %T146 = mul i32 8, %T145
  %T147 = sext i32 %T146 to i64
  %T148 = call ptr @malloc(i64 %T147)
  store ptr %T148, ptr %T143
  %T149 = load ptr, ptr %T143
  %T150 = load i32, ptr %T144
  call void @fillWith(ptr %T149, i32 %T150, double 1.400000000000000e+00)
  %T152 = load ptr, ptr %T143
  %T154 = sext i32 3 to i64
  %T153 = getelementptr inbounds double, ptr %T152, i64 %T154
  %T155 = load double, ptr %T153
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T155)
  %T156 = call ptr @zeroMatrix(i32 3, i32 4)
  %T157 = alloca ptr
  store ptr %T156, ptr %T157
  %T158 = load ptr, ptr %T157
  %T160 = sext i32 1 to i64
  %T159 = getelementptr inbounds ptr, ptr %T158, i64 %T160
  %T161 = load ptr, ptr %T159
  %T163 = sext i32 1 to i64
  %T162 = getelementptr inbounds double, ptr %T161, i64 %T163
  %T164 = load double, ptr %T162
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %T164)
  ret i32 0
}

