    
module lcd(
	
	input [31:0] instruction, // Dados de instrução ou ação
	input [31:0] data, // Dados para escrever no LCDs
	input clk,
	input en,
          
	output     rw,
	output reg rs,
	output reg enable,
	output reg [7:0] display // Saída de dados para o LCD
);
	
	assign rw    = 1'b0;         // Atribuindo o pino rw, sempre escrita
	reg    state = 1'b0;
	always @(posedge clk)
		 if(en) begin
			 enable    <= 1'b0;
			 state <= 1'b1; 
		 end else if(state) begin
			 enable    <= 1'b1;
			 rs    <= instruction[0];
			 display[7:0] <= data[7:0];
			 state <= 1'b0;
		 end
endmodule 