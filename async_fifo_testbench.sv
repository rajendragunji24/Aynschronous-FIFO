`timescale 1ns/1ps
`include "interface.sv"
`include "environment.sv"

module async_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // ---------------------------------------------------
    // Interface instantiation
    // ---------------------------------------------------
    fifo_if #(DATA_WIDTH, ADDR_WIDTH) fifo_if();

    // ---------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------
    async_fifo_sv #(
        .data_width(DATA_WIDTH),
        .addr_width(ADDR_WIDTH)
    ) dut (
        .data_in (fifo_if.data_in),
        .wr_en   (fifo_if.wr_en),
        .wr_clk  (fifo_if.wr_clk),
        .wr_rst  (fifo_if.wr_rst),
        .full    (fifo_if.full),

        .data_out(fifo_if.data_out),
        .rd_en   (fifo_if.rd_en),
        .rd_clk  (fifo_if.rd_clk),
        .rd_rst  (fifo_if.rd_rst),
        .empty   (fifo_if.empty)
    );

    // ---------------------------------------------------
    // Clock Generators
    // ---------------------------------------------------
    initial begin
        fifo_if.wr_clk = 0;
        forever #5 fifo_if.wr_clk = ~fifo_if.wr_clk;
    end

    initial begin
        fifo_if.rd_clk = 0;
        forever #7 fifo_if.rd_clk = ~fifo_if.rd_clk;
    end

    // ---------------------------------------------------
    // Environment
    // ---------------------------------------------------
    environment env;

    initial begin
        env = new(fifo_if);
        env.run();
    end

    // ---------------------------------------------------
    // Coverage Transaction Object
    // ---------------------------------------------------
    fifo_transaction tr_cov;

    initial begin
        tr_cov = new();
    end

    // ---------------------------------------------------
    // Helper: Sample coverage
    // ---------------------------------------------------
    task sample_cov();
        tr_cov.wr_en    = fifo_if.wr_en;
        tr_cov.rd_en    = fifo_if.rd_en;
        tr_cov.data_in  = fifo_if.data_in;
        tr_cov.data_out = fifo_if.data_out;
        tr_cov.sample_cov();
    endtask

    // ---------------------------------------------------
    // Reset Test
    // ---------------------------------------------------
    task reset_test();
        $display("\n[TEST 1] RESET TEST STARTED...");
        fifo_if.wr_rst = 1;
        fifo_if.rd_rst = 1;
        fifo_if.wr_en  = 0;
        fifo_if.rd_en  = 0;
        fifo_if.data_in = '0;

        repeat (4) @(posedge fifo_if.wr_clk);
        sample_cov();

        fifo_if.wr_rst = 0;
        fifo_if.rd_rst = 0;

        $display("[TEST 1] RESET TEST PASSED\n");
    endtask

    // ---------------------------------------------------
    // Write & Read Test
    // ---------------------------------------------------
    task write_read_test();
        integer i;
        $display("\n[TEST 2] WRITE AND READ TEST STARTED...");

        // WRITE
        for (i = 0; i < 8; i++) begin
            @(posedge fifo_if.wr_clk);
            if (!fifo_if.full) begin
                fifo_if.data_in = $urandom_range(0,255);
                fifo_if.wr_en = 1;
            end else fifo_if.wr_en = 0;

            sample_cov();
        end
        fifo_if.wr_en = 0;

        #100;

        // READ
        for (i = 0; i < 8; i++) begin
            @(posedge fifo_if.rd_clk);
            if (!fifo_if.empty)
                fifo_if.rd_en = 1;
            else
                fifo_if.rd_en = 0;

            sample_cov();
        end
        fifo_if.rd_en = 0;

        $display("[TEST 2] WRITE AND READ TEST COMPLETED\n");
    endtask

    // ---------------------------------------------------
    // Overflow Test
    // ---------------------------------------------------
    task overflow_test();
        integer i;
        $display("\n[TEST 3] OVERFLOW TEST STARTED...");

        for (i = 0; i < (1 << ADDR_WIDTH) + 4; i++) begin
            @(posedge fifo_if.wr_clk);
            fifo_if.data_in = $urandom_range(0,255);
            fifo_if.wr_en = 1;
            sample_cov();
        end

        fifo_if.wr_en = 0;
        $display("[TEST 3] OVERFLOW TEST COMPLETED\n");
    endtask

    // ---------------------------------------------------
    // Underflow Test
    // ---------------------------------------------------
    task underflow_test();
        integer i;
        $display("\n[TEST 4] UNDERFLOW TEST STARTED...");

        for (i = 0; i < 8; i++) begin
            @(posedge fifo_if.rd_clk);
            fifo_if.rd_en = 1;
            sample_cov();
        end

        fifo_if.rd_en = 0;
        $display("[TEST 4] UNDERFLOW TEST COMPLETED\n");
    endtask

    // ---------------------------------------------------
    // Wrap-around Test
    // ---------------------------------------------------
    task wrap_around_test();
        integer i;
        $display("\n[TEST 5] WRAP-AROUND TEST STARTED...");

        for (i = 0; i < (1 << ADDR_WIDTH) * 3; i++) begin

            @(posedge fifo_if.wr_clk);
            fifo_if.data_in = $urandom_range(0,255);
            fifo_if.wr_en = !fifo_if.full;
            sample_cov();

            @(posedge fifo_if.rd_clk);
            fifo_if.rd_en = !fifo_if.empty;
            sample_cov();
        end

        fifo_if.wr_en = 0;
        fifo_if.rd_en = 0;

        $display("[TEST 5] WRAP-AROUND TEST COMPLETED\n");
    endtask

    // ---------------------------------------------------
    // Main Sequence
    // ---------------------------------------------------
    initial begin
        fifo_if.wr_rst = 0;
        fifo_if.rd_rst = 0;
        fifo_if.wr_en  = 0;
        fifo_if.rd_en  = 0;
        fifo_if.data_in = 0;

        #50;

        reset_test();
        write_read_test();
        overflow_test();
        underflow_test();
        wrap_around_test();

        // FINAL COVERAGE
        $display("\n==========================================");
        $display("            FUNCTIONAL COVERAGE");
        $display("==========================================");
        $display(" FINAL COVERAGE = %0.2f %%", $get_coverage());
        $display("==========================================\n");

        #100;
        $finish;
    end

    // ---------------------------------------------------
    // VCD DUMP
    // ---------------------------------------------------
    initial begin
        $dumpfile("async_fifo_tb.vcd");
        $dumpvars(0, async_fifo_tb);
    end

endmodule
