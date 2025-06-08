module top_module(
    input clk,
    input reset,
    input ena,
    output pm,
    output [7:0] hh,
    output [7:0] mm,
    output [7:0] ss,
    output chime); 
    wire ssmm_switch, mmhh_switch, ampm_switch;
    reg pm_reg;
    assign ssmm_switch = (ss[7:4] == 5) & (ss[3:0] == 9) & ena;
    assign mmhh_switch = ssmm_switch & (mm[7:4] == 5) & (mm[3:0] == 9);
    assign ampm_switch = mmhh_switch & (hh[7:4] == 1) & (hh[3:0] == 1);
    sixty_counter second(clk, ena, reset, ss);
    sixty_counter minute(clk, ssmm_switch, reset, mm);
    twelve_counter hour(clk, mmhh_switch, reset, hh);
    sound_pulse plse(clk, mmhh_switch, chime);
    assign pm = pm_reg;
    always @(posedge clk) begin
        if (reset) begin
            pm_reg <= 0;
        end else begin
            pm_reg = ampm_switch ? ~pm_reg : pm_reg;
        end
    end
endmodule

module sixty_counter (
    input clk,
    input enable,
    input reset,
    output reg [7:0] q);
    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (enable) begin
                if ((q[7:4] == 5) & (q[3:0] == 9)) begin
                    q <= 0;
                end else if (q[3:0] == 9) begin
                  q[7:4] <= q[7:4] + 1;
                  q[3:0] <= 0;
                end else begin
                  q[3:0] <= q[3:0] + 1;
                end
            end
        end
    end
    
endmodule

module twelve_counter (
    input clk,
    input enable,
    input reset,
    output reg [7:0] q);
    always @(posedge clk) begin
        if (reset) begin
          q[3:0] <= 2;
          q[7:4] <= 1;
        end else begin
            if (enable) begin
                if ((q[7:4] == 1) & (q[3:0] == 2)) begin
                  q[3:0] <= 1;
                  q[7:4] <= 0;
                end else if (q[3:0] == 9) begin
                  q[7:4] <= q[7:4] + 1;
                  q[3:0] <= 0;
                end else begin
                  q[3:0] <= q[3:0] + 1;
                end
            end
        end
    end
    
endmodule

module sound_pulse(
    input clk,
    input request, 
    output reg trigger
);
    reg has_triggered;
    always @(posedge clk) begin
        if (!has_triggered && request) begin
            has_triggered <= 1;
            trigger <= 1;
        end else begin
            trigger <= 0;
        end

        if (!request) begin
            has_triggered <= 0;
        end
    end
endmodule