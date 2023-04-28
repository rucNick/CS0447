# Nick Cao
# ruc36

# Cardinal directions.
.eqv DIR_N 0
.eqv DIR_E 1
.eqv DIR_S 2
.eqv DIR_W 3

# Game grid dimensions.
.eqv GRID_CELL_SIZE 4 # pixels
.eqv GRID_WIDTH  16 # cells
.eqv GRID_HEIGHT 14 # cells
.eqv GRID_CELLS 224 #= GRID_WIDTH * GRID_HEIGHT

# How long the snake can possibly be.
.eqv SNAKE_MAX_LEN GRID_CELLS # segments

# How many frames (1/60th of a second) between snake movements.
.eqv SNAKE_MOVE_DELAY 12 # frames

# How many apples the snake needs to eat to win the game.
.eqv APPLES_NEEDED 20

# ------------------------------------------------------------------------------------------------
.data

# set to 1 when the player loses the game (running into the walls/other part of the snake).
lost_game: .word 0

# the direction the snake is facing (one of the DIR_ constants).
snake_dir: .word DIR_N

# how long the snake is (how many segments).
snake_len: .word 2

# parallel arrays of segment coordinates. index 0 is the head.
snake_x: .byte 0:SNAKE_MAX_LEN
snake_y: .byte 0:SNAKE_MAX_LEN

# used to keep track of time until the next time the snake can move.
snake_move_timer: .word 0

# 1 if the snake changed direction since the last time it moved.
snake_dir_changed: .word 0

# how many apples have been eaten.
apples_eaten: .word 0

# coordinates of the (one) apple in the world.
apple_x: .word 3
apple_y: .word 2

# A pair of arrays, indexed by direction, to turn a direction into x/y deltas.
# e.g. direction_delta_x[DIR_E] is 1, because moving east increments X by 1.
#                         N  E  S  W
direction_delta_x: .byte  0  1  0 -1
direction_delta_y: .byte -1  0  1  0

.text

# ------------------------------------------------------------------------------------------------

# these .includes are here to make these big arrays come *after* the interesting
# variables in memory. it makes things easier to debug.
.include "display_2211_0822.asm"
.include "textures.asm"

# ------------------------------------------------------------------------------------------------

.text
.globl main
main:
	jal setup_snake
	jal wait_for_game_start

	# main game loop
	_loop:
		jal check_input
		jal update_snake
		jal draw_all
		jal display_update_and_clear
		jal wait_for_next_frame
	jal check_game_over
	beq v0, 0, _loop

	# when the game is over, show a message
	jal show_game_over_message
syscall_exit

# ------------------------------------------------------------------------------------------------
# Misc game logic
# ------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------

# waits for the user to press a key to start the game (so the snake doesn't go barreling
# into the wall while the user ineffectually flails attempting to click the display (ask
# me how I know that that happens))
wait_for_game_start:
enter
	_loop:
		jal draw_all
		jal display_update_and_clear
		jal wait_for_next_frame
	jal input_get_keys_pressed
	beq v0, 0, _loop
leave

# ------------------------------------------------------------------------------------------------

# returns a boolean (1/0) of whether the game is over. 1 means it is.
check_game_over:
enter
	li v0, 0

	# if they've eaten enough apples, the game is over.
	lw t0, apples_eaten
	blt t0, APPLES_NEEDED, _endif
		li v0, 1
		j _return
	_endif:

	# if they lost the game, the game is over.
	lw t0, lost_game
	beq t0, 0, _return
		li v0, 1
_return:
leave

# ------------------------------------------------------------------------------------------------

show_game_over_message:
enter
	# first clear the display
	jal display_update_and_clear

	# then show different things depending on if they won or lost
	lw t0, lost_game
	bne t0, 0, _lost
		# they finished successfully!
		li   a0, 7
		li   a1, 25
		lstr a2, "yay! you"
		li   a3, COLOR_GREEN
		jal  display_draw_colored_text

		li   a0, 12
		li   a1, 31
		lstr a2, "did it!"
		li   a3, COLOR_GREEN
		jal  display_draw_colored_text
	j _endif
	_lost:
		# they... didn't...
		li   a0, 5
		li   a1, 30
		lstr a2, "oh no :("
		li   a3, COLOR_RED
		jal  display_draw_colored_text
	_endif:

	jal display_update_and_clear
leave

# ------------------------------------------------------------------------------------------------
# Snake
# ------------------------------------------------------------------------------------------------

# sets up the snake so the first two segments are in the middle of the screen.
setup_snake:
enter
	# snake head in the middle, tail below it
	li  t0, GRID_WIDTH
	div t0, t0, 2
	sb  t0, snake_x
	sb  t0, snake_x + 1

	li  t0, GRID_HEIGHT
	div t0, t0, 2
	sb  t0, snake_y
	add t0, t0, 1
	sb  t0, snake_y + 1
