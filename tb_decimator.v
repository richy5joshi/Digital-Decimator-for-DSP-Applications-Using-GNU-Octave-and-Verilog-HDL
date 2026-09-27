`timescale 1ns / 1ps

module tb_decimator;

    // =========================================================
    // PARAMETERS
    // =========================================================

    parameter DATA_WIDTH = 16;
    parameter N = 400;
    parameter DECIMATION_FACTOR = 4;
    parameter OUTPUT_N = N / DECIMATION_FACTOR;


    // =========================================================
    // SIGNAL DECLARATIONS
    // =========================================================

    reg clk;
    reg rst;

    reg signed [DATA_WIDTH-1:0] data_in;

    wire signed [DATA_WIDTH-1:0] data_out;
    wire data_valid;


    // =========================================================
    // INPUT MEMORY
    // =========================================================

    reg signed [DATA_WIDTH-1:0] sample_mem [0:N-1];


    // =========================================================
    // EXPECTED OUTPUT MEMORY
    // =========================================================

    reg signed [DATA_WIDTH-1:0] expected_mem [0:OUTPUT_N-1];


    // =========================================================
    // VARIABLES
    // =========================================================

    integer i;
    integer out_index;

    integer actual_txt_file;
    integer actual_mem_file;


    // =========================================================
    // READ INPUT DATA
    // =========================================================

    initial begin

        $readmemh("input_data.mem", sample_mem);

        $display("--------------------------------------------");
        $display("Input data loaded from input_data.mem");
        $display("Number of input samples = %0d", N);
        $display("--------------------------------------------");

    end


    // =========================================================
    // READ EXPECTED OUTPUT
    // =========================================================

    initial begin

        $readmemh("expected_output.mem", expected_mem);

        $display("--------------------------------------------");
        $display("Expected output loaded from expected_output.mem");
        $display("Expected output samples = %0d", OUTPUT_N);
        $display("--------------------------------------------");

    end


    // =========================================================
    // OPEN OUTPUT FILES
    // =========================================================

    initial begin

        actual_txt_file =
            $fopen("actual_decimated_output.txt", "w");

        actual_mem_file =
            $fopen("actual_decimated_output.mem", "w");

        out_index = 0;

    end


    // =========================================================
    // DUT
    // =========================================================

    decimator #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    DUT (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out),
        .data_valid(data_valid)
    );


    // =========================================================
    // CLOCK GENERATION
    // 100 MHz CLOCK
    // Period = 10 ns
    // =========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // =========================================================
    // CAPTURE AND VERIFY DECIMATED OUTPUT
    // =========================================================

    always @(posedge clk) begin

        #1;

        if (data_valid) begin

            // -------------------------------------------------
            // WRITE ACTUAL OUTPUT AS DECIMAL
            // -------------------------------------------------

            $fwrite(
                actual_txt_file,
                "%0d\n",
                data_out
            );


            // -------------------------------------------------
            // WRITE ACTUAL OUTPUT AS HEX
            // -------------------------------------------------

            $fwrite(
                actual_mem_file,
                "%04X\n",
                data_out
            );


            // -------------------------------------------------
            // COMPARE ACTUAL WITH EXPECTED
            // -------------------------------------------------

            if (data_out !== expected_mem[out_index]) begin

                $display(
                    "ERROR: Sample %0d | Expected = %0d | Actual = %0d",
                    out_index,
                    expected_mem[out_index],
                    data_out
                );

            end

            else begin

                $display(
                    "PASS: Sample %0d | Value = %0d",
                    out_index,
                    data_out
                );

            end


            // Move to next expected sample
            out_index = out_index + 1;

        end

    end


    // =========================================================
    // APPLY INPUT SAMPLES
    // =========================================================

    initial begin

        // Initial conditions
        rst = 1'b1;
        data_in = 16'sd0;


        // Keep reset active
        #20;


        // Release reset
        rst = 1'b0;


        // -----------------------------------------------------
        // SEND ALL INPUT SAMPLES
        // -----------------------------------------------------

        for (i = 0; i < N; i = i + 1) begin

            @(negedge clk);

            data_in = sample_mem[i];

        end


        // Allow final output to appear
        #50;


        // -----------------------------------------------------
        // CLOSE FILES
        // -----------------------------------------------------

        $fclose(actual_txt_file);
        $fclose(actual_mem_file);


        // -----------------------------------------------------
        // FINAL REPORT
        // -----------------------------------------------------

        $display("");
        $display("============================================");
        $display("       DECIMATOR SIMULATION COMPLETE");
        $display("============================================");

        $display("Input Samples          = %0d", N);

        $display(
            "Decimation Factor      = %0d",
            DECIMATION_FACTOR
        );

        $display(
            "Expected Output        = %0d",
            OUTPUT_N
        );

        $display(
            "Actual Output Samples  = %0d",
            out_index
        );

        $display("--------------------------------------------");

        if (out_index == OUTPUT_N) begin

            $display(
                "OUTPUT SAMPLE COUNT : PASS"
            );

        end

        else begin

            $display(
                "OUTPUT SAMPLE COUNT : ERROR"
            );

        end

        $display("--------------------------------------------");

        $display(
            "Generated Files:"
        );

        $display(
            "  actual_decimated_output.txt"
        );

        $display(
            "  actual_decimated_output.mem"
        );

        $display("============================================");


        // Finish simulation
        $finish;

    end

endmodule
