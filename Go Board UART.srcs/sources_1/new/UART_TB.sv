`timescale 1ns / 10ps
////////////////////////////////////////////////////////////////////////////////// 
// Module Name: UART_TB
//////////////////////////////////////////////////////////////////////////////////


module UART_TB();
    
    localparam c_duty_cycle = 40;       // for a clock with freq of 25MHz.
    localparam c_clk_per_bit = 217;     // for a desired baud rate of 115200 -> 25*10^9 / 115200  ~ 217
                                        // when we divide the freq of a clock sigal by the baud rate, we get the number of clock cycles per second.
                                        // Clock signal freq -> represents the number of clock cycles per second
                                        // Baud rate -> represents the number of symbols per second
    localparam c_bit_period = 8600;     // bit period is the duration of one bit period for UART communication.                                        
                                        
    
    logic clk = 0,serial_in;
    logic [7:0] uart_out;
    logic [6:0] seg_right, seg_left;
    
    // Module instantition    
    top_module UART (.clk(clk), .uart_in(serial_in), .uart_out(uart_out), .seg_right(seg_right), .seg_left(seg_left));
    // Generating clock
    always #(c_duty_cycle/2) clk = ~clk;
    // Serializing data
    
    task UART_WRITE_BYTE;
        input [7:0] i_data;
        begin
        
        // Send start bit
        serial_in <= 1'b0;
        #(c_bit_period);
        // Send data byte
        for(int ii = 0; ii < 8; ii=ii+1) begin
            serial_in <= i_data[ii];
            #(c_bit_period);
        end
        // Send stop bit
        serial_in <= 1'b1;
        #(c_bit_period);
        end
    endtask
    
    initial begin
        // Send a command to the UART
        @(posedge clk);
        UART_WRITE_BYTE(8'hAA);
        @(posedge clk);
        
        if(uart_out == 8'h37)
            $display("Expected 8'h37 and received 8'%0h : test Passed - correct Byte received ", uart_out);
        else 
            $display("Expected 8'h37 and received 8'%0h : test Failed - incorrect Byte received ", uart_out);
        $finish;
    end
endmodule
