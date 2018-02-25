# Requierements
- nasm

# Resumen
En el presente trabajo se muestra la forma en que se implementó un programa de productos matriciales con assembler usando la sintaxis de NASM	bajo el sistema operativo fedora (Linux), su funcionamiento y todo a lo que se vio enfrentado el programador  para llegar al producto final.
 
# Palabras clave.
Nasm, assembler, matrices, producto, operaciones vectoriales, tiempo de ejecución.

# 1. Funcionamiento
El programa inicia con mensaje de bienvenida en el cual se le indica al usuario que solo ingrese enteros positivos, entonces se le piden los órdenes de las matrices para posteriormente leer cada uno de los valores de estas. Una vez se tienen la matriz a y b se hace el producto matricial entre estas en la forma clásica y usando operaciones vectoriales para luego imprimir en pantalla las dos matrices, la transpuesta de b que se usa dentro del producto, la matriz c producto del producto clásico y la d producto de las operaciones vectoriales, finalmente se muestran los tiempos de ejecución de cada una.
Para ejecutar el programa, en un ambiente Linux, se debe posicionar la consola en la carpeta en que esta el archivo praticaOrg.exe y escribir el comando bash practcaOrg.

# 2. scripts
Al no usar un ambiente de desarrollo, pronto note lo tedios que era compilar cada vez que se hacía un cambio, primero borrar los archivos, luego crear el object, linkearlo, etc. Para evitar esto se crearon dos scripts para bash que contenían los comandos para borrar dichos archivos y compilar, y otro para lanzar el debug, estos son scriptCompilar y scriptDebug.

# 3. I/O
Un gran problema al haber decidido hacer la practica completamente en assembler fue el manejo de entrada y salida, por lo regular esto se hace usando funciones de c pero pero en mi caso tuve que averiguar cómo hacerlo todo desde el código. [1]

Gaste horas tratando de saber por qué esta instrucción me sacaba error
sysExit equ 1, resulto que al aprecer es una palabra reservada, y debe llamarse sys_Exit o algo así, de manera que se diferencie.

Hice una función llamada displayInt, que reconvertía el entero a char y lo imprimía, pero como al hacer esto se me modificaba el valor para uso posterior tuve que usar variables locales.

Cuando implemente el algoritmo para parsear ASCII a int use los registros de 32 bits para todos, esto fue un gran problema, pues cada ASCII es solo un byte, se tuvo que analizar cuando se trataba de referencias y cuando de bytes individuales para usar el registro del tamaño correspondiente.

Al final se implementaron dos funciones para parsear de ASCII a int y viceversa, estas se especifican en la sección de seudocódigo.

# 4. operaciones vectoriales de Intel.
En la práctica anterior se implementó toda la forma normal del producto de matrices, por lo cual en un principio se pensó en traducir ese código al assembler de nasm, pero luego, considerando que también se debe hacer usando las operaciones vectoriales de Intel, se decidió averiguar bien cómo funcionan, para tener presente si las matrices de deben almacenar en una forma específica que las haga incompatibles con el otro código.

Al investigar me di cuenta que esto de los procesadores tiene más cosas de lo que pensé, mirando las diferentes familias de operaciones note que siempre decían para que micro arquitectura estaban disponibles, yo ni siquiera sabía que un mismo procesador core i5 podía tener varios modelos, mi procesador es un Intel core i5-2430m y se encontró que su micro arquitectura es sandy bridge [2]

http://en.wikibooks.org/wiki/X86_Assembly/SSE
También se encontró que las características son las siguientes:



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

Sabiendo entonces que mi procesador soportaba todas estas familias de operaciones me dedique a averiguar que funciones podía usar, después de investigar en varias partes encontré dos pdf que mostraban todas las instrucciones simd del Intel [3 y 4].

Experimente con varias, en un principio quería hallar una instrucción que multiplicara dos vectores y otra que hiciese la sumatoria de un vector, pero la segunda no la encontré:

