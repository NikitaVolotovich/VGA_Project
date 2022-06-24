module rom #(parameter ADDRESS_WIDTH = 4, parameter WIDTH = 8, parameter FILE = "")(
    input [ADDRESS_WIDTH - 1:0]address,
    input clk,
    output reg [WIDTH - 1:0]q
);

initial begin
    q = 0;
end

reg [WIDTH - 1:0]mem[2**ADDRESS_WIDTH - 1:0];

initial begin
    $readmemb(FILE, mem);
end

always @(posedge clk) begin
    q <= mem[address];
end


endmodule
