`include "top_module.v"
`timescale 10ns/1ns

module tb_top;
  reg clk;
  reg reset;
  reg ena;
  wire pm, chime;
  wire[7:0] hh, mm, ss;
  top_module TOP(.clk(clk), .reset(reset), .ena(ena), .pm(pm), .hh(hh), .mm(mm), .ss(ss), .chime(chime));
  always #5 clk = ~clk;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, tb_top);
    clk = 0;
    reset = 1;
    ena = 1;

    #10 reset = 0;
    wait(pm);
    $display("Timer completed at time %t", $time);
    #20 ena = 0;
    #20
    $finish;
  end
  task display_time;
  	input [1023:0] label;
  	begin
    	$display("[%0t] %s | Time = %0d:%0d:%0d %s", 
        	$time, label, hh, mm, ss, pm ? "PM" : "AM");
  	end
  endtask
    
endmodule