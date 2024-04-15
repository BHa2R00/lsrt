VCS = vcs -o ./a.out -cc clang -cpp clang++ -j16 -RI -full64 -sverilog +v2k -debug_access+all -kdb +sdfverbos +define+vcs +maxdelays -timescale=1ns/100ps 
VCSXA = vcs -o ./a.out -cc clang -cpp clang++ -j16 -RI -full64 -sverilog +v2k -debug_access+all -kdb +sdfverbos +define+vcs +maxdelays -timescale=1ns/1ps

lsrt_tb: ../tb/lsrt_tb.sv
	rm -rfv lsrt_tb.fsdb
	${VCS} ../tb/lsrt_tb.sv
	./a.out 

lsrt_uart_tb: ../tb/lsrt_uart_tb.sv
	rm -rfv lsrt_uart_tb.fsdb
	${VCS} ../tb/lsrt_uart_tb.sv
	./a.out 
