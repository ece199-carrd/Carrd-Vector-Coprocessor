`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2023 17:32:38
// Design Name: 
// Module Name: v_lanes
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module v_lanes(
    input logic clk,
    input logic nrst,
    input logic [5:0] op_instr_alu,
    input logic [5:0] op_instr_mul,
    input logic [2:0] vsew,
    input bit [2:0] lmul,
    input bit [1:0] lanes,
    // output logic [31:0] result_valu,
    // output logic [31:0] result_vmul,
    output logic [127:0] result_valu_1,
    output logic [127:0] result_vmul_1,
    output logic [127:0] result_valu_2,
    output logic [127:0] result_vmul_2,
    output logic [127:0] result_valu_3,
    output logic [127:0] result_vmul_3,
    output logic [127:0] result_valu_4,
    output logic [127:0] result_vmul_4,
    output bit done,
    output bit[1:0] try,


	input logic [127:0] op_A_1,
	input logic [127:0] op_A_2,
	input logic [127:0] op_A_3,
	input logic [127:0] op_A_4,

    input logic [127:0] op_B_1,
	input logic [127:0] op_B_2,
	input logic [127:0] op_B_3,
	input logic [127:0] op_B_4

    );

    logic [127:0] result_valu_32b_1;
    logic [127:0] result_vmul_32b_1;
    logic [127:0] result_valu_32b_2;
    logic [127:0] result_vmul_32b_2;

    bit [1:0] step;
    bit [1:0] step_rt;
    
    assign step_rt = step;
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin

            //ALU

            v_alu valu(
                .clk(~clk),
                .nrst(nrst),
                .op_instr(op_instr_alu),
                .vsew(vsew),
                .op_A((step_rt == 2'd0)? op_A_1[(i*32)+32-1:i*32] : (step_rt == 2'd1)? op_A_2[(i*32)+32-1:i*32] : (step_rt == 2'd2)? op_A_3[(i*32)+32-1:i*32] : op_A_4[(i*32)+32-1:i*32]),
                .op_B((step_rt == 2'd0)? op_B_1[(i*32)+32-1:i*32] : (step_rt == 2'd1)? op_B_2[(i*32)+32-1:i*32] : (step_rt == 2'd2)? op_B_3[(i*32)+32-1:i*32] : op_B_4[(i*32)+32-1:i*32]),
                .result(result_valu_32b_1[(i*32)+32-1:i*32])

            );
            
            //MUL

            v_mul vmul(
                .clk(~clk),
                .nrst(nrst),
                .op_instr(op_instr_mul),
                .sew(vsew),
                .op_A((step_rt == 2'd0)? op_A_1[(i*32)+32-1:i*32] : (step_rt == 2'd1)? op_A_2[(i*32)+32-1:i*32] : (step_rt == 2'd2)? op_A_3[(i*32)+32-1:i*32] : op_A_4[(i*32)+32-1:i*32]),
                .op_B((step_rt == 2'd0)? op_B_1[(i*32)+32-1:i*32] : (step_rt == 2'd1)? op_B_2[(i*32)+32-1:i*32] : (step_rt == 2'd2)? op_B_3[(i*32)+32-1:i*32] : op_B_4[(i*32)+32-1:i*32]),
                .result(result_vmul_32b_1[(i*32)+32-1:i*32])
            );


            //always @(step,result_valu_32b_1,result_vmul_32b_1) begin 
            always @(posedge clk) begin 
                case (step)
                        2'd0: begin
                            if (i == 3) begin
                                    done = (lanes == 2'b00 && lmul==3'b01)? 0: (lanes == 2'b00 && lmul==3'b10)? 0 : (lanes == 2'b01 && lmul==3'b10)? 0: 1; //LMUL==2'b11 returns 1
                                    step = (lanes == 2'b00 && lmul==3'b01)? 1: (lanes == 2'b00 && lmul==3'b10)? 2'd1 : (lanes == 2'b01 && lmul==3'b10)? 2'd2: 0;
                                    try = (lanes == 2'b00 && lmul==3'b01)? 1: (lanes == 2'b00 && lmul==3'b10)? 2'd1 : (lanes == 2'b01 && lmul==3'b10)? 2'd2: 0;
                                    //step = 1;                                   
                            end

                            result_vmul_1[(i*32)+32-1:i*32] = result_vmul_32b_1[(i*32)+32-1:i*32];
                            result_valu_1[(i*32)+32-1:i*32] = result_valu_32b_1[(i*32)+32-1:i*32];
                            // result_vmul_1[(i*32)+32-1:i*32] = 32'h010203b1 ;
                            // result_valu_1[(i*32)+32-1:i*32] = 32'h050607a1;
                        end 
                        2'd1: begin
                            if (i == 3) begin
                                    done = (lmul==2'b01)? 1: 0;
                                    step = (lmul==3'b10)? 2'd2 : 2'd0;             
                                    try = (lmul==3'b10)? 2'd2 : 2'd0;                             
                
                            end

                            result_vmul_2[(i*32)+32-1:i*32] = result_vmul_32b_1[(i*32)+32-1:i*32];
                            result_valu_2[(i*32)+32-1:i*32] = result_valu_32b_1[(i*32)+32-1:i*32];
                            // result_vmul_2[(i*32)+32-1:i*32] = 32'h010202b2 ;
                            // result_valu_2[(i*32)+32-1:i*32] = 32'h010202a2 ;

                        end 
                        2'd2: begin
                            if (i == 3) begin
                                done = (lanes == 2'b01 && lmul==3'b10)? 1:0;
                                step = (lanes == 2'b01 && lmul==3'b10)? 0: 2'd3;       
                                try = (lanes == 2'b01 && lmul==3'b10)? 0: 2'd3;                            
                            end

                            result_vmul_3[(i*32)+32-1:i*32] = result_vmul_32b_1[(i*32)+32-1:i*32];
                            result_valu_3[(i*32)+32-1:i*32] = result_valu_32b_1[(i*32)+32-1:i*32];
                            // result_vmul_3[(i*32)+32-1:i*32] = 32'h010202b3 ;
                            // result_valu_3[(i*32)+32-1:i*32] = 32'h010202a3 ;
  


                        end 
                        2'd3: begin
                            if (i == 3) begin
                                done = (lmul==2'b10)? 1: 0;
                                step = 2'd0;                           
                                try = 2'd0;                           
                            end

                            result_vmul_4[(i*32)+32-1:i*32] = result_vmul_32b_1[(i*32)+32-1:i*32];
                            result_valu_4[(i*32)+32-1:i*32] = result_valu_32b_1[(i*32)+32-1:i*32];
                            // result_vmul_4[(i*32)+32-1:i*32] = 32'h010202b4 ;
                            // result_valu_4[(i*32)+32-1:i*32] = 32'h010202a4 ;
 


                        end
                        default:  begin //assume step = 0
                            if (i == 3) begin
                                    done = (lanes == 2'b00 && lmul==3'b01)? 0: (lanes == 2'b00 && lmul==3'b10)? 0 : (lanes == 2'b01 && lmul==3'b10)? 0: 1; //LMUL==2'b11 returns 1
                                    step = (lanes == 2'b00 && lmul==3'b01)? 1: (lanes == 2'b00 && lmul==3'b10)? 2'd1 : (lanes == 2'b01 && lmul==3'b10)? 2'd2: 0;
                                    try = (lanes == 2'b00 && lmul==3'b01)? 1: (lanes == 2'b00 && lmul==3'b10)? 2'd1 : (lanes == 2'b01 && lmul==3'b10)? 2'd2: 0;
                                    //step = 1;                                   
                            end

                            result_vmul_1[(i*32)+32-1:i*32] = result_vmul_32b_1[(i*32)+32-1:i*32];
                            result_valu_1[(i*32)+32-1:i*32] = result_valu_32b_1[(i*32)+32-1:i*32];
                            // result_vmul_1[(i*32)+32-1:i*32] = 32'h010203b1 ;
                            // result_valu_1[(i*32)+32-1:i*32] = 32'h050607a1;


                        end 
                endcase                                  
            end
        end

        for (i = 4; i < 8; i++) begin

            //ALU

            v_alu valu(
                .clk((lanes == 0 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_alu),
                .vsew(vsew),
                .op_A((step == 2'd0)? op_A_2[((i-4)*32)+32-1:(i-4)*32] : op_A_4[((i-4)*32)+32-1:(i-4)*32]),
                .op_B((step == 2'd0)? op_B_2[((i-4)*32)+32-1:(i-4)*32] : op_B_4[((i-4)*32)+32-1:(i-4)*32]),
                .result(result_valu_32b_2[((i-4)*32)+32-1:(i-4)*32])

            );

            //MUL

            v_mul vmul(
                .clk((lanes == 0 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_mul),
                .sew(vsew),
                .op_A((step == 2'd0)? op_A_2[((i-4)*32)+32-1:(i-4)*32] : op_A_4[((i-4)*32)+32-1:(i-4)*32]),
                .op_B((step == 2'd0)? op_B_2[((i-4)*32)+32-1:(i-4)*32] : op_B_4[((i-4)*32)+32-1:(i-4)*32]),
                .result(result_vmul_32b_2[((i-4)*32)+32-1:(i-4)*32])
            );

            //always @(posedge clk) begin
            always @(result_valu_32b_2,result_vmul_32b_2) begin
                if ((lanes == 2'b01) || (lanes == 2'b10)) begin
                    case (step)
                            2'd0: begin
                                result_vmul_2[((i-4)*32)+32-1:(i-4)*32] = result_vmul_32b_2[((i-4)*32)+32-1:(i-4)*32];
                                result_valu_2[((i-4)*32)+32-1:(i-4)*32] = result_valu_32b_2[((i-4)*32)+32-1:(i-4)*32]; 
                                // result_vmul_2[((i-4)*32)+32-1:(i-4)*32] = 32'h010202d2 ;
                                // result_valu_2[((i-4)*32)+32-1:(i-4)*32] = 32'h010202c2 ;
                            end 
                            2'd2: begin
                                result_vmul_4[((i-4)*32)+32-1:(i-4)*32] = result_vmul_32b_2[((i-4)*32)+32-1:(i-4)*32];
                                result_valu_4[((i-4)*32)+32-1:(i-4)*32] = result_valu_32b_2[((i-4)*32)+32-1:(i-4)*32];
                                // result_vmul_4[((i-4)*32)+32-1:(i-4)*32] = 32'h010202d4 ;
                                // result_valu_4[((i-4)*32)+32-1:(i-4)*32] = 32'h010202c4 ;                            
                            end
                            default: ;
                    endcase                      
                end                 
            end

        end

    endgenerate



    //genvar i;
    generate
        for (i = 8; i < 12; i++) begin

            //ALU

            v_alu valu(
                .clk((lanes == 0 )? 0 :(lanes == 1 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_alu),
                .vsew(vsew),
                .op_A(op_A_3[((i-8)*32)+32-1:(i-8)*32]),
                .op_B(op_B_3[((i-8)*32)+32-1:(i-8)*32]),
                .result(result_valu_3[((i-8)*32)+32-1:(i-8)*32])

            );

            //MUL

            v_mul vmul(
                .clk((lanes == 0 )? 0 :(lanes == 1 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_mul),
                .sew(vsew),
                .op_A(op_A_3[((i-8)*32)+32-1:(i-8)*32]),
                .op_B(op_B_3[((i-8)*32)+32-1:(i-8)*32]),
                .result(result_vmul_3[((i-8)*32)+32-1:(i-8)*32])
            );
        end

        for (i = 12; i < 16; i++) begin

            //ALU

            v_alu valu(
                .clk((lanes == 0 )? 0 :(lanes == 1 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_alu),
                .vsew(vsew),
                .op_A(op_A_4[((i-12)*32)+32-1:(i-12)*32]),
                .op_B(op_B_4[((i-12)*32)+32-1:(i-12)*32]),
                .result(result_valu_4[((i-12)*32)+32-1:(i-12)*32])

            );

            //MUL

            v_mul vmul(
                .clk((lanes == 0 )?0: (lanes == 1 )? 0 : ~clk),
                .nrst(nrst),
                .op_instr(op_instr_mul),
                .sew(vsew),
                .op_A(op_A_4[((i-12)*32)+32-1:(i-12)*32]),
                .op_B(op_B_4[((i-12)*32)+32-1:(i-12)*32]),
                .result(result_vmul_4[((i-12)*32)+32-1:(i-12)*32])
            );
        end        
    endgenerate

/*     //genvar i;
    generate
        for (i = 12; i < 16; i++) begin

            //ALU

            v_alu valu(
                .clk((lanes == 0 )? 0 : clk),
                .nrst(nrst),
                .op_instr(op_instr_alu),
                .vsew(vsew),
                .op_A(op_A_4[((i-12)*32)+32-1:(i-12)*32]),
                .op_B(op_B_4[((i-12)*32)+32-1:(i-12)*32]),
                .result(result_valu_4[((i-12)*32)+32-1:(i-12)*32])

            );

            //MUL

            v_mul vmul(
                .clk((lanes == 0 )? 0 : clk),
                .nrst(nrst),
                .op_instr(op_instr_mul),
                .sew(vsew),
                .op_A(op_A_4[((i-12)*32)+32-1:(i-12)*32]),
                .op_B(op_B_4[((i-12)*32)+32-1:(i-12)*32]),
                .result(result_vmul_4[((i-12)*32)+32-1:(i-12)*32])
            );
        end
    endgenerate  */


endmodule
