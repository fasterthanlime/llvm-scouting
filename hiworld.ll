
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

; Define the 'String' class
; names are prefixed with 'tool_' to make sure we don't
; run into some other identifier.

%tool.String.Class = type {
  ; %cstring ; name
}
%tool.String = type { i32, i8 * }

define %tool.String * @tool.String.new(i32 %length, i8 * %data) {
  %mem = call i8 * @malloc(i32 8)
  %str = bitcast i8 * %mem to %tool.String *
  ret %tool.String * %str
}

define i32 @main() {
  %cast210 = getelementptr [12 x i8]* @.LC0, i64 0, i64 0
  %str = call %tool.String * @tool.String.new(i32 12, i8 * %cast210)
  call void @println(i8 * %cast210)
  ret i32 0
}
