; 324CB - Dragomir Constantin-Cristian

section .data
    cnt dd 0,
    ; iterator
    str_len dd 0,
    ; numarul de caractere din sirul dat ca input
    ; NU ramane constant
    word_cnt dd 0,
    ; variabila de tip iterator
    word_cnt_init dd 0,
    ; retinerea numarului de cuvinte gasite
    temp dd 0,
    ; variabila folosita pentru a retine pozitia la 
    ; care s-a ajuns in parcurgerea sirului de la intrarea in program
   	words_array dd 0,
   	; vector ce contine adrese catre subsiruri de caractere
   	tree_root dd 0,
   	; radacina arborelui construit
   	char db 0,
   	; retinerea unui caracter

section .bss
    root resd 1

section .text

extern printf
extern malloc
extern free

global create_tree
global iocla_atoi

iocla_atoi:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov ebx, [ebp + 8]
    
    xor ecx, ecx
    calc_len:
    	inc ecx
    	cmp byte [ebx + ecx], 0
    	jne calc_len

    ; se calculeaza lungimea sirului dat ca parametru

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

    ; punerea pe stiva a caracterelor in ordine inversa
    ; pentru ca ulterior acestea sa fie scoase
    ; in ordinea data de sirul de caractere dat ca parametru

    exit_push_chars:
		mov ecx, eax
		xor eax, eax
		mov ebx, [ebp + 8]
		cmp byte [ebx], 45
		jne build_number
		dec ecx

	; se neglijeaza caracterul '-', pentru moment,
	; in caz ca exista

    build_number:
    	mov dword ebx, 10
    	mul dword ebx
    	xor ebx, ebx
    	pop ebx
    	sub dword ebx, '0'
    	add dword eax, ebx
    	dec ecx
    	test ecx, ecx
    	jne build_number

    ; construirea efectiva in eax a numarului reprezentat ca string

    mov ebx, [ebp + 8]
    cmp byte [ebx], '-'
    jne final
    xor ebx, ebx
    mov ebx, -1
    mul ebx

    ; daca numarul este negativ, se inmulteste numarul din eax cu -1

	final:
    	leave
    	ret

