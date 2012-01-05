; constants

@.LC0 = internal constant [7 x i8] c"hello \00"
@.LC1 = internal constant [6 x i8] c"world\00"

; standard library function

declare i32 @puts(i8 *)
declare i8 * @malloc(i32)
declare i8 * @memcpy(i8 *, i8 *, i32)

define void @println(i8 * %str) {
  call i32 @puts(i8 * %str)
  ret void
}

%tool.CString = type i8 *

%tool.Class = type {
  ; methods here
}

%tool.Object = type {
  %tool.Class * ; class
}

; Allocate an object

define %tool.Object * @tool.Object.allocate(i32 %size, %tool.Class * %class) {
  %mem = call i8 * @malloc(i32 %size)
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
  %data.addr = getelementptr %tool.String * %str, i32 0, i32 2
  store i8 * %data, i8 ** %data.addr

  ret %tool.String * %str
}

define %tool.String * @tool.String.concat(%tool.String * %s1, %tool.String * %s2) {
  %len1.addr = getelementptr %tool.String * %s1, i32 0, i32 1
  %len1 = load i32* %len1.addr
  %mem1.addr = getelementptr %tool.String * %s1, i32 0, i32 2
  %mem1 = load i8** %mem1.addr

  %len2.addr = getelementptr %tool.String * %s2, i32 0, i32 1
  %len2 = load i32* %len2.addr
  %mem2.addr = getelementptr %tool.String * %s1, i32 0, i32 2
  %mem2 = load i8** %mem2.addr

  %len3 = add i32 %len1, %len2
  %mem3 = call i8* @malloc(i32 %len3)
  
  %mem3start = ptrtoint i8 * %mem3 to i64
  %len1.64 = zext i32 %len1 to i64
  %mem3moved = add i64 %mem3start, %len1.64
  %mem3pt2 = inttoptr i64 %mem3moved to i8 *
  
  call i8 * @memcpy(i8 * %mem3, i8* %mem1, i32 %len1)
  call i8 * @memcpy(i8 * %mem3pt2, i8* %mem2, i32 %len2)

  %str3 = call %tool.String * @tool.String.new(i32 %len3, i8 * %mem3)
  ret %tool.String * %str3
}

define void @println.String(%tool.String * %str) {
  %mem.addr = getelementptr %tool.String * %str, i32 0, i32 2
  %mem = load i8 ** %mem.addr
  call i32 @puts(i8 * %mem)
  ret void
}

define i32 @main() {
  %slit1 = getelementptr [7 x i8]* @.LC0, i64 0, i64 0
  %slit2 = getelementptr [6 x i8]* @.LC1, i64 0, i64 0
  %str1 = call %tool.String * @tool.String.new(i32 7, i8 * %slit1)
  %str2 = call %tool.String * @tool.String.new(i32 6, i8 * %slit2)

  %str3 = call %tool.String * @tool.String.concat(%tool.String * %str1, %tool.String * %str2)
  call void @println.String(%tool.String * %str3)
  ret i32 0
}


