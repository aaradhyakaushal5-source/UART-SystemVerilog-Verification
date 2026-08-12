`timescale 1ns / 1ps

module uart_reciever(
    input clk,
    input rst,
    input rx,
    input rdy_clr,
    input clken,
    output reg rdy,
    output reg [7:0] data_out
);

    parameter RX_STATE_START    = 2'b00;
    parameter RX_STATE_DATA     = 2'b01;
    parameter RX_STATE_STOP     = 2'b10;

    reg [1:0] state = RX_STATE_START;
    reg [3:0] sample = 0;
    reg [3:0] index = 0;
    reg [7:0] temp = 8'b0;

    always @(posedge clk) begin
        if (rst) begin
            rdy      <= 1'b0;
            data_out <= 8'b0;
            state    <= RX_STATE_START;
            sample   <= 0;
            index    <= 0;
            temp     <= 8'b0;
        end else begin
            
            if (rdy_clr) begin
                rdy <= 1'b0;
            end

            if (clken) begin
                case (state)
                    RX_STATE_START: begin
                        if (rx == 1'b0) begin
                            if (sample == 15) begin
                                state  <= RX_STATE_DATA;
                                index  <= 0;
                                sample <= 0;
                            end else begin
                                sample <= sample + 4'b1;
                            end
                        end else begin
                            sample <= 0; // Reset if rx goes high (filters noise)
                        end
                    end
                    
                    RX_STATE_DATA: begin
                        sample <= sample + 4'b1;
                        
                        if (sample == 4'h8) begin
                            temp[index] <= rx;
                            index <= index + 4'b1;
                        end
                        
                        if (index == 4'h8 && sample == 15) begin
                            state <= RX_STATE_STOP;
                            sample <= 0;
                        end
                    end
                    
                    RX_STATE_STOP: begin
                        if (sample == 15) begin
                            state    <= RX_STATE_START;
                            data_out <= temp;
                            rdy      <= 1'b1;
                            sample   <= 0;
                        end else begin
                            sample <= sample + 4'b1;
                        end
                    end
                    
                    default: begin
                        state <= RX_STATE_START;
                    end
                endcase
            end
        end
    end

endmodule