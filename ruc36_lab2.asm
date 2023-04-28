# Nick Cao
# ruc36

#preserves a0,v0

.macro print_str %str
       .data
       print_str_message: .asciiz %str
       .text
       push a0
       push v0
       la a0, print_str_message
       li v0,4
       syscall
       pop v0
       pop a0
.end_macro

.globl main
.data
      display:.word 0
      operation: .word 0
.text
main:
     print_str "Welcome to CALCY THE CALCULATOR!!\n"
     # while(true) {
     _loop:
     lw t0,display
     move a0,t0
     li v0,1
     syscall
     print_str "\nOperation (=,+,-,*,/,c,q):"
     
     # operation = read_char();
     li v0,12
     syscall
     sw v0,operation
     
     # switch(operation) {
     lw  t0,operation
     beq t0,'q', _quit
     beq t0,'c', _clear
     beq t0,'=', _equal
     beq t0,'+', _plus
     beq t0,'-', _subtract
     beq t0,'*', _muti
     beq t0,'/', _divi
     j   _default
     
     #case /
     _divi:
           print_str"\nValue:\t"
            li v0,5
            syscall
            # value cannt be 0
            beq v0,0,_haha
            
            lw t0,display
            sw v0,display
            lw t1,display
            div t2,t0,t1
            sw t2,display
            #move a0,t2
            #li v0,1
            #syscall
            j _break
     
     #case *
     _muti:
           print_str"\nValue:\t"
            li v0,5
            syscall
            
            lw t0,display
            sw v0,display
            lw t1,display
            mul t2,t0,t1
            sw t2,display
            #move a0,t2
            #li v0,1
            #syscall
            j _break
     
     #case -
     _subtract:
             print_str"\nValue:\t"
            li v0,5
            syscall
            
            lw t0,display
            sw v0,display
            lw t1,display
            sub t2,t0,t1
            sw t2,display
            #move a0,t2
            #li v0,1
            #syscall
            j _break
     
     #case +
     _plus:
            print_str"\nValue:\t"
            li v0,5
            syscall
            
            lw t0,display
            sw v0,display
            lw t1,display
            add t2,t0,t1
            sw t2,display
            #move a0,t2
            #li v0,1
            #syscall
            j _break
            
     #case '='
     _equal:
            print_str"\nValue:\t"
            li v0,5
            syscall
            
            sw v0,display
            #move a0,v0
            #li v0,1
            #syscall
            j _break

     # case 'q'
     _quit:
          li a0,0
          li v0,10
          syscall
          j _break

     # case 'c'
     _clear:
        print_str "\nclear\n"
        sw zero,display
        j _break
     
     
     # divi by 0
     _haha:
        print_str "\nAttempting to divide by 0!\n"
        j _break

     # default:
     _default:
        print_str "\nHuh?\n"
_break:

     j _loop
     
     
     
     
     
     
