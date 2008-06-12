	.text
	.global squareCheck
	
squareCheck:	
	push %ebp
	mov %esp, %ebp

	push %eax  # Salvar Registros  
	push %ecx
	push %edx

	mov 8(%ebp), %eax    # Mover el n�mero a EAX como primer operando 
	imull 8(%ebp)        # Multiplicar por s� mismo (atenci�n al sufijo) 
	mov 12(%ebp), %ecx
	mov %eax, (%ecx)     # Almacenar el resultado 
	mov %edx, 4(%ecx)    # Almacenar el resultado 

	pop %edx             # Restaurar registros 
	pop %ecx
	pop %eax	

	mov %ebp, %esp
	pop %ebp
	ret
