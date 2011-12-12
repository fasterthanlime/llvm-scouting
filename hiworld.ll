; constants

@.LC0 = internal constant [12 x i8] c"hello world\00"

; standard library function

declare i32 @puts(i8 *)
declare i8 * @malloc(i32)

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

define void @println.String(%tool.String * %str) {
  %mem.addr = getelementptr %tool.String * %str, i32 0, i32 2
  %mem = load i8 ** %mem.addr
  call i32 @puts(i8 * %mem)
  ret void
}

define i32 @main() {
  %cast210 = getelementptr [12 x i8]* @.LC0, i64 0, i64 0
  %str = call %tool.String * @tool.String.new(i32 12, i8 * %cast210)
  call void @println.String(%tool.String * %str)
  ret i32 0
}


