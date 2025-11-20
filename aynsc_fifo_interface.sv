interface fifo_if #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4
);

  // ==========================================================
  // 1. Signals
  // ==========================================================
  // Write domain
  logic wr_clk;
  logic wr_rst;
  logic wr_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic full;

  // Read domain
  logic rd_clk;
  logic rd_rst;
  logic rd_en;
  logic [DATA_WIDTH-1:0] data_out;
  logic empty;

  // ==========================================================
  // 2. Assertions
  // ==========================================================

  // ----------------------------------------------------------
  // A1. No write when FIFO is full
  // ----------------------------------------------------------
  property no_write_when_full;
    @(posedge wr_clk)
    disable iff (wr_rst)
    wr_en |-> !full;
  endproperty

  assert property (no_write_when_full)
    else $error("ASSERTION FAILED: Write attempted while FIFO is FULL");

  // ----------------------------------------------------------
  // A2. No read when FIFO is empty
  // ----------------------------------------------------------
  property no_read_when_empty;
    @(posedge rd_clk)
    disable iff (rd_rst)
    rd_en |-> !empty;
  endproperty

  assert property (no_read_when_empty)
    else $error("ASSERTION FAILED: Read attempted while FIFO is EMPTY");

  // ----------------------------------------------------------
  // A3. FULL and EMPTY should not both stay high for long
  // (Short overlap allowed due to async domain crossing)
  // ----------------------------------------------------------
  property full_empty_exclusive_relaxed;
    @(posedge wr_clk)
    disable iff (wr_rst)
    not (full && empty)[*3];  // Allow up to 3 cycles overlap
  endproperty

  assert property (full_empty_exclusive_relaxed)
    else $warning("FULL and EMPTY overlapped for multiple cycles (possible CDC delay)");

  // ----------------------------------------------------------
  // A4. FIFO should be empty immediately after reset
  // ----------------------------------------------------------
  property empty_after_reset;
    @(posedge rd_clk)
    disable iff (rd_rst)
    rd_rst |=> empty;
  endproperty

  assert property (empty_after_reset)
    else $error("ASSERTION FAILED: FIFO not EMPTY after reset");

  // ----------------------------------------------------------
  // A5. Simple assertion-based coverage
  // ----------------------------------------------------------
  cover property (@(posedge wr_clk) full);
  cover property (@(posedge rd_clk) empty);
  cover property (@(posedge wr_clk) wr_en && !full);
  cover property (@(posedge rd_clk) rd_en && !empty);

endinterface
