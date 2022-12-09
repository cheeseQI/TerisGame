#include <stdio.h>
#include <stdlib.h>
int n1,n2,n3,n4;
#define height 20
#define width 10
#define N 2^19 //////////////////////////////??????????????////////////
int rotateType;
int score;
#define begin  0
#define end  200
#define input 0
#define output
int block[end-begin];
int c = 0;



/**
 * @author: Siqi, Luxin, students from DKU ECE.
 * @brief :This is the C code for Teris project for ECE550, which is going to be translated into MIPS by hand
 * main function:
 * 
 * In this project, we do not use the common push stack and pop stack way, because it is a hugh project and using that
 * will make code redundant and hard to debug. So we use some register with specific purpose in the whole program!
 * 
 * Functional register:
 * $0 always equal zero
 * $31 are used as $ra
 * $1 $2 $3 $4 four blocks: n1, n2, n3, n4(position 0-200)
 * $5 rotateType(0,1,2,3) 
 * $6 randomType(0,1,2,3,4), the shape type!
 * $7 2^21 randNumber from hardware, selected by 20 bit enbale
 * $8 2^22 write???
 * $9 N speed controller
 * $10 c counter
 * $11 input from keyboard
 * $12 score
 * $13 begin
 * $14 end
 * $20 a
 * $21 d
 * $22 s
 * $23 w
 * $24 p
 * Leaving all other registers and general-purpose-register, for storing constant adder or maybe temporary used number
 * 
 * blockType: valid = 1, blank = 0, stuck = 3(r30)
 * blockSize: 20 height * 10 width, each block is 20*20 pixel
 * 
 * Five default shapes:
 * 
 * shape1 BBBB 1234
 
 * shape2 BBB  123
           B   4
 
 * shape3 BB   12
           B    3
		   B    4

 * shape4  BB  12
          BB  34

 * shape5 BB   12
          BB   34

*/


int main(){
    restart();
    while(1){ //mainLoop
        createShape(n1,n2,n3,n4);
        while(N > c){
            if (input == 97) left(n1,n2,n3,n4); //a
            if (input == 100) right(n1,n2,n3,n4); //d
            if (input ==115) down(n1,n2,n3,n4);//s
            if (input ==119) rotate(n1,n2,n3,n4); //w
            if (input == 'p') pause(n1,n2,n3,n4);//p
            c ++;
        }
        down(n1,n2,n3,n4);//normal drop
    } 
    return EXIT_SUCCESS;
}

 
void restart(){
	n1=0;
	n2=0;
	n3=0;
	n4=0;
	score=0;
	output score;;//just the output score!
	clean();
}

void clean(){
	for(int i=0;i<end-begin;i++){
		block[i]=0;
	}
}
void createShape(n1, n2, n3, n4){
	int shape = rand_generator();
	if(shape==0){
		n1=begin+3;
		n2=begin+4;
		n3=begin+5;
		n4=begin+6;
		if(block[n1]==3){
			gameover();
		}
		if(block[n2]==3){
			gameover();
		}
		if(block[n3]==3){
			gameover();
		}
		if(block[n4]==3){
			gameover();
		}
	}
	if(shape==1){
		n1=begin+4;
		n2=begin+5;
		n3=begin+6;
		n4=begin+15;
		if(block[n1]==3){
			gameover();
		}
		if(block[n2]==3){
			gameover();
		}
		if(block[n3]==3){
			gameover();
		}
		if(block[n4]==3){
			gameover();
		}
	}
	if(shape==2){
		n1=begin+4;
		n2=begin+5;
		n3=begin+15;
		n4=begin+25;
		if(block[n1]==3){
			gameover();
		}
		if(block[n2]==3){
			gameover();
		}
		if(block[n3]==3){
			gameover();
		}
		if(block[n4]==3){
			gameover();
		}
	}
	if(shape==3){
		n1=begin+5;
		n2=begin+6;
		n3=begin+14;
		n4=begin+15;
		if(block[n1]==3){
			gameover();
		}
		if(block[n2]==3){
			gameover();
		}
		if(block[n3]==3){
			gameover();
		}
		if(block[n4]==3){
			gameover();
		}
	}
	if(shape==4){
		n1=begin+4;
		n2=begin+5;
		n3=begin+14;
		n4=begin+15;
		if(block[n1]==3){
			gameover();
		}
		if(block[n2]==3){
			gameover();
		}
		if(block[n3]==3){
			gameover();
		}
		if(block[n4]==3){
			gameover();
		}
	}
	block[n1]=1;
	block[n2]=1;
	block[n3]=1;
	block[n4]=1;
	write();
}

