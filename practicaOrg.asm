
sys_Exit	equ	1 ;id codigos del sistema
sysRead		equ	3;id leet
sysWrite	equ     4;id escribir
stdin		equ     0;entrada std (teclado)
stdout		equ     1;salida std (pantalla)
stderr		equ     3; id error
;sysExit es una maldita palabra reservada

segment .data
	espacioEnBlaco:	db	20H
	saltoDeLinea:	db	0AH
	msgBienv:     	db      'Welcome to the pure assembly matrix calculator', 0AH
	msgBienvF:	equ	$-msgBienv

	msgAviso:     	db      'Please enter only positive integers', 0AH
	msgAvisoF:	equ	$-msgAviso

	msgIngM:	db	'Enter m matrix 1',0AH
	msgIngMF:	equ	$-msgIngM

	msgIngN:	db	'Enter n matrix 1',0AH
	msgIngNF:	equ	$-msgIngN

	msgIngQ:	db	'Enter n matrix 2',0AH
	msgIngQF:	equ	$-msgIngQ

	msgMatA:	db	'Matrix A',0AH
	finmsgMatA:	equ	$-msgMatA

	msgMatB:	db	'Matrix B',0AH
	finmsgMatB:	equ	$-msgMatB

	msgMatBTrans:	db	'Transposed Matrix B',0AH
	finmsgMatBTrans:	equ	$-msgMatBTrans

	msgMatC:	db	'Matrix C',0AH
	finmsgMatC:	equ	$-msgMatC

	msgMatD:	db	'Matrix D',0AH
	finmsgMatD:	equ	$-msgMatD

	msgTiempoC:	db	'Time classic matrix product',0AH
	finmsgTiempoC:	equ	$-msgTiempoC

	msgTiempoD:	db	'Time mmx matrix product',0AH
	finmsgTiempoD:	equ	$-msgTiempoD

	i:		dd	0
	j:		dd	0
	ind:		dd	0

	;matB:		dd	3,2,1,4,1,2,7,5,3
	;matA:		dd	1,2,3,4,5,6
	indTrans:	dd	0

	cuatro:		dd	4
	diesyseis:	dd	16

segment .bss
	m: 	resd	1
	n: 	resd	1
	q:	resd	1
	mLeido: 	resd	1
	nLeido: 	resd	1
	qLeido:	resd	1
	tamA:	resd	1
	tamB:	resd	1
	matA:	resd	100
	matB:	resd	100
	matC:	resd	100
	matD:	resd	100
	matBtransp:	resd 100

	;variables leer
	matLeer:	resd	1
	tamLeer:	resd	1
	retLeer:	resd	1

	prodPuntoResultado:	resd	1

	numeroLeido:		resb	12
	numeroConvertido:	resd 1

	vectorTemp:	resd	4
	cerosA:		resd	4
	cerosB:		resd	4

	tiempoEjecC:	resd	2
	tiempoEjecD:	resd	2



segment .text
global  _start

