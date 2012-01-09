; constants

@.LC0 = internal constant [7 x i8] c"hello \00"
@.LC1 = internal constant [6 x i8] c"world\00"

@.LCIntToString = internal constant [3 x i8] c"%d\00"

; standard library function

declare i32 @puts(i8 *)
declare i8 * @malloc(i64)
declare i8 * @strncpy(i8 *, i8 *, i64)
declare i8 * @strncat(i8 *, i8 *, i64)
declare i32 @snprintf(i8 *, i32, i8*, ...)

define void @println(i8 * %str) {
  call i32 @puts(i8 * %str)
  ret void
}

%tool.Int = type i32
%tool.CString = type i8 *

%tool.Class = type {
  ; methods here
}

%tool.Object = type {
  %tool.Class * ; class
}

; Allocate an object

define %tool.Object * @tool.Object.allocate(i32 %size, %tool.Class * %class) {
  %size.64 = sext i32 %size to i64
  %mem = call i8 * @malloc(i64 %size.64)
  %obj = bitcast i8 * %mem to %tool.Object *
  %obj.class = getelementptr %tool.Object * %obj, i32 0, i32 0
  store %tool.Class * %class, %tool.Class ** %obj.class
  ret %tool.Object * %obj
}

; Define the 'String' class

%tool.String.Class = type {
  ; methods here, but String doesn't have any
}

@tool.String.class = internal constant %tool.String.Class {
  ; here we'd assign method addresses, but well, String doesn't have any.
}

%tool.String = type { ; extends tool.Object
  %tool.String.Class *, ; class
  i32, ; size
  %tool.CString ; mem
}

define %tool.String * @tool.String.new(i32 %length, i8 * %data) {
  %cls = bitcast %tool.String.Class * @tool.String.class to %tool.Class *
  %obj = call %tool.Object * @tool.Object.allocate(i32 12, %tool.Class * %cls)
  %str = bitcast %tool.Object * %obj to %tool.String *

  %length.addr = getelementptr %tool.String * %str, i32 0, i32 1
  store i32 %length, i32 * %length.addr

  %data.addr = getelementptr %tool.String * %str, i32 0, i32 2
  store i8 * %data, i8 ** %data.addr

  ret %tool.String * %str
}

define %tool.String * @tool.String.concat(%tool.String * %s1, %tool.String * %s2) {
  ; compute length of result string
  %1 = getelementptr %tool.String * %s1, i64 0, i32 1
  %2 = load i32* %1
  %3 = getelementptr %tool.String * %s2, i64 0, i32 1
  %4 = load i32* %3
  %5 = add i32 %2, %4
  %6 = add i32 %5, 1
  %7 = sext i32 %6 to i64

  ; allocate memory for result string
  %8 = call i8* @malloc(i64 %7) nounwind

  ; copy first string into result string
  %9 = getelementptr %tool.String * %s1, i64 0, i32 2
  %10 = load i8** %9
  %11 = sext i32 %2 to i64
  %12 = call i8* @strncpy(i8* %8, i8* %10, i64 %11)

  ; append second string to result string
  %13 = getelementptr %tool.String * %s2, i64 0, i32 2
  %14 = load i8** %13
  %15 = sext i32 %4 to i64
  %16 = call i8* @strncat(i8* %8, i8* %14, i64 %15)

  ; create string object and return it
  %17 = call %tool.String * @tool.String.new(i32 %5, i8 * %8)
  ret %tool.String * %17
}

define %tool.String * @tool.Int.toString(%tool.Int %num) {
  %slit = getelementptr [3 x i8]* @.LCIntToString, i64 0, i64 0
  ; for some reason that escapes me, LLVM requires a more verbose type signature
  ; when calling varargs functions.
  %length = call i32 (i8*, i32, i8*, ...)* @snprintf(i8 * null, i32 0, i8 * %slit, %tool.Int %num)

  %allocLength = add i32 %length, 1
  %allocLength.64 = sext i32 %allocLength to i64
  %mem = call i8 * @malloc(i64 %allocLength.64)

  call i32 (i8*, i32, i8*, ...)* @snprintf(i8 * %mem, i32 %allocLength, i8 * %slit, %tool.Int %num)
  %result = call %tool.String * @tool.String.new(i32 %length, i8 * %mem)
  ret %tool.String * %result
}

define void @println.String(%tool.String * %str) {
  %mem.addr = getelementptr %tool.String * %str, i32 0, i32 2
  %mem = load i8 ** %mem.addr
  call i32 @puts(i8 * %mem)
  ret void
}

define i32 @main() {
  %slit1 = getelementptr [7 x i8]* @.LC0, i64 0, i64 0
  %str1 = call %tool.String * @tool.String.new(i32 7, i8 * %slit1)
  call void @println.String(%tool.String * %str1)

  %slit2 = getelementptr [6 x i8]* @.LC1, i64 0, i64 0
  %str2 = call %tool.String * @tool.String.new(i32 6, i8 * %slit2)
  call void @println.String(%tool.String * %str2)

  %str3 = call %tool.String * @tool.String.concat(%tool.String * %str1, %tool.String * %str2)
  call void @println.String(%tool.String * %str3)

  %str4 = call %tool.String * @tool.Int.toString(%tool.Int 42)
  call void @println.String(%tool.String * %str4)

  ret i32 0
}