void gameover(){
	int temp=2^29;//over
	int temp2=score;
	score=score|temp;
	output score;
	while(1){
		input;
		if(input=="R"){//restart
			//jump to initialize
		}
	}
}


void write(){ //Update
	//using sw to the block data
	output score;
}

void End(n1,n2,n3,n4){ //checkClear
	int count=0;
	int h=end-10; //start of endline
	block[n1]=3;
	block[n2]=3;
	block[n3]=3;
	block[n4]=3; //set stuck(infection)
	while(h- 30 >begin){ //until meet third line region
		int j = 0;
		while (j < 10){
			if (block[h+j] == 3) {
				count++;
				j++;
			}
			else j++;
		}
		if(count==10){ //check whether can do clear
			clear(h);
			score+=10;
		}
		else{
			h-=10; //continue check every line
		}
		count=0;
	}
	update();
}

void clear(int h){  //move all block down into next line
	while(h>begin){
		for(int j=0;j<width;j++){
			block[h+j]=block[h-10+j];
		}
		h-=10;
	}
}

void down(n1,n2,n3,n4){
	if(block[n1+10]==3){ //meet the stuck block
		End(n1,n2,n3,n4);
		return;
	}
	else if(block[n2+10]==3){
		End(n1,n2,n3,n4);
		return;
	}
	else if(block[n3+10]==3){
		End(n1,n2,n3,n4);
		return;
	}
	else if(block[n4+10]==3){
		End(n1,n2,n3,n4);
		return;
	}
	n1=n1+10;
	n2=n2+10;
	n3=n3+10;
	n4=n4+10;
	block[n1]=1;
	block[n2]=1;
	block[n3]=1;
	block[n4]=1;
	write();
	return;
}

void left(n1,n2,n3,n4){
	if(block[n1-1]==3){
		return;
	}
	if(block[n2-1]==3){
		return;
	}
	if(block[n3-1]==3){
		return;
	}
	if(block[n4-1]==3){
		return;
	}
	moveleft(n1,n2,n3,n4); //before move we do check, if meet boarder, then never call move;
}

void right(n1,n2,n3,n4){
	if(block[n1+1]==3){
		return;
	}
	if(block[n2+1]==3){
		return;
	}
	if(block[n3+1]==3){
		return;
	}
	if(block[n4+1]==3){
		return;
	}
	moveleft(n1,n2,n3,n4);
}

void moveleft(n1,n2,n3,n4){
	block[n1]=0; //set former to be 0
	block[n1-1]=1;
	block[n2]=0;
	block[n2-1]=1;
	block[n3]=0;
	block[n3-1]=1;
	block[n4]=0;
	block[n4-1]=1;
	write();
}

void moveright(n1,n2,n3,n4){
	block[n4]=0;
	block[n4+1]=1;
	block[n3]=0;
	block[n3+1]=1;
	block[n2]=0;
	block[n2+1]=1;
	block[n1]=0;
	block[n1+1]=1;
	write();
}