_start: 
	mov     ecx, msgBienv ;Bienvenida
	mov     edx, msgBienvF
	call 	DisplayText

	mov     ecx, msgAviso ;Bienvenida
	mov     edx, msgAvisoF
	call 	DisplayText

	mov     ecx, msgIngM;leer M
	mov     edx, msgIngMF
	call 	DisplayText
	mov 	ecx,mLeido
	call 	ReadInt

	mov     ecx, msgIngN;leer N
	mov     edx, msgIngNF
	call 	DisplayText
	mov 	ecx,nLeido
	call 	ReadInt

	mov     ecx, msgIngQ;leer Q
	mov     edx, msgIngQF
	call 	DisplayText
	mov 	ecx,qLeido
	call 	ReadInt

	;sacar tamA y tamB

	mov	edx,0
	mov	eax,[mLeido]
	mul	dword [nLeido]
	mov	dword [tamA],eax;tamA=m*n

	mov	edx,0
	mov	eax,[nLeido]
	mul	dword [qLeido]
	mov	dword [tamB],eax;tamB=n*q

	;sacar los x4 para ciertas funciones

	mov	edx,0
	mov	eax,[mLeido]
	mul	dword [cuatro]
	mov	dword [m],eax

	mov	edx,0
	mov	eax,[nLeido]
	mul	dword [cuatro]
	mov	dword [n],eax

	mov	edx,0
	mov	eax,[qLeido]
	mul	dword [cuatro]
	mov	dword [q],eax

	;leer matrices

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	eax,[tamA]
	push	eax
	push	matA		
	call leerMatriz

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	eax,[tamB]
	push	eax
	push	matB		
	call leerMatriz


	;mov	dword [m],8;2
	;mov	dword [n],12;3
	;mov	dword [q],12;3

	call	transpuesta

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	;matriz clasica---------------------
        rdtsc                         
        mov     [tiempoEjecC], eax          
        mov     [tiempoEjecC + 4], edx       

	call	productoMatrizClasico

        rdtsc                                             
	sub	eax,[tiempoEjecC]
	sbb	edx,[tiempoEjecC + 4]
        mov     [tiempoEjecC], eax           
        mov     [tiempoEjecC + 4], edx 
	;--------------------------------



	;matriz SSE---------------------
        rdtsc                         
        mov     [tiempoEjecD], eax          
        mov     [tiempoEjecD + 4], edx    

	call	productoMatrizSse

        rdtsc                                                
	sub	eax,[tiempoEjecD]
	sbb	edx,[tiempoEjecD + 4]
        mov     [tiempoEjecD], eax           
        mov     [tiempoEjecD + 4], edx 
	;--------------------------------


	;imprimir matrices---------------------
	mov	ecx,msgMatA
	mov	edx,finmsgMatA
	call 	DisplayText

	mov eax, matA
 	push eax
	mov eax,[n];columnas
 	push eax
	mov ebx,[m];filas
	push ebx
	call imprimirMatriz
	pop eax
	pop eax
	pop eax

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	ecx,msgMatB
	mov	edx,finmsgMatB
	call 	DisplayText

	mov eax, matB
 	push eax
	mov eax,[q]
 	push eax
	mov ebx,[n]
	push ebx
	call imprimirMatriz
	pop eax
	pop eax
	pop eax

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	ecx,msgMatBTrans
	mov	edx,finmsgMatBTrans
	call 	DisplayText

	mov eax, matBtransp
 	push eax
	mov eax,[n]
 	push eax
	mov ebx,[q]
	push ebx
	call imprimirMatriz
	pop eax
	pop eax
	pop eax

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	ecx,msgMatC
	mov	edx,finmsgMatC
	call 	DisplayText

	mov eax, matC
 	push eax
	mov eax,[q]
 	push eax
	mov ebx,[m]
	push ebx
	call imprimirMatriz
	pop eax
	pop eax
	pop eax

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText

	mov	ecx,msgMatD
	mov	edx,finmsgMatD
	call 	DisplayText

	mov eax, matD
 	push eax
	mov eax,[q]
 	push eax
	mov ebx,[m]
	push ebx
	call imprimirMatriz
	pop eax
	pop eax
	pop eax

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText
	
	;imprimir tiempos de ejecucion-----------

	mov	ecx,msgTiempoC
	mov	edx,finmsgTiempoC
	call 	DisplayText

	mov	eax,[tiempoEjecC]
	push	eax
	call	parseStringInt
	pop	ecx

	mov	ecx,espacioEnBlaco
	mov	edx,1
	call	DisplayText

	mov	eax,[tiempoEjecC+4]
	push	eax
	call	parseStringInt
	pop	ecx

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText



	mov	ecx,msgTiempoD
	mov	edx,finmsgTiempoD
	call 	DisplayText

	mov	eax,[tiempoEjecD]
	push	eax
	call	parseStringInt
	pop	ecx

	mov	ecx,espacioEnBlaco
	mov	edx,1
	call	DisplayText

	mov	eax,[tiempoEjecD+4]
	push	eax
	call	parseStringInt
	pop	ecx

	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText



	jmp Exit



;-----------------------------------------------------------------
productoMatrizSse:
push	ebp
mov	ebp,esp
sub	esp, 80

mov	word [ebp-20],0;i=0
mov	word [ebp-16],0;j=0
mov	dword [ebp-12],matA
mov	dword [ebp-8],matBtransp
mov	word [ebp-4],0

