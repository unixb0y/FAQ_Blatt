import GetPut :: *;
import StmtFSM :: *;

interface PairAverage;
        interface Get#(int) out_data;
        interface Put#(int) in_data;
endinterface

module mkPairAverage(PairAverage);
        Reg#(int) input1 <- mkReg(0);
        Reg#(int) input2 <- mkReg(0);
        Reg#(Bool) valid1 <- mkReg(False);
        Reg#(Bool) valid2 <- mkReg(False);

        interface Get out_data;
                method ActionValue#(int) get() if(valid1 && valid2);
                        return (input1+input2)/2;
                endmethod
        endinterface

        interface Put in_data;
                method Action put(int v);
                        if(valid1) begin
                                input2 <= input1;
                                valid2 <= True;
                        end
                        input1 <= v;
                        valid1 <= True;
                endmethod
        endinterface
endmodule


module mkTB(Empty);
        PairAverage uut <- mkPairAverage();
        Stmt fsm = {
                seq
                        uut.in_data.put(12);
                        uut.in_data.put(4);
                        $display("average of 12 and 4 is: %d", uut.out_data.get());
                        uut.in_data.put(8);
                        $display("average of 4 and 8 is: %d", uut.out_data.get());
                endseq
        };

        mkAutoFSM(fsm);
endmodule