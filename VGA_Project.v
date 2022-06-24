module VGA_Project(
	input clk,
	input [3:0] KEY,
	output reg [4:0] LED,	
	output reg VGA_CLK,
	output reg SEC_CLK,
	output VGA_HS, VGA_VS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);
	integer mode = 0, counter = 0;
	reg [2:0] pixel = 8'b11111111;
	reg [2:0] temp_pixel = 8'b00000000;
	assign VGA_R = {8{pixel[1]}};
	assign VGA_G = {8{pixel[2]}};
	assign VGA_B = {8{pixel[0]}};
	
	parameter FILE = "rom2.txt";
	

	always @(posedge clk) begin
		VGA_CLK <= ~VGA_CLK;
		if(~KEY[0]) begin mode <= 0; LED[3:0] <= 4'b0001; end
		if(~KEY[1]) begin mode <= 1; LED[3:0] <= 4'b0010; end
		if(~KEY[2]) begin mode <= 2; LED[3:0] <= 4'b0100; end
		if(~KEY[3]) begin mode <= 3; LED[3:0] <= 4'b1000; end
	end
	
	
	wire [9:0] x;
	wire [9:0] y;
	reg [12:0] rom_addr;
	wire [2:0] rom_q;
	wire [9:0] x_fwd = x + 1;
	
	
	rom #(13, 3, FILE) vrom(rom_addr, VGA_CLK, rom_q);

	vga_driver vga_driver(VGA_CLK, VGA_HS, VGA_VS, x, y);
	
	always @(posedge VGA_CLK) begin
		counter <=  counter + 1;
		if(counter  % 12500000 == 0)
			SEC_CLK <= ~SEC_CLK;
	end
	
	always @(posedge SEC_CLK) begin
		if(counter % 10000 == 0) begin
			LED[4] <= LED[4] == 1'b1 ? 1'b0 : 1'b1;
			if(mode == 3)
				temp_pixel <= temp_pixel + 8'b00000001;
		end
		
	end

	always @(posedge VGA_CLK) begin
	
		if(mode == 0) begin
			if((x < 640) && (y < 480)) begin
				if (x % 80 == 0)
					pixel <= 8'b11111111;
			end else
				pixel <= 0;
		end 
		
		if(mode == 1) begin
			if((x < 640) && (y < 480)) begin
				if (x % 80 == 0)
					pixel <= pixel - 8'b1;
			end else
				pixel <= 0;
		end 
		
		if (mode == 2) begin
			rom_addr = x_fwd[9:3] + y[9:3] * 80;
			pixel <= ((x < 640) && (y < 480)) ? rom_q : 3'b0;
		end 
		
		if (mode == 3) begin
			if((x < 640) && (y < 480)) begin
				pixel <= temp_pixel;
			end else
				pixel <= 0;
		end
		
	end
endmodule
