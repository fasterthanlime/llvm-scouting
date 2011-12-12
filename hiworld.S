
; constants

@.LC0 = internal constant [12 x i8] c"hello world\00"

; standard library function

declare i32 @puts(i8 *)

define void @println(i8 * %str) {
  call i32 @puts(i8 * %str)
  ret void
}

define i32 @main() {
  %cast210 = getelementptr [12 x i8]* @.LC0, i64 0, i64 0
  call void @println(i8 * %cast210)
  ret i32 0
}