leave

# ------------------------------------------------------------------------------------------------

# checks for the arrow keys to change the snake's direction.
check_input:
enter
 #------------------------------------
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
	
	
leave

# ------------------------------------------------------------------------------------------------

# update the snake.
update_snake:
enter	
	lw t0,snake_move_timer
	li t1,SNAKE_MOVE_DELAY
	
	bne t0,$0,_if
	
	move t0,t1
	sw t0,snake_move_timer
	sw $0,snake_dir_changed
	jal move_snake
	j _end	
_if:
	
	sub t0,t0,1
	sw t0,snake_move_timer
_end:
	
	
leave

# ------------------------------------------------------------------------------------------------

move_snake:
enter s0,s1	
	
	jal compute_next_snake_pos
	blt s0,$0,_game_over
	bge s0,GRID_WIDTH,_game_over
	blt s1,$0,_game_over
	bge s1,GRID_HEIGHT,_game_over
	
	jal shift_snake_segments
	sb s0,snake_x
	sb s1,snake_y
	j _break
_game_over:
	li t2,1
	sw t2,lost_game
	j _break
_break:	
leave s0,s1

# ------------------------------------------------------------------------------------------------

shift_snake_segments:
enter
	lw t0,snake_len
	sub t0,t0,1
	li t1,1
_loop:	
	move t2,t0
	sub t2,t2,1
	lb v0,snake_x(t2)
	lb v1,snake_y(t2)
	sb v0,snake_x(t0)
	sb v1,snake_y(t0)
	sub t0,t0,1
	sge s3,t0,t1
	beq s3,t1,_loop
leave

# ------------------------------------------------------------------------------------------------

move_apple:
enter	
	
leave

# ------------------------------------------------------------------------------------------------

compute_next_snake_pos:
enter
	# t9 = direction
	lw t9, snake_dir

	# v0 = direction_delta_x[snake_dir]
	lb v0, snake_x
	lb t0, direction_delta_x(t9)
	add v0, v0, t0

	# v1 = direction_delta_y[snake_dir]
	lb v1, snake_y
	lb t0, direction_delta_y(t9)
	add v1, v1, t0
leave

# ------------------------------------------------------------------------------------------------

# takes a coordinate (x, y) in a0, a1.
# returns a boolean (1/0) saying whether that coordinate is part of the snake or not.
is_point_on_snake:
enter
	# for i = 0 to snake_len
	li t9, 0
	_loop:
		lb t0, snake_x(t9)
		bne t0, a0, _differ
		lb t0, snake_y(t9)
		bne t0, a1, _differ

			li v0, 1
			j _return

		_differ:
	add t9, t9, 1
	lw  t0, snake_len
	blt t9, t0, _loop

	li v0, 0

_return:
leave

# ------------------------------------------------------------------------------------------------
# Drawing functions
# ------------------------------------------------------------------------------------------------

draw_all:
enter
	# if we haven't lost...
	lw t0, lost_game
	bne t0, 0, _return

		# draw everything.
		jal draw_snake
		jal draw_apple
		jal draw_hud
_return:
leave

# ------------------------------------------------------------------------------------------------

draw_snake:
enter s0
	
_loop:	
	lw v0,snake_len
	lb a0,snake_x(s0)
	lb a1,snake_y(s0)
	mul a0,a0,4
	mul a1,a1,4
	beq s0,$0,_head
	j _normal
_head:	
	lw t1,snake_dir
	mul t1,t1,4
	lw a2,tex_snake_head(t1)
	jal display_blit_5x5_trans
	add s0,s0,1
	blt s0,v0,_loop
	
_normal:	
	la a2,tex_snake_segment
	jal display_blit_5x5_trans
	add s0,s0,1	
	blt s0,v0,_loop	
leave s0

# ------------------------------------------------------------------------------------------------

draw_apple:
enter
	lw a0,apple_x
	li t0,GRID_CELL_SIZE
	mul a0,t0,a0
	lw a1,apple_y
	mul a1,t0,a1
	la a2, tex_apple
	jal display_blit_5x5_trans
	
leave

# ------------------------------------------------------------------------------------------------

draw_hud:
enter
	# draw a horizontal line above the HUD showing the lower boundary of the playfield
	li  a0, 0
	li  a1, GRID_HEIGHT
	mul a1, a1, GRID_CELL_SIZE
	li  a2, DISPLAY_W
	li  a3, COLOR_WHITE
	jal display_draw_hline

	# draw apples collected out of remaining
	li a0, 1
	li a1, 58
	lw a2, apples_eaten
	jal display_draw_int

	li a0, 13
	li a1, 58
	li a2, '/'
	jal display_draw_char

	li a0, 19
	li a2, 58
	li a2, APPLES_NEEDED
	jal display_draw_int
leave
