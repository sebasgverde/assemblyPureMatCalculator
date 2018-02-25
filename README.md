# Requierements
- nasm

# Summary
This paper shows how a program of matrix products with assembler was implemented using NASM syntax under the federative operating system (Linux), its operation and everything the programmer was faced with in order to reach the final product.
 
# Key words.
Nasm, assembly, matrices, product, vector operations, runtime.

# Run example

```
~/assemblyPureMatCalculator$ ./scriptCompile 
Welcome to the pure assembly matrix calculator
Please enter only positive integers
Enter m matrix 1
2
Enter n matrix 1
3
Enter n matrix 2
2

0 2
1 2
2 2
3 2
4 2
5 2

0 3
1 3
2 3
3 3
4 3
5 3

Matrix A
2 2 2 
2 2 2 

Matrix B
3 3 
3 3 
3 3 

Matrix B transpuesta
3 3 3 
3 3 3 

Matrix C
18 18 
18 18 

Matrix D
18 18 
18 18 

Time classic matrix product
2634 0
Time mmx matrix product
11694 0

```

# 1. Functioning
The program starts with a welcome message in which the user is prompted to enter only positive integers, then prompted for matrix commands and then read each of the matrix values. Once you have the matrix a and b, the matrix product is made between them in the classical form and using vectorial operations to then print on screen the two matrices, the transposition of b that is used within the product, the matrix c product of the classical product and the product of the vector operations, finally the execution times of each one are shown.
To run the program, in a Linux environment, you must position the console in the folder where the praticaOrg. exe file is located and write the bash practcaOrg command.

# 2. scripts
By not using a development environment, you will soon notice how tedious it was to compile every time a change was made, first deleting the files, then creating the object, linke it, etc. To avoid this two bash scripts were created that contained the commands to delete those files and compile, and another to launch the debug, these are scriptCompilar and scriptDebug.

# 3. I/O
A big problem to have decided to do the practice completely in assembler was the input and output management, usually this is done using c functions but in my case I had to figure out how to do it all from the code. [1]

I spent hours trying to figure out why this instruction got me wrong.
sysExit equ 1, it turns out that appreciating is a reserved word, and it should be called sys_Exit or something like that, so that it differs.

I did a function called displayInt, which reconverted the integer to char and printed it, but since doing this changed the value for later use I had to use local variables.

When implementing the algorithm for parsing ASCII to int use the 32-bit registers for everyone, this was a big problem, as each ASCII is only one byte, it had to be analyzed when it came to references and individual bytes to use the corresponding size register.

In the end, two functions were implemented for parsing from ASCII to int and vice versa, these are specified in the pseudo-code section.

4. Intel vector operations.
In the previous practice, the entire normal form of the matrix product was implemented, so it was initially thought to translate this code into nasm assembler, but then, considering that it should also be done using Intel's vector operations, it was decided to find out how well they work, to keep in mind whether the matrices should be stored in a specific form that makes them incompatible with the other code.

When researching I realized that this processors has more things than I thought, looking at the different families of operations I noticed that they always said that micro architecture was available, I didn't even know that a same core i5 processor could have several models, my processor is an Intel core i5-2430m and it was found that its micro architecture is sandy bridge[2].

http://en.wikibooks.org/wiki/X86_Assembly/SSE
It was also found that the features are as follows:



## Features
MMX instructions
SSE / Streaming SIMD Extensions
SSE2 / Streaming SIMD Extensions 2
SSE3 / Streaming SIMD Extensions 3
SSSE3 / Supplemental Streaming SIMD Extensions 3
SSE4 / SSE4.1 + SSE4.2 / Streaming SIMD Extensions 4 
AES / Advanced Encryption Standard instructions
AVX / Advanced Vector Extensions
EM64T / Extended Memory 64 technology / Intel 64 
NX / XD / Execute disable bit 
HT / Hyper-Threading technology 
TBT 2.0 / Turbo Boost technology 2.0 
VT-x / Virtualization technology 
Low power features
Enhanced SpeedStep technology 

Knowing then that my processor supported all these families of operations, I decided to find out what functions I could use, after investigating in several parts I found two pdf files that showed all the simd instructions of Intel[3 and 4].

I experimented with several, at first I wanted to find an instruction that multiplied two vectors and another that did the summation of a vector, but the second one I did not find:

PMULDQ — Multiply Packed Signed Dword Integers
PMULHRSW — Packed Multiply High with Round and Scale
PMULHUW—Multiply Packed Unsigned Integers and Store High Result (16)
PMULLD — Multiply Packed Signed Dword Integers and Store Low Result 
PMULUDQ—Multiply Packed Unsigned Doubleword Integers