cicloProMatSse1:
mov	eax,[ebp-20]
mov	ebx,[m]
cmp	eax,ebx	
jge	fincicloProMatSse1
	cicloProMatSse2:
	mov	eax,[ebp-16]
	mov	ebx,[q]
	cmp	eax,ebx	
	jge	fincicloProMatSse2
	
		mov	eax,[n]
		push	eax
		mov	eax,[ebp-12]
		push	eax
		mov	eax,[ebp-8]
		push	eax
		call	productoPuntoSse
		pop eax
		pop eax
		pop eax

		mov	eax,matD
		add	eax,[ebp - 4];matC+ind
		mov	ebx,[prodPuntoResultado];estaba usando eax, lo 
		mov	[eax],ebx;cual daño todo...obviamente

		mov	eax,[n]
		add	[ebp-8],eax;m5’ = m5’ + n
		add	word [ebp-16],4;j+=4
		add	word [ebp-4],4;ind+=4

	jmp cicloProMatSse2
	fincicloProMatSse2:

	mov	eax,[n]
	add	[ebp -12],eax
	add	word [ebp-20],4;i+=4
	mov	word [ebp - 16],0;j=0
	mov	dword [ebp-8],matBtransp;m5’=m5

jmp cicloProMatSse1
fincicloProMatSse1:

add	esp,80
pop	ebp
ret

;----------------------------------------------
productoPuntoSse:
push	ebp
mov	ebp,esp
sub	esp, 80



mov	dword [cerosA],0
mov	dword [cerosA+4],0
mov	dword [cerosA+8],0
mov	dword [cerosA+12],0
mov	dword [cerosB],0
mov	dword [cerosB+4],0
mov	dword [cerosB+8],0
mov	dword [cerosB+12],0

mov	dword [ebp-24],cerosA
mov	dword [ebp-28],cerosB

mov	edx,0
mov	eax,[ebp +16]
div	dword [diesyseis];/4
mov	dword [ebp - 12],eax
mov	dword [ebp - 16],edx

mov	edx,0
mov	eax,[ebp -12]
mul	dword [diesyseis];/4
mov	[ebp-12],eax;lo necesito por 16 para las direcciones

mov	dword [ebp-4],0
mov	dword [prodPuntoResultado],0

cicloProdSse:
mov	eax,[ebp-4]
mov	ebx,[ebp-12]
cmp	eax,ebx
jge	fincicloProdSse

	mov	eax,[ebp+8]
	add	eax,[ebp-4]
	movups	xmm0,[eax]

	mov	eax,[ebp+12]
	add	eax,[ebp-4]
	movups	xmm1,[eax]

	;--------esta parte es la que se puede reemplazar por cualquier 
	;forma de pdto punto de 4
	;PMULLD  xmm0, xmm1   

	;movups [vectorTemp], xmm0 ;store v1 in v3
	
	;mov eax,[vectorTemp]
	;add	eax,[vectorTemp+4]
	;add	eax,[vectorTemp+8]
	;add	eax,[vectorTemp+12]

	;otra manera de hacer pdto punto de enteros
	CVTDQ2PS	xmm0,xmm0
	CVTDQ2PS	xmm1,xmm1
	dpps		xmm0, xmm1,241;f1
	CVTPS2DQ	xmm0,xmm0
	movups		[vectorTemp],xmm0
	mov		eax,[vectorTemp]

	mov	[ebp-20],eax
	;-----------
	mov	eax,[ebp-20]
	add	dword [prodPuntoResultado],eax

	add	dword [ebp-4],16

jmp	cicloProdSse
fincicloProdSse:

mov	dword [ebp-8],0

cicloProdSse2:
mov	eax,[ebp-8]
mov	ebx,[ebp-16]
cmp	eax,ebx
jge	fincicloProdSse2

	mov	eax,[ebp-24];cerosA
	add	eax,[ebp-8]
	mov	ebx,[ebp+8];matA
	add	ebx,[ebp-8]
	add	ebx,[ebp-4];matA+i+j
	mov	ebx,[ebx]
	mov	[eax],ebx
	
	mov	eax,[ebp-28];cerosB
	add	eax,[ebp-8]
	mov	ebx,[ebp+12];matB
	add	ebx,[ebp-8]
	add	ebx,[ebp-4];matB+i+j
	mov	ebx,[ebx]
	mov	[eax],ebx

	add	dword [ebp-8],4

