*&---------------------------------------------------------------------*
*& Include          ZRLA_CRIAR_HOSPITAL_TOP
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS

data: ol_hospital type ref to zcl_hospital. "instacia da classe hospital

data: ls_hospital type zhospitais,             "estrutura da tabela z de hospitais
      id_hospital type zhospitais-id_hospital. "id do hospital

data: result type zapr_result. "estrutura de retorno de mensagens

data: return_validation type zapr_result. "flag de validacao de campos

data: lv_spec  type string, "especializacoes
      it_specs type table of string. "especializacoes checadas.

"tabela e estrutura da dropdown
data: it_list type vrm_values,
      ls_list like line of it_list.

*&---------------------------------------------------------------------*
*& Include          ZRLA_CRIAR_HOSPITAL_SCREEN
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"SCREEN001

"DROPDOWN DE PROCURA
selection-screen: begin of block c1 with frame title text-008.
parameters: p_nomes type zhospitais-id_hospital as listbox visible length 25.
selection-screen: end of block c1.
"CAMPOS DE INFORMACOES GERAIS
selection-screen: begin of block a1 with frame title text-007.
parameters: p_nome type zhospitais-nome_hospital,                              "nome
            p_nifh type zhospitais-nif default '000000000',                    "nif
            p_mord type zhospitais-morada,                                     "morada
            p_codp type zhospitais-codigo_postal default '00000000',           "codigo postal
            p_fone type zhospitais-telefone default '000000000',               "telefone
            p_mail type zhospitais-email_contacto,                             "email
            p_tipo type zhospitais-tipo_hospital as listbox visible length 25, "tipo de hospital
            p_cama type zhospitais-capacidade_cama.                            "capacidade de camas
selection-screen: end of block a1.
"ESPECIALIZACOES
selection-screen: begin of block d1 with frame title text-010.
parameters: p_spec1  as checkbox, "Cardiologia
            p_spec2  as checkbox, "Endocrinologia
            p_spec3  as checkbox, "Neurologia
            p_spec4  as checkbox, "Oncologia
            p_spec5  as checkbox, "Gastroenterologia
            p_spec6  as checkbox, "Pneumologia
            p_spec7  as checkbox, "Nefrologia
            p_spec8  as checkbox, "Reumatologia
            p_spec9  as checkbox, "Infectologia
            p_spec10 as checkbox, "Dermatologia
            p_spec11 as checkbox. "Hematologia
selection-screen: end of block d1.
"INFORMACOES ADICIONAIS
selection-screen: begin of block e1 with frame title text-009.
parameters: p_fndc type zhospitais-data_fundacao, "data de fundacao
            p_dirt type zhospitais-diretor_resp.  "diretor responsavel
selection-screen: end of block e1.
"PUSHBUTTONS
selection-screen: begin of block b1 with frame title text-005.
selection-screen pushbutton 32(10) text-001 user-command insert.
selection-screen pushbutton 45(10) text-002 user-command edit.
selection-screen pushbutton 58(10) text-003 user-command delete.
selection-screen pushbutton 71(10) text-004 user-command read.
selection-screen: skip 1.
selection-screen: end of block b1.

*&---------------------------------------------------------------------*
*& Include          ZRLA_CRIAR_HOSPITAL_ROT
*&---------------------------------------------------------------------*

*"------------------------------------------------------------------------------------------------------
*"ROTINAS

form field_validations.

  "se o nif nao tiver 9 digitos...
  if strlen( p_nifh ) ne 9.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo NIF deve respeitar a quantidade de 9 dígitos. |.
    return.
    "se o codigo postal nao tiver 8 digitos...
  elseif strlen( p_codp ) ne 8.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Código Postal deve respeitar a quantidade de 8 dígitos. |.
    return.
    "se o telefone nao tiver 9 digitos...
  elseif strlen( p_fone ) ne 9.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Telefone deve respeitar a quantidade de 9 dígitos. |.
    return.
    "se o numero de camas for igual ou menor que zero...
  elseif p_cama le 0.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Capacidade de Leitos deve ser preenchido com um valor válido e positivo. |.
    return.
  elseif '@' cn p_mail.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Email deve conter @ no endereço. |.
    return.
  endif.

  perform get_especializacoes.

  "se todas as checkboxes estiverem vazias...
  if lv_spec is initial.
    return_validation-rc = 1.
    return_validation-mensagem = | Prencha as informações sobre Especializações. |.
    return.
  endif.

endform.

form get_data.

  "estrutura recebe os valores dos campos preenchidos.
  clear ls_hospital.
  ls_hospital-nome_hospital   = p_nome.
  ls_hospital-nif             = p_nifh.
  ls_hospital-morada          = p_mord.
  ls_hospital-codigo_postal   = p_codp.
  ls_hospital-telefone        = p_fone.
  ls_hospital-email_contacto  = p_mail.
  ls_hospital-tipo_hospital   = p_tipo.
  ls_hospital-capacidade_cama = p_cama.
  ls_hospital-especialidades  = lv_spec.
  ls_hospital-data_fundacao   = p_fndc.
  ls_hospital-diretor_resp    = p_dirt.

endform.

form insert_hospital.

  "metodo para cadastrar hospital
  ol_hospital->insert_hospital(
    exporting
      hospital = ls_hospital " Estrutura do Hospital
    importing
      e_result = result      " Mensagem
  ).

  "limpa os dados
  clear lv_spec.
  clear ls_hospital.
  free ol_hospital.

  if result-rc eq 0.
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

