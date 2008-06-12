	.text
	.global buscar

	# subrutina buscar
	#
	#    - entrada:
	#        (%ebp+ 8) tamaño del array 
	#        (%ebp+12) dirección del array 
	#        (%ebp+16) dato a buscar
	#    - salida:
	#        (%ebp+20) posición en que se encuentra,
	#                    o -1 si no se encuentra
	#
buscar:
	push %ebp
	mov %esp, %ebp
	sub $4, %esp             # espacio para la variable local
	                         #     (contador)
		
	push %eax                # guarda los registros
	push %ebx
	push %ecx
	push %edx
	push %esi

	movl $0, -4(%ebp)        # incrementa el contador
	
	mov 12(%ebp), %esi       # dirección del array
	mov 16(%ebp), %edx       # dato a buscar
	
	mov $0, %ecx             # variable a
	mov 8(%ebp), %ebx        # variable b
	dec %ebx
bucle:
	add $1, -4(%ebp)         # incrementa el contador
	
	cmp %ebx, %ecx           # si (a>b) devuelve -1
	jg no_encontrado
	            
	mov %ecx, %eax           # m = (a+b) / 2
	add %ebx, %eax
	shr %eax
	
	cmp (%esi,%eax,4), %edx  # si (dato=array[m]) devuelve m
	je encontrado

	jg dato_mayor            # si (dato>array[m]) ...
	                         
	mov %eax, %ebx           # dato<array[m]: b=m-1
	dec %ebx
	jmp bucle

dato_mayor:	
	mov %eax, %ecx           # dato>array[m]: a=m+1
	inc %ecx
	jmp bucle

encontrado:
	mov %eax, 20(%ebp)       # devuelve m
	jmp fin

no_encontrado:
	movl $-1, 20(%ebp)        # devuelve m

fin:

	pop %esi
	pop %edx
	pop %ecx
	pop %ebx
	pop %eax
	add $4, %esp             # variable local
	pop %ebp
	ret
