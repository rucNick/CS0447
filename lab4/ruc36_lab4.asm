# Nick Cao
# ruc36

.include "lab4_include.asm"

.eqv NUM_DOTS 3

.data
	dotX: .word 10, 30, 50
	dotY: .word 20, 30, 40
	curDot: .word 0
.text
.globl main
main:
	
	# when done at the beginning of the program, clears the display
	# because the display RAM is all 0s (black) right now.
	jal display_update_and_clear

	_loop:
		# code goes here!
		jal check_input
		jal wrap_dot_position
		jal draw_dots
		jal display_update_and_clear # from your include file
		jal sleep # from your include file
	j _loop

_exit:
	# exit()
	li v0, 10
	syscall

#-----------------------------------------

# methods go here
draw_dots:
push ra
push s0
	
	_loop:
	lw  t0,curDot
	beq t0,s0, _orange
	j   _default
	#case orange
	_orange:
	li a2, COLOR_ORANGE
	j _break
	#case default
	 _default:
	li a2, COLOR_WHITE
	j _break
	
	_break:
	mul t1,s0,4
	lw a0, dotX(t1)
	lw a1, dotY(t1)
	jal display_set_pixel
	add s0,s0,1
	blt s0,NUM_DOTS,_loop
pop s0
pop ra
jr ra
#------------------------------------------------------------------------
check_input:
push ra
	jal input_get_keys_held
	and t0, v0, KEY_Z
	bne t0, $0, _Z
	and t0, v0, KEY_X
	bne t0, $0, _X
	and t0, v0, KEY_C
	bne t0, $0, _C
	#case Z
	_Z:
	beq t0, 0, _break
	li t0, 0
         	sw t0, curDot
         	j _break
         	#case X
         	_X:
         	beq t0, 0, _break
	li t0, 1
         	sw t0, curDot
         	j _break
         	#case C
         	_C:
         	beq t0, 0, _break
	li t0, 2
         	sw t0, curDot
         	j _break
        _break:
        #------------------------------------	
	#moving dots
	lw  t8,curDot
	and t0, v0, KEY_R
	bne t0, $0, _keyR
	and t0, v0, KEY_L
	bne t0, $0, _keyL
	and t0, v0, KEY_D
	bne t0, $0, _keyD
	and t0, v0, KEY_U
	bne t0, $0, _keyU
	#case right
	_keyR:
	beq t0, 0, _end
	mul t1,t8,4
	lw a0, dotX(t1) 
	add a0,a0,1
	sw a0, dotX(t1)
	j _end
	#case Left
	_keyL:
	beq t0, 0, _end
	mul t1,t8,4
	lw a0, dotX(t1) 
	sub a0,a0,1
	sw a0, dotX(t1)
	j _end
	#case Down
	_keyD:
	beq t0, 0, _end
	mul t1,t8,4
	lw a0, dotY(t1) 
	add a0,a0,1
	sw a0, dotY(t1)
	j _end
	#case Up
	_keyU:
	beq t0, 0, _end
	mul t1,t8,4
	lw a0, dotY(t1) 
	sub a0,a0,1
	sw a0, dotY(t1)
	j _end
_end:						
pop ra	
jr ra

wrap_dot_position:
push ra	
	lw t0, curDot
	mul t1,t0,4
	lw a0, dotX(t1)
	lw a1, dotY(t1)
	and a0, a0,63
	and a1, a1,63
	sw a0,dotX(t1)
	sw a1,dotY(t1)
pop ra	
jr ra







#-----------
	jal input_get_keys_held
	lw t8,snake_dir
	and t0, v0, KEY_R
	bne t0, $0, _keyR
	
	and t0, v0, KEY_L
	bne t0, $0, _keyL
	
	and t0, v0, KEY_D
	bne t0, $0, _keyD
	
	and t0, v0, KEY_U
	bne t0, $0, _keyU
	#case right
	_keyR:
	beq t0, 0, _end
	li t8,DIR_E
	sw t8,snake_dir(s0)
	j _end
	#case Left
	_keyL:
	beq t0, 0, _end
	li t8,DIR_W
	sw t8,snake_dir(s0)
	j _end
	#case Down
	_keyD:
	beq t0, 0, _end
	li t8,DIR_S
	sw t8,snake_dir(s0)
	j _end
	#case Up
	_keyU:
	beq t0, 0, _end
	li t8,DIR_N
	sw t8,snake_dir(s0)
	j _end		
_end:	





#--------------------------------


	li v0,42
	syscall
	move t0,v0
	li t1,14
	div t0,t1
	mfhi t0
	addi t0,t0,1
	sw t0,apple_y
	
	li v0,42
	syscall
	move t0,v0
	li t1,16
	div t0,t1
	mfhi t0
	addi t0,t0,1
	sw t0,apple_x

