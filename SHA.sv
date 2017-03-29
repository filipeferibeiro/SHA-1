module SHA(
	input logic PCLK_IN,
	input logic [4:0] PADDR_IN,
	input logic PRESETn_IN,
	input logic PSEL_IN,
	input logic PENABLE_IN,
	input logic PWRITE_IN,
	input logic [31:0] PWDATA_IN,
	output logic PREADY_OUT,
	output logic [31:0] PRDATA_OUT);
		
	logic [31:0] regis [15:0];
	logic [31:0] H [4:0]; //Hash
	logic [31:0] W [79:0];
	logic [6:0] t, i;
	logic [2:0] j;
	logic [31:0] T, a, b, c, d, e, Kt, Ft, Wt;
	
	//enum {IDLE, SETUP, ACCESS} state;
	
	//logic calc_time = 1'b0;

	
	always_ff @(posedge PCLK_IN) begin

	if (PRESETn_IN == 1'b0) begin
			H[0] <= 32'h67452301;
			H[1] <= 32'hefcdab89;
			H[2] <= 32'h98badcfe;
			H[3] <= 32'h10325476;
			H[4] <= 32'hc3d2e1f0;
			t <= 7'd0;
			i <= 7'd0;
			j <= 3'd0;
			regis [0] <= 32'd0;
			regis [1] <= 32'd0;
			regis [2] <= 32'd0;
			regis [3] <= 32'd0;
			regis [4] <= 32'd0;
			regis [5] <= 32'd0;
			regis [6] <= 32'd0;
			regis [7] <= 32'd0;
			regis [8] <= 32'd0;
			regis [9] <= 32'd0;
			regis [10] <= 32'd0;
			regis [11] <= 32'd0;
			regis [12] <= 32'd0;
			regis [13] <= 32'd0;
			regis [14] <= 32'd0;
			regis [15] <= 32'd0;
			PREADY_OUT <= 1'd1;
			W [79:0] <= '{32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0,
							32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 
							32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 
							32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0};
		end	

		else if (PSEL_IN) begin
			if (PENABLE_IN == 1'b0 && PWRITE_IN && PREADY_OUT) begin
				case (PADDR_IN)
					5'd0: regis[0] <= PWDATA_IN;
					5'd1: regis[1] <= PWDATA_IN;
					5'd2: regis[2] <= PWDATA_IN;
					5'd3: regis[3] <= PWDATA_IN;
					5'd4: regis[4] <= PWDATA_IN;
					5'd5: regis[5] <= PWDATA_IN;
					5'd6: regis[6] <= PWDATA_IN;
					5'd7: regis[7] <= PWDATA_IN;
					5'd8: regis[8] <= PWDATA_IN;
					5'd9: regis[9] <= PWDATA_IN;
					5'd10: regis[10] <= PWDATA_IN;
					5'd11: regis[11] <= PWDATA_IN;
					5'd12: regis[12] <= PWDATA_IN;
					5'd13: regis[13] <= PWDATA_IN;
					5'd14: regis[14] <= PWDATA_IN;
					5'd15: regis[15] <= PWDATA_IN;
					default: regis[15] <= PWDATA_IN;
				endcase
				end
				
				else if (PENABLE_IN) begin
					PREADY_OUT <= 1'b0;
					j <= 3'd0;
				end
				else if (PREADY_OUT == 1'b0) begin
					if (i < 7'd16) begin
						W[i] <= regis[i];
						i <= i+1'b1;
						j <= 3'd0;
					end
					else if ((i >= 7'd16) && (i< 7'd80)) begin
						W[i] <= ((W[i-3] ^ W[i-8] ^ W[i-14] ^ W[i-16]) << 1 | (W[i-3] ^ W[i-8] ^ W[i-14] ^ W[i-16]) >> 31);
						i <= i+1'b1;
						j <= 3'd0;
						if (i == 7'd79) begin
							a <= H[0];
							b <= H[1];
							c <= H[2];
							d <= H[3];
							e <= H[4];
							j <= 3'd0;
						end
					end
					if (i == 7'd80) begin
						//i <= 7'd80;
						if (t < 7'd20) begin
							case (j)
								3'd0: begin T <= ((a << 5 | a >> 27) + ((b & c) ^ (~b & d)) + e + 32'h5a827999 + W[t]); j <= j + 3'd1; end
								3'd1: begin e <= d; j <= j + 3'd1; end
								3'd2: begin d <= c; j <= j + 3'd1; end
								3'd3: begin c <= (b << 30 | b >> 2); j <= j + 3'd1; end
								3'd4: begin b <= a; j <= j + 3'd1; end
								3'd5: begin a <= T; j <= j + 3'd1; end
								3'd6: begin j <= 3'd0; t <= t + 1'b1; end
							endcase
						end
						if ((t >= 7'd20) && (t< 7'd40)) begin
							case (j)
								3'd0: begin T <= ((a << 5 | a >> 27) + (b ^ c ^ d) + e + 32'h6ed9eba1 + W[t]); j <= j + 3'd1; end
								3'd1: begin e <= d; j <= j + 3'd1; end
								3'd2: begin d <= c; j <= j + 3'd1; end
								3'd3: begin c <= (b << 30 | b >> 2); j <= j + 3'd1; end
								3'd4: begin b <= a; j <= j + 3'd1; end
								3'd5: begin a <= T; j <= j + 3'd1; end
								3'd6: begin j <= 3'd0; t <= t + 1'b1; end
							endcase
						end
						if ((t >= 7'd40) && (t< 7'd60)) begin
							case (j)
								3'd0: begin T <= ((a << 5 | a >> 27) + ((b & c) ^ (b & d) ^ (c & d)) + e + 32'h8f1bbcdc + W[t]); j <= j + 3'd1; end
								3'd1: begin e <= d; j <= j + 3'd1; end
								3'd2: begin d <= c; j <= j + 3'd1; end
								3'd3: begin c <= (b << 30 | b >> 2); j <= j + 3'd1; end
								3'd4: begin b <= a; j <= j + 3'd1; end
								3'd5: begin a <= T; j <= j + 3'd1; end
								3'd6: begin j <= 3'd0; t <= t + 1'b1; end
							endcase
						end
						if ((t >= 7'd60) && (t< 7'd80)) begin
							case (j)
								3'd0: begin T <= ((a << 5 | a >> 27) + (b ^ c ^ d) + e + 32'hca62c1d6 + W[t]); j <= j + 3'd1; end
								3'd1: begin e <= d; j <= j + 3'd1; end
								3'd2: begin d <= c; j <= j + 3'd1; end
								3'd3: begin c <= (b << 30 | b >> 2); j <= j + 3'd1; end
								3'd4: begin b <= a; j <= j + 3'd1; end
								3'd5: begin a <= T; j <= j + 3'd1; end
								3'd6: begin j <= 3'd0;
								t <= t + 1'b1; end
							endcase
						end
					end
				end
				if (t == 7'd80) begin
					PREADY_OUT <= 1'b1;
					t <= 7'd0;
					i <= 7'd0;
					j <= 3'd0;
					H[0] <= a + H[0];
					H[1] <= b + H[1];
					H[2] <= c + H[2];
					H[3] <= d + H[3];
					H[4] <= e + H[4];
				end
			end					
		end
	always_ff @(posedge PCLK_IN) begin
		if (PREADY_OUT) begin
			case (PADDR_IN)
					5'd16: PRDATA_OUT <= H[0];
					5'd17: PRDATA_OUT <= H[1];
					5'd18: PRDATA_OUT <= H[2];
					5'd19: PRDATA_OUT <= H[3];
					5'd20: PRDATA_OUT <= H[4];
					default: PRDATA_OUT <= 32'd0;
			endcase
		end
	end
	endmodule: SHA
	
