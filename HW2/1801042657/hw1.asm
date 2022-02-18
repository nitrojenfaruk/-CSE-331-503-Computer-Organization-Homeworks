.data

inputFile: .asciiz "input.txt"
outputFile: .asciiz "output.txt" 

buffer: .space 2048
array: .space 2048
subseq: .byte -1:2048
output: .byte -1:2048  

divider: .asciiz "*****************************************"
candSeqStr: .asciiz "candidate sequence : ["
outpStr: .asciiz "Array_outp: ["
sizeStr: .asciiz "] , size = "
newLine: .asciiz "\n"
comma: .asciiz ","

# These'll be used on int to string part
firstArr: .space 6  
secondArr: .space 6  
thirdArr: .space 6  
fourthArr: .space 6 
fifthArr: .space 6   
sixthArr: .space 6   

sizeArr: .space 6 

# Garbage bytes to hold some register values
garb: .space 1
garb2: .space 1
garb3: .space 1
garb4: .space 1
garb5: .space 1


.text
	main:
		# Input File opening
		li   $v0, 13
		la   $a0, inputFile
		li   $a1, 0
		syscall
		addi $s0, $v0, 0
		
		# Reading file
		li   $v0, 14
		addi $a0, $s0, 0				# $a0 -> file pointer
		la   $a1 buffer
		la   $a2 1024
		syscall

		addi $s2, $v0, 0	   			# $s2 = number of bytes read		
		
		# Closing input file
		li   $v0, 16
		addi $a0, $s0, 0      
		syscall
		
		# Output File opening
		li   $v0, 13
		la   $a0, outputFile
		li   $a1, 1				   		 # 1 -> write
		syscall
		addi $a3, $v0, 0				

		li $s0, 0		  				 # $s0 is used for EOF
		
	# Ýnitilization of registers
	Inception:
		li $t1, 0         				 # i = 0
		li $t5, 0       				 # j = 0
		li $t3, 9 		  				 # $t3 = 9 -> control number
		li $t0, 0         				 # digit = 0 -> flag for multi digit number
		li $s4, 0         				 # size = 0 -> number counter 
	
	
	loop:
		# buffer holds input file characters
		la   $s5, buffer($s0)
		lb   $s1, ($s5)
		
		# Line finished
		beq  $s1, 93, functionCall       # (ASCII)93 = ']' 
		
		# $s0 == $s2 ($s2 = number of bytes read)
		# EOF control	
		bgt  $s0, $s2, exit
		addi $s0, $s0, 1 	
			
		addi $s1, $s1, -48      		 # Subtraction to achieve decimal num.
		slt  $t2, $s1, $zero			 # $s1 < 0
 		sgt  $t4, $s1, $t3      		 # $s1 > 9 
		or   $t4, $t2, $t4				
		beq  $t4, $zero, digitTransfer
		li   $t0, 0            		     # digit = 0
		j loop
	
	# Byte is number
	digitTransfer:
		bne  $t0, $zero, multiDigitNum   # digit != 0 , it means number has 2 or more digit.
		addi $s3, $s1, 0                 # previous digit - $s3  ;  new digit - $s1
		sb   $s1, array($t5)
		li   $t0, 1          			 # digit = 1 
		addi $t5, $t5, 1   				 # j++
		addi $s4, $s4, 1   				 # size++    
		j loop
	
	multiDigitNum:
		# previous digit - $s3  ;  new digit - $s1								
		mul  $s3, $s3, 10     	     	 # $s3 *= 10
		add  $s3, $s1, $s3     		 	 # $s3 += $s1
		addi $t5, $t5, -1     			 # j holds previous index.
		sb   $s3, array($t5)  
		li   $t0, 1             		 # digit = 1
		addi $t5, $t5, 1      			 # j++  
		j loop
				 

	functionCall:
		la   $s6, array     			# $s6 - array
		addi $s7, $s4, 0				# $s7 - size 
			
		addi $s0, $s0, 3                # pass \r and \n
		################################################
		# Longest Increasing Subsequence Function
		jal  LongestIncSub			
		################################################	
		j    Inception					# jump initilazation part for new array
		
	
	LongestIncSub:
		
		# Storing save registers..
		addi $sp, $sp, -32
		sb   $s7, 28($sp)
		sb   $s6, 24($sp)
		sb   $s5, 20($sp)
		sb   $s4, 16($sp)
		sb   $s3, 12($sp)
		sb   $s2, 8($sp)
		sb   $s1, 4($sp)
		sb   $s0, 0($sp)
	
		# !!!
		# I have lots of checkpoint on my algorithm,
		# therefore I loaded registers before I use.
		# !!!
		
		      ### $t0-$t7 ###
  		li $t0, 0		  # k = 0
		li $t1, 0		  # n = 0
		li $t2, 0		  # last_i = 0
		li $t3, 0		  # flag = 0
		li $t4, 0		  # last_j = 0
		li $t5, 0		  # again = 0
		li $t6, 0		  # over = 0
		li $t7, -5		  # temp = -5 -> dummy value
		
  			  ### $s0-$s6 ###
		li $s0, 1		  # no_subseq = 1
		li $s1, 0		  # pre_size = 0
		li $s2, 0		  # max_size = 0
		li $s3, 0		  # i = 0;	
		li $s5, 1		  # check = 1
		li $s6, -1		  # index = -1
		addi $s4, $s3, 1  # j = i + 1
		
		
	OuterLoop:
	# Final -> printing Array_outp
	# $s7 = size of array
		beq  $s3, $s7, Final     
		addi $s4, $s3, 1  # j = i + 1
		addi $t2, $s3, 0  # last_i = i
      	li   $t0, 0		  # k = 0   
      	li   $t5, 0		  # again = 0
      	li   $t6, 0		  # over = 0
      	li   $s5, 1	   	  # check = 1    
      	
      	
   	InnerLoop: 
   	# $s7 = size of array
   		beq  $s4, $s7, incrementOuter    
   		bgt  $s4, $s7, incrementOuter
   		
   		
   	# if(i == last_i && j != last_j)
   	Condition:
   		bne $s3, $t2, Condition_2 
   		beq $s4, $t4, Condition_2 
		li $t5, 0					# again = 0;
        li $t6, 0    				# over = 0;
        li $s5, 1  				    # check = 1;
	
	
	# if((array[j] == temp) && again && over)
	Condition_2:
		lb  $t8, array($s4)
		bne $t8, $t7, Condition_3			
		beq $t5, 0,   Condition_3
		beq $t6, 0,   Condition_3
		 
		li  $t5, 0							# again = 0;
        j   Increment_j_counter  			# continue;   
        
        
    # if(array[j] > array[i])
    Condition_3:
    	
        lb  $t8, array($s4)      	# array[j]
        lb  $t9, array($s3)      	# array[i]
        sgt $t8, $t8, $t9
        beq $t8, 0, Condition_4
		 
								# subseq holds subsequences.
		# if(k == 0)
		InnerIfCondition_3:
			bne  $t0, 0, InnerElseCondition_3     
			lb   $t8, array($s3)     				
			sb   $t8, subseq($t0) 					# subseq[k] = array[i];				    
			addi $t0, $t0, 1 						# k+1
			lb   $t9, array($s4)
			sb   $t9, subseq($t0)      				# subseq[k+1] = array[j];
            addi $t4, $s4, 0  						# last_j = j;
            addi $t0, $t0, 1 						# k += 1;
            j EndIf_3
			
		InnerElseCondition_3:
			lb   $t8, array($s4)
			sb   $t8, subseq($t0)				    # subseq[k] = array[j];
            addi $t0, $t0, 1  						# k++;
		
		EndIf_3:
			li   $s0, 0								# no_subseq = 0;
           	addi $s3, $s4, 0						# i = j;
		
	
	# if(array[last_j] < array[j]  && array[j] < array[i] && (check == 1))  
	Condition_4:
		lb   $t8, array($t4)      		# array[last_j]
		lb   $t9, array($s4)      		# array[j]	
		slt  $t8, $t8, $t9
        beq  $t8, 0, Condition_5  
		lb   $t8, array($s4)			# $t8 = array[j]	
		lb   $t9, array($s3)      		# $t9 = array[i]
		slt  $t8, $t8, $t9
        beq  $t8, 0, Condition_5  
        bne  $s5, 1, Condition_5  		# check != 1
        
        # All conditions met!
        li   $t5, 1						# again = 1;
        lb   $t7, array($s3)      		# temp = array[i];
        addi $s6, $s3, 0  				# index = i;
        li   $s5, 2   					# check = 2;
        
        
	# if(j == size - 1 && subseq[0] != -1)
	Condition_5:	
		addi $t8, $s7, -1				# $t8 = size - 1
		bne  $s4, $t8, Condition_6
		lb   $t8, subseq($zero)      	# subseq[0]
		beq  $t8, -1, Condition_6
		
		# All conditions met!
		addi $s3, $t2, 0 			    # i = last_i;
        addi $s4, $t4, 0				# j = last_j;   
        li   $t0, 0 					# k = 0;
        li   $t1, 0  					# n = 0;
        li   $t3, 0 					# flag = 0;
		
		# printf("%s", "candidate sequence : [");
		li $v0, 4
		la $a0, candSeqStr
		syscall
			
        
        # for (int x = 0; x < size; ++x)
        InnerLoop1:
        	li $t8, 0    								# $t8 = x
        	
        RealInnerLoop1:    
        	beq $t8, $s7, InnerLoop2					# x == size
        	
        	# if(subseq[x+1] != -1)
        	InnerIfCondition_5:
        		addi $t9, $t8, 1            			# $t9 = x + 1
        		lb   $t9, subseq($t9)  		            # subseq[x+1]
        		beq  $t9, -1, InnerElseCondition_5		# subseq[x+1] == -1
        		addi $t1, $t1, 1  						# n++;
        
							# printf("%d,",subseq[x]);
					# Store register values on memory to not lose
					#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				
				# !!!!!!!
				# itoa2, itoa3, itoa4, itoa5, ito6
				# All of the above will apply almost the same actions.
				# !!!!!!
				
				itoa:
					li $t2, 0				# $t2 --> digit num
					lb $t9, subseq($t8)     # subseq[x]
					
     				la   $t5, firstArr+4	
     	 			sb   $0,  1($t5)     	
     	 			li   $t1, '0'  			# for controlling end of array
      				sb   $t1, ($t5)     	
    	 			li   $t3, 10       	    
     
				luup:
					div  $t9, $t3       	# number /= 10
      				mflo $t9				# quotient
    			 	mfhi $t6                # remainder
     	 			addi $t6, $t6, 48   	
     	 			addi $t2, $t2, 1		# $t2 --> digit num
      				sb   $t6, ($t5)     	
     				sub  $t5, $t5, 1    	
     				bne  $t9, $0, luup  	
     				addi $t5, $t5, 1    	
     				
     				li $v0, 4
     				la $a0, ($t5)			# print subseq[x]
     				syscall
     	
				load:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					# Load register values from memory
					#############################################	
					
				# printf("%s",comma);
				li $v0, 4
     			la $a0, comma
     			syscall

				j  EndIf_5		
						
        	
       		InnerElseCondition_5:
					# printf("%d",subseq[x]);
					#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				
				#
				# Same procedure...
				#
				itoa2:
					li $t2, 0
					lb $t9, subseq($t8)      			

     				la   $t5, secondArr+4     
     	 			sb   $0,  1($t5)     
     	 			li   $t1, '0'  
      				sb   $t1, ($t5)     
    	 			li   $t3, 10        
     
				luup2:
					div  $t9, $t3       
      				mflo $t9
    			 	mfhi $t6            
     	 			addi $t6, $t6, 48   
     	 			addi $t2, $t2, 1	
      				sb   $t6, ($t5)     
     				sub  $t5, $t5, 1    
     				bne  $t9, $0, luup2  
     				addi $t5, $t5, 1    
     				
     				li $v0, 4
     				la $a0, ($t5)
     				syscall
					
				load2:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					#############################################	
				
				
            	# printf("%s%d\n","] , size = ",n+1);
            	li $v0, 4
     			la $a0, sizeStr
     			syscall
				
				addi $t1, $t1, 1 	 		# n = n + 1
				addi $t9, $t1, 0      				
        		addi $t9, $t9, 48
        		sb   $t9, sizeArr
        		
        		li $v0, 4
     			la $a0, sizeArr($zero)
     			syscall
				
				li $v0, 4
     			la $a0, newLine
     			syscall

       			addi $t1, $t1, -1 			# n = n - 1
       			
       			
       			# if(pre_size == 0)
                bne  $s1, 0, Cond_1
                addi $s1, $t1, 0	              # pre_size = n;
                    
                # if(temp == array[index] && check == 2)
       			Cond_1:
       				lb  $t9, array($s6)           # array[index]
       				bne	$t7, $t9, Else_Cond_1     # !(temp == array[index])
       				bne $s5, 2, Else_Cond_1       # !(check == 2)
                    li $s5, 3					  # check = 3;
                    li $t6, 1 					  # over = 1;
                    j InnerLoop2                  ### BREAK LOOP !!!
                    
       			Else_Cond_1:
       				li $t6, 0 					  # over = 0;
       			
       			j InnerLoop2                      ### BREAK LOOP !!!
       		
       		
        	# if(n > pre_size)
        	EndIf_5:
        		sgt  $t9, $t1, $s1			# (n > pre_size)
        		beq  $t9, 0, Increment_x
                addi $s2, $t1, 1			# max_size = n + 1;     
        		addi $s1, $s2, -1			# pre_size = max_size - 1;   
        		li   $t3, 1					# flag = 1;
        		
        		
        	Increment_x:
        		addi $t8, $t8, 1	   		# x++;
           		j    RealInnerLoop1
           		
   
        # for (int z = 0; z < max_size; ++z)
        InnerLoop2:
        	li $t8, 0    					# $t8 = z
        RealInnerLoop2: 
        	beq $t8, $s2, Condition_6	    # z == max_size
        	beq $t3, 0, fillSubseq 		
        	lb  $t9, subseq($t8)  		
			sb  $t9, output($t8)		    # output[z] = subseq[z];
        	
            fillSubseq:   
            	li   $t9, -1
            	sb   $t9, subseq($t8)       # subseq[z] = -1;
           		addi $t8, $t8, 1	        # z++;
           		j RealInnerLoop2
		
		
	# if(over && again && check == 3)
	Condition_6:	
		beq  $t6, 0, Increment_j_counter 	
		beq  $t5, 0, Increment_j_counter  
		bne  $s5, 3, Increment_j_counter  			
		li   $s5, 4						# check = 4;
		addi $s4, $t4, -1   			# j = last_j - 1;
	
	
	# increment j counter
	Increment_j_counter:
    	addi $s4, $s4, 1
    	j    InnerLoop
    	

	# increment i counter
	incrementOuter:	
    	addi $s3, $s3, 1
    	j    OuterLoop

	
	
	Final:
		# To divide different arrays candidate.
		li $v0, 4
		la $a0, newLine
		syscall
		
		bne $s0, 0, OneOrSameNumbers  
		# if(!no_subseq)
		# printf("%s","Array_outp: [");
		li $v0, 15
		addi $a0, $a3, 0
		la $a1, outpStr
		la $a2, 13     
		syscall				
     

        # for (int u = 0; u < max_size - 1; ++u)
        li   $t8, 0    					# $t8 = u
        addi $t9, $s2, -1               # $t9 = max_size - 1
        final_loop:
        	beq $t8, $t9, last_num	# u == max_size - 1       
        	
        	   				 # printf("%d,",output[u]);
					#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				
				#
				# Same procedure...
				#
				itoa3:
					li $t2, 0
					lb $t9, output($t8)      				
					
     				la   $t5, thirdArr+4    
     	 			sb   $0,  1($t5)     
     	 			li   $t1, '0'  
      				sb   $t1, ($t5)    
    	 			li   $t3, 10       
     
				luup3:
					div  $t9, $t3       
      				mflo $t9
    			 	mfhi $t6            
     	 			addi $t6, $t6, 48   
     	 			addi $t2, $t2, 1	
      				sb   $t6, ($t5)    
     				sub  $t5, $t5, 1    
     				bne  $t9, $0, luup3 
     				addi $t5, $t5, 1    
     				
     				li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, ($t5)
					la   $a2, 1     				 
					syscall
					
					beq $t2, 1, load3
					addi $t2, $t2, -1
				
					li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, 1($t5)
					la   $a2, ($t2)    			 
					syscall
					
				load3:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					#############################################
  			
  			# print comma
  			li   $v0, 15
			addi $a0, $a3, 0
			la   $a1, comma
			la   $a2, 1     				 
			syscall		
        				
            addi $t9, $s2, -1           # $t9 = max_size - 1
        	addi $t8, $t8, 1	  		# u++;
           	j final_loop
        
        
        	last_num:
       		addi $t9, $s2, -1               # $t9 = max_size - 1
       	
       					# printf("%d",output[max_size-1]);
					#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				
				#
				# Same procedure...
				#
				itoa4:
					li $t2, 0
					lb $t9, output($t9)      				

     				la   $t5, fourthArr+4    
     	 			sb   $0,  1($t5)     
     	 			li   $t1, '0'  
      				sb   $t1, ($t5)     
    	 			li   $t3, 10        
     
				luup4:
					div  $t9, $t3       
      				mflo $t9
    			 	mfhi $t6           
     	 			addi $t6, $t6, 48   
     	 			addi $t2, $t2, 1	
      				sb   $t6, ($t5)     
     				sub  $t5, $t5, 1    
     				bne  $t9, $0, luup4 
     				addi $t5, $t5, 1    
     				
     				li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, ($t5)
					la   $a2, 1     				 
					syscall
					
					beq $t2, 1, load4
					addi $t2, $t2, -1
					
					li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, 1($t5)
					la   $a2, ($t2)    			 
					syscall
					
				load4:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					#############################################
	
				
     	   # printf("%s%d\n","] size = ",max_size);
			li   $v0, 15
			addi $a0, $a3, 0
			la   $a1, sizeStr
			la   $a2, 11          	 	# length of sizeStr     				
			syscall	

			addi $t9, $s2, 0	 	    # $t9 = max_size 
        	addi $t9, $t9, 48
        	sb   $t9, sizeArr	
				
			li   $v0, 15 	    
			addi $a0, $a3, 0
			la   $a1, sizeArr($zero)
			la   $a2, 1         	    			
			syscall	
       		
       		# print newline
       		li   $v0, 15
			addi $a0, $a3, 0
			la   $a1, newLine
			li   $a2, 1        	      				
			syscall	
       		
       		
			lb   $s7, 28($sp)
			lb   $s6, 24($sp)
			lb   $s5, 20($sp)
			lb   $s4, 16($sp)
			lb   $s3, 12($sp)
			lb   $s2, 8($sp)
			lb   $s1, 4($sp)
			lb   $s0, 0($sp)
			addi $sp, $sp, 32
			# Load save registers from memory
			#################################

			## 
       		jr $ra  		
			## 
		
		
		OneOrSameNumbers:				# [7,7,7,7,7] or [7]
			# output[0] = array[0];
      		# max_size = 2;
			lb  $t8, array($zero) 	
			sb  $t8, output($zero)		# output[0] = array[0];
			li  $s2, 2					# max_size = 2;
			
			# printf("%s", "candidate sequence : [");
			li $v0, 4
			la $a0, candSeqStr
			syscall

								# printf("%d",output[0]);
						#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				###
				# Same procedure...
				###
				itoa5:
					li $t2, 0
					lb $t9, output($zero)      				# output[0]
					
     				la   $t5, fifthArr+4     
     	 			sb   $0,  1($t5)     
     	 			li   $t1, '0'  
      				sb   $t1, ($t5)     
    	 			li   $t3, 10         
     
				luup5:
					div  $t9, $t3       
      				mflo $t9
    			 	mfhi $t6            
     	 			addi $t6, $t6, 48   
     	 			addi $t2, $t2, 1	
      				sb   $t6, ($t5)    
     				sub  $t5, $t5, 1    
     				bne  $t9, $0, luup5 
     				addi $t5, $t5, 1  
     				
     				li $v0, 4
					la $a0, ($t5)
					syscall
					
				load5:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					#############################################
	
        				
        	# printf("%s%d\n","] , size = ",max_size-1);
        	li $v0, 4
        	la $a0, sizeStr
        	syscall
		
			addi $t9, $s2, -1	 	    # $t9 = max_size - 1 
        	addi $t9, $t9, 48
        	sb   $t9, sizeArr	
			
			li $v0, 4
        	la $a0, sizeArr($zero)
        	syscall
			
			li $v0, 4
        	la $a0, newLine
        	syscall
			
			# printf("%s","Array_outp: [");
			li $v0, 15
			addi $a0, $a3, 0
			la $a1, outpStr
			la $a2, 13     
			syscall				
        	
        								
    	    			# printf("%d",output[0]);	
        		#############################################
					sb   $t5, garb
					sb   $t6, garb2		  
					sb   $t3, garb3		   
					sb   $t1, garb4	
					sb   $t2, garb5
				###
				# Same procedure...
				###
				itoa6:
					li $t2, 0
					lb $t9, output($zero)      				
					
     				la   $t5, sixthArr+4     
     	 			sb   $0,  1($t5)     
     	 			li   $t1, '0'  
      				sb   $t1, ($t5)     
    	 			li   $t3, 10          
     
				luup6:
					div  $t9, $t3       
      				mflo $t9
    			 	mfhi $t6           
     	 			addi $t6, $t6, 48   
     	 			addi $t2, $t2, 1	
      				sb   $t6, ($t5)     
     				sub  $t5, $t5, 1   
     				bne  $t9, $0, luup6  
     				addi $t5, $t5, 1   
     				
     				li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, ($t5)
					la   $a2, 1     				 
					syscall
					
					beq $t2, 1, load6
					addi $t2, $t2, -1
		
					li   $v0, 15
					addi $a0, $a3, 0
					la   $a1, 1($t5)
					la   $a2, ($t2)    			 
					syscall
					
				load6:
					lb $t2, garb5		# $t2 = last_i
					lb $t1, garb4	    # $t1 = n
					lb $t5, garb	    # $t5 = again
					lb $t6, garb2		# $t6 = over 
					lb $t3, garb3		# $t3 = flag  
					#############################################
					
        	
        	# printf("%s%d\n","] , size = ",max_size-1);
			li   $v0, 15
			addi $a0, $a3, 0
			la   $a1, sizeStr
			la   $a2, 11          	 	# length of sizeStr     				
			syscall	
		
				
			addi $t9, $s2, -1	 	    # $t9 = max_size - 1 
        	addi $t9, $t9, 48
        	sb   $t9, sizeArr	
				
			li   $v0, 15 	    
			addi $a0, $a3, 0
			la   $a1, sizeArr($zero)
			la   $a2, 1         	    
			syscall	
       		
       		li   $v0, 15
			addi $a0, $a3, 0
			la   $a1, newLine
			li   $a2, 1        	      				
			syscall	
			
			li $v0, 4
			la $a0, newLine
			syscall
			
			
			lb   $s7, 28($sp)
			lb   $s6, 24($sp)
			lb   $s5, 20($sp)
			lb   $s4, 16($sp)
			lb   $s3, 12($sp)
			lb   $s2, 8($sp)
			lb   $s1, 4($sp)
			lb   $s0, 0($sp)
			addi $sp, $sp, 32
			# Load save registers from memory
			#################################

		
			##
       		jr $ra  		
			##
			
			
	exit:
		# Closing output file
		li $v0, 16
		move $a0, $a3
		syscall
		
		# Exiting from program
		li $v0, 10
		syscall
		