jmp	cicloProdSse2
fincicloProdSse2:

movups	xmm0,[cerosA]
movups	xmm1,[cerosB]

	;--------esta parte es la que se puede reemplazar por cualquier 
	;forma de pdto punto de 4
	;PMULLD  xmm0, xmm1   

	;movups [vectorTemp], xmm0 ;store v1 in v3
	
	;mov eax,[vectorTemp]
	;add	eax,[vectorTemp+4]
	;add	eax,[vectorTemp+8]
	;add	eax,[vectorTemp+12]

	;otra manera de hacer pdto punto de enteros
	CVTDQ2PS	xmm0,xmm0
	CVTDQ2PS	xmm1,xmm1
	dpps		xmm0, xmm1,241;f1
	CVTPS2DQ	xmm0,xmm0
	movups		[vectorTemp],xmm0
	mov		eax,[vectorTemp]

	mov	[ebp-20],eax
	;-----------

mov	eax,[ebp-20]
add	dword [prodPuntoResultado],eax

;cerosB	[ebp -28]
;cerosA	[ebp -24]
;prod	[ebp -20]
;mRes	[ebp -16]
;m'	[ebp -12]
;j	[ebp -8]
;i	[ebp -4]
;ret 	[ebp + 4]
;A 	[ebp +8]
;B 	[ebp +12]
;m 	[ebp +16]
add	esp,80
pop	ebp
ret

;-------------------------------------------------------
parseIntString:
push	ebp
mov	ebp,esp
sub	esp, 80

mov	dword [ebp - 12],0;num=0
mov	dword [ebp -4],10
mov	eax,[ebp+8]
mov	dword [ebp-16],eax

;ascii’[ebp - 16]
;num [ebp - 12]
;10 [ebp - 4]
;ret [ebp + 4]
;ascii [ebp + 8]

cicloParsIntStr:
mov	eax,[ebp -16]
mov	al,[eax];un ascci

mov	bl, 10
cmp	al,bl
je	fincicloParsIntStr

	ifcicloParsIntStr:
	mov	eax,[ebp -16]
	mov	al,[eax];un ascci
	mov	bl, 47
	cmp	al,bl
	jle	elsecicloParsIntStr

	mov	eax,[ebp -16]
	mov	al,[eax];un ascci
	mov	bl, 58
	cmp	al,bl
	jge	elsecicloParsIntStr

	mov	edx,0
	mov	eax,[ebp - 12]
	mul	dword [ebp -4];*10
	mov	ecx,0;reiniciar ecx para evitar resultados anteriores
	mov	ebx,[ebp -16];estaba usando ebx para todo, mala idea
	mov	cl,[ebx]
	add	eax,ecx
	sub	eax,48;num=(num*10)+(ascii-48)
	mov	[ebp - 12],eax

	inc	word [ebp -16]

	elsecicloParsIntStr:

jmp	cicloParsIntStr
fincicloParsIntStr:
mov	eax,[ebp - 12]
mov	[numeroConvertido],eax

add	esp,80
pop	ebp
ret

;--------------------------------------------------

;i [ebp - 20]
;j [ebp - 16]
;A’ [ebp -12]
;m5’ [ebp -8]
;ind [ebp - 4]
;ret [ebp + 4]
productoMatrizClasico:
push	ebp
mov	ebp,esp
sub	esp, 80

mov	dword [ebp-20],0;i=0
mov	dword [ebp-16],0;j=0
mov	dword [ebp-12],matA
mov	dword [ebp-8],matBtransp
mov	dword [ebp-4],0

