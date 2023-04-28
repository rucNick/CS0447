#ruc36_lab1
#Nick Cao //ruc36
.globl main
.data
      x: .word 0
      y: .word 0
.text
main:
     # loading immediates into registers
     li t0,1
     li t1,2
     li t2,3
     # moving values between registers
      move a0,t1
      move v0,t1
      move t2,zero

     # print 123
     li a0,123
     li v0,1
     syscall
     # print the newline
     li a0,'\n'
     li v0,11
     syscall
     # print 456
     li a0,456
     li v0,1
     syscall
     
     # input and global variables
     # print the newline
     li a0,'\n'
     li v0,11
     syscall
     #use syscal number5
     li a0,0
     li v0,5
     syscall
     
     #Setting the variables
     sw v0,x
     
     #another syscal 5
     li a0,0
     li v0,5
     syscall
     
     #setting the variable y
     sw v0,y
     
     #print the sum
     lw t0,x
     lw t1,y
     add t2,t0,t1
     move a0,t2
     li v0,1
     syscall
     
     #Exit
     li a0,0
     li v0,10
     syscall
     
     
     

     
