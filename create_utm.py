# EXPECTED FORMAT OF THE UTM INPUT:
#    <initial_state> | <sub_machine_input> | <transitions> | <final_state>
#
# EXPECTED FORMAT OF TRANSITIONS:
#    <from_state> <from_letter> <to_state> <to_letter> <movement>
#
# each of the above items is represented by a letter of the input_alphabet,
# it is up to the user to decide how to distribute those input characters.
#
# EXAMPLE:
#    translation of user input:
#    '1' = '1'
#    '+' = '+'
#    '=' = '='
#    '.' = '.'
#    'a' = 'scanright'
#    'b' = 'replaceplus'
#    'c' = 'eraseone'
#    'd' = 'halt'
#
#    ft_turing input for a unary_add:         "a|111+11=|a.a.Ra1a1Ra+b1Rb1b1Rb=c.Lc1d.R|d"
#    ft_turing expected output for the above: "a|11111..|a.a.Ra1a1Ra+b1Rb1b1Rb=c.Lc1d.R|d"
#
# EXAMPLE 2:
#    translation of user input:
#    '1' = '1'
#    '.' = '.'
#    '-' = '-'
#    '=' = '='
#    'a' = 'scanright'
#    'b' = 'eraseone'
#    'c' = 'subone'
#    'd' = 'skip'
#    'e' = 'HALT'
#
#    ft_turing input for a unary_sub:         "a|111-11=|a.a.Ra1a1Ra-a-Ra=b.Lb1c=Lb-e.Lc1c1Lc-d-Ld.d.Ld1a.R|e"
#    ft_turing expected output for the above: "a|1......|a.a.Ra1a1Ra-a-Ra=b.Lb1c=Lb-e.Lc1c1Lc-d-Ld.d.Ld1a.R|e"

import json

# user alphabet
input_alphabet = ["a", "b", "c", "d", "e", "1", "+", "-", ".", "="]
#reserved alphabet
input_alphabet_marker = "!"
section_separator = "|"
movement_chars = ["L", "R"]
transitions_alphabet = input_alphabet + movement_chars
blank = "~"
#total machine alphabet
machine_alphabet = [blank] + input_alphabet + [input_alphabet_marker] + [section_separator] + movement_chars
initial_state = "get_init_state"
final_state = "HALT"

# fill in json info
machine_description = {}
machine_description["name"] = "universal_turing_machine"
machine_description["alphabet"] = machine_alphabet
machine_description["blank"] = blank
machine_description["states"] = []
machine_description["initial"] = initial_state
machine_description["finals"] = [final_state]
machine_description["transitions"] = {}

def create_new_state(name):
    machine_description["states"].append(name)
    machine_description["transitions"][name] = []

def create_new_transition(from_state, read, to_state, write, action):
    machine_description["transitions"][from_state].append({
        "read" : read,
        "to_state" : to_state,
        "write" : write,
        "action" : action
    })

create_new_state(initial_state)
create_new_state(final_state)

# buscar el estado inicial
for s in input_alphabet:
    find_input_from_state_s = f"find_input_from_state_{s}"
    create_new_state(find_input_from_state_s)
    create_new_transition(initial_state, s, find_input_from_state_s, s, "RIGHT")

    # saltarse el separador
    create_new_transition(find_input_from_state_s, section_separator, find_input_from_state_s, section_separator, "RIGHT")

    # encontrar el primer carácter del input de la submáquina (desde el estado inicial) y marcarlo
    for l in input_alphabet:
        find_trans_from_state_s_letter_l = f"find_trans_from_state_{s}_letter_{l}"
        create_new_state(find_trans_from_state_s_letter_l)
        create_new_transition(find_input_from_state_s, l, find_trans_from_state_s_letter_l, input_alphabet_marker, "RIGHT")

        # buscar transición para el estado y letra actual, saltándose todo el input hasta llegar al 2º separador
        for l2 in input_alphabet:
            create_new_transition(find_trans_from_state_s_letter_l, l2, find_trans_from_state_s_letter_l, l2, "RIGHT")