cicloProMatClas1:
mov	eax,[ebp-20]
mov	ebx,[m]
cmp	eax,ebx	
jge	fincicloProMatClas1
	cicloProMatClas2:
	mov	eax,[ebp-16]
	mov	ebx,[q]
	cmp	eax,ebx	
	jge	fincicloProMatClas2
	
		mov	eax,[n]
		push	eax
		mov	eax,[ebp-12]
		push	eax
		mov	eax,[ebp-8]
		push	eax
		call	productoPunto
		pop eax
		pop eax
		pop eax

		mov	eax,matC
		add	eax,[ebp - 4];matC+ind
		mov	ebx,[prodPuntoResultado];estaba usando eax, lo 
		mov	[eax],ebx;cual daño todo...obviamente

		mov	eax,[n]
		add	[ebp-8],eax;m5’ = m5’ + n
		add	word [ebp-16],4;j+=4
		add	word [ebp-4],4;ind+=4

	jmp cicloProMatClas2
	fincicloProMatClas2:

	mov	eax,[n]
	add	[ebp -12],eax
	add	word [ebp-20],4;i+=4
	mov	word [ebp - 16],0;j=0
	mov	dword [ebp-8],matBtransp;m5’=m5

jmp cicloProMatClas1
fincicloProMatClas1:

add	esp,80
pop	ebp
ret

;----------------------------------------------
parseStringInt:
push	ebp
mov	ebp,esp
sub	esp, 80

mov	dword [ebp - 12],0
mov	dword [ebp -4],10
cicloParsStrInt1:

;cont [ebp - 12]
;aux [ebp - 8]
;10 [ebp - 4]
;num [ebp + 8];por valor

	mov	edx,0
	mov	eax,[ebp + 8]
	div	dword [ebp -4];/10
	mov	dword [ebp - 8],eax

	mov	edx,0
	mov	eax,[ebp - 8]
	mul	dword [ebp -4];*10
	sub	[ebp + 8], eax

	push	dword [ebp + 8]

	mov	eax,[ebp - 8]
	mov	[ebp + 8], eax;num=aux

	inc	dword [ebp-12];cont++

mov	eax,[ebp +8]
mov	ebx,0
cmp	eax,ebx
jg cicloParsStrInt1
finCicloParsStrInt1:

cicloParsStrInt2:
mov	eax,[ebp-12]
mov	ebx,0
cmp	eax,ebx
jle	fincicloParsStrInt2

	mov ecx,esp
	call	DisplayInt
	pop	ecx
	dec	dword [ebp - 12]

jmp cicloParsStrInt2
fincicloParsStrInt2:

add	esp,80
pop	ebp
ret



;------------------------------------------------
productoPunto:
push	ebp
mov	ebp,esp
sub	esp, 80

mov	dword [ebp - 4], 0
mov	dword [prodPuntoResultado],0

cicloProd1:
	mov	eax, [ebp - 4]
	mov	ebx, [ebp +16]
	cmp	eax,ebx
	jge	finCicloProd

	mov	eax,[ebp + 8]
	add	eax,[ebp - 4]
	mov	eax,[eax]
	mov	[ebp - 12],eax

	mov	eax,[ebp + 12]
	add	eax,[ebp - 4]
	mov	eax,[eax]
	mov	[ebp - 8],eax

	mov	edx,0
	mov	eax,[ebp - 12]
	mul	dword [ebp - 8]

	add	[prodPuntoResultado],eax

	add	word [ebp-4],4

jmp cicloProd1
finCicloProd:
add	esp,80
pop	ebp
ret



transpuesta:;#600
	mov	byte [i],0
	mov	byte [j],0
	mov	byte [ind],0
	ciclo1Tranp:;60A 
		;COMP I  CON N
		mov	al,[i]
		mov	bl,[q]
		cmp	al,bl
		Jae finCiclo1Trans;622
		ciclo2Trans:;60D 
			mov	al,[j];COMP J CON M
			mov	bl,[n]
			;mov	ebx,[ebx]
			CMP 	al,bl
			jae	finCiclo2Trans;61C

			mov	eax,matB
			add	eax,[i]

			add	eax,[ind];CARGO MATA + IND
			mov	eax,[eax];GUARDO EN MATB

			mov	ebx,matBtransp
			add	ebx,[indTrans]
			mov	[ebx],eax;cargp dir matb

			mov	eax,[q]
			add	[ind],al;IND = IND + q

			mov	eax,4
			add 	byte [j],4;J++
			add 	byte [indTrans],4;J++
		JMP 	ciclo2Trans;60D
		finCiclo2Trans:;61C 
		mov	eax,4
		add 	byte [i],4;I++
		;mov 	eax,[esp+4];MATA++
		;inc	eax
		;mov	[esp+4],eax
		mov	byte [j],0
		mov	byte [ind],0	
	JMP ciclo1Tranp;60A
	finCiclo1Trans:;622 
	ret;RETORNO DINAMICO

