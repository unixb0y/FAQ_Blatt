import StmtFSM :: *;

interface CRegCounter;
	method Action up(Int#(32) v); method Action down(Int#(32) v); method Action reset();
	method Int#(32) getCounter();
endinterface

module mkCounter(CRegCounter);
	Reg#(Int#(32))	upCount[2] 		<- mkCReg(2, 0);
	Reg#(Int#(32)) 	downCount[2] 	<- mkCReg(2, 0);
	Reg#(Bool) 		rst[2] 			<- mkCReg(2, False);
	Reg#(Int#(32)) 	value[2]		<- mkCReg(2, 0);

	rule counterRule;
		value[0] <= rst[0] ? 0 : value[0] + upCount[0] - downCount[0];
		rst[0] <= False;
		upCount[0] <= 0;
		downCount[0] <= 0;
	endrule

	method Action reset();
		rst[0] <= True;
	endmethod

	method Action up(Int#(32) v);
		upCount[0] <= v;
	endmethod

	method Action down(Int#(32) v);
		downCount[0] <= v;
	endmethod
	
	method Int#(32) getCounter();
		return rst[1] ? 0 : value[1] + upCount[1] - downCount[1];
	endmethod
endmodule

module mkCounter2(CRegCounter);
    Reg#(Int#(32)) result[4] <- mkCReg(4, 0);

    method Action reset();
        result[2] <= 0;
    endmethod

    method Action up(Int#(32) v);
        result[0] <= result[0]+v;
    endmethod

    method Action down(Int#(32) v);
        result[1] <= result[1]-v;
    endmethod

    method Int#(32) getCounter();
        return result[3];
    endmethod
endmodule


module mkCounterTestbench(Empty);
    CRegCounter uut <- mkCounter2();

    Stmt testStmt = {
        seq
            par
            	uut.up(14);
                uut.down(5);
                $display("Counter is: %d - should be 9", uut.getCounter());
            endpar

            par
                uut.down(3);
                $display("Counter is: %d - should be 6", uut.getCounter());
            endpar

            par
                $display("Counter is: %d - should be 6", uut.getCounter());
            endpar

            par
                uut.up(9);
                uut.reset();
                $display("Counter is: %d - should be 0", uut.getCounter());
            endpar

            par
                $display("Counter is: %d - should be 0", uut.getCounter());
            endpar
        endseq
    };

    mkAutoFSM(testStmt);
endmodule