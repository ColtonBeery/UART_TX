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
// Revision 0.14 - Solved error that caused synthesis of Revision 0.13 caused my laptop 
//                 to BSOD twice. Solved by removing debug declarations from XDC file.
//                 Not sure why they cause a proble because they worked for the last several
//                 revisions. 
//                 Now it at least outputs some incorrect stuff, instead of always 
//                 asserting 0 when button pushed.  
// Revision 0.13 - Adding more states to try to solve the problem of no data output. 
//                      After using LEDs for Debugging in Revision 0.12, it looks 
//                      like the input data is being read from the switches correctly,
//                      because using assign IO_LED = data; turns on the correct LEDs. 
//                      But trying to concatenate transmission = {stop_bit, data, start_bit};
//                      and outputting that to the LED's doesn't turn on any LEDs.  
// Revision 0.12 - Still no data output. Added LEDs for debugging.  
// Revision 0.11 - 0.10 still wouldn't output anything. I think I tried to get too fancy
//                 by setting data size to [number_data_bits-1:0] instead of hardcoding size
// Revision 0.10 - Fixed logic error on line 120 where I put a 1 when it should be a 0,
//                 resulting in the Tx pin always asserting 0 after button pushed
// Revision 0.09 - Apparently I never incremented counter in revision 0.08. Fixed that. 
// Revision 0.08 - I think the for loop logic is messing me up. Trying if statements instead. 
// Revision 0.07 - tried changing all nonblocking statements to blocking statements
// Revision 0.06 - changed read logic from 
//     if (IO_BTN_C ) begin
//   to
//     if (IO_BTN_C && ~transmit ) begin  
// Revision 0.05 - Removed read state, moved into an if statement 
// Revision 0.04 - Added baud rate generation 
// Revision 0.03 - Move transmit logic into for loop
// Revision 0.02 - First attempts at basic code
// Revision 0.01 - File Created
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
