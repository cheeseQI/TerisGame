restart: addi $1 $0 0   # n1-n4 #####################################################
addi $2 $0 0
addi $3 $0 0
addi $4 $0 0
addi $12 $12 0   #score
output $12
addi $13 $0 300   # r13 = 200 - dmem start address(block[0])
addi $14 $0 500   # end address 
clean: sw   $0  0($13) #clean all block##########################################################
addi $13 $13 1
bgt  $14 $13 clean # until $13 >= 300
addi $31 $0 42 ##########################################set default jump register################!!!!!!!!!!!!!!!!!!!!!11
addi $30 $0 300 #############set out of left boarder start########
addi $29 $0 499 
addi $28 $0 3 #stuck constant
addLeftBoarder: sw $28 0($30)
addi $30 $30 10
bgt $29 $30 addLeftBoarder
addi $30 $0 309 #############set out of left boarder start########
addi $29 $0 500 
addRightBoarder: sw $28 0($30)
addi $30 $30 10
bgt $29 $30 addRightBoarder
addi $30 $0 490 #############set out of left boarder start########
addi $29 $0 500
addDownBoarder: sw $28 0($30)
addi $30 $30 1
bgt $29 $30 addDownBoarder
addi $9 $0 1
addi $16 $0 19
sll $9 $9 $16 # 2^19 speed controller#############################################
updateBlock: addi $19 $0 300 # start from 300 in demem ###########update block################################
addi $16 $0 22
addi $17 $0 1 
sll  $16 $17 $16    # 2^22 trigger  block.mif(vga reading) and also the vga_addr ++
lw $18 0($19) # load block type info (0,1,3) in temp reg 
sw $18 0($16) # only used for vga, too large for dmem addr, will not store
addi $16 $16 1 # only used for vga
addi $19 $19 1 # only used for counting and load
bgt  $14 $19 -5 # check whether reach end
jr $31
mainLoop: addi $15 $0 1 #####################main loop############################################
addi $7 $0 20
sll  $7 $15 $7       # trigger block & random 1000...000 
lw   $6 0($7)        # read random number->random block;
addi $13 $0 300 # initialize start addi
addi $15 $0 0
addi $16 $0 1
addi $17 $0 2
addi $18 $0 3
addi $19 $0 4
addi $5 $0 0 # set initial rotate type
beq $6 $15 createShape0
beq $6 $16 createShape1
beq $6 $17 createShape2
beq $6 $18 createShape3
beq $6 $19 createShape4
movementBegin: addi $10 $0 0 # counter
movement: addi $20 $0 97     # r20 key "a"  97 #########################movement#####################
addi $21 $0 100    # r21 key "d" 100
addi $22 $0 119    # r22 for key "w" 119
addi $23 $0 115		# r23 for key"s" 113
addi $24 $0 112     # r24 for "p"
addi $25 $0 104        # r25 for "h"
input $11           # r11 used for input signal
beq $11 $20 left
beq $11 $21 right #################need other input######################################################
beq $11 $22 rotate
beq $11 $23 down
beq $11 $25 hardMode
beq $11 $24 interrupt
endmove: addi $10 $10 1 # counter++
bgt $9 $10 movement # if N still > c loop again
down: addi $15 $1 10
addi $16 $2 10
addi $17 $3 10
addi $18 $4 10 
lw $25 0($15)
addi $30 $0 3
beq $25 $30 checkClear
lw $25 0($16)
beq $25 $30 checkClear
lw $25 0($17)
beq $25 $30 checkClear
lw $25 0($18)
beq $25 $30 checkClear #check whether meet stuck
sw $0 0($1) # original block to be blank(0)
sw $0 0($2)
sw $0 0($3)
sw $0 0($4)
addi $1 $1 10 # move down
addi $26 $0 1 # valid bit = 1
sw $26 0($1) # store in dmem
addi $2 $2 10
sw $26 0($2) 
addi $3 $3 10 
sw $26 0($3) 
addi $4 $4 10
sw $26 0($4)
jal updateBlock
bgt $9 $10 endmove
j movementBegin # back to moveBegin
createShape0: addi $1 $13 3 # set n1 - n4 ##########################createShape()#############################################
addi $2 $13 4
addi $3 $13 5
addi $4 $13 6
addi $30 $0 3 #stuck constant 3
lw $15 0($1) 
beq $15 $30 gameOver # check whether meets stuck block
lw $15 0($2) 
beq $15 $30 gameOver
lw $15 0($3) 
beq $15 $30 gameOver
lw $15 0($4) 
beq $15 $30 gameOver
addi $16 $0 1 # constant 1
sw $16 0($1) # constant 1 store into n1 block(valid) 
sw $16 0($2)
sw $16 0($3)
sw $16 0($4) # constant 1 store into n4 block(valid) 
jal updateBlock #update back
j movementBegin
createShape1: addi $1 $13 4 # set n1 - n4
addi $2 $13 5
addi $3 $13 6
addi $4 $13 15
addi $30 $0 3 #stuck constant 3
lw $15 0($1) 
beq $15 $30 gameOver # check whether meets stuck block
addi $16 $0 1 
sw $16 0($1) # constant 1 store into n1 block(valid) 
lw $15 0($2) 
beq $15 $30 gameOver
sw $16 0($2) # constant 1 store into n2 block(valid) 
lw $15 0($3) 
beq $15 $30 gameOver
sw $16 0($3) # constant 1 store into n3 block(valid) 
lw $15 0($4) 
beq $15 $30 gameOver
sw $16 0($4) # constant 1 store into n4 block(valid) 
jal updateBlock #update back
j movementBegin
createShape2: addi $1 $13 5 # set n1 - n4
addi $2 $13 15
addi $3 $13 25
addi $4 $13 24
addi $30 $0 3 #stuck constant 3
lw $15 0($1) 
beq $15 $30 gameOver # check whether meets stuck block
addi $16 $0 1 
sw $16 0($1) # constant 1 store into n1 block(valid) 
lw $15 0($2) 
beq $15 $30 gameOver
sw $16 0($2) # constant 1 store into n2 block(valid) 
lw $15 0($3) 
beq $15 $30 gameOver
sw $16 0($3) # constant 1 store into n3 block(valid) 
lw $15 0($4) 
beq $15 $30 gameOver
sw $16 0($4) # constant 1 store into n4 block(valid) 
jal updateBlock #update back
j movementBegin
createShape3: addi $1 $13 5 # set n1 - n4
addi $2 $13 6
addi $3 $13 14
addi $4 $13 15
addi $30 $0 3 #stuck constant 3
lw $15 0($1) 
beq $15 $30 gameOver # check whether meets stuck block
addi $16 $0 1 
sw $16 0($1) # constant 1 store into n1 block(valid) 
lw $15 0($2) 
beq $15 $30 gameOver
sw $16 0($2) # constant 1 store into n2 block(valid) 
lw $15 0($3) 
beq $15 $30 gameOver
sw $16 0($3) # constant 1 store into n3 block(valid) 
lw $15 0($4) 
beq $15 $30 gameOver
sw $16 0($4) # constant 1 store into n4 block(valid) 
jal updateBlock #update back
j movementBegin
createShape4: addi $1 $13 4 # set n1 - n4
addi $2 $13 5
addi $3 $13 14
addi $4 $13 15
addi $30 $0 3 #stuck constant 3
lw $15 0($1) 
beq $15 $30 gameOver # check whether meets stuck block
addi $16 $0 1 
sw $16 0($1) # constant 1 store into n1 block(valid) 
lw $15 0($2) 
beq $15 $30 gameOver
sw $16 0($2) # constant 1 store into n2 block(valid) 
lw $15 0($3) 
beq $15 $30 gameOver
sw $16 0($3) # constant 1 store into n3 block(valid) 
lw $15 0($4) 
beq $15 $30 gameOver
sw $16 0($4) # constant 1 store into n4 block(valid) 
jal updateBlock #update back
j movementBegin
left: addi $15 $1 -1
addi $16 $2 -1
addi $17 $3 -1
addi $18 $4 -1 #left shift
addi $30 $0 3 #constant 3
lw $25 0($15)
beq $25 $30 endmove
lw $25 0($16)
beq $25 $30 endmove
lw $25 0($17)
beq $25 $30 endmove
lw $25 0($18)
beq $25 $30 endmove #check whether meet stuck
addi $26 $0 1 # valid bit = 1
sw $0 0($1) # original block to be blank(0)
sw $0 0($2) # original block to be blank(0)
sw $0 0($3) # original block to be blank(0)
sw $0 0($4) # original block to be blank(0)
addi $1 $1 -1 # move left
sw $26 0($1) 
addi $2 $2 -1 # move left
sw $26 0($2)
addi $3 $3 -1 # move left
sw $26 0($3) 
addi $4 $4 -1 # move left
sw $26 0($4) 
jal updateBlock
j endmove
right: addi $15 $1 1
addi $16 $2 1
addi $17 $3 1
addi $18 $4 1 # right shift
addi $30 $0 3
lw $25 0($15)
beq $25 $30 endmove
lw $25 0($16)
beq $25 $30 endmove
lw $25 0($17)
beq $25 $30 endmove
lw $25 0($18)
beq $25 $30 endmove # check whether meet stuck
addi $26 $0 1 # valid bit = 1
sw $0 0($4) # original block to be blank(0)
sw $0 0($3) # original block to be blank(0)
sw $0 0($2) # original block to be blank(0)
sw $0 0($1) # original block to be blank(0)
addi $4 $4 1 # move right
sw $26 0($4) 
addi $3 $3 1 # move right
sw $26 0($3)  
addi $2 $2 1 # move right
sw $26 0($2)
addi $1 $1 1 # move right
sw $26 0($1)
jal updateBlock 
j endmove
gameOver: j gameOver
interrupt: input $11
addi $11 $11 -114
beq $11 $0 endmove
j interrupt
checkClear: addi $15 $0 3 # constant 3 for stuck################################check whether should we clear##########
sw $15 0($1)
sw $15 0($2)
sw $15 0($3)
sw $15 0($4)
addi $16 $14 -20 # start of last line, as h
checkClearWhile1: addi $15 $0 0 # count for stuck, init and set zero per loop
addi $17 $0 0 # while2 loop counter j
addi $25 $0 10 # while2 loop times
checkClearWhile2: addi $17 $17 1 # while1 loop counter j++
add $18 $16 $17 # block[h+j], 10-blocks while loop
lw $19 0($18) # value of block[h+j]
addi $30 $0 3 # value of 3 ###temp constant 3 will be replaced when loop
beq $19 $30 counterPlus
bgt $25 $17 checkClearWhile2 # when 10 > j
beq $15 $25 clear # when count == 10 call clear
j clearElse
counterPlus: addi $15 $15 1 #count for stuck
bgt $25 $17 checkClearWhile2
beq $15 $25 clear # when count == 10 call clear
clearElse: addi $16 $16 -10
addi $26 $16 -30 #temp check h-30
bgt $26 $13 checkClearWhile1 #when N > h - 30
j mainLoop # back to down function # no need to update
clear: addi $12 $12 10 #score += 10
output $12
add $24 $0 $16 #temp register for store current h value!
addi $26 $16 -30 #temp check h-30
clearWhile: addi $28 $0 0 # while loop counter i, used to clear every line, move upper into lower
addi $29 $0 10 # while loop width
clearInnerWhile: add $30 $24 $28 # block[h+i]
addi $7 $30 -10 # h+j -10
lw $27 0($7) # value of block[h+i-10]
sw $27 0($30) # value of h+j-10 => addr of h+i
addi $28 $28 1 # i++
bgt $29 $28 clearInnerWhile  # i < width
addi $24 $24 -10 #h -= 10 
bgt $24 $13 clearWhile 
bgt $26 $13 checkClearWhile1 # when begin < h - 30
j mainLoop
rotate: sw $0 0($1)   # rotate type 0, 1, 2, 3 in $5 initial default as 0
sw $0 0($2) 
sw $0 0($3)
sw $0 0($4)  # set current block as blank
addi $27 $0 0 # variable used to change and measure $6 value 
beq $6 $27 rotate0 # check which random shape it is!
addi $27 $0 1
beq $6 $27 rotate1
addi $27 $0 2
beq $6 $27 rotate2
addi $27 $0 3
beq $6 $27 rotate3
j rotateFinish
rotate0: beq $5 $0 rotate00 #check type finding real rotate shape
addi $30 $0 1
beq $5 $30 rotate01
rotate1: beq $5 $0 rotate10 #check type finding real rotate shape
addi $30 $0 1
beq $5 $30 rotate11
addi $30 $0 2
beq $5 $30 rotate12
addi $30 $0 3
beq $5 $30 rotate13
rotate2: beq $5 $0 rotate20 #check type finding real rotate shape
addi $30 $0 1
beq $5 $30 rotate21
addi $30 $0 2
beq $5 $30 rotate22
addi $30 $0 3
beq $5 $30 rotate23
rotate3: beq $5 $0 rotate30 #check type finding real rotate shape
addi $30 $0 1
beq $5 $30 rotate31
rotate00: nop
addi $15 $0 3 #constant 3   -9 0 9 18
addi $16 $1 -9 # block[n1-9]
lw $17 0($16) # value of block[n1-9]
beq $17 $15 rotateFinish
lw $17 $2 # value of block[n2]
beq $17 $15 rotateFinish
addi $16 $3 9 # block[n3+9]
lw $17 0($16)
beq $17 $15 rotateFinish
addi $16 $4 18 # block[n4+18]
lw $17 0($16) 
beq $17 $15 rotateFinish
addi $1 $1 -9
addi $3 $3 9
addi $4 $4 18
addi $5 $0 1
j rotateFinish
rotate01: nop
addi $15 $0 3 # 9 0 -9 -18
addi $16 $1 9 # block[n1+9]
lw $17 0($16) # value of block[n1+9]
beq $17 $15 rotateFinish
lw $17 0($2) # value of block[n2]
beq $17 $15 rotateFinish
addi $16 $3 -9 # block[n3-9]
lw $17 0($16) 
beq $17 $15 rotateFinish
addi $16 $4 -18 # block[n4-18]
lw $17 0($16) 
beq $17 $15 rotateFinish
addi $1 $1 9
addi $3 $3 -9
addi $4 $4 -18
addi $5 $0 0
j rotateFinish
rotate10: nop
addi $15 $0 3 #constant 3   0 0 -11 0
lw $17 0($1) # value of block[n1]
beq $17 $15 rotateFinish
lw $17 $2 # value of block[n2]
beq $17 $15 rotateFinish
addi $16 $3 -11 # block[n3-11]
lw $17 0($16) 
beq $17 $15 rotateFinish
lw $17 0($4) 
beq $17 $15 rotateFinish
addi $3 $3 -11
addi $5 $0 1 #go to next state
j rotateFinish
rotate11: nop
nop
addi $15 $0 3 #constant 3  0 0 0 -9
lw $17 0($1) # value of block[n1]
beq $17 $15 rotateFinish
lw $17 0($2) # value of block[n2]
beq $17 $15 rotateFinish
lw $17 0($3) 
beq $17 $15 rotateFinish
addi $16 $4 -9
lw $17 0($16)  #block[n4-9]
beq $17 $15 rotateFinish
addi $4 $4 -9
addi $5 $0 2 #go to next state
j rotateFinish
rotate12: nop
addi $15 $0 3 #constant 3  11 0 0 0
addi $16 $1 11
lw $17 0($16) # value of block[n1 + 11]
beq $17 $15 rotateFinish
lw $17 0($2) # value of block[n2]
beq $17 $15 rotateFinish
lw $17 0($3) #block[n3]
beq $17 $15 rotateFinish
lw $17 0($4)  #block[n4]
beq $17 $15 rotateFinish
addi $1 $1 11
addi $5 $0 3 #go to next state
j rotateFinish
rotate13: nop
nop
addi $15 $0 3 #constant 3  -11 0 11 9
addi $16 $1 -11
lw $17 0($16) # value of block[n1 - 11]
beq $17 $15 rotateFinish
lw $17 0($2) # value of block[n2]
beq $17 $15 rotateFinish
addi $16 $3 11
lw $17 0($16) #block[n3 + 11]
beq $17 $15 rotateFinish
addi $16 $4 9
lw $17 0($16)  #block[n4+9]
beq $17 $15 rotateFinish
addi $1 $1 -11
addi $3 $3 11
addi $4 $4 9
addi $5 $0 0 #go to next state
j rotateFinish
rotate20: nop
nop
addi $15 $0 3 #constant 3  22 11 0 -9
addi $16 $1 22
lw $17 0($16) # value of block[n1 + 22]
beq $17 $15 rotateFinish
addi $16 $2 11
lw $17 0($16) # value of block[n2+11]
beq $17 $15 rotateFinish
lw $17 0($3) #block[n3]
beq $17 $15 rotateFinish
addi $16 $4 -9
lw $17 0($16)  #block[n4-9]
beq $17 $15 rotateFinish
addi $1 $1 22
addi $2 $2 11
addi $3 $3 0
addi $4 $4 -9
addi $5 $0 1 #go to next state
j rotateFinish
rotate21: nop
nop
addi $15 $0 3 #constant 3  18 9 0 11
addi $16 $1 18
lw $17 0($16) # value of block[n1 + 18]
beq $17 $15 rotateFinish
addi $16 $2 9
lw $17 0($16) # value of block[n2+9]
beq $17 $15 rotateFinish
lw $17 0($3) #block[n3]
beq $17 $15 rotateFinish
addi $16 $4 11
lw $17 0($16)  #block[n4+11]
beq $17 $15 rotateFinish
addi $1 $1 18
addi $2 $2 9
addi $3 $3 0
addi $4 $4 11
addi $5 $0 2 #go to next state
j rotateFinish
rotate22: nop
nop
addi $15 $0 3 #constant 3  -22 -11 0 9
addi $16 $1 -22
lw $17 0($16) # value of block[n1 -22]
beq $17 $15 rotateFinish
addi $16 $2 -11
lw $17 0($16) # value of block[n2-11]
beq $17 $15 rotateFinish
lw $17 0($3) #block[n3]
beq $17 $15 rotateFinish
addi $16 $4 9
lw $17 0($16)  #block[n4+9]
beq $17 $15 rotateFinish
addi $1 $1 -22
addi $2 $2 -11
addi $3 $3 0
addi $4 $4 9
addi $5 $0 3 #go to next state
j rotateFinish
rotate23: nop
nop
addi $15 $0 3 #constant 3  -18 -9 0 -11
addi $16 $1 -18
lw $17 0($16) # value of block[n1 + 18]
beq $17 $15 rotateFinish
addi $16 $2 -9
lw $17 0($16) # value of block[n2+9]
beq $17 $15 rotateFinish
lw $17 0($3) #block[n3]
beq $17 $15 rotateFinish
addi $16 $4 -11
lw $17 0($16)  #block[n4-11]
beq $17 $15 rotateFinish
addi $1 $1 -18
addi $2 $2 -9
addi $3 $3 0
addi $4 $4 -11
addi $5 $0 0 #go to next state
j rotateFinish
rotate30:nop
nop
addi $15 $0 3 #constant 3  11 20 -9 0
addi $16 $1 11
lw $17 0($16) # value of block[n1 + 11]
beq $17 $15 rotateFinish
addi $16 $2 20
lw $17 0($16) # value of block[n2+20]
beq $17 $15 rotateFinish
addi $16 $3 -9
lw $17 0($16) #block[n3-9]
beq $17 $15 rotateFinish
lw $17 0($4)  #block[n4]
beq $17 $15 rotateFinish
addi $1 $1 11
addi $2 $2 20
addi $3 $3 -9
addi $4 $4 0
addi $5 $0 1 #go to next state
j rotateFinish
rotate31:nop
nop
addi $15 $0 3 #constant 3  -11 -20 9 0
addi $16 $1 -11
lw $17 0($16) # value of block[n1 -11 ]
beq $17 $15 rotateFinish
addi $16 $2 -20
lw $17 0($16) # value of block[n2-20]
beq $17 $15 rotateFinish
addi $16 $3 9
lw $17 0($16) #block[n3+9]
beq $17 $15 rotateFinish
lw $17 0($4)  #block[n4]
beq $17 $15 rotateFinish
addi $1 $1 -11
addi $2 $2 -20
addi $3 $3 9
addi $4 $4 0
addi $5 $0 0 #go to next state
j rotateFinish
rotateFinish: nop
nop # deal with translator error
addi $15 $0 1 #finish set valid and update
sw $15 0($1)
sw $15 0($2)
sw $15 0($3)
sw $15 0($4)
jal updateBlock
j endmove
jr $31
hardMode: nop
addi $30 $0 1
srl $9 $9 $30
j endmove  