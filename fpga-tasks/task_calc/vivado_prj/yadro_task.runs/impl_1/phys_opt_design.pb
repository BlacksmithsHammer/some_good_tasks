
B
Command: %s
53*	vivadotcl2
phys_opt_designZ4-113h px� 

@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
Implementation2	
xczu3egZ17-347h px� 
o
0Got license for feature '%s' and/or device '%s'
310*common2
Implementation2	
xczu3egZ17-349h px� 
R

Starting %s Task
103*constraints2
Initial Update TimingZ18-103h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.303 . Memory (MB): peak = 3769.965 ; gain = 0.000h px� 
�
^PhysOpt_Tcl_Interface Runtime Before Starting Physical Synthesis Task | CPU: %ss |  WALL: %ss
566*	vivadotcl2
0.002
0.31Z4-1435h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0012

3769.9652
0.000Z17-268h px� 
O

Starting %s Task
103*constraints2
Physical SynthesisZ18-103h px� 
^

Phase %s%s
101*constraints2
1 2#
!Physical Synthesis InitializationZ18-101h px� 
n
EMultithreading enabled for phys_opt_design using a maximum of %s CPUs380*physynth2
2Z32-721h px� 
e
ACheck ILP status : ILP-based clock placer completed successfully.12580*placeZ30-3162h px� 
q
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-0.0062
-0.569Z32-619h px� 
[
%s*common2B
@Phase 1 Physical Synthesis Initialization | Checksum: 1e47d8158
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.270 . Memory (MB): peak = 3769.965 ; gain = 0.000h px� 
q
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-0.0062
-0.569Z32-619h px� 
V

Phase %s%s
101*constraints2
2 2
DSP Register OptimizationZ18-101h px� 
j
FNo candidate cells for DSP register optimization found in the design.
274*physynthZ32-456h px� 
�
aEnd %s Pass. Optimized %s %s. Created %s new %s, deleted %s existing %s and moved %s existing %s
415*physynth2
22
02
net or cell2
02
cell2
02
cell2
02
cellZ32-775h px� 
S
%s*common2:
8Phase 2 DSP Register Optimization | Checksum: 1e47d8158
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.275 . Memory (MB): peak = 3769.965 ; gain = 0.000h px� 
W

Phase %s%s
101*constraints2
3 2
Critical Path OptimizationZ18-101h px� 
q
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-0.0062
-0.569Z32-619h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
mult_sub_add_reg/XOROUT[0]mult_sub_add_reg/XOROUT[0]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2R
&mult_sub_add0/DSP_A_B_DATA.B2_DATA<17>&mult_sub_add0/DSP_A_B_DATA.B2_DATA<17>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2L
#mult_sub_add_reg/DSP_ALU.ALU_OUT<0>#mult_sub_add_reg/DSP_ALU.ALU_OUT<0>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2H
!mult_sub_add0/DSP_ALU.ALU_OUT<47>!mult_sub_add0/DSP_ALU.ALU_OUT<47>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2L
#mult_sub_add0/DSP_M_DATA.V_DATA<43>#mult_sub_add0/DSP_M_DATA.V_DATA<43>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2J
"mult_sub_add0/DSP_MULTIPLIER.V<43>"mult_sub_add0/DSP_MULTIPLIER.V<43>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2R
&mult_sub_add0/DSP_PREADD_DATA.B2B1<17>&mult_sub_add0/DSP_PREADD_DATA.B2B1<17>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2(
clk_IBUF_inst/OUTclk_IBUF_inst/OUT8Z32-702h px� 
v
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2
clkclk8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
mult_sub_add_reg/XOROUT[0]mult_sub_add_reg/XOROUT[0]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2R
&mult_sub_add0/DSP_A_B_DATA.B2_DATA<17>&mult_sub_add0/DSP_A_B_DATA.B2_DATA<17>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2L
#mult_sub_add_reg/DSP_ALU.ALU_OUT<0>#mult_sub_add_reg/DSP_ALU.ALU_OUT<0>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2H
!mult_sub_add0/DSP_ALU.ALU_OUT<47>!mult_sub_add0/DSP_ALU.ALU_OUT<47>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2L
#mult_sub_add0/DSP_M_DATA.V_DATA<43>#mult_sub_add0/DSP_M_DATA.V_DATA<43>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2J
"mult_sub_add0/DSP_MULTIPLIER.V<43>"mult_sub_add0/DSP_MULTIPLIER.V<43>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2R
&mult_sub_add0/DSP_PREADD_DATA.B2B1<17>&mult_sub_add0/DSP_PREADD_DATA.B2B1<17>8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2(
clk_IBUF_inst/OUTclk_IBUF_inst/OUT8Z32-702h px� 
v
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2
clkclk8Z32-702h px� 
q
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-0.0062
-0.569Z32-619h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0012

3769.9652
0.000Z17-268h px� 
T
%s*common2;
9Phase 3 Critical Path Optimization | Checksum: 1e47d8158
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.294 . Memory (MB): peak = 3769.965 ; gain = 0.000h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0012

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

3769.9652
0.000Z17-268h px� 
v
>Post Physical Optimization Timing Summary | WNS=%s | TNS=%s |
318*physynth2
-0.0062
-0.569Z32-603h px� 
B
-
Summary of Physical Synthesis Optimizations
*commonh px� 
B
-============================================
*commonh px� 


*commonh px� 


*commonh px� 
�
�-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Optimization   |  WNS Gain (ns)  |  TNS Gain (ns)  |  Added Cells  |  Removed Cells  |  Optimized Cells/Nets  |  Dont Touch  |  Iterations  |  Elapsed   |
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  DSP Register   |          0.000  |          0.000  |            0  |              0  |                     0  |           0  |           1  |  00:00:00  |
|  Critical Path  |          0.000  |          0.000  |            0  |              0  |                     0  |           0  |           1  |  00:00:00  |
|  Total          |          0.000  |          0.000  |            0  |              0  |                     0  |           0  |           2  |  00:00:00  |
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 


*commonh px� 


*commonh px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

3769.9652
0.000Z17-268h px� 
P
%s*common27
5Ending Physical Synthesis Task | Checksum: 2ebba728c
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.317 . Memory (MB): peak = 3769.965 ; gain = 0.000h px� 
H
Releasing license: %s
83*common2
ImplementationZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1162
2002
02
0Z4-41h px� 
O
%s completed successfully
29*	vivadotcl2
phys_opt_designZ4-42h px� 
H
&Writing timing data to binary archive.266*timingZ38-480h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write ShapeDB Complete: 2

00:00:002
00:00:00.0032

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PlaceDB: 2

00:00:002
00:00:00.0422

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PulsedLatchDB: 2

00:00:002

00:00:002

3769.9652
0.000Z17-268h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote RouteStorage: 2

00:00:002
00:00:00.0392

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Netlist Cache: 2

00:00:002
00:00:00.0022

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Device Cache: 2

00:00:002
00:00:00.0162

3769.9652
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write Physdb Complete: 2

00:00:002
00:00:00.1092

3769.9652
0.000Z17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2Z
XC:/Users/taifun/Desktop/yadro_impulse/vivado_prj/yadro_task.runs/impl_1/calc_physopt.dcpZ17-1381h px� 


End Record