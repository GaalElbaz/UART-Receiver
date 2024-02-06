`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: UART_RX
//////////////////////////////////////////////////////////////////////////////////


module UART_RX(
    input clk,            // clock of the fpga board. in this project we use GO BOARD which has a clock in freq of 25MHz.
    input rx_serial,        // actual data stream coming from the computer
    output logic rx_dv,           // data valid pulse
    output logic [7:0] rx_byte    // parallel out data
    );
    
    // Based on the freq of the clock on the Go-Board (25Mhz) divided by the freq of the baud rate (115200)
    // we will get 217 clocks per bit.    
    localparam CLKS_PER_BIT = 217;
    
    // We are going to use a state machine so we will specify the states.
    localparam IDLE = 3'b000;
    localparam RX_START_BIT = 3'b001;
    localparam RX_DATA_BITS = 3'b010;
    localparam RX_STOP_BIT = 3'b011;
    localparam CLEANUP = 3'b100;
    
    // The UART receiver will look for the falling edge in order to find the start bit.
    // we are sampling the middle of each bit -> there are 217 clocks per bit so it will count to 217/2 
    
    logic [7:0] clock_count = 0; // in order to represent 217/2
    logic [2:0] bit_index = 0;   // 8 bits in total -> 3 index bit
    logic [7:0] byte_out = 0;    // temp variable
    logic data_valid = 0;        // temp variable
    logic [2:0] uart_state = IDLE;
    
    always_ff @(posedge clk) begin
        case(uart_state) 
            IDLE: begin
                data_valid <= 1'b0;
                clock_count <= 0;
                bit_index <= 0;
                
                if(rx_serial == 1'b0) begin // start bit detected
                    uart_state <= RX_START_BIT;                    
                end
                else begin
                    uart_state <= IDLE;
                end                                 
            end
            RX_START_BIT: begin
                if(clock_count ==  (CLKS_PER_BIT-1)/2) begin // we are at the middle of the start bit
                    if(rx_serial == 1'b0) begin              // make sure we are still low
                        uart_state <= RX_DATA_BITS;          // go to data state
                        clock_count <= 0;                    // reset counter
                    end
                    else begin
                        uart_state <= IDLE;                  // if there was a glitch with the start bit
                    end
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                    uart_state <= RX_START_BIT;
                end
            end
            RX_DATA_BITS: begin
                if(clock_count < CLKS_PER_BIT -1) begin
                    clock_count <= clock_count + 1'b1;
                    uart_state <= RX_DATA_BITS;
                end
                else begin
                    clock_count <= 0;
                    byte_out[bit_index] <= rx_serial;
                    
                    // check if we have received all bits
                    if(bit_index < 7) begin
                        bit_index <= bit_index + 1'b1;
                        uart_state <= RX_DATA_BITS;
                    end
                    else begin
                        uart_state <= RX_STOP_BIT;
                        bit_index <= 0;
                    end
                end
            end
            RX_STOP_BIT: begin
                if(clock_count < CLKS_PER_BIT - 1) begin
                    clock_count <= clock_count + 1'b1;
                    uart_state <= RX_STOP_BIT;
                end
                else begin
                    if(rx_serial == 1'b0) begin  // a stop bit has been detected
                        data_valid <= 1'b1;
                        clock_count <= 0;
                        uart_state <= CLEANUP;                     
                    end
                    else begin                   // a stop bit has not been detected
                        uart_state <= CLEANUP;
                    end
                end
            end
            CLEANUP: begin
               uart_state <= IDLE;
               data_valid = 1'b0;
            end
        endcase
    end
    
    assign rx_dv = data_valid;
    assign rx_byte = byte_out;
       

endmodule
