TARGET=hiconcat

llvm-as $TARGET.ll
llvm-ld $TARGET.bc -native -o $TARGET.x
