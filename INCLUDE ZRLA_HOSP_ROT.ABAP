*&---------------------------------------------------------------------*
*& Include          ZRLA_HOSP_ROT
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
  "se nao houver @ no email...
  elseif '@' cn p_mail.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Email deve conter @ no endereço. |.
    return.
  endif.

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

  clear lv_spec. "limpa a variavel antes de atribuir novos valores
  perform get_especializacoes. "pega as especialidades

  ls_hospital-especialidades  = lv_spec.
  ls_hospital-data_fundacao   = p_fndc.
  ls_hospital-diretor_resp    = p_dirt.

  "verifica o status - se checkbox estiver marcada...
  ls_hospital-status = cond #( when p_act = 'X' then 'X' else '' ).

endform.

form insert_hospital.

  "metodo para cadastrar hospital
  ol_hospital->insert_hospital(
    exporting
      hospital = ls_hospital " Estrutura do Hospital
    importing
      e_result = result      " Mensagem
  ).

  clear ls_hospital.
  free ol_hospital.

  if result-rc eq 0.
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

  perform refresh_dropdown.

endform.

form update_hospital.

  "metodo para atualizar hospital
  ol_hospital->edit_hospital(
    exporting
      hospital = ls_hospital " Hospital
    importing
      e_result = result      " Estrutura de resultados de operações
  ).

  clear ls_hospital.
  free ol_hospital.

  if result-rc eq 0.
    message result-mensagem type 'S'.
  else.
    message result-mensagem type 'S' display like 'E'.
  endif.

  free ol_hospital.
  perform refresh_dropdown.

endform.

form get_especializacoes.

  "se a checkbox estiver marcada, insere a string na tabela
  append cond string( when p_spec1  eq  'X' then 'Cardiologia'       ) to it_specs.
  append cond string( when p_spec2  eq  'X' then 'Endocrinologia'    ) to it_specs.
  append cond string( when p_spec3  eq  'X' then 'Neurologia'        ) to it_specs.
  append cond string( when p_spec4  eq  'X' then 'Oncologia'         ) to it_specs.
  append cond string( when p_spec5  eq  'X' then 'Gastroenterologia' ) to it_specs.
  append cond string( when p_spec6  eq  'X' then 'Pneumologia'       ) to it_specs.
  append cond string( when p_spec7  eq  'X' then 'Nefrologia'        ) to it_specs.
  append cond string( when p_spec8  eq  'X' then 'Reumatologia'      ) to it_specs.
  append cond string( when p_spec9  eq  'X' then 'Infectologia'      ) to it_specs.
  append cond string( when p_spec10 eq  'X' then 'Dermatologia'      ) to it_specs.
  append cond string( when p_spec11 eq  'X' then 'Hematologia'       ) to it_specs.

  "itera sobre a tabela concatenando os valores das checkboxes marcadas
  loop at it_specs into data(ls_spec).
    if ls_spec is not initial. "se a linha estiver preenchida...
      concatenate ls_spec lv_spec into lv_spec separated by space.
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

    sort it_ddown by id_hospital. "ordena por id

    data: id_char type char10. "id em char

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

  data: dd_hospital type zrla_hospital, "estrutura da tabela
        lv_id_hosp  type char10.        "id do hospital em caracteres

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

    "limpa todos os campos.
    clear: p_nome, p_nifh, p_mord, p_codp, p_fone, p_mail, p_tipo, p_cama, p_fndc, p_dirt,
    p_spec1, p_spec2, p_spec3, p_spec4, p_spec5, p_spec6, p_spec7, p_spec8, p_spec9, p_spec10, p_spec11.

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

    clear: p_noact.
    "verifica o status
    p_act   = cond #( when dd_hospital-status = 'X' then 'X' else '' ).
    p_noact = cond #( when dd_hospital-status = ''  then 'X' else '' ).

    "procura no campo de especialidades as strings
    "se achar, marca a dropdown
    p_spec1 =  cond #( when 'Cardiologia'       co dd_hospital-especialidades then 'X' else '' ).
    p_spec2 =  cond #( when 'Endocrinologia'    co dd_hospital-especialidades then 'X' else '' ).
    p_spec3 =  cond #( when 'Neurologia'        co dd_hospital-especialidades then 'X' else '' ).
    p_spec4 =  cond #( when 'Oncologia'         co dd_hospital-especialidades then 'X' else '' ).
    p_spec5 =  cond #( when 'Gastroenterologia' co dd_hospital-especialidades then 'X' else '' ).
    p_spec6 =  cond #( when 'Pneumologia'       co dd_hospital-especialidades then 'X' else '' ).
    p_spec7 =  cond #( when 'Nefrologia'        co dd_hospital-especialidades then 'X' else '' ).
    p_spec8 =  cond #( when 'Reumatologia'      co dd_hospital-especialidades then 'X' else '' ).
    p_spec9 =  cond #( when 'Infectologia'      co dd_hospital-especialidades then 'X' else '' ).
    p_spec10 = cond #( when 'Dermatologia'      co dd_hospital-especialidades then 'X' else '' ).
    p_spec11 = cond #( when 'Hematologia'       co dd_hospital-especialidades then 'X' else '' ).

  endif.

endform.

form refresh_dropdown.

  refresh it_list.

  "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'P_NOMES'
        values = it_list.

  perform fill_dropdown_names.

endform.