The one you use was the one in bold because it is the most stable with integers, after having this, just add the 4 values by hand.

However, I looked for more and I found an instruction that toward the product point as such, the problem in both of them is that for int32 they can only do 4, so he had to devise the algorithm to do so (see pseudo code), the other instructions used were:

movups	xmm0,[eax]
CVTDQ2PS	xmm0,xmm0
CVTPS2DQ	xmm0,xmm0
dpps		xmm0, xmm1,imm0

Another problem with dpps was that of imm0, at first I thought it was an 8-bit register where the result would be, but it turned out to be a kind of indicator that tells the operation how to work:

Table 4-8. Summary of Imm8 Control Byte 
Imm8 Description
-------0b 128-bit sources treated as 16 packed bytes.
-------1b 128-bit sources treated as 8 packed words.
------0-b Packed bytes/words are unsigned.
------1-b Packed bytes/words are signed.
----00--b Mode is equal any.
----01--b Mode is ranges.
----10--b Mode is equal each.
----11--b Mode is equal ordered.
---0----b IntRes1 is unmodified.
---1----b IntRes1 is negated (1’s complement).
--0-----b Negation of IntRes1 is for all 16 (8) bits.
--1-----b Negation of IntRes1 is masked by reg/mem validity.
-0------b Index of the least significant, set, bit is used (regardless of corresponding input element validity). 
IntRes2 is returned in least significant bits of XMM0.
-1------b Index of the most significant, set, bit is used (regardless of corresponding input element validity).
Each bit of IntRes2 is expanded to byte/word.
0-------b This bit currently has no defined effect, should be 0.
1-------b This bit currently has no defined effect, should be 0.

Therefore, in order to make the product it needed to be 11110001 (F1 in hexa and 241 in decimal)


# 5. Memory reserve
I was changing results when doing operations, because I defined numbers as byte, but the operation was bigger, modifying also the next number, so I chose to define everything as a word, because I think this would help me to take more control over the memory.

all the variables in which I was going to save a memory position (for example temporary copies), must be at least double words, I had a problem because I had them as a word, and when I assigned one the value modified the other, which problematic is problematic in nasm this of the data types, I had never had to analyze so much the length of a variable before assigning it.

When invoking the functions, it is necessary to differentiate whether the parameter is commanded by value or by reference.

in one part I was using it to add only to that, big mistake, to add an index to addresses and things like that is better to use the complete 32 record, because at some point you can pass and throw out numbers causing errors.

another problem arose when I started to merge functions and work on matrices that I entered myself with readMatriz (), because of the sizes I also kept the enter, and took out some of the strangest errors that I have seen, I must handle all these well and make sure that in memory only numerical values are saved, here the key are the functions of parsing.

in the matrix product function (and others) started the variables as follows:
mov	word [ebp-20],0;i=0
mov	word [ebp-16],0;j=0
mov	dword [ebp-12],matA
mov	dword [ebp-8],matBtransp
mov	word [ebp-4],0

i. e., when he noticed that he didn't need the 32 bits he didn't modify them, a big mistake because when there were delays in the pile of a previous use, everything was damaged, it must be consistent with what is defined at the beginning.

in the normal point product I defined the point product as byte when I restarted it, this is 
This caused me to restart only a part of it, here the recurring error is noticed in practice, and it was the lack of habit of having to pay so much attention to the size in memory.

5.1 operations
It is very important to put in zero edx before making the division, and not to forget that in edx the residue remains.

# 6. Pseudocode
msg bienvenido a practica 2
msg ingrese m de matriz 1
msg ingrese n de matriz 1
msg ingrese n de matriz 2


## 6.1 parseIntString
```
parseIntString(ascii)
	num=0
	m(ascii’ != enter)
		si(ascii’> 47 y ascii’ < 58)
			num=(num*10)+(ascii-48)
			ascii’++;este si es de a 1
		finsi
	fm
fin parseIntString
```

## 6.2 parseStringInt
```
parseStringInt(num)
	cont=0
	haga
		aux=(num/10);division entera
		num=num-aux*10
		push num
		num=aux
		cont++
	mientras(num > 0)

	m(cont > 0)
		pop eax
		imprimir eax
		cont--
	fm
fin parseStringInt
```
I was presented with a problem because in the part where I start to unstack to print I was doing pop ecx, this is useless because the interruption that prints receives the address, not the value, was mov ecx, esp and then unstacked.

## 6.3 leer
```
inicio leer(&a,ret)	
	i=0
	m i < m
	j=0
		m j < n
			m1 = leer A[i,j]
		j++
		fin m
	i++
	fin m
fin leer()	
```

