# Carry Lookahead Adder — 4-bit FPGA Calculator

A 4-bit calculator built on the Digilent **Basys3** FPGA board using a **carry lookahead adder (CLA)**. Two 4-bit operands and a carry-in are entered on the board switches; the sum is latched into a 5-bit register on a button press and displayed on the LEDs.

## How it works

Per-bit **propagate** (`P`) and **generate** (`G`) signals are computed combinationally from `A` and `B`, then the carry into each bit is expanded so it depends only on `C0` (the input carry), not on the carry from the previous stage. The final sum (`Sum[3:0]`) and carry-out (`Cout`) are concatenated into a 5-bit value and loaded into `look_register` on the rising clock edge, but only while `enable` is held.

```
A[3:0], B[3:0], Cin ──► CLA_4bits ──► {Cout, Sum[3:0]} ──► look_register ──► Q[4:0] (LEDs)
                                                                 ▲
                                                        enable (Store button)
```

## Files

| File | Description |
|---|---|
| `CLA_4bits.v` | Top-level module — computes P/G/carries and instantiates `look_register` |
| `look_register.v` | 5-bit enabled register, loads on `posedge clk` when `enable` is high |
| `CLA_tb.v` | Testbench exercising the input combinations below |
| `CLA_cstr.xdc` | Basys3 pin constraints |
| `CLA_4bits.bit` | Prebuilt bitstream for the Basys3 |

## Module Reference

**`CLA_4bits`** (top level)
```verilog
module CLA_4bits(
    input clk,
    input enable,
    input [3:0] A, B,
    input Cin,
    output [4:0] Q,
    output enable_led
);

wire [3:0] G, P, S;
wire [4:0] C;
wire [3:0] Sum;
wire Cout;
wire [4:0] data;

assign P = A ^ B;
assign G = A & B;
assign C[0] = Cin;

assign C[1] = G[0] | (P[0] & C[0]);
assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0])
                    | (P[3] & P[2] & P[1] & P[0] & C[0]);

assign Sum  = P ^ C[3:0];
assign Cout = C[4];
assign data = {Cout, Sum};
assign enable_led = enable;

look_register register_logic(.clk(clk), .data(data), .Q(Q), .enable(enable));
endmodule
```

Every carry bit (`C1`–`C4`) is expressed purely in terms of `P`, `G`, and `C0` — no bit waits on the previous bit's carry to resolve, which is what gives the CLA its speed advantage over the ripple carry design.

**`look_register`**
```verilog
module look_register(
    input clk,
    input enable,
    input [4:0] data,
    output reg [4:0] Q
);
always @(posedge clk) begin
    if (enable)
        Q <= data;
    else
        Q <= Q;
end
endmodule
```

## Verification — Testbench Cases

| A[3:0] | B[3:0] | Cin | Sum[3:0] | Cout |
|---|---|---|---|---|
| 0000 | 0101 | 0 | 0101 | 0 |
| 0101 | 0111 | 0 | 1100 | 0 |
| 1000 | 0111 | 1 | 0000 | 1 |
| 1001 | 0100 | 0 | 1101 | 0 |
| 1000 | 1000 | 1 | 0001 | 1 |
| 1101 | 1010 | 1 | 1000 | 1 |
| 1110 | 1111 | 0 | 1101 | 1 |

Run `CLA_tb.v` in simulation and confirm `Sum`/`Cout` match expected binary addition for each row.

## FPGA Pin Constraints (`CLA_cstr.xdc`)

| Port | Basys3 Pin |
|---|---|
| `clk` | W5 (internal clock) |
| `enable` | U18 (push button) |
| `A[3:0]` | SW[3:0] |
| `B[3:0]` | SW[7:4] |
| `Cin` | SW8 |
| `Q[4:0]` | LD[4:0] |
| `enable_led` | LD15 |

## Build & Program (Vivado)

1. Create a new RTL project in Vivado, targeting the **Basys3** board.
2. Add `CLA_4bits.v` and `look_register.v` as design sources.
3. Add `CLA_tb.v` as a simulation source and run behavioral simulation to verify against the table above.
4. Add `CLA_cstr.xdc` as the constraints file.
5. Run Synthesis → Implementation → Generate Bitstream (or use the included `CLA_4bits.bit`).
6. Program the Basys3 board via Hardware Manager.

## Using the Calculator on Hardware

1. Set operand `A` on `SW[3:0]`, operand `B` on `SW[7:4]`, and `Cin` on `SW8`.
2. Press and hold the Store button (`U18`) — `LD15` lights up to confirm `enable` is active.
3. While held, on the next clock edge the sum loads into the register and shows on `LD[4:0]` (`LD4` = Cout, `LD3:0` = Sum).
4. Release the button — the value stays latched on the LEDs until the next load.