leerMatriz:;#900

	POP eBX;SACO RETORNO
	MOV [retLeer],eBX
	POP eBX
	MOV [matLeer],eBX;saco &matriz
	POP eBX
	MOV [tamLeer],eBX ;saco tam

	mov	dword [i],0
	cicloLeer:
		mov	eBX,[i]
		mov	eax,[tamLeer];
		;mov	ebx,[ebx]
		cmp	eBX,eax

		Jae finLeer

		;mov	msgBienv,'Enter elemento'
		;mov 	ecx,msgBienv

			mov	eax,[i]
			push	eax
			call	parseStringInt
			pop	ecx

			mov	ecx,espacioEnBlaco
			mov	edx,1
			call	DisplayText
	
		;MSG DE LA MATRIZ
		mov 	ecx,[matLeer]
		call 	ReadInt

		INC dword [i]
		add dword [matLeer],4

	JMP cicloLeer
	finLeer:
	mov	byte [i],0
	jmp [retLeer];RETORNO DINAMICO

imprimirMatriz:
push	ebp
mov	ebp,esp
sub	esp, 80

;nFilas [ebp - 8]
;nColum [ebp - 12]
;matriz [ebp - 16]

	mov	dword [i],0
	mov	dword [ind],0
	cicloMostrar:
		mov	ebx,[i]

		mov	eax,[ebp+8];16;numero de filas * 4

		;mov	ebx,[ebx]
		cmp	ebx,eax
		Jae finMostrar
		mov	dword [j],0;cambie mil cosas para lo de imprimir completo pero no esto lo deje como byte -_-
		ciclo2Mos:
		mov	ebx,[j]

		mov	eax,[ebp+12];12;numero de columnas * 4

		;mov	ebx,[ebx]
		cmp	ebx,eax
		jae	finMostrar2
			;mov	msgBienv,'Enter elemento'
			;mov 	ecx,msgBienv

			mov	ecx,[ebp + 16];matriz que quiero imprimir
			add	ecx,[ind]

			mov	eax,[ecx]
			push	eax
			call	parseStringInt
			pop	ecx;esto falto -> segmentation fault -_-

			mov	ecx,espacioEnBlaco
			mov	edx,1
			call	DisplayText
			add byte [j],4
			add byte [ind],4
		jmp ciclo2Mos
		finMostrar2:
		add  byte [i],4
	mov	ecx,saltoDeLinea
	mov	edx,1
	call	DisplayText
	JMP cicloMostrar
	finMostrar:
mov	byte [i],0
add	esp,80
pop	ebp
;pop eax
;jmp eax;ret hace lo mismo que estos 2
ret


;-------------Entrada y salida---------------
;saca en pantalla el resultado
DisplayText:

	mov     eax, sysWrite
	mov     ebx, stdout
	int     80H
	ret

DisplayInt:
	mov	eax,48
	add	[ecx],eax
	;mov 	ecx,num
	mov 	edx,1
	mov     eax, sysWrite
	mov     ebx, stdout
	int     80H
	;sufri y perdi horas a causa de lo de abajo, trataba de imprimir el i al leer las matrices, pero como le suma 48 para imprimir arruinaba la i, tenia que arreglarla despues de usarla
	mov	eax,48
	sub	[ecx],eax
	ret

;me deja en eax lo que ingrese el usuario
ReadText:
    mov     ebx, stdin
    mov     eax, sysRead
    int     80H
    ret

ReadInt:
	push	ecx;direccion de donde ira el numero final

	mov 	ecx,numeroLeido
	mov     edx,11;pues son 2^32
	mov     ebx, stdin
	mov     eax, sysRead
	int     80H

	push	numeroLeido
	call parseIntString
	pop eax

	pop	ecx
	mov	eax,[numeroConvertido]
	mov	[ecx],eax;guardo el num convertido en donde quiero

	ret

;termina el programa
Exit: 
	mov     eax, sys_Exit
	mov     ebx, 0
	int     80H
