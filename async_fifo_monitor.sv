class fifo_monitor;
    virtual fifo_if vif;
    mailbox mon2scb;

    function new(virtual fifo_if vif, mailbox mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        fifo_transaction tr;
        forever begin
            @(posedge vif.rd_clk);

            // ✅ Sample on both write and read
            if ((vif.wr_en && !vif.full) || (vif.rd_en && !vif.empty)) begin
                tr = new();
                tr.wr_en   = vif.wr_en;
                tr.rd_en   = vif.rd_en;
                tr.data_in = vif.data_in;
                tr.data_out = vif.data_out;

                // ✅ Sample coverage here per transaction
                tr.sample_cov();
                tr.display("MON_SAMPLE");

                mon2scb.put(tr);
            end
        end
    endtask
endclass
