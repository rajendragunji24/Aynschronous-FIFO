class fifo_driver;
    virtual fifo_if vif;
    mailbox gen2drv;

    function new(virtual fifo_if vif, mailbox gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task run();
        fifo_transaction tr;
        forever begin
            gen2drv.get(tr);

            // Write operation
            if (tr.wr_en && !vif.full) begin
                @(posedge vif.wr_clk);
                vif.data_in <= tr.data_in;
                vif.wr_en   <= 1;
                tr.display("DRV_WRITE");
                @(posedge vif.wr_clk);
                vif.wr_en   <= 0;
            end

            // Read operation
            if (tr.rd_en && !vif.empty) begin
                @(posedge vif.rd_clk);
                vif.rd_en <= 1;
                tr.display("DRV_READ_REQ");
                @(posedge vif.rd_clk);
                vif.rd_en <= 0;
            end
        end
    endtask
endclass
