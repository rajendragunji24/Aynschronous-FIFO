class fifo_scoreboard;
    mailbox mon2scb;
    bit [7:0] ref_queue[$];

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    // Model write
    task model_write(bit [7:0] data);
        ref_queue.push_back(data);
    endtask

    // Model read and compare
    task model_read(bit [7:0] data_from_fifo);
        if (ref_queue.size() == 0) begin
            $error("[%0t] SCOREBOARD ERROR: Unexpected read, queue empty!", $time);
        end else begin
            bit [7:0] expected = ref_queue.pop_front();
            if (expected !== data_from_fifo)
                $error("[%0t] MISMATCH: Expected %0h, Got %0h", $time, expected, data_from_fifo);
            else
                $display("[%0t] MATCH: Data %0h OK", $time, data_from_fifo);
        end
    endtask

    task run();
        fifo_transaction tr;
        forever begin
            mon2scb.get(tr);
            model_read(tr.data_out);
        end
    endtask
endclass

