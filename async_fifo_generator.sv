class fifo_generator;
    fifo_transaction tr;
    mailbox gen2drv;

    function new(mailbox gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task run(int num_transactions = 20);
        repeat (num_transactions) begin
            tr = new();
            assert(tr.randomize());
            gen2drv.put(tr);
            tr.display("GEN");
            #10;
        end
    endtask
endclass
