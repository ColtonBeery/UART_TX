`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SDSU
// Engineer: Colton Beery
// 
// Create Date: 02/20/2019 08:59:18 AM
// Design Name: 
// Module Name: UART_TX
// Project Name: UART
// Target Devices: Basys3
// Tool Versions: 
//
// Description: Tx: The simpler of the two. When an 8 bit value is loaded into a 
//              register using the 8 DIP switches for the number and a push button
//              for the "load" signal, it shifts the byte out in asynchronous 
//              serial format (initially at 9600 bits per second, later at an 
//              arbitrary, programmable data rate).  That begins with a start bit (0),
//              followed by the 8 data bits LSB first, and a stop (1) bit.
// 
// Dependencies: Basys3_Master_Customized.xdc
// 
// Revision History 
// Current Revision: 0.14
// Changelog in Changelog.txt
//
// Additional Comments:  
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TX(
    input [15:0] IO_SWITCH, //IO Dipswitches; up = 1
    input IO_BTN_C,         //IO Pushbutton (Center); pushed = 1
    input clk,              //Master clock signal
    output reg [7:0] JA,     //PMOD JA; port JA1 used as TX pin
    output wire [7:0] IO_LED     //IO LED's for debugging data
//    output wire [9:0] IO_LED     //IO LED's for debugging transmit
    );
    
    /* State Machine Parameters */
    reg [1:0] current_state, next_state;
    /* Old case logic
    parameter idle = 2'b00; //State 0 = idle
    parameter read = 2'b01; //State 1 = read
    parameter out = 2'b10;  //State 2 = output
    */
    parameter idle = 2'b00; //State 0 = idle
    parameter start = 2'b01; //State 1 = start bit
    parameter out = 2'b10;  //State 2 = output
    parameter stop = 2'b11; //State 3 = stop bit
//    reg transmit; //still data to transmit
    
    /* Data and transmission parameters */
    parameter idle_bit = 1;                  //idle high
    parameter start_bit = 0;                 //start bit 0
//    parameter number_data_bits = 8;          //data bits 
    parameter stop_bit = 1;                  //stop bit
//    reg [number_data_bits-1:0] data;         //data input
//    reg [number_data_bits+1:0] transmission; //what to output
    reg [7:0] data;         //data input    
//    reg [9:0] transmission; //what to output
    reg [3:0] bit;                           //bit number currently being transmitted 
    
    /* Baud rate generation parameters */
//    parameter master_clk_freq = 100000;                 // Master clock frequency 100 MHz
//    parameter baud_rate = 9600;                         //Baud rate 9600
//    parameter max_counter = master_clk_freq/baud_rate;  //what the counter needs to go up to for baud rate 9600
    parameter max_counter = 10415;
    reg [13:0] counter;                                 //counter for baud rate generation; currently hardcoded to 14 bits for 9600 baud
    
    assign IO_LED = data; //LEDs used to check if data is read successfully
//    assign IO_LED = transmission; //LEDs used to check if data is read successfully
    
    always @(posedge clk) begin
        
//        /* Read Logic */
//        if (IO_BTN_C ) begin
            
//            data = IO_SWITCH[7:0];     //read switches 1-8, where 0 is LSB
//            transmission = {stop_bit, data, start_bit}; //transmission is Start->data (lsb first)->Stop
//            //IO_LED = transmission;
//            bit = 0;
//            counter = 0;
////            transmit = 1;                           //then output
//            next_state = start;
//        end       
        
        
        /* Current State Logic */    
        case (current_state)
            idle: begin              
                JA[0] = idle_bit; //When idle, assert idle bit
                /* Read Logic */
                if (IO_BTN_C) begin
                    data = IO_SWITCH[7:0];     //read switches 1-8, where 0 is LSB
//                    transmission = {stop_bit, data, start_bit}; //transmission is Start->data (lsb first)->Stop
                    //IO_LED = transmission;
                    next_state = start;
                    bit = 0;
//                    counter = 0;
                end                 
            end
            
            start: begin
                for (counter = 0; counter < max_counter; counter = counter + 1) begin //if counter hasn't overflowed yet, transmit
                    JA[0] = start_bit;                        
                end
//                counter = 0;
                next_state = out;
            end
            
            out: begin
//                    if (bit < 9) // If there's still more bits to transmit
                      for (bit = 0; counter < 7; bit = bit + 1) begin
    //                        if (counter < max_counter) begin //if counter hasn't overflowed yet, transmit
    //                            JA[0] = transmission[bit];
    //                            counter = counter + 1;
    //                        end else begin //when counter overflows, go to next bit
    //                            counter = 0;
    //                            bit = bit + 1;
    //                        end                            
    //                    else begin //when you run out of bits to transmit, go back to idle
    //                        transmit = 0;
                          for (counter = 0; counter < max_counter; counter = counter + 1) //if counter hasn't overflowed yet, transmit
//                                JA[0] = transmission[bit];
                                JA[0] = data[bit];
//                      counter = 0;   
                    end
                    bit = 0;  
                    next_state = stop;                   
                end
            
            stop: begin
                for (counter = 0; counter < max_counter; counter = counter + 1) //if counter hasn't overflowed yet, transmit
//                            JA[0] = transmission[stop_bit];
                              JA[0] = stop_bit;                            
//                counter = 0;
                next_state = idle;
            end
            
            default: next_state = idle;
//                  transmit = 0; //Return to idle if error
                    
        endcase
        
//        case (transmit)
//            0 : next_state = idle; //Return to idle when done outputting
//            1 : next_state = out; //Return to idle when done outputting
//            default : next_state = idle; //Return to idle when error
//        endcase;
        current_state = next_state;
    
    end
endmodule