## 6.4 transpuesta
```
tranpuesta(&A,&B,&ret,m,n)
	sacar retorno y ponerlo fin de funcion	
	matA = &a
	matB = &b
	m=m
	n=n
	i = 0
	j = 0
	ind = 0
indTrans=0
	m i < n;por 4 en nasm
		m j < m;por 4 en nasm
			[matB+indTrans]=[matA + ind +i]
			ind+=n
			indTrans+=4
			j+=4
		fin m
		i+=4
		j=0
		ind = 0
	fin m
fin transpuesta
```

# 6.5 productoPunto
```
productoPunto(A,B,m)
	sacar A
	sacar B
	i=0
    suma=0
	m i<m*4
		A’ =[A+i]
		B’=[B+i]
		prod = A*B
		suma = suma + prod;prodPuntoResultado
		i+=4
	fin m
	retornar
fin pdtoPto
```

# 6.6 productoPuntoSse
```
productoPuntoSse(A,B,m)

cerosA=[0,0,0,0]
cerosB=[0,0,0,0]
m’=m/4;entera *16
mRes=m%4;residual * 4
	sacar A
	sacar B
	i=0
suma=0
	m i<m’*4
		xmm0 =[A+i]
		xmm1=[B+i]
		prod = xmm0,xmm1
		suma = suma + prod;prodPuntoResultado
		i+=16
	fin m
j=0
m j<mRes
	[cerosA+j]=[A+i+j]
	[cerosB+j]=[B+i+j]
	j+=4
fin m
		xmm0 =[cerosA]
		xmm1=[cerosB]
		prod = xmm0,xmm1
		suma = suma + prod;prodPuntoResultado

	retornar
fin pdtoPto
```

## 6.7 matrix product

```
quemadas
A,B=m5,C o D segun cual sea

m5 = transpuesta(&B,&m5, aqui,n,q);que esto se haga en el main

multiplicaion(A,m5,C,m,n,q,ret)
	i=0
	j=0
	A’=A
	m5’=m5
	ind=0

	m i<m;*4
		m j<q;*4
			PDTOPTO= pdctoPto(A’,m5’,[n])
			[C + ind] = PDTOPTO
			m5’ = m5’ + n;*4, es decir ya la n esta así, no multiplicar de nuevo
			j+=4
			ind+=4
		fin m
		A’=A’+n;*4
		i+=4
		j=0
		m5’=m5;REINICIAR &m5 'ESTO SE ME OLVIDO VAYA PROBLEMA
	fin m
fin multiplicacion
```

for vector operations is D instead of c and pdtoPuntoSse () is invoked.

## 6.8 Invocation Templates.

### 6.8.1 parseIntString template
push ascii
call parseIntString
pop eax

### 6.8.2 parseStringInt template

	mov	eax,num
	push	eax
	call	parseStringInt
	pop eax

### 6.8.3 Point product template (works for both)
	mov	eax,[n]
	push	eax
	mov	eax,vecB
	push	eax
	mov	eax,vecA
	push	eax
	call	productoPunto
	pop eax
	pop eax
	pop eax

# 7. Debuger
In the absence of a development environment such as visual studio, it was necessary to learn how to use debuger gdb for which this tutorial was very useful[5]

# 8. Execution times
runtimes were made based on an example, however in this one they used the stack to save the results, I preferred to use variables to have more control and to have to store two measurements[6 and 7]". 

# 9. Possible improvements
In the future it could be possible to support floating point, with the operations mmx a simple way to convert was found, the problem here would be the function of parse from string to float and vice versa, this would be a big problem.
Although the program only supports integers, validation is limited to a message at the beginning that indicates that floating points, negatives or letters should not be entered, all validations and exception control could be done, so that the program does not block but warns the user to enter a correct data.
The decision to make the product point 4 in the matrix operations instead of using the 8 xmm registers resulted from the desire for an algorithm that was not limited to a vector size (which in the case of this practice is a maximum of 10), However, these registers could be used to make it 16 and not give 4, this way the capacity of this algorithm would grow enormously, and in these cases would begin to notice really big changes in the execution times.
One could look for an optimization of the product code sse since it is necessary to make such a quantity of validations and use of variable and auxiliary vectors, that for small arrangements it is very inefficient compared to the classic form, however I think that a conclusion of the work is that this of the vectorial operations depends a lot on the form of the matrix, not in 100% of the cases it is more efficient.
For some of the functions there was not enough knowledge about the use of the battery when they were implemented, so local variables of this function were declared at first, the total practice could be handled with the local variables in stack.

