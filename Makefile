all:
	llvm-as hiworld.ll
	llvm-ld hiworld.bc -o hiworld

clean:
	rm *.bc hiworld
