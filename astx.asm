%include "printf32.asm"

section .data
    delim db " ", 0
    it1 dd 0,
    cnt dd 0,
    str_len dd 0,
    word_cnt dd 0,
    word_cnt_init dd 0,
    temp dd 0,
   	char db 0,
   	words_array dd 0,
   	tree_root dd 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern malloc
extern free
extern strcpy

global create_tree
global iocla_atoi

iocla_atoi: 
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx

    xor eax, eax
    mov ebx, [ebp + 8]
    xor ecx, ecx

    calc_len:
    	inc ecx
    	cmp byte [ebx + ecx], 0
    	jne calc_len

    mov eax, ecx
    push_chars:
    	xor edx, edx
    	mov dl, [ebx + ecx - 1]
    	cmp dl, 45
    	je exit_push_chars
    	push edx
    	dec ecx
    	test ecx, ecx
    	jne push_chars

    exit_push_chars:
		mov ecx, eax
		xor eax, eax
		mov ebx, [ebp + 8]
		cmp byte [ebx], 45
		jne build_number
		dec ecx

    build_number:
    	mov ebx, 10
    	mul ebx
    	xor ebx, ebx
    	pop ebx
    	sub ebx, '0'
    	add eax, ebx
    	dec ecx
    	test ecx, ecx
    	jne build_number

    xor ebx, ebx
    mov ebx, [ebp + 8]
    cmp byte [ebx], '-'
    jne final
    mov ebx, -1
    mul ebx

	final:
    	pop edx
    	pop ecx
    	pop ebx
    	leave
    	ret

