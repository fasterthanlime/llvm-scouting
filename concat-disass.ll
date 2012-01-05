; ModuleID = '/tmp/webcompile/_21478_0.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.String = type { i32, i8* }

define noalias %struct.String* @newString(i32 %length, i8* %mem) nounwind uwtable {
  %1 = tail call noalias i8* @malloc(i64 16) nounwind
  %2 = bitcast i8* %1 to %struct.String*
  %.01 = bitcast i8* %1 to i32*
  store i32 %length, i32* %.01, align 8
  %.12 = getelementptr inbounds i8* %1, i64 8
  %3 = bitcast i8* %.12 to i8**
  store i8* %mem, i8** %3, align 8
  ret %struct.String* %2
}

declare noalias i8* @malloc(i64) nounwind

define noalias %struct.String* @concat(%struct.String* nocapture %s1, %struct.String* nocapture %s2) nounwind uwtable {
  %1 = getelementptr inbounds %struct.String* %s1, i64 0, i32 0
  %2 = load i32* %1, align 4, !tbaa !0
  %3 = getelementptr inbounds %struct.String* %s2, i64 0, i32 0
  %4 = load i32* %3, align 4, !tbaa !0
  %5 = add i32 %2, 1
  %6 = add i32 %5, %4
  %7 = sext i32 %6 to i64
  %8 = tail call noalias i8* @malloc(i64 %7) nounwind
  %9 = getelementptr inbounds %struct.String* %s1, i64 0, i32 1
  %10 = load i8** %9, align 8, !tbaa !3
  %11 = sext i32 %2 to i64
  %12 = tail call i8* @strncpy(i8* %8, i8* %10, i64 %11) nounwind
  %13 = getelementptr inbounds %struct.String* %s2, i64 0, i32 1
  %14 = load i8** %13, align 8, !tbaa !3
  %15 = sext i32 %4 to i64
  %16 = tail call i8* @strncat(i8* %8, i8* %14, i64 %15) nounwind
  %17 = tail call noalias i8* @malloc(i64 16) nounwind
  %18 = bitcast i8* %17 to %struct.String*
  %.01.i = bitcast i8* %17 to i32*
  store i32 %6, i32* %.01.i, align 8
  %.12.i = getelementptr inbounds i8* %17, i64 8
  %19 = bitcast i8* %.12.i to i8**
  store i8* %8, i8** %19, align 8
  ret %struct.String* %18
}

declare i8* @strncpy(i8*, i8* nocapture, i64) nounwind

declare i8* @strncat(i8*, i8* nocapture, i64) nounwind

!0 = metadata !{metadata !"int", metadata !1}
!1 = metadata !{metadata !"omnipotent char", metadata !2}
!2 = metadata !{metadata !"Simple C/C++ TBAA", null}
!3 = metadata !{metadata !"any pointer", metadata !1}