create_tree:
    enter 0, 0
    pushad
    
    ; retinerea valorilor initiale din registri
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    mov edx, [ebp + 8]
    
    ; initializare registri

	find_str_specs:
		inc ecx
		cmp byte [edx + ecx], ' '
		je increment_word_cnt
		find_str_specs_pt2:
			cmp byte [edx + ecx], 0
			jne find_str_specs
			jmp specs_found

	; aflarea numarului de caractere din sirul dat la intrare 

	increment_word_cnt:
		mov dword ebx, [word_cnt]
		inc ebx
		mov dword [word_cnt], ebx
		jmp find_str_specs_pt2

	; cand se gaseste un spatiu se incrementeaza numarul de cuvinte

	specs_found:
	mov dword ebx, [word_cnt]
	inc ebx
	mov dword [word_cnt], ebx

	; numarul de spatii este mai mic cu 1 fata de numarul de cuvinte

	dec ecx
	mov dword [str_len], ecx

	; in str_len se retine pozitia ultimului caracter (nu cea a lui \0)!

    mov dword ebx, [word_cnt]
    mov dword [word_cnt_init], ebx

    ; se va retine numarul de cuvinte intr-o alta variabila

    shl ebx, 2
    push ebx
    call malloc
    pop ebx
    mov dword [words_array], eax 

    ; alocam un vector care va retine pointeri catre siruri de caractere
    ; o adresa va ocupa 4 bytes, de aceea necesitatea inmultirii cu 4

    mov dword [cnt], 0
    push_words:
    	mov ebx, [str_len]
    	find_word_start:
    		mov edx, [ebp + 8]
    		dec ebx
    		test ebx, ebx
    		jl push_words_pt_2
    		cmp byte [edx + ebx], ' '
    		je push_words_pt_2
    		jmp find_word_start

    	; IDEE INITIALA:
    	; vrem sa salvam pe stiva pointerii catre sirurile
    	; de caractere ce vor fi generate
    	; subsirurile trebuie puse in ordine inversa
    	; pentru a fi scoase in ordinea din input
    	; astfel, se incepe de la sfarsit si se parcurge 
    	; sirul catre inceput, cu opriri asupra spatiilor
    	; sau cand iteratorul ajunge la -1
    	; IDEE FINALA:
    	; se vor salva adresele in vectorul [words_array]

    	push_words_pt_2:
		inc ebx
		mov dword ecx, [str_len]
		sub ecx, ebx
		add ecx, 2

		; subsirul generat trebuie sa i alipeasca un '\0'

		push ecx
		call malloc
		pop ecx
		mov dword [temp], ebx

		; se retine in [temp] pozitia la care am ajuns in
		; parcurgerea sirului initial

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

    	; constructia efectiva a subsirului

    	mov dword ecx, [cnt]
    	mov byte [eax + ecx], 0
    	
    	; alipirea efectiva a '\0'

    	push ebx
    	push edx
    	mov dword ebx, [word_cnt]
    	mov dword edx, [words_array]
    	mov dword [edx + 4 * (ebx - 1)], eax
    	pop edx
    	pop ebx

    	; retinerea in vector a adresei catre subsirul de caractere

    	mov dword ebx, [temp]
    	sub ebx, 2
    	mov dword [str_len], ebx

    	; se trece, in sens inapoi, la urmatorul cuvant
    	; si se considera ca acela este ultimul cuvant
    	; ceea ce justifica modificarea lui [str_len]

    	mov dword ebx, [word_cnt]
    	dec ebx
    	mov dword [word_cnt], ebx
    	test ebx, ebx
    	jnz push_words

    	; se decrementeaza numarul de cuvinte [word_cnt] si
    	; se reia algoritmul
    	; se trece mai departe cand se vor fi memorat
    	; toate adresele subsirurilor generate

    mov dword ebx, [word_cnt_init]
    mov dword [word_cnt], ebx
    mov dword [cnt], 0

    ; se reface iteratorul [word_cnt]
    ; cu [cnt] vom parcurge, de la inceput la sfarsit
    ; vectorul [words_array]

    xor eax, eax
    push eax
    put_strings:
    	xor ebx, ebx
    	xor edx, edx
    	mov dword edx, [cnt]
    	mov dword ecx, [words_array]
    	mov dword ebx, [ecx + 4 * edx]

    	; preluarea, pe rand, a adreselor memorate
    	; din vectorul [words_array]

    	cmp byte [ebx], '+'
    	je put_sign
    	cmp byte [ebx], '-'
    	je check_sign_number
    	cmp byte [ebx], '*'
    	je put_sign
    	cmp byte [ebx], '/'
    	je put_sign
    	jmp put_number

    	; verificam daca trebuie introdus in arbore un semn
    	; sau un numar

    	check_sign_number:
    		cmp byte [ebx + 1], 0
    		je put_sign
    		jmp put_number

    	; '-' poate indica un semn sau un numar

    	put_strings_pt_2:
    	mov dword edx, [cnt]
    	inc edx
    	mov dword [cnt], edx
    	cmp dword edx, [word_cnt]
    	jne put_strings
    	jmp func_final

    	; se incrementeaza [cnt] si se verifica
    	; daca sunt egale [cnt] si [word_cnt]
   	
    put_sign:
    ; se adauga un nod a carui informatie este reprezentata de un semn
    	test eax, eax
    	jne put_sign_left_node
    	push dword 12
    	call malloc
    	pop ecx
    	mov dword [eax], ebx
    	mov dword [eax + 4], 0
    	mov dword [eax + 8], 0
    	mov dword [tree_root], eax
    	jmp put_sign_done

    	; toate sirurile de caractere de la intrare incep
    	; cu un semn
    	; daca in eax avem NULL ( valoarea 0) atunci
    	; se creeaza radacina arborelui

    	put_sign_left_node:
    	; daca radacina exista atunci se incearca
    	; introducerea unui nod in stanga nodului 
    	; considerat la momentul actual

	    	push eax
	    	; inainte de malloc se introduce pe stiva
	    	; adresa nodului considerat
	    	; pentru a se asigura o cale de revenire
	    	; catre radacina

	    	push dword 12
	    	call malloc
	    	pop ecx
	    	mov dword [eax], ebx
	    	mov dword [eax + 4], 0
	    	mov dword [eax + 8], 0
	    	; eax retine adresa unui nod (conventie cdecl)

	    	pop ecx
	    	
	    	; vrem ca nodul anterior sa aiba la stanga sa adresa
	    	; noului nod retinut in registrul eax

	    	cmp dword [ecx + 4], 0
	    	jne put_sign_pt2_right_node
	    	mov dword [ecx + 4], eax
	    	push ecx
			
			; am reusit sa introducem nodul in arbore
			; adresa nodului anterior trebuie reintrodusa
			; pe stiva pentru a nu strica ramura de revenire
			
			jmp put_sign_done
		
			put_sign_pt2_right_node:
			; exista posibilitatea ca nodul din stanga
			; sa fie ocupat
			; se incearca introducerea sa la dreapta

				cmp dword [ecx + 8], 0
				jne put_sign_lower_node
				mov dword [ecx + 8], eax
				push ecx
				jmp put_sign_done

			put_sign_lower_node:
			
			; in ultima instanta, nodul nu poate
			; fi introdus nici la stanga, nici la dreapta
				
				find_free_slot_sign:
					pop ecx
					cmp dword [ecx + 8], 0
					jne find_free_slot_sign
				mov dword [ecx + 8], eax
				push ecx
				
				; din aceasta cauza, se preiau adrese ale
				; nodurilor stocate pe stiva
				; pana se ajunge la unul care are partea dreapta libera
				; (adica are atribuita valoarea 0 - NULL)

		put_sign_done:
		; dupa ce s-a introdus nodul, se revine la algortimul
		; de parcurgere a adreselor din vectorul [words_array]

    	jmp put_strings_pt_2

    put_number:
    ; se adauga un nod a carui informatie este reprezentata de un numar
    	push eax
    	push dword 12
    	call malloc
    	pop ecx
    	; se creeaza un nod a carui adresa se retine in eax

    	mov dword [eax], ebx
    	mov dword [eax + 4], 0
    	mov dword [eax + 8], 0
    	; se initializeaza campurile nodului
    	
    	pop ecx
    	; in ecx se retine adresa nodului anterior
		cmp dword [ecx + 4], 0
    	jne put_number_right
    	mov [ecx + 4], eax
    	mov eax, ecx
    	jmp put_number_done
    	
    	; se incearca punerea nodului in stanga

    	put_number_right:
    		cmp dword [ecx + 8], 0
    		jne put_number_lower_node
	    	mov [ecx + 8], eax
	    	mov eax, ecx
    		jmp put_number_done

    		; se incearca punerea nodului in dreapta

    	put_number_lower_node:
			find_free_slot_number:
				pop ecx
				cmp dword [ecx + 8], 0
				jne find_free_slot_number
			mov [ecx + 8], eax
			mov eax, ecx

		; in cazul in care incercarile anterior mentionate
		; esueaza, se cauta la un nivel inferior pe ramura
		; un nod care are partea dreapta libera

    	put_number_done:
    	jmp put_strings_pt_2
    	; Observatie:
    	; nodul ce contine un numar va fi frunza
    	; deci nu mai e necesar ca adresa sa
    	; sa fie trecuta pe stiva

    func_final:

    empty_stack:
    	pop ecx
    	test ecx, ecx
    	jnz empty_stack

    ; este posibil ca in arbore sa ramana resturi ale unei ramuri
    ; de aceea se goleste stiva pana se ajunge valoarea 0
    ; (evident, scoasa si ea de pe stiva)

    push dword [words_array]
    call free
    pop ecx
    
    ; eliberarea memoriei utilizata de vectorul ce retine
    ; adrese catre subsiruri [words_array]

   	popad

   	; restaurarea registrilor

    mov dword eax, [tree_root]
    
    ; scrierea in eax a adresei radacinei arborelui
    ; rezultatul din eax va fi returnat functiei apelante

    leave
    ret
