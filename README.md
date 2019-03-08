# COMPE470L UART Lab

<details>
	<summary>The Instructions </summary>


[Professor Ken Arnold's instruction video](https://drive.google.com/file/d/1Q-ztf6lWboTvkhMa8we5UHa06pon7dVH/view)

This assignment is to create two state machine designs in Verilog and demonstrate them on the FPGA board:

1. **Tx:** The simpler of the two. When an 8 bit value is loaded into a register using the 8 DIP switches for the number and a push button for the "load" signal, it shifts the byte out in asynchronous serial format (initially at 9600 bits per second, later at an arbitrary, programmable data rate).  That begins with a start bit (0), followed by the 8 data bits LSB first, and a stop (1) bit.

2. Rx: The tough one, receiving a byte in the format above and displaying it using the LEDs. Your Rx will have to detect the start bit, with 1/2 bit period to confirm a valid start bit, then sample in the middle of each bit interval shifting each bit into an 8 bit register that drives the 8 LEDs on the IO board.

<details>
	<summary>**Part 1 - Transmit**</summary>
For this specific assignment, in part 1 you must implement a UART that takes paralllel input data from the switches and buttons, and produces a serial output on one of the FPGA output pins.  In order to do that, you must also create a clock with an appropriate frequency to operate the UART from the on-board oscillator connected to the FPGA.  The clock frequency should be higher than the data rate to allow for the requirements for part 2 below, most UARTs use a clock that is 16x the data rate. Capture the serial output data on the scope or logic analyzer abd confirm the serial output data is correct and that the bit period is 1/9600th second long.
	</details>

<details>
	<summary>Part 2 - Receive</summary>
In part 2, you will design a serial to parallel receiver that will receive the asynchronous data from your transmitter in part 1 above, and convert it into an 8 bit parallel word for display on the LEDs on the I/O board.
	</details>

Ultimately, you will be implementing the core subset of transmit/receive functions of a device similar to the SCC2691 serial UART chip in the file listed below, _(Note: no such file was found in the professor's lab instructions.)_ so you should review the transmit buffer empty and receive buffer full status registers of that device.  For full credit, your final UART design should implement the receive buffer full and transmit buffer empty bits. You will need to take the raw FPGA input clock ~~(8MHz for the older version of the board, 50MHz for the newer rev A board that has DIYchips.com written in white letters on the top of the board)~~ _(This instruction was originally written by the teacher with the [FPGADEVS6 board from DIYchips.com](http://diychips.com/fpgadevs6.html) in mind. This project has been implemented instead on the [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/start) which has a single 100 MHz oscillator.)_ and convert that clock into an appropriate clock for your two state machines.
</details>

<details>
	<summary> The Logic (To-Do) </summary>

	![My Original Logic](https://uc1abf78fe64f9ebb980517a3fc7.dl.dropboxusercontent.com/cd/0/get/Acrqs4rf_yU2oDbzewRzjOw8QDTLzinJJJFHfRd5kJGqK--muFy2zPbOb6foDuQ6Ybvxel0HFq_REhbRP-uVDO__RxaKPtF7ZKm2ksaJJq6o45rylfwBIOM9ktfW6IwavFE/file?_download_id=6721779728052737635490905859036659654075933702716381400345204966&_notify_domain=www.dropbox.com&dl=1 "My Original Logic")

  This was my first attempt at figuring out the state machine logic for the transmitter. It had to be revised a bit as issues came up.

	Remember to go back and add the final version of this later.

</details>

<details>
	<summary>The Lab Report </summary>


<details>
	<summary>What Did I Do To Complete the Lab?</summary>
I watched the video on blackboard about UART Tx and then drew out a first version of my state machine logic, as shown in the Logic section above.

Then I started trying to write out a basic state machine code using this. This didn’t really work well, though, and I had to make a lot of changes to get it to even output anything. After all those changes, I got it to output garbage, which was better than nothing. Every time a problem came up, I google searched what might be causing that, got a new problem, google searched, etc.
	</details>

<details>
	<summary>What Challenges Did I Have With This Lab?</summary>
+ I was getting no data output at first, because the board didn’t like the way that I was trying to read the data and then concatenate it with the start and stop bits into a single register titled _transmit._
+ Laptop BSOD’d from trying to synthesize my code. Apparently using Vivado’s internal debugging tools sometimes causes problems for… reasons. Still not sure why they suddenly caused problems when they worked fine for hours before that.
+ Swapped back and forth between for loops and if loops several times, because I was having trouble getting if loops to output anything and I thought that outputting something that seemed like garbage was probably better than outputting nothing. Turns out my if loops were just set up wrong, because I had to use if loops in my final version.
	</details>

<details>
	<summary>What Did I Learn From This Lab?</summary>
* For loops in Verilog
    * Are synthesized by essentially copy/pasting the for loop over and over for every value of , so my 2 nested for loops were essentially making 8*10415 = 83320 statements.
    * do not execute sequentially, so my code was running 83320 iterations of the loop and only outputting the final result
	</details>

</details>
