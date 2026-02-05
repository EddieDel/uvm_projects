module counter (
  input logic clk,
  input logic reset_n,
  input logic enable,
  output logic [3:0] count );
  
  
  always @(posedge clk) begin
    if (enable == 1 && reset_n == 1)
      count <= count +1;
    else if (reset_n == 0)
      count <= 0;
  end
endmodule
