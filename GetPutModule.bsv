import GetPut :: *;
import StmtFSM :: *;


interface GetPutModule;
	interface Put#(int) in_data;
	interface Get#(int) out_data;
endinterface

module mkGetPutModule(GetPutModule);
	Reg#(int) currentData[2] <- mkCReg(2,0);

	interface Put in_data;
		method Action put(int v);
			currentData[0] <= v;
		endmethod
	endinterface

	interface Get out_data;
		method ActionValue#(int) get();
			return currentData[1];
		endmethod
	endinterface
endmodule

module mkTB(Empty);
	GetPutModule uut <- mkGetPutModule();
	Stmt fsm = {
		seq
			par
				uut.in_data.put(29);
				$display("%d",uut.out_data.get());
			endpar

			par
				uut.in_data.put(8);
				$display("%d",uut.out_data.get());
			endpar
		endseq
	};
	mkAutoFSM(fsm);
endmodule
