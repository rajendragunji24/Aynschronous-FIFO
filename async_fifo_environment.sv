
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;

    virtual fifo_if vif;
    fifo_generator gen;
    fifo_driver   drv;
    fifo_monitor  mon;
    fifo_scoreboard scb;

    mailbox gen2drv;
    mailbox mon2scb;

    function new(virtual fifo_if vif);
        this.vif = vif;
        gen2drv  = new();
        mon2scb  = new();

        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);
    endfunction

    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none
    endtask

endclass