PMULDQ — Multiply Packed Signed Dword Integers
PMULHRSW — Packed Multiply High with Round and Scale
PMULHUW—Multiply Packed Unsigned Integers and Store High Result (16)
PMULLD — Multiply Packed Signed Dword Integers and Store Low Result 
PMULUDQ—Multiply Packed Unsigned Doubleword Integers

La que utilice fue la que está en negrilla pues es la más estable con enteros, luego de tener esto, simplemente sume a mano los 4 valores.

Sin embargo busque más y encontré una instrucción que hacia el producto punto como tal, el problema en ambas es que para int32 solo pueden hacer de a 4, por lo cual tuvo que idear el algoritmo para hacerlo así (ver seudocódigo), las otras instrucciones usadas fueron:

movups	xmm0,[eax]
CVTDQ2PS	xmm0,xmm0
CVTPS2DQ	xmm0,xmm0
dpps		xmm0, xmm1,imm0

otro problema con dpps fue eso de imm0, en principio creí que era un registro de 8 bits donde quedaría el resultado, pero resulto ser una especie de indicador que le dice a la operación como trabajar:

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

Por lo cual, para como necesitaba que se hiciese el producto debía ser 11110001 (F1 en hexa y 241 en decimal)


# 5. Reservar memoria
hay gran incidencia de la reserva de memoria, me estaba cambiando resultados al hacer operaciones, pues definí números como byte, pero la operación me daba más grande, modificando también el siguiente número, por esto opte por definir todo como palabra, pues pienso que esto me ayudara a llevar más control sobre la memoria.

todas las variables en las que vaya a guardar una posición de memoria (por ejemplo copias temporales), deben ser como mínimo palabras dobles, tuve un problema pues las tenía como word, y cuando asignaba una el valor me modificaba la otra, que problemático es en nasm  esto de los tipos de dato, nunca había tenido que analizar tanto la longitud de una variable antes de asignarla.

a la hora de invocar las funciones se debe diferenciar bien si mando el parámetro por valor o por referencia

en una parte estaba usando al para sumarle solo a eso, gran error, para irle sumado un índice a direcciones y cosas de ese estilo es mejor usar el registro de 32 completo, pues en algún momento se puede pasar y botar cifras provocando errores.

se me presento otro problema cuando empecé a unir funciones y a trabajar sobre matrices que yo mismo ingresaba con leerMatriz(), por los tamaños me quedaba guardado también el enter, y me sacaba algunos de los errores más extraños que he visto, debo manejar bien todo estos y asegurarme de que en memoria me queden guardados solo valores numéricos, aquí la calve son las funciones de parsing.

en la función producto matricial (y en otras) iniciaba las variables en la siguiente forma:
mov	word [ebp-20],0;i=0
mov	word [ebp-16],0;j=0
mov	dword [ebp-12],matA
mov	dword [ebp-8],matBtransp
mov	word [ebp-4],0

es decir, cuando notaba que que no necesitaba los 32 bits no los modificaba, gran error pues cuando quedaban rezagos en la pila de un uso anterior, todo se dañaba, se debe ser consecuente con con lo que se define al principio.

en el producto punto normal definí el producto punto como byte cuando lo reiniciaba, esto 
esto provoco que solo reiniciara una parte, aquí se nota el error recurrente en la práctica, y fue la falta de costumbre de tener que poner tanto cuidado al tamaño en memoria.

## 5.1 operaciones
Es muy importante poner en cero edx antes de hacer la división, y no olvidar que en edx queda el residuo

# 6. Pseudocodigo
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
se me presento un problema pues en la parte en que empiezo a desapilar para imprimir estaba haciendo pop ecx, esto no sirve pues la interrupcion que imprime recibe es la direccion, no el valor, era mov  ecx,esp y luego se desapilaba.

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

## 6.7 producto matricial

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

para la de operaciones vectoriales es D en vez de c y se invoca pdtoPuntoSse()