# 10. Attachments
1. practicaOrg.asm: programa final
2. practicaOrg: ejecutable desde bash
3. scriptCompilar: script de bash que facilita la compilación del código del .asm
4. scriptDebug: script de bash que facilita el proceso de debug.
5. tabla de símbolos: mapa de las variables locales con su posición en la pila dentro de las funciones
6. nasmFedora: pruebas de código que se hicieron al principio para aprender a manejar el ambiente de desarrollo.
7. otra versiones y cosas: experimentos con las operaciones vectoriales, aritméticas, funciones de medición, interrupciones y cada una de las versiones de la practica incrementalmente.

# 11. Useful links
The following is a set of links that cannot be considered bibliography since they were not used as documentation but that helped to understand many things of the practice.

http://codewiki.wikispaces.com/x86_code_timing.nasm

http://stackoverflow.com/questions/13577226/intel-sse-and-avx-examples-and-tutorials
http://computadoras.about.com/od/preguntas-frecuentes/a/Que-Son-Y-En-Qu-E-Se-Diferencian-Mmx-3d-Now-Sse-Y-Avx.htm
https://gist.github.com/rygorous/4172889

http://www.walkingrandomly.com/?p=3378
http://locklessinc.com/articles/vectorize/

http://en.wikipedia.org/wiki/Streaming_SIMD_Extensions

http://softpixel.com/~cwright/programming/simd/sse.php

http://en.wikipedia.org/wiki/SSE4
PPS, DPPD
Dot product for AOS (Array of Structs) data. This takes an immediate operand consisting of four (or two for DPPD) bits to select which of the entries in the input to multiply and accumulate, and another four (or two for DPPD) to select whether to put 0 or the dot-product in the appropriate field of the output.

DPPD xmmreg,xmmrm,imm SSE41 
DPPS xmmreg,xmmrm,imm SSE41

This imm is not where the result is, it is the indicator that tells the function how to operate.

### example
http://www.csie.ntu.edu.tw/~cyy/courses/assembly/07fall/lectures/handouts/lec15_simd_4up.pdf
http://www.csee.umbc.edu/~chang/cs313/nasmdoc/html/nasmdocb.html

### functions commands
http://cs.nyu.edu/courses/fall02/V22.0201-001/nasm_doc_html/nasmdocb.html

http://www.ualberta.ca/AICT/RESEARCH/LinuxClusters/doc/icc91/main_cls/mergedProjects/intref_cls/common/intref_sample_dotprod.htm

http://www.csee.umbc.edu/portal/help/nasm/sample.shtml

# Bibliography
[1]http://www.dreamincode.net/forums/topic/286248-nasm-linux-terminal-inputoutput-wint-80h/
[2] http://www.cpu-world.com/CPUs/Core_i5/Intel-Core%20i5%20Mobile%20i5-2430M.html

[3]http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf

[4]http://download.intel.com/products/processor/manual/325383.pdf

[5]http://www.csee.umbc.edu/~cpatel2/links/310/nasm/gdb_help.shtml

[6] http://stackoverflow.com/questions/7885359/assembly-compute-execution-time-of-instructions

[7] http://www.asmcommunity.net/board/index.php?topic=12879.0


imprimir		pdtoPuntoSse	
nFilas	[ebp - 8]	cerosB	[ebp -52]
nColum	[ebp - 12]	cerosA	[ebp -36]
matriz	[ebp - 16]	prod	[ebp -20]
		mRes	[ebp -16]
		m'	[ebp -12]
		j	[ebp -8]
producto punto		i	[ebp -4]
A’	[ebp - 12]	ret	[ebp + 4]
B’	[ebp - 8]	A	[ebp +8]
i	[ebp -4]	B	[ebp +12]
		m	[ebp +16]
ret	[ebp + 4]		
A	[ebp +8]		
B	[ebp +12]	parseIntString	
m	[ebp +16]	ascii’	[ebp - 16]
		num 	[ebp - 12]
parseStringInt		10	[ebp - 4]
cont	[ebp - 12]	ret 	[ebp + 4]
aux	[ebp - 8]	ascii 	[ebp + 8]
10	[ebp - 4]		
ret	[ebp+4]		
num	[ebp + 8]		
			
pdto matricial		multiplicacion	
i	[ebp - 20]	i	 [ebp - 20]
j	[ebp - 16]	j 	[ebp - 16]
A’	[ebp -12]	A’’	 [ebp -12]
m5’	[ebp -8]	m5’ 	[ebp -8]
ind	[ebp - 4]	ind 	[ebp - 4]
ret	[ebp + 4]	ret 	[ebp + 4]