void rotate(type,n1,n2,n3,n4,rotateType){ //rotate type 0, 1, 2, 3
	block[n1]=0;
	block[n2]=0;
	block[n3]=0;
	block[n4]=0;
	if(type==1){
		if(rotateType==1){
			rotate11(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==2){
			rotate12(n1,n2,n3,n4);
			rotateType=1;
		}
	}
	if(type==2){
		if(rotateType==1){
			rotate21(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==2){
			rotate22(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==3){
			rotate23(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==4){
			rotate24(n1,n2,n3,n4);
			rotateType=1;
		}
	}
	if(type==3){
		if(rotateType==1){
			rotate31(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==2){
			rotate32(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==3){
			rotate33(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==4){
			rotate34(n1,n2,n3,n4);
			rotateType=1;
		}
	}
	if(type==4){
		if(rotateType==1){
			rotate41(n1,n2,n3,n4);
			rotateType++;
		}
		else if(rotateType==2){
			rotate42(n1,n2,n3,n4);
			rotateType=1;
		}
	}
	//type 5 have no rotate.
}

void rotatewrite(n1,n2,n3,n4){
	block[n1]=1;
	block[n2]=1;
	block[n3]=1;
	block[n4]=1;
	write();
}

void rotate11(n1,n2,n3,n4){
	if(block[n1-9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n3+9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4+18]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1-9;
	n2=n2;
	n3=n3+9;
	n4=n4+18;
	rotatewrite(n1,n2,n3,n4);
}

void rotate12(n1,n2,n3,n4){
	if(block[n1+9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n3-9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4-18]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1+9;
	n2=n2;
	n3=n3-9;
	n4=n4-18;
	rotatewrite(n1,n2,n3,n4);
}

void rotate21(n1,n2,n3,n4){
	if(block[n3-9]==3) rotatewrite(n1,n2,n3,n4);
	n3=n3-9;
	rotatewrite(n1,n2,n3,n4);
}

void rotate22(n1,n2,n3,n4){
	if(block[n4-9]==3) rotatewrite(n1,n2,n3,n4);
	n4=n4-9;
	rotatewrite(n1,n2,n3,n4);
}

void rotate23(n1,n2,n3,n4){
	if(block[n1+11]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1+11;
	rotatewrite(n1,n2,n3,n4);
}

void rotate24(n1,n2,n3,n4){
	if(block[n1-9]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1-9;
	n3=n3+11;
	n4=n4+9;
	rotatewrite(n1,n2,n3,n4);
}

void rotate31(n1,n2,n3,n4){
	if(block[n1+2]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2-9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4-9]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1+2;
	n2=n2-9;
	n4=n4-9;
	rotatewrite(n1,n2,n3,n4);
}

void rotate32(n1,n2,n3,n4){
	if(block[n1+19]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2-9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4+10]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1+19;
	n2=n2-9;
	n4=n4+10;
	rotatewrite(n1,n2,n3,n4);
}

void rotate33(n1,n2,n3,n4){
	if(block[n1-9]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2+19]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4-10]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1-9;
	n2=n2+19;
	n4=n4-10;
	rotatewrite(n1,n2,n3,n4);
}

void rotate41(n1,n2,n3,n4){
	if(block[n1-20]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2-11]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4+9]==3)  rotatewrite(n1,n2,n3,n4);
	n1=n1-20;
	n2=n2-11;
	n4=n4+9;
	rotatewrite(n1,n2,n3,n4);
}

void rotate42(n1,n2,n3,n4){
	if(block[n1+20]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n2+11]==3) rotatewrite(n1,n2,n3,n4);
	if(block[n4-9]==3) rotatewrite(n1,n2,n3,n4);
	n1=n1+20;
	n2=n2+11;
	n4=n4-9;
	rotatewrite(n1,n2,n3,n4);
}

void pause(){
	int temp=0;
	int temp2=2^30;//30 -> pause
	int temp3=score;
	score=score|temp2;
	output score;
	while(1){
		input;
		score=temp3;
		if(input=="r"){//resume, does not change anything
			break;
		}
		if(input=="re"){//restart the game
			//jump to initialize (this instruction is little bit hard to be implemented in C code)
			//in MIPS, we can simply use j
		}
	}
}