## 6.8 Plantillas de invocación.

### 6.8.1 plantilla parseIntString
push ascii
call parseIntString
pop eax

### 6.8.2 plantilla parseStringInt

	mov	eax,num
	push	eax
	call	parseStringInt
	pop eax

### 6.8.3 Plantilla producto punto (funciona para ambos)
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
Ante la falta de un ambiente de desarrollo como visual studio fue necesario aprender a usar el debuger gdb para lo cual fue muy útil este tutorial [5]

# 8. Tiempos de ejecución
los tiempos de ejecución se hicieron en base a un ejemplo, sin embargo en  este usaban la pila para guardar los resultados, yo prefería usar variables para tener más control y por tener que almacenar dos mediciones [6 y 7] 

# 9. Posibles mejoras
En un futuro se podría dar soporte para punto flotantes, con las operaciones mmx se encontró una forma sencilla de convertir, el problema aquí seria la función de parse de string a float y viceversa, esto supondría un gran problema.
Aunque el programa solo soporta enteros la validación se limita a un mensaje al inicio que señala que no se deben ingresar punto flotantes, negativos o letras, se podrían hacer todas las validaciones y control de excepciones, para que el programa no se bloquee sino que avise al usuario que entre un dato correcto.
La decisión de hacer el producto punto de a 4 en las operaciones matriciales en vez de usar los 8 registros xmm obedeció a que se deseaba un algoritmo que no se viese limitado a un tamaño de vector (que en el caso de esta práctica es máximo 10), sin embargo se podrían usar dichos registro para hacerlo de a 16 y no dé a 4, de esta manera crecería enormemente la capacidad de este algoritmo, y en estos casos se empezarían a notar cambios realmente grandes en los tiempos de ejecución.
Se podría buscar una optimización del código del producto sse pues hay que hacer tal cantidad de validaciones y uso de variable y vectores auxiliares, que para arreglos pequeños es muy ineficiente comparado con la forma clásica, sin embargo pienso que una conclusión del trabajo es que esto de las operaciones vectoriales depende mucho de la forma de la matriz, no en el 100% de los casos es más eficiente.
Para algunas de las funciones no se contaba con suficiente conocimiento sobre el uso de la pila cuando fueron implementadas, por lo cual se declararon variables locales de esa función al principio, se podría manejar el total de la practica con las variable locales en pila.

# 10. Anexos
1. practicaOrg.asm: programa final
2. practicaOrg: ejecutable desde bash
3. scriptCompilar: script de bash que facilita la compilación del código del .asm
4. scriptDebug: script de bash que facilita el proceso de debug.
5. tabla de símbolos: mapa de las variables locales con su posición en la pila dentro de las funciones
6. nasmFedora: pruebas de código que se hicieron al principio para aprender a manejar el ambiente de desarrollo.
7. otra versiones y cosas: experimentos con las operaciones vectoriales, aritméticas, funciones de medición, interrupciones y cada una de las versiones de la practica incrementalmente.

# 11. Enlaces útiles
Lo siguiente es un conjunto de enlaces a los que no se les puede considerar bibliografía pues no fueron usados como documentación pero que ayudaron a entender muchas cosas de la práctica.

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

el tal imm no es donde queda el resultado, es el indicador que dice a la funcion como operar

### ejemplos
http://www.csie.ntu.edu.tw/~cyy/courses/assembly/07fall/lectures/handouts/lec15_simd_4up.pdf
http://www.csee.umbc.edu/~chang/cs313/nasmdoc/html/nasmdocb.html

### comandos de las funciones
http://cs.nyu.edu/courses/fall02/V22.0201-001/nasm_doc_html/nasmdocb.html

http://www.ualberta.ca/AICT/RESEARCH/LinuxClusters/doc/icc91/main_cls/mergedProjects/intref_cls/common/intref_sample_dotprod.htm

http://www.csee.umbc.edu/portal/help/nasm/sample.shtml

# Bibliografia
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