endform.

form get_especializacoes.

  "insere os valores das checkboxes na tabela
  if p_spec1 eq 'X'.
    append 'Cardiologia' to it_specs.
  endif.
  if p_spec2 eq 'X'.
    append 'Endocrinologia' to it_specs.
  endif.
  if p_spec3 eq 'X'.
    append 'Neurologia' to it_specs.
  endif.
  if p_spec4 eq 'X'.
    append 'Oncologia' to it_specs.
  endif.
  if p_spec5 eq 'X'.
    append 'Gastroenterologia' to it_specs.
  endif.
  if p_spec6 eq 'X'.
    append 'Pneumologia' to it_specs.
  endif.
  if p_spec7 eq 'X'.
    append 'Nefrologia' to it_specs.
  endif.
  if p_spec8 eq 'X'.
    append 'Reumatologia' to it_specs.
  endif.
  if p_spec9 eq 'X'.
    append 'Infectologia' to it_specs.
  endif.
  if p_spec10 eq 'X'.
    append 'Dermatologia' to it_specs.
  endif.
  if p_spec11 eq 'X'.
    append 'Hematologia' to it_specs.
  endif.

  "itera sobre a tabela concatenando os valores das checkboxes marcadas
  loop at it_specs into data(ls_spec).
    if ls_spec is not initial.
      concatenate ls_spec lv_spec into lv_spec separated by ', '.
    endif.
  endloop.

  clear it_specs.

endform.

form fill_dropdown_names. "enche a dropdown com os nomes dos hospitais.

  "estrutura com ids e nomes do hospital
  types: begin of wa_ddown,
           id_hospital   type zhospitais-id_hospital,
           nome_hospital type zhospitais-nome_hospital,
         end of wa_ddown.

  "tabela e estrutura da estrutura types
  data: it_ddown type table of wa_ddown with key id_hospital,
        ls_ddown type wa_ddown.

  "preenche os campos da tabela interna com id e nome
  select * from zhospitais
    into corresponding fields of table it_ddown.

  if sy-subrc eq 0.

    sort it_ddown by id_hospital.

    data: id_char type char10.

    "passa os dados da tabela para a tabela da dropdown
    loop at it_ddown into ls_ddown.
      clear ls_list.
      id_char = ls_ddown-id_hospital.
      ls_list-key = id_char.
      ls_list-text = ls_ddown-nome_hospital.
      append ls_list to it_list.
      clear ls_ddown.
    endloop.

    "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'P_NOMES'
        values = it_list.
  endif.

endform.

form fill_fields.

  data: dd_hospital type zhospitais, "estrutura da tabela
        lv_id_hosp  type char10.     "id do hospital em caracteres

  "itera sobre a dropdown
  loop at it_list into ls_list.
    "pega o id relacionado ao nome escolhido na dropdown
    if ls_list-key eq p_nomes.
      condense ls_list-key no-gaps. "remove os espaços
      lv_id_hosp = ls_list-key.     "recebe o id sem espaços
      dd_hospital-id_hospital = lv_id_hosp. "recebe o id
      dd_hospital-nome_hospital = ls_list-text. "recebe o nome
    endif.
  endloop.

  "procura a linha relacionada ao id
  select single * from zhospitais
    into dd_hospital
    where id_hospital eq dd_hospital-id_hospital.

  if sy-subrc eq 0.

    "preenche os campos
    p_nome = dd_hospital-nome_hospital.
    p_nifh = dd_hospital-nif.
    p_mord = dd_hospital-morada.
    p_codp = dd_hospital-codigo_postal.
    p_fone = dd_hospital-telefone.
    p_mail = dd_hospital-email_contacto.
    p_tipo = dd_hospital-tipo_hospital.
    p_cama = dd_hospital-capacidade_cama.
    p_fndc = dd_hospital-data_fundacao.
    p_dirt = dd_hospital-diretor_resp.

    "procura no campo de especialidades as strings
    "se achar, marca a dropdown
    if 'Cardiologia' co dd_hospital-especialidades.
      p_spec1 = 'X'.
    endif.
    if 'Endocrinologia' co dd_hospital-especialidades.
      p_spec2 = 'X'.
    endif.
    if 'Neurologia' co dd_hospital-especialidades.
      p_spec3 = 'X'.
    endif.
    if 'Oncologia' co dd_hospital-especialidades.
      p_spec4 = 'X'.
    endif.
    if 'Gastroenterologia' co dd_hospital-especialidades.
      p_spec5 = 'X'.
    endif.
    if 'Pneumologia' co dd_hospital-especialidades.
      p_spec6 = 'X'.
    endif.
    if 'Nefrologia' co dd_hospital-especialidades.
      p_spec7 = 'X'.
    endif.
    if 'Reumatologia' co dd_hospital-especialidades.
      p_spec8 = 'X'.
    endif.
    if 'Infectologia' co dd_hospital-especialidades.
      p_spec9 = 'X'.
    endif.
    if 'Dermatologia' co dd_hospital-especialidades.
      p_spec10 = 'X'.
    endif.
    if 'Hematologia' co dd_hospital-especialidades.
      p_spec11 = 'X'.
    endif.
  endif.

endform.