# cuando encuentra el segundo separador de sección, se lo salta pero entra en un nuevo estado
# para comprobar si la siguiente letra que encuentre es el state que busca:
for s in input_alphabet:
    for l in input_alphabet:
        find_trans_from_state_s_letter_l = f"find_trans_from_state_{s}_letter_{l}"
        check_state_from_state_s_letter_l = f"check_state_from_state_{s}_letter_{l}"
        create_new_state(check_state_from_state_s_letter_l)
        create_new_transition(find_trans_from_state_s_letter_l, section_separator, check_state_from_state_s_letter_l, section_separator, "RIGHT")
        # si encuentra una "R" o "L", que separan transiciones, tiene el mismo comportamiento que con el separador 2 (se usa para saltar de una transición a otra):
        create_new_transition(find_trans_from_state_s_letter_l, "R", check_state_from_state_s_letter_l, "R", "RIGHT")
        create_new_transition(find_trans_from_state_s_letter_l, "L", check_state_from_state_s_letter_l, "L", "RIGHT")

        # comprobar si la siguiente letra que encuentre es el state que busca:
        for l2 in input_alphabet:
            if l2 != s:
                # si el state NO ha coincidido, buscar la siguiente transition (se reusan las transiciones que hemos creado anteriormente):  
                create_new_transition(check_state_from_state_s_letter_l, l2, find_trans_from_state_s_letter_l, l2, "RIGHT")
            else:
                # si sí coincide el state, saltárselo para comprobar si la siguiente letra es la letter que buscamos:
                check_letter_from_state_s_letter_l = f"check_letter_from_state_{s}_letter_{l}"
                create_new_state(check_letter_from_state_s_letter_l)
                create_new_transition(check_state_from_state_s_letter_l, l2, check_letter_from_state_s_letter_l, l2, "RIGHT")

# si el state ha coincidido, comprobar si la siguiente letra que encuentre es la letter que busca:
find_new_state = "find_new_state"
create_new_state(find_new_state)
for s in input_alphabet:
    for l in input_alphabet:
        find_trans_from_state_s_letter_l = f"find_trans_from_state_{s}_letter_{l}"
        check_letter_from_state_s_letter_l = f"check_letter_from_state_{s}_letter_{l}"
        for l2 in input_alphabet:
            if l2 != l:
                # si la letra NO ha coincidido, buscar la siguiente transition (se reusan las transiciones que hemos creado anteriormente):
                # FIXME: se tiene que saltar tb el R y L
                create_new_transition(check_letter_from_state_s_letter_l, l2, find_trans_from_state_s_letter_l, l2, "RIGHT")
            else:
                # saltarse la letra actual para encontrar el to_state al que hay que cambiar:
                create_new_transition(check_letter_from_state_s_letter_l, l2, find_new_state, l2, "RIGHT")

# si tanto el state como la letra han coincidido con los que buscábamos, guardarse el state y letra al que hay que cambiar, y el L o R de la transición
for s in input_alphabet:
    find_new_letter_for_new_state_s = f"find_new_letter_for_new_state_{s}"
    create_new_state(find_new_letter_for_new_state_s)
    create_new_transition(find_new_state, s, find_new_letter_for_new_state_s, s, "RIGHT")
    for l in input_alphabet:
        find_movement_for_new_state_s_letter_l = f"find_movement_for_new_state_{s}_letter_{l}"
        create_new_state(find_movement_for_new_state_s_letter_l)
        create_new_transition(find_new_letter_for_new_state_s, l, find_movement_for_new_state_s_letter_l, l, "RIGHT")

for s in input_alphabet:
    for l in input_alphabet:
        find_movement_for_new_state_s_letter_l = f"find_movement_for_new_state_{s}_letter_{l}"
        find_finals_section_from_trans_s_l_R = f"find_finals_section_from_trans_{s}_{l}_R"
        find_finals_section_from_trans_s_l_L = f"find_finals_section_from_trans_{s}_{l}_L"
        create_new_state(find_finals_section_from_trans_s_l_R)
        create_new_state(find_finals_section_from_trans_s_l_L)
        create_new_transition(find_movement_for_new_state_s_letter_l, "R", find_finals_section_from_trans_s_l_R, "R", "RIGHT")
        create_new_transition(find_movement_for_new_state_s_letter_l, "L", find_finals_section_from_trans_s_l_L, "L", "RIGHT")

        # hay que llegar hasta el separador 3 para poder comprobar si nuestro nuevo estado al que tenemos que cambiar es un final, así que nos saltamos todo lo que haya entre medias:
        for l2 in transitions_alphabet:
            create_new_transition(find_finals_section_from_trans_s_l_R, l2, find_finals_section_from_trans_s_l_R, l2, "RIGHT")
            create_new_transition(find_finals_section_from_trans_s_l_L, l2, find_finals_section_from_trans_s_l_L, l2, "RIGHT")

