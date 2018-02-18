import StmtFSM :: *;

interface Mult#(numeric type maximumValue);
	method Action placeOperands(Int#(TLog#(maximumValue)) a,
								Int#(TLog#(maximumValue)) b);
	method Int#(64) getResult();
endinterface

module mkMult(Mult#(maximumValue))
	provisos(
		Log#(maximumValue, operandsBits),
		Add#(operandsBits, operandsBits, resultBits),
		Add#(resultBits, x, 64)
	);
    
    Reg#(Int#(resultBits)) result <- mkReg(0);

	method Action placeOperands(Int#(operandsBits) a,
								Int#(operandsBits) b);
		Int#(resultBits) aE = extend(a);
		Int#(resultBits) bE = extend(b);
		result <= aE * bE;
	endmethod

	method Int#(64) getResult();
		return extend(result);
	endmethod
endmodule

module mkTB(Empty);
	Mult#(128) uut <- mkMult();
	
	Stmt fsm = {
		seq		
			uut.placeOperands(23, 2);
			$display("result: 23*2 = %d", uut.getResult());
		endseq
	};
	mkAutoFSM(fsm);
endmodule