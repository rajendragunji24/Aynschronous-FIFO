class fifo_transaction;
    rand bit        wr_en;
    rand bit        rd_en;
    rand bit [7:0]  data_in;
         bit [7:0]  data_out;

    // Optional: remove this constraint to allow all cases
    // constraint c_wr_rd { !(wr_en && rd_en); }

    // -------------------------------
    // ✅ Functional Coverage
    // -------------------------------
    covergroup fifo_cov;
        option.per_instance = 1;

        wr_cp   : coverpoint wr_en  { bins active = {1}; bins inactive = {0}; }
        rd_cp   : coverpoint rd_en  { bins active = {1}; bins inactive = {0}; }

        data_in_cp  : coverpoint data_in {
            bins low   = {[0:63]};
            bins mid   = {[64:127]};
            bins high  = {[128:191]};
            bins upper = {[192:255]};
        }

        data_out_cp : coverpoint data_out {
            bins low   = {[0:63]};
            bins mid   = {[64:127]};
            bins high  = {[128:191]};
            bins upper = {[192:255]};
        }

        // Crosses
        wr_rd_cross : cross wr_cp, rd_cp;
        data_cross  : cross data_in_cp, data_out_cp;
    endgroup

    function new();
        fifo_cov = new();
    endfunction

    function void display(string tag);
        $display("[%0t] %s : wr_en=%0b rd_en=%0b data_in=%0h data_out=%0h",
                 $time, tag, wr_en, rd_en, data_in, data_out);
    endfunction

    function void sample_cov();
        fifo_cov.sample();
    endfunction
endclass