# Cuando encuentra el 3er separador, se mueve al siguiente carácter para poder checkear si coincide con el state al que estamos cambiando:
for s in input_alphabet:
    for l in input_alphabet:
        find_finals_section_from_trans_s_l_R = f"find_finals_section_from_trans_{s}_{l}_R"
        find_finals_section_from_trans_s_l_L = f"find_finals_section_from_trans_{s}_{l}_L"
        find_final_state_from_trans_s_l_R = f"find_final_state_from_trans_{s}_{l}_R"
        find_final_state_from_trans_s_l_L = f"find_final_state_from_trans_{s}_{l}_L"
        create_new_state(find_final_state_from_trans_s_l_R)
        create_new_state(find_final_state_from_trans_s_l_L)
        create_new_transition(find_finals_section_from_trans_s_l_R, section_separator, find_final_state_from_trans_s_l_R, section_separator, "RIGHT")
        create_new_transition(find_finals_section_from_trans_s_l_L, section_separator, find_final_state_from_trans_s_l_L, section_separator, "RIGHT")

# comprobar si el estado al que tiene que cambiar es un final state (de momento, solo vamos a trabajar como si solo pudiese haber un final state)
for l in input_alphabet:
    create_new_state(f"jump_back_2_separators_to_process_final_trans_{l}_R")
    create_new_state(f"jump_back_2_separators_to_process_final_trans_{l}_L")
    create_new_state(f"jump_back_1_separator_to_process_final_trans_{l}_R")
    create_new_state(f"jump_back_1_separator_to_process_final_trans_{l}_L")
for s in input_alphabet:
    for l in input_alphabet:
        find_final_state_from_trans_s_l_R = f"find_final_state_from_trans_{s}_{l}_R"
        find_final_state_from_trans_s_l_L = f"find_final_state_from_trans_{s}_{l}_L"
        jump_back_2_separators_to_process_final_trans_l_R = f"jump_back_2_separators_to_process_final_trans_{l}_R"
        jump_back_2_separators_to_process_final_trans_l_L = f"jump_back_2_separators_to_process_final_trans_{l}_L"
        jump_back_1_separator_to_process_final_trans_l_R = f"jump_back_1_separator_to_process_final_trans_{l}_R"
        jump_back_1_separator_to_process_final_trans_l_L = f"jump_back_1_separator_to_process_final_trans_{l}_L"
        
        jump_back_2_separators_to_process_trans_s_l_R = f"jump_back_2_separators_to_process_trans_{s}_{l}_R"
        jump_back_2_separators_to_process_trans_s_l_L = f"jump_back_2_separators_to_process_trans_{s}_{l}_L"
        create_new_state(jump_back_2_separators_to_process_trans_s_l_R)
        create_new_state(jump_back_2_separators_to_process_trans_s_l_L)
        jump_back_1_separator_to_process_trans_s_l_R = f"jump_back_1_separator_to_process_trans_{s}_{l}_R"
        jump_back_1_separator_to_process_trans_s_l_L = f"jump_back_1_separator_to_process_trans_{s}_{l}_L"
        create_new_state(jump_back_1_separator_to_process_trans_s_l_R)
        create_new_state(jump_back_1_separator_to_process_trans_s_l_L)
        
        for l2 in input_alphabet:
            if l2 != s:
                create_new_transition(find_final_state_from_trans_s_l_R, l2, jump_back_2_separators_to_process_trans_s_l_R, l2, "LEFT")
                create_new_transition(find_final_state_from_trans_s_l_L, l2, jump_back_2_separators_to_process_trans_s_l_L, l2, "LEFT")
            else:
                create_new_transition(find_final_state_from_trans_s_l_R, l2, jump_back_2_separators_to_process_final_trans_l_R, l2, "LEFT")
                create_new_transition(find_final_state_from_trans_s_l_L, l2, jump_back_2_separators_to_process_final_trans_l_L, l2, "LEFT")

        # movemos la head hacia atrás saltándonos todo hasta llegar al input de nuevo (al separator 2) para poder aplicar la transición:
        for l2 in transitions_alphabet:
            create_new_transition(jump_back_2_separators_to_process_trans_s_l_R, l2, jump_back_2_separators_to_process_trans_s_l_R, l2, "LEFT")
            create_new_transition(jump_back_2_separators_to_process_trans_s_l_L, l2, jump_back_2_separators_to_process_trans_s_l_L, l2, "LEFT")
            create_new_transition(jump_back_1_separator_to_process_trans_s_l_R, l2, jump_back_1_separator_to_process_trans_s_l_R, l2, "LEFT")
            create_new_transition(jump_back_1_separator_to_process_trans_s_l_L, l2, jump_back_1_separator_to_process_trans_s_l_L, l2, "LEFT")

        create_new_transition(jump_back_2_separators_to_process_trans_s_l_R, section_separator, jump_back_1_separator_to_process_trans_s_l_R, section_separator, "LEFT")
        create_new_transition(jump_back_2_separators_to_process_trans_s_l_L, section_separator, jump_back_1_separator_to_process_trans_s_l_L, section_separator, "LEFT")

# mover la head hacia atrás saltándonos todo hasta llegar al input de nuevo (al separator 2), pero para el caso final:
for l in input_alphabet:
    jump_back_2_separators_to_process_final_trans_l_R = f"jump_back_2_separators_to_process_final_trans_{l}_R"
    jump_back_2_separators_to_process_final_trans_l_L = f"jump_back_2_separators_to_process_final_trans_{l}_L"
    jump_back_1_separator_to_process_final_trans_l_R = f"jump_back_1_separator_to_process_final_trans_{l}_R"
    jump_back_1_separator_to_process_final_trans_l_L = f"jump_back_1_separator_to_process_final_trans_{l}_L"

    create_new_transition(jump_back_2_separators_to_process_final_trans_l_R, section_separator, jump_back_1_separator_to_process_final_trans_l_R, section_separator, "LEFT")
    create_new_transition(jump_back_2_separators_to_process_final_trans_l_L, section_separator, jump_back_1_separator_to_process_final_trans_l_L, section_separator, "LEFT")
    for l2 in transitions_alphabet:
        create_new_transition(jump_back_2_separators_to_process_final_trans_l_R, l2, jump_back_2_separators_to_process_final_trans_l_R, l2, "LEFT")
        create_new_transition(jump_back_2_separators_to_process_final_trans_l_L, l2, jump_back_2_separators_to_process_final_trans_l_L, l2, "LEFT")
        create_new_transition(jump_back_1_separator_to_process_final_trans_l_R, l2, jump_back_1_separator_to_process_final_trans_l_R, l2, "LEFT")
        create_new_transition(jump_back_1_separator_to_process_final_trans_l_L, l2, jump_back_1_separator_to_process_final_trans_l_L, l2, "LEFT")
        

# Cuando encuentra el 2º separador, empieza a buscar el input marcado para sustituirlo y aplicar la transición:
for s in input_alphabet:
    for l in input_alphabet:
        jump_back_1_separator_to_process_trans_s_l_R = f"jump_back_1_separator_to_process_trans_{s}_{l}_R"
        jump_back_1_separator_to_process_trans_s_l_L = f"jump_back_1_separator_to_process_trans_{s}_{l}_L"
        find_marked_input_to_apply_s_l_R = f"find_marked_input_to_apply_{s}_{l}_R"
        find_marked_input_to_apply_s_l_L = f"find_marked_input_to_apply_{s}_{l}_L"
        create_new_state(find_marked_input_to_apply_s_l_R)
        create_new_state(find_marked_input_to_apply_s_l_L)

        create_new_transition(jump_back_1_separator_to_process_trans_s_l_R, section_separator, find_marked_input_to_apply_s_l_R, section_separator, "LEFT")
        create_new_transition(jump_back_1_separator_to_process_trans_s_l_L, section_separator, find_marked_input_to_apply_s_l_L, section_separator, "LEFT")

        # saltarse caracteres no marcados:
        for l2 in input_alphabet:
            create_new_transition(find_marked_input_to_apply_s_l_R, l2, find_marked_input_to_apply_s_l_R, l2, "LEFT")
            create_new_transition(find_marked_input_to_apply_s_l_L, l2, find_marked_input_to_apply_s_l_L, l2, "LEFT")

# lo mismo pero para el final state (es distinto xq solo guarda la letra, el state no le hace falta)
for l in input_alphabet:
    jump_back_1_separator_to_process_final_trans_l_R = f"jump_back_1_separator_to_process_final_trans_{l}_R"
    jump_back_1_separator_to_process_final_trans_l_L = f"jump_back_1_separator_to_process_final_trans_{l}_L"
    find_marked_input_to_apply_final_l_R = f"find_marked_input_to_apply_final_{l}_R"
    find_marked_input_to_apply_final_l_L = f"find_marked_input_to_apply_final_{l}_L"
    create_new_state(find_marked_input_to_apply_final_l_R)
    create_new_state(find_marked_input_to_apply_final_l_L)

    create_new_transition(jump_back_1_separator_to_process_final_trans_l_R, section_separator, find_marked_input_to_apply_final_l_R, section_separator, "LEFT")
    create_new_transition(jump_back_1_separator_to_process_final_trans_l_L, section_separator, find_marked_input_to_apply_final_l_L, section_separator, "LEFT")

    # saltarse caracteres no marcados:
    for l2 in input_alphabet:
        create_new_transition(find_marked_input_to_apply_final_l_R, l2, find_marked_input_to_apply_final_l_R, l2, "LEFT")
        create_new_transition(find_marked_input_to_apply_final_l_L, l2, find_marked_input_to_apply_final_l_L, l2, "LEFT")

# si el carácter del input está marcado, sustituir el carácter por el que toque y mover la head según indica la transición:
for s in input_alphabet:
    move_head_with_state_s = f"move_head_with_state_{s}"
    create_new_state(move_head_with_state_s)
    for l in input_alphabet:
        find_marked_input_to_apply_s_l_R = f"find_marked_input_to_apply_{s}_{l}_R"
        find_marked_input_to_apply_s_l_L = f"find_marked_input_to_apply_{s}_{l}_L"
        create_new_transition(find_marked_input_to_apply_s_l_R, input_alphabet_marker, move_head_with_state_s, l, "RIGHT") # se mueve right
        create_new_transition(find_marked_input_to_apply_s_l_L, input_alphabet_marker, move_head_with_state_s, l, "LEFT") # se mueve left

        # una vez movido el head, buscar una nueva transición para el state y letter actuales (vuelta al principio!)
        find_trans_from_state_s_letter_l = f"find_trans_from_state_{s}_letter_{l}"
        create_new_transition(move_head_with_state_s, l, find_trans_from_state_s_letter_l, input_alphabet_marker, "RIGHT")

# lo mismo para los final states:
move_head_with_final_state = "move_head_with_final_state"
create_new_state(move_head_with_final_state)
for l in input_alphabet:
    find_marked_input_to_apply_final_l_R = f"find_marked_input_to_apply_final_{l}_R"
    find_marked_input_to_apply_final_l_L = f"find_marked_input_to_apply_final_{l}_L"
    create_new_transition(find_marked_input_to_apply_final_l_R, input_alphabet_marker, move_head_with_final_state, l, "RIGHT") # se mueve right
    create_new_transition(find_marked_input_to_apply_final_l_L, input_alphabet_marker, move_head_with_final_state, l, "LEFT") # se mueve left
    
    # una vez movido el head, TERMINAR!!!!
    create_new_transition(move_head_with_final_state, l, final_state, l, "RIGHT")

with open("machine_descriptions/universal_turing_machine.json", "w") as f:
    f.write(json.dumps(machine_description, indent=4))
