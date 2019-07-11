module uart_tx(
	input clock,
	input enable,
	input reset,
	input clk_conf,
	input[7:0] data_in,
	output reg data_out,
	output reg done
);

reg[3:0] STATE;
reg[7:0] aux_data;
reg[7:0] aux_cont;

reg clock_gen;


parameter MAX_CONT = 217;
parameter STATE_0 = 4'b0000; //idle
parameter STATE_1 = 4'b0001; //start
parameter STATE_2 = 4'b0010; //d0
parameter STATE_3 = 4'b0011; //d1
parameter STATE_4 = 4'b0100; //d2
parameter STATE_5 = 4'b0101; //d3
parameter STATE_6 = 4'b0110; //d4
parameter STATE_7 = 4'b0111; //d5
parameter STATE_8 = 4'b1000; //d6
parameter STATE_9 = 4'b1001; //d7
parameter STATE_10 = 4'b1010; //stop

always @(posedge clock)
	begin
		aux_cont <= aux_cont + 1;
		if(aux_cont >= MAX_CONT)
			begin
				clock_gen <= ~clock_gen;
				aux_cont <= 0;
			end
	end

always @ (posedge clock_gen)
	begin
		if(reset)
			begin
				STATE = STATE_0;
			end
		else
			case (STATE)
				STATE_0:
					begin
						data_out <= 1'b1;
						done <= 1'b0;
						
						if(enable == 1'b0)
							begin
								aux_data <= data_in;
								STATE <= STATE_1;
							end
						else
							STATE <= STATE_0;
					end
				STATE_1:
					begin
						data_out <= 1'b0;
						STATE <= STATE_2;
		
					end
				STATE_2:
					begin
						data_out <= aux_data[0];
						STATE <= STATE_3;
					end
				STATE_3:
					begin
						data_out <= aux_data[1];
						STATE <= STATE_4;
					end
				STATE_4:
					begin
						data_out <= aux_data[2];
						STATE <= STATE_5;
					end
				STATE_5:
					begin
						data_out <= aux_data[3];
						STATE <= STATE_6;
					end
				STATE_6:
					begin
						data_out <= aux_data[4];
						STATE <= STATE_7;
					end
				STATE_7:
					begin
						data_out <= aux_data[5];
						STATE <= STATE_8;
					end
				STATE_8:
					begin
						data_out <= aux_data[6];
						STATE <= STATE_9;
					end
				STATE_9:
					begin
					data_out <= aux_data[7];
						STATE <= STATE_10;
					end
				STATE_10:
					begin
						data_out <= 1'b1;
						done <= 1'b1;
						STATE <= STATE_0;
					end
				default:
					STATE <= STATE_0;
			endcase
	end
endmodule