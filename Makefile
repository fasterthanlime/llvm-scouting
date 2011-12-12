all:
	llvm-as hiworld.S
	llvm-ld hiworld.S.bc