create_tree:
    enter 0, 0
    pushad
    xor eax, eax
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

   	mov dword [it1], 0
   	mov dword [cnt], 0
   	mov dword [str_len], 0
   	mov dword [word_cnt], 0
   	mov dword [word_cnt_init], 0
   	mov dword [temp], 0
   	mov byte [char], 0
   	mov dword [words_array], 0
   	mov dword [tree_root], 0

    mov edx, [ebp + 8]

	find_str_specs:
		inc ecx
		cmp byte [edx + ecx], ' '
		je increment_word_cnt
		find_str_specs_pt2:
			cmp byte [edx + ecx], 10
			jne find_str_specs
			jmp specs_found

	increment_word_cnt:
		xor ebx, ebx
		mov dword ebx, [word_cnt]
		inc ebx
		mov dword [word_cnt], ebx
		jmp find_str_specs_pt2

	specs_found:
	xor ebx, ebx
	mov dword ebx, [word_cnt]
	inc ebx
	mov dword [word_cnt], ebx
	mov dword ebx, [word_cnt]

	dec ecx
	mov dword [str_len], ecx
	xor ecx, ecx

    mov dword ebx, [word_cnt]
    mov dword [word_cnt_init], ebx

    ; deci am gasit numarul de cuvinte si lungimea sirului

    shl ebx, 2
    ;PRINTF32 `Capacitate vector: %d\n\x0`, ebx
    push edx
    push ebx
    call malloc
    pop ebx
    pop edx
    mov dword [words_array], eax 
    mov dword [cnt], 0

    push_words:
    	mov ebx, [str_len]
    	find_word_start:
    		mov edx, [ebp + 8]
    		dec ebx
    		cmp ebx, -1
    		je push_words_pt_2
    		cmp byte [edx + ebx], ' '
    		je push_words_pt_2
    		jmp find_word_start

    	push_words_pt_2:
		inc ebx
		xor eax, eax
		mov dword eax, [str_len]
		sub eax, ebx
		;inc eax ; asta e regula aia ca adaugi 1
		;inc eax ; asta e pentru '\0'
		add eax, 2
		;PRINTF32 `%d\n\x0`, ebx
		push eax
		call malloc
		pop ecx
		mov dword [temp], ebx
		
		;PRINTF32 `%d\n\x0`, ebx

		mov dword [cnt], 0

    	build_substring:
    		xor ecx, ecx
    		mov edx, [ebp + 8]
    		mov cl, [edx + ebx]
    		mov byte [char], cl
    		mov dword ecx, [cnt]
    		xor edx, edx
    		mov byte dl, [char]
    		mov byte [eax + ecx], dl
    		inc ecx
    		mov dword [cnt], ecx
    		inc ebx
    		cmp dword ebx, [str_len]
    		jle build_substring

    	mov dword ecx, [cnt]
    	mov byte [eax + ecx], 0
    	
    	pushad
    	xor ebx, ebx
    	xor edx, edx
    	mov dword ebx, [word_cnt]
    	;PRINTF32 `%d\n\x0`, ebx
    	mov dword edx, [words_array]
    	mov dword [edx + 4 * (ebx - 1)], eax
    	;PRINTF32 `%d\n\x0`, eax
    	popad

    	xor ebx, ebx
    	mov dword ebx, [temp]
    	sub ebx, 2
    	mov dword [str_len], ebx

    	mov dword ebx, [word_cnt]
    	dec ebx
    	mov dword [word_cnt], ebx
    	test ebx, ebx
    	jnz push_words

    mov dword ebx, [word_cnt_init]
    mov dword [word_cnt], ebx
    mov dword [cnt], 0

    xor eax, eax
    push eax
    ;PRINTF32 `\n\x0`
    ;PRINTF32 `Am ajuns la partea de constructie a arborelui\n\x0`
    put_strings:
    	xor ebx, ebx
    	xor edx, edx
    	mov dword edx, [cnt]
    	mov dword ecx, [words_array]
    	mov dword ebx, [ecx + 4 * edx]

    	;PRINTF32 `%d\n\x0`, ebx
    	;PRINTF32 `%s\n\x0`, ebx

    	cmp byte [ebx], '+'
    	je put_sign
    	cmp byte [ebx], '-'
    	je check_sign_number
    	cmp byte [ebx], '*'
    	je put_sign
    	cmp byte [ebx], '/'
    	je put_sign
    	jmp put_number

    	check_sign_number:
    		cmp byte [ebx + 1], 0
    		je put_sign
    		jmp put_number

    	put_strings_pt_2:
    	
    	mov dword edx, [cnt]
    	inc edx
    	;PRINTF32 `deci [cnt]: %d\n\x0`, edx
    	mov dword [cnt], edx
    	xor ebx, ebx
    	mov dword ebx, [word_cnt]
    	dec ebx
    	mov dword [word_cnt], ebx
    	test ebx, ebx
    	jnz put_strings
    	jmp func_final
   	
    put_sign:
    	test eax, eax
    	jne put_sign_left_node
    	push edx
    	push dword 12
    	call malloc
    	pop ecx
    	pop edx
    	;mov dword [eax], ebx
    	push eax
    	push dword 100
    	call malloc
    	pop ecx
    	push ebx
    	push eax
    	call strcpy
    	pop ecx
    	pop ebx
    	pop eax
    	mov dword [eax], ecx 

    	mov dword [eax + 4], 0
    	mov dword [eax + 8], 0
    	mov dword [tree_root], eax
    	jmp put_sign_done

    	put_sign_left_node:
	    	push eax
	    	push edx
	    	push dword 12
	    	call malloc
	    	pop ecx
	    	pop edx
	    	;mov dword [eax], ebx
	    	push eax
	    	push dword 100
	    	call malloc
	    	pop ecx
	    	push ebx
	    	push eax
	    	call strcpy
	    	pop ecx
	    	pop ebx
	    	pop eax
	    	mov dword [eax], ecx 
	    	mov dword [eax + 4], 0
	    	mov dword [eax + 8], 0
	    	pop ecx

	    	cmp dword [ecx + 4], 0
	    	jne put_sign_pt2_right_node
	    	mov dword [ecx + 4], eax
	    	push ecx
			jmp put_sign_done
		
			put_sign_pt2_right_node:
				cmp dword [ecx + 8], 0
				jne put_sign_lower_node
				mov dword [ecx + 8], eax
				push ecx
				jmp put_sign_done

			put_sign_lower_node:
				find_free_slot_sign:
					pop ecx
					cmp dword [ecx + 8], 0
					jne find_free_slot_sign
				mov dword [ecx + 8], eax
				push ecx

		put_sign_done:
    	jmp put_strings_pt_2

    put_number:
    	push eax
    	push edx
    	push dword 12
    	call malloc
    	pop ecx
    	pop edx
    	;mov dword [eax], ebx
    	push eax
    	push dword 100
    	call malloc
    	pop ecx
    	push ebx
    	push eax
    	call strcpy
    	pop ecx
    	pop ebx
    	pop eax
    	mov dword [eax], ecx
    	mov dword [eax + 4], 0
    	mov dword [eax + 8], 0
    	pop ecx

    	cmp dword [ecx + 4], 0
    	jne put_number_right
    	mov [ecx + 4], eax
    	mov eax, ecx
    	jmp put_number_done

    	put_number_right:
    		cmp dword [ecx + 8], 0
    		jne put_number_lower_node
	    	mov [ecx + 8], eax
	    	mov eax, ecx
    		jmp put_number_done

    	put_number_lower_node:
			find_free_slot_number:
				pop ecx
				cmp dword [ecx + 8], 0
				jne find_free_slot_number
			mov [ecx + 8], eax
			mov eax, ecx

    	put_number_done:
    	jmp put_strings_pt_2

    func_final:

    empty_stack:
    	pop ecx
    	test ecx, ecx
    	jnz empty_stack

    mov dword ecx, [word_cnt_init]
    free_strings:
    	mov dword edx, [words_array]
    	mov dword ebx, [edx + 4 * (ecx - 1)]
    	;PRINTF32 `%s\n\x0`, ebx
    	push ecx
    	push ebx
    	call free
    	pop ebx
    	pop ecx
    	dec ecx
    	test ecx, ecx
    	jne free_strings

    push dword [words_array]
    call free
    pop ecx
    xor ecx, ecx
   	popad ; se restaureaza toti registri
   		  ; trebuie sa pun in eax, baza arborelui
    mov dword eax, [tree_root]
    leave
    ret
