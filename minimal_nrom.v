/*

Copyright 2024 Something Nerdy Studios LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

// This module will be synthesized to an RBF file and loaded onto a
// Cyclone IV EP4CE6F17C8N FPGA.  You can use this model number to find a
// data sheet from Altera/Intel.
module minimal_nrom(

  // cpu_d - cpu data bus (8 bits)
  // For full usage, make this an inout, not an output
  output [7:0]cpu_d,
  
  // cpu_a - cpu address bus (15 bits)
  input [14:0]cpu_a,
  
  // cpu_romsel - cpu rom select (cartridge space) (delayed by NAND with m2)
  // Use this to infer top address pin of cpu_a
  input cpu_romsel,
  
  // cpu_rw - cpu read/write (pin 14) - high on read, low on write
  input cpu_rw,
  
  // m2 - main 1.79MHz cpu clock with ~3/8 duty cycle
  input m2,
  
  // cpu_irq - cpu interrupt line - pull high to initiate interrupt
  output cpu_irq,

  // cpu_dir - CPU direction, probably turning on level shifters on the board
  output cpu_dir,
  
  // cpu_ex - unknown
  output cpu_ex,
  
  // ppu_d - PPU data bus (8 bits)
  // For full usage, make this an inout, not an output
  output [7:0]ppu_d,
  
  // ppu_a - PPU address bus (14 bits)
  input [13:0]ppu_a,
  
  // ppu_rd - PPU read - low when PPU is reading
  input ppu_rd,
  
  // ppu_wr - PPU write - low when PPU is writing
  input ppu_wr,
  
  // ppu_a13n - PPU address 13 inverted
  input ppu_a13n,
  
  // ppu_ciram_ce - ppu ciram (internal nt ram) chip enable
  output ppu_ciram_ce,
  
  // ppu_ciram_a10 - ppu ciram address 10 - controls nametable mirroring
  output ppu_ciram_a10,

  // ppu_dir - PPU direction, probably turning on level shifters on the board
  output ppu_dir,
  
  // ppu_ex - unknown
  output ppu_ex,

  // PRG pins.  PRG is an 8MB PSRAM memory chip that the N8OS dumps
  // the NES ROM PRG onto before starting it.
  // Refer to IS66WVE4M16EBLL data sheet for more information about these pins.
  // That datasheet also applies to CHR memory chip.
  
  // 8M PRG data bus (8 bits)
  input [7:0]prg_d,
  
  // 8M PRG address bus (23 bits)
  output [22:0]prg_a,
  
  // 8M PRG chip enable
  output prg_ce,

  //    PRG output enable
  output prg_oe,

  //    PRG write enable - note: if enabled, ignores oe. must be held low for 46ns
  output prg_we,

  //    PRG upper byte (8M chip has 16-bit word size)
  output prg_ub,

  //    PRG lower byte
  output prg_lb,
  
  // 8M CHR data bus (8 bits)
  input [7:0]chr_d,

  // 8M CHR address bus (23 bits)
  output [22:0]chr_a,

  // 8M CHR chip enable
  output chr_ce,

  //    CHR output enable - active low but inverted in map_out
  output chr_oe,

  //    CHR write enable - note: if enabled, ignores oe
  output chr_we,

  //    CHR upper byte (8M chip has 16-bit word size)
  output chr_ub,

  //    CHR lower byte - Q: Is this available in <70ns?
  //                     A: No, because krikzz loads data by using ub/lb as the uppermost
  //                        bit of the address instead of as the lowermost bit of the
  //                        address. If you store data onto the CHR chip yourself using
  //                        the appropriate addressing, you can access neighboring bytes
  //                        in 25ns using the page access time.  But you would really have
  //                        to know what you're doing, so be warned.  All this same reasoning
  //                        applies the the PRG PSRAM as well.
  output chr_lb,

  // sram_ce - SRAM chip enable.  chip enable pin of 256K SRAM chip used for NES work ram
  // refer to IS62LV2568LL data sheet for details on these pins.
  // On the N8 Pro, this chip shares the address and data bus with the PSRAM used for PRG.
  output sram_ce,

  // sram_oe - SRAM output enable.
  output sram_oe,

  // sram_we - SRAM write enable.
  output sram_we,
  
  // mcu_miso - master in slave out output to MCU
  // 1bit serial interface driven by 42MHz ARM STM32F401
  output mcu_miso,

  // mcu_mosi - master out slave in input from MCU
  input mcu_mosi,

  // mcu_clk - 42MHz clock from MCU
  input mcu_clk,

  // mcu_ss - slave select (active low) signal from MCU
  input mcu_ss,
  
  // clk50 - 50MHz clock on board
  input clk50,

  // fds_sw - unknown probably fds related
  input fds_sw,

  // mcu_busy - MCU busy signal
  input mcu_busy,
  
  // led - on-board LED - assign 1 to turn on and 0 to turn off.
  // You can also pulse-width modulate to light up at any level in between
  output led,

  // pwm - audio pin to expansion port (pulse width modulation)
  output pwm,

  // fifo_rxf - signal MCU that output fifo has data to read, and needs to select FPGA as slave
  output fifo_rxf,

  // boot_on - unknown, possibly for initializing fpga
  output boot_on,

  // gpio - unknown, possibly for debugging/testing cartridge
  inout [3:0]gpio,

  // exp - expansion port pins, corresponding to the expansion port on the bottom
  //       of a front-loader NES
  inout [9:0]exp,

  // xio - unknown
  output [2:0]xio,

  // rx - unknown
  input rx,

  // tx - unknown
  output tx
);
  
  // Don't assert on any of these pins.
  assign exp[9:0] = 10'bzzzzzzzzzz;
  assign xio[2:0] = 3'bzzz;
  assign gpio[3:0] = 4'bzzzz;

  // If boot on is not held at 0, nothing works.
  assign boot_on = 0;
  
  // Pass through CPU address to PRG for normal NROM memory access.
  assign prg_a[22:0] = {8'b00000000, cpu_a[14:0]};
  // Enable PRG chip whenever CPU is trying to access cart.
  assign prg_ce = cpu_romsel;
  // Enable output of PRG chip whenever CPU is trying to access cart.
  assign prg_oe = cpu_romsel;
  // Never write to PRG for NROM.
  assign prg_we = 1'b1;
  
  // Assert PRG data lines directly onto CPU data lines.
  // Since PRG is disabled when CPU is writing, the PRG data lines don't assert then.
  assign cpu_d[7:0] = prg_d[7:0];
  
  // Pass through the PPU address lines for getting CHR pattern data for backgrounds and sprites.
  assign chr_a[22:0] = {10'b0000000000, ppu_a[12:0]};
  // Only enable CHR when PPU is accessing pattern data
  assign chr_ce = ppu_a[13];
  // Only enable output of CHR when PPU is accessing pattern data
  assign chr_oe = ppu_a[13];
  // Never write to CHR.
  assign chr_we = 1'b1;

  // Directly hook up CHR data lines to PPU data lines.
  assign ppu_d[7:0] = chr_d[7:0];
  
  // Never issue a hardware interrupt to the CPU
  assign cpu_irq = 1'b1;

  // (Speculation) enable level shifters to convert 3.3V to 5V when CPU is reading from cart.
  assign cpu_dir = !cpu_romsel;

  // Enable internal video RAM when PPU wants access.
  assign ppu_ciram_ce = !ppu_a[13];
  // Mirroring
  assign ppu_ciram_a10 = ppu_a[10];
  // (Speculation) enable level shifters to convert 3.3V to 5V when PPU is reading, and not reading from CIRAM.
  assign ppu_dir = !ppu_rd & !ppu_a[13];

  // Unknown
  assign ppu_ex = 0;
  assign cpu_ex = 0;
  
  // Disable the SRAM chip
  assign sram_ce = 1'b1;
  assign sram_oe = 1'b1;
  assign sram_we = 1'b1;
  
  // Force usage of lower byte of 16bit words since that's where roms are dumped on load
  assign prg_lb = 1'b0;
  assign prg_ub = 1'b1;
  assign chr_lb = 1'b0;
  assign chr_ub = 1'b1;
  
  // Never signal MCU that there is data to read
  assign fifo_rxf = 1'b1;
  
  // Set to high impedence
  assign tx = 1'bz;
  assign mcu_miso = 1'bz;

  // Turn LED off
  assign led = 1'b0;

  // Set output audio to zero.
  assign pwm = 1'b0;
endmodule