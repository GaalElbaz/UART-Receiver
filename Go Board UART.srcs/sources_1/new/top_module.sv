`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_module
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input clk,
    input uart_in,
    output logic [7:0] uart_out,
    output logic [6:0] seg_right,
    output logic [6:0] seg_left
    );
    
    // declaring wires
    logic rx_dv;
    
    // module instantition
    UART_RX           U0(.clk(clk), .rx_serial(uart_in), .rx_dv(rx_dv), .rx_byte(uart_out));
    seven_seg_display U1(.bin_in(uart_out[3:0]), .seg(seg_right));
    seven_seg_display U2(.bin_in(uart_out[7:4]), .seg(seg_left));
endmodule
