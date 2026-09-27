`timescale 1ns / 1ps

module decimator #(
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [DATA_WIDTH-1:0] data_in,

    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg data_valid
);

    reg [1:0] count;

    always @(posedge clk) begin

        if (rst) begin
            count      <= 2'd0;
            data_out   <= 0;
            data_valid <= 1'b0;
        end

        else begin

            data_valid <= 1'b0;

            if (count == 2'd0) begin
                data_out   <= data_in;
                data_valid <= 1'b1;
                count      <= 2'd1;
            end

            else if (count == 2'd3) begin
                count <= 2'd0;
            end

            else begin
                count <= count + 1'b1;
            end

        end
    end

endmodule
