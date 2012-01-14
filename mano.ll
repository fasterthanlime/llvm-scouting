; LLVM bitcode generated from Tool program polymorphism.tool

; A few functions from libc
declare i32 @puts(i8 *)
declare i8 * @malloc(i64)
declare i8 * @strncpy(i8 *, i8 *, i64)
declare i8 * @strncat(i8 *, i8 *, i64)
declare i32 @snprintf(i8 *, i32, i8*, ...)

@.LCIntToString = internal constant [3 x i8] c"%d\00"
@.LCTrue = internal constant [5 x i8] c"true\00"
@.LCFalse = internal constant [6 x i8] c"false\00"

; Basic types
%tool.CString = type i8 *
%tool.Int = type i32
%tool.ArrayStruct = type {
   %tool.Int*, ; memory
   %tool.Int   ; number of elements
} 
%tool.Array = type %tool.ArrayStruct*
%tool.Bool = type i1
%tool.Class = type { }
%tool.Object = type {
  %tool.Class * ; class
}

; Array allocation routine
define %tool.Array @tool.Array.allocate(%tool.Int %size) {
  ; first allocate the object structure
  ; 2 pointers = 16 bytes on 64-bit
  %obj.mem = call i8 * @malloc(i64 16)
  %obj = bitcast i8 * %obj.mem to %tool.Array

  %mem.addr  = getelementptr %tool.Array %obj, i32 0, i32 0
  %size.addr = getelementptr %tool.Array %obj, i32 0, i32 1

  ; there are 4 bytes in a %tool.Int
  %bytes = mul i32 %size, 4
  %size.64 = sext i32 %bytes to i64
  %mem = call i8 * @malloc(i64 %size.64)
  %mem.ints = bitcast i8 * %mem to %tool.Int *
  store %tool.Int * %mem.ints, %tool.Int ** %mem.addr

  store %tool.Int %size, %tool.Int * %size.addr

  ret %tool.Array %obj
}

define %tool.Int @tool.Array.get(%tool.Array %array, %tool.Int %index) {
  %mem.addr = getelementptr %tool.Array %array, i32 0, i32 0
  %mem = load %tool.Int ** %mem.addr

  %elem.addr = getelementptr %tool.Int * %mem, %tool.Int %index
  %result = load %tool.Int* %elem.addr
  ret %tool.Int %result
}

define void @tool.Array.set(%tool.Array %array, %tool.Int %index, %tool.Int %value) {
  %mem.addr = getelementptr %tool.Array %array, i32 0, i32 0
  %mem = load %tool.Int ** %mem.addr

  %elem.addr = getelementptr %tool.Int * %mem, %tool.Int %index
  store %tool.Int %value, %tool.Int* %elem.addr
  ret void
}

define %tool.Int @tool.Array.getsize(%tool.Array %array) {
  %length.addr = getelementptr %tool.Array %array, i32 0, i32 1
  %length = load %tool.Int * %length.addr
  ret %tool.Int %length
}


; Object allocation routine
define %tool.Object * @tool.Object.allocate(i32 %size, %tool.Class * %class) {
  %size.64 = sext i32 %size to i64
  %mem = call i8 * @malloc(i64 %size.64)
  %obj = bitcast i8 * %mem to %tool.Object *
  %obj.class = getelementptr %tool.Object * %obj, i32 0, i32 0
  store %tool.Class * %class, %tool.Class ** %obj.class
  ret %tool.Object * %obj
}

; String class
%tool.String.Class = type { }
@tool.String.class = internal constant %tool.String.Class { }
%tool.String = type {
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

define %tool.String * @tool.Bool.toString(%tool.Bool %bool) {
  br %tool.Bool %bool, label %true, label %false

true:
  %trueLiteral = getelementptr [5 x i8]* @.LCTrue, i64 0, i64 0
  %trueString = call %tool.String * @tool.String.new(i32 4, i8 * %trueLiteral)
  ret %tool.String * %trueString

false:
  %falseLiteral = getelementptr [6 x i8]* @.LCFalse, i64 0, i64 0
  %falseString = call %tool.String * @tool.String.new(i32 5, i8 * %falseLiteral)
  ret %tool.String * %falseString
}

define void @println.String(%tool.String * %str) {
  %mem.addr = getelementptr %tool.String * %str, i32 0, i32 2
  %mem = load i8 ** %mem.addr
  call i32 @puts(i8 * %mem)
  ret void
}
      
@.LC0 = internal constant [7 x i8] c"Yeehaw\00"
%tool.SteamPunk = type { %tool.SteamPunk.Class * }
%tool.SteamMachine = type { %tool.SteamMachine.Class * }
%tool.CallApp = type { %tool.CallApp.Class * }
%tool.SteamPunk.Class = type 
{%tool.Bool (%tool.SteamPunk *, %tool.Int, %tool.Int) *}
@tool.SteamPunk.class = internal constant %tool.SteamPunk.Class 
; {%tool.Bool (%tool.SteamMachine *, %tool.Int, %tool.Int) * @tool.SteamMachine.somefunc}
{%tool.Bool (%tool.SteamPunk *, %tool.Int, %tool.Int) * bitcast (%tool.Bool (%tool.SteamMachine *, %tool.Int, %tool.Int) * @tool.SteamMachine.somefunc to %tool.Bool (%tool.SteamPunk *, %tool.Int, %tool.Int) *) }
%tool.SteamMachine.Class = type 
{%tool.Bool (%tool.SteamMachine *, %tool.Int, %tool.Int) *}
@tool.SteamMachine.class = internal constant %tool.SteamMachine.Class 
{%tool.Bool (%tool.SteamMachine *, %tool.Int, %tool.Int) * @tool.SteamMachine.somefunc}
%tool.CallApp.Class = type 
{%tool.String * (%tool.CallApp *) *}
@tool.CallApp.class = internal constant %tool.CallApp.Class 
{%tool.String * (%tool.CallApp *) * @tool.CallApp.run}

define i32 @main() {
  %local.10 = call %tool.CallApp * @tool.CallApp.new()
  %local.11 = call %tool.String * @tool.CallApp.run(%tool.CallApp * %local.10)
  call void @println.String(%tool.String * %local.11)
  ret i32 0
  
}

define %tool.SteamPunk * @tool.SteamPunk.new() {
  %cls = bitcast %tool.SteamPunk.Class * @tool.SteamPunk.class to %tool.Class *
  %mem = call %tool.Object * @tool.Object.allocate(i32 8, %tool.Class * %cls)
  %obj = bitcast %tool.Object * %mem to %tool.SteamPunk *
  ret %tool.SteamPunk * %obj
  
}

define %tool.Bool @tool.SteamMachine.somefunc(%tool.SteamMachine * %this.param, %tool.Int %i.param, %tool.Int %j.param) {
  %i = alloca %tool.Int
  store %tool.Int %i.param, %tool.Int* %i
  %j = alloca %tool.Int
  store %tool.Int %j.param, %tool.Int* %j
  %local.8 = load %tool.Int* %i
  %local.9 = load %tool.Int* %j
  %local.7 = icmp slt %tool.Int %local.8, %local.9
  ret %tool.Bool %local.7
  
}

define %tool.Bool @tool.SteamPunk.somefunc(%tool.SteamPunk * %this.param, %tool.Int %i.param, %tool.Int %j.param) {
  %class.addr = getelementptr %tool.SteamPunk * %this.param, i64 0, i32 0
  %class = load %tool.SteamPunk.Class ** %class.addr
  %func.addr = getelementptr %tool.SteamPunk.Class * %class, i64 0, i32 0
  %func = load %tool.Bool (%tool.SteamPunk *, %tool.Int, %tool.Int)** %func.addr
  %result = call %tool.Bool %func(%tool.SteamPunk * %this.param, %tool.Int %i.param, %tool.Int %j.param)
  ret %tool.Bool %result
}

define %tool.SteamMachine * @tool.SteamMachine.new() {
  %cls = bitcast %tool.SteamMachine.Class * @tool.SteamMachine.class to %tool.Class *
  %mem = call %tool.Object * @tool.Object.allocate(i32 8, %tool.Class * %cls)
  %obj = bitcast %tool.Object * %mem to %tool.SteamMachine *
  ret %tool.SteamMachine * %obj
  
}

define %tool.String * @tool.CallApp.run(%tool.CallApp * %this.param) {
  %sm = alloca %tool.SteamPunk *
  %local.1 = call %tool.SteamPunk * @tool.SteamPunk.new()
  store %tool.SteamPunk * %local.1, %tool.SteamPunk ** %sm
  %local.2 = load %tool.SteamPunk ** %sm
  %local.3 = call %tool.Bool @tool.SteamPunk.somefunc(%tool.SteamPunk * %local.2, %tool.Int 45, %tool.Int 3)
  %local.4 = call %tool.String * @tool.Bool.toString(%tool.Bool %local.3)
  call void @println.String(%tool.String * %local.4)
  %local.5 = getelementptr [7 x i8]*  @.LC0, i64 0, i32 0
  %local.6 = call %tool.String * @tool.String.new(i32 6, i8* %local.5)
  ret %tool.String * %local.6
  
}

define %tool.CallApp * @tool.CallApp.new() {
  %cls = bitcast %tool.CallApp.Class * @tool.CallApp.class to %tool.Class *
  %mem = call %tool.Object * @tool.Object.allocate(i32 8, %tool.Class * %cls)
  %obj = bitcast %tool.Object * %mem to %tool.CallApp *
  ret %tool.CallApp * %obj
  
}
