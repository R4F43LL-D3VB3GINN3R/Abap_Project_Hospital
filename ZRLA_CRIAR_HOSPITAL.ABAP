*&---------------------------------------------------------------------*
*& Report ZRLA_CRIAR_HOSPITAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zrla_criar_hospital.

include zrla_criar_hospital_top.
include zrla_criar_hospital_screen.
include zrla_criar_hospital_rot.
include zrla_display_alv.

at selection-screen output.

at selection-screen.

  "------------------------------------------------------------------------------------------------------
  "SCREEN 100

  check sy-dynnr = 100. "confere se é a tela 100 que está em atividade

  "se a dropdown nao estiver vazia
  if p_nomes is not initial and sy-ucomm ne 'EDIT' and sy-ucomm ne 'INSERT' and sy-ucomm ne 'READ'.
    perform fill_fields.
  endif.

  "se algum destes botoes forem pressionados
  if return_validation-rc eq 0.

    "cria objeto de instancia
    create object ol_hospital
      exporting
        id_hospital = id_hospital.
    .

    perform get_data. "preenche a estrutura

    case sy-ucomm.
      when 'INSERT'.
        perform insert_hospital.   "inserir
      when 'EDIT'.
        perform update_hospital.   "editar
      when 'READ'.
        perform display_hospitais. "exibe os hospitais em alv.´
      when 'TAB2'.

    endcase.
  else.
    message return_validation-mensagem type 'S' display like 'E'.
    clear: return_validation-rc. "limpa a variavel
  endif.

*"------------------------------------------------------------------------------------------------------
  "INICIALIZACAO DE DADOS

initialization.
  perform fill_dropdown_names. "enche a dropdown com os nomes dos hospitais.

  tab1 = '@0U@' && 'Hospitais'.
  tab2 = '@0U@' && 'Pacientes'.

*&---------------------------------------------------------------------*
*& Include          ZRLA_CRIAR_HOSPITAL_TOP
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS - HOSPITAIS

tables: zhospitais, sscrfields.

data: ol_hospital type ref to zcl_hospital. "instacia da classe hospital

data: ls_hospital type zrla_hospital,          "estrutura da tabela z de hospitais
      id_hospital type zhospitais-id_hospital. "id do hospital

data: result type zapr_result. "estrutura de retorno de mensagens

data: return_validation type zapr_result. "flag de validacao de campos

data: lv_spec  type string, "especializacoes
      it_specs type table of string. "especializacoes checadas.

"tabela e estrutura da dropdown
data: it_list type vrm_values,
      ls_list like line of it_list.

"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS - ALV

"instancias alv
  data: lo_alv           type ref to cl_salv_table,
        lo_alv_functions type ref to cl_salv_functions,
        lo_alv_columns   type ref to cl_salv_columns,
        lo_alv_column    type ref to cl_salv_column,
        lo_alv_display   type ref to cl_salv_display_settings.

  data: color type lvc_s_colo. "cores

  types: begin of wa_hospital,
           id_hospital      type zhospitais-id_hospital,
           nome_hospital    type zhospitais-nome_hospital,
           nif              type zhospitais-nif,
           morada           type zhospitais-morada,
           codigo_postal    type zhospitais-codigo_postal,
           telefone         type zhospitais-telefone,
           email_contacto   type zhospitais-email_contacto,
           tipo_hospital    type zhospitais-tipo_hospital,
           capacidade_cama  type zhospitais-capacidade_cama,
           especialidades   type zhospitais-especialidades,
           data_fundacao    type zhospitais-data_fundacao,
           diretor_resp     type zhospitais-diretor_resp,
           data_criacao     type zhospitais-data_criacao,
           data_modificacao type zhospitais-data_modificacao,
           alterado_por     type zhospitais-alterado_por,
           status_c         type icon_d,
    end of wa_hospital.

    data: it_output type table of wa_hospital,
          ls_output type wa_hospital.

    data: it_hospitais type table of zhospitais,
          ls_hospital_alv type zrla_hospital.

"------------------------------------------------------------------------------------------------------

*&---------------------------------------------------------------------*
*& Include          ZRLA_CRIAR_HOSPITAL_SCREEN
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"SCREEN001

"TABSTRIP BUTTONS
selection-screen: function key 1.

"TELAS QUE RECEBEM AS SUBTELAS
selection-screen: begin of tabbed block tb1 for 40 lines.
selection-screen: tab (20) tab1 user-command tab1 default screen 100, "TELA DE HOSPITAIS
                  tab (20) tab2 user-command tab2 default screen 101. "TELA DE PACIENTES
selection-screen: end of block tb1.

include zrla_screen_hospital.  "selection screen: hospital

"------------------------------------------------------------------------------------------------------
"TELA DE PACIENTES

"CAMPOS DE PESQUISA
selection-screen: begin of screen 101 as subscreen.

parameters: num1 type i.

selection-screen: end of screen 101.

*&---------------------------------------------------------------------*
*& Include          ZRLA_SCREEN_HOSPITAL
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"TELA DE HOSPITAIS

"DROPDOWN DE PROCURA
selection-screen: begin of screen 100 as subscreen.
selection-screen: begin of block f1 with frame.
selection-screen: begin of block c1 with frame title text-008.
parameters: p_nomes type zhospitais-id_hospital as listbox visible length 25.
selection-screen: end of block c1.

"ZHOSPITAIS
"-------------------------
*ID_HOSPITAL      INT4
*NOME_HOSPITAL    CHAR100
*NIF              CHAR9
*MORADA	          CHAR255
*CODIGO_POSTAL    CHAR8
*TELEFONE	        CHAR9
*EMAIL_CONTACTO	  CHAR100
*TIPO_HOSPITAL    ZTIPOH
*CAPACIDADE_CAMA  INT4
*ESPECIALIDADES	  CHAR255
*DATA_FUNDACAO    DATS
*DIRETOR_RESP	    CHAR100
*DATA_CRIACAO	    DATS
*DATA_MODIFICACAO	DATS
*STATUS	          CHAR1
"-------------------------

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
selection-screen begin of line.
selection-screen position 30.
parameters p_act radiobutton group grp1 default 'X'.                           "hospital em atividade
selection-screen comment 32(10) text-040.
selection-screen position 50.
parameters p_noact radiobutton group grp1.                                     "hospital inativo
selection-screen comment 52(10) text-041.
selection-screen end of line.
selection-screen: end of block a1.

"ESPECIALIZACOES
selection-screen: begin of block d1 with frame title text-010.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec1 as checkbox.
selection-screen comment 3(20) text-020.
selection-screen position 24.
parameters p_spec2 as checkbox.
selection-screen comment 26(20) text-021.
selection-screen position 47.
parameters p_spec3 as checkbox.
selection-screen comment 49(20) text-022.
selection-screen position 70.
parameters p_spec4 as checkbox.
selection-screen comment 72(20) text-023.
selection-screen end of line.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec5 as checkbox.
selection-screen comment 3(20) text-024.
selection-screen position 24.
parameters p_spec6 as checkbox.
selection-screen comment 26(20) text-025.
selection-screen position 47.
parameters p_spec7 as checkbox.
selection-screen comment 49(20) text-026.
selection-screen position 70.
parameters p_spec8 as checkbox.
selection-screen comment 72(20) text-027.
selection-screen end of line.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec9 as checkbox.
selection-screen comment 3(20) text-028.
selection-screen position 24.
parameters p_spec10 as checkbox.
selection-screen comment 26(20) text-029.
selection-screen position 47.
parameters p_spec11 as checkbox.
selection-screen comment 49(20) text-030.
selection-screen end of line.
selection-screen: end of block d1.

"INFORMACOES ADICIONAIS
selection-screen: begin of block e1 with frame title text-009.
parameters: p_fndc type zhospitais-data_fundacao, "data de fundacao
            p_dirt type zhospitais-diretor_resp.  "diretor responsavel
selection-screen: end of block e1.

"PUSHBUTTONS
selection-screen: begin of block b1 with frame title text-005.
selection-screen pushbutton 25(15) text-001 user-command insert.
selection-screen pushbutton 45(15) text-002 user-command edit.
selection-screen pushbutton 65(15) text-004 user-command read.
selection-screen: end of block b1.
selection-screen: end of block f1.
selection-screen: end of screen 100.

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

form update_hospital.

  "metodo para atualizar hospital
  ol_hospital->edit_hospital(
    exporting
      hospital = ls_hospital " Hospital
    importing
      e_result = result      " Estrutura de resultados de operações
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

  free ol_hospital.

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

*&---------------------------------------------------------------------*
*& Include          ZRLA_DISPLAY_ALV
*&---------------------------------------------------------------------*
form build_alv_columns.

  "funcoes
    lo_alv_functions = lo_alv->get_functions( ).
    lo_alv_functions->set_all( abap_true ).

    "opcoes de display
    lo_alv_display = lo_alv->get_display_settings( ).
    lo_alv_display->set_striped_pattern( cl_salv_display_settings=>true ).
    lo_alv_display->set_list_header( 'Listagem de Hospitais' ).

    "configurando os nomes das colunas
    lo_alv_columns = lo_alv->get_columns( ).

    "por preferencia, os nomes serao alterados, centralizados e sempre
    "lidos na forma mais extensa possivel e com medidas de largura fixas

    lo_alv_column = lo_alv_columns->get_column( 'ID_HOSPITAL' ).
    lo_alv_column->set_long_text( 'ID Hospital' ).
    lo_alv_column->set_fixed_header_text( 'L' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('11').
    lo_alv_column->set_optimized( 'X' ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column = lo_alv_columns->get_column( 'NOME_HOSPITAL' ).
    lo_alv_column->set_long_text( 'Nome' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('20').
    lo_alv_column->set_optimized( 'X' ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column = lo_alv_columns->get_column( 'NIF' ).
    lo_alv_column->set_long_text( 'NIF' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('11').
    lo_alv_column->set_optimized( 'X' ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'MORADA' ).
    lo_alv_column->set_long_text( 'Morada' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('20').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'CODIGO_POSTAL' ).
    lo_alv_column->set_long_text( 'Código Postal' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('10').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'TELEFONE' ).
    lo_alv_column->set_long_text( 'Telefone' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('11').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'EMAIL_CONTACTO' ).
    lo_alv_column->set_long_text( 'Email' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('12').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'TIPO_HOSPITAL' ).
    lo_alv_column->set_long_text( 'Tipo Hospital' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('15').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'CAPACIDADE_CAMA' ).
    lo_alv_column->set_long_text( 'Capacidade' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('12').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'ESPECIALIDADES' ).
    lo_alv_column->set_long_text( 'Especialidades' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('60').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'DATA_FUNDACAO' ).
    lo_alv_column->set_long_text( 'Data Fundação' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('15').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'DIRETOR_RESP' ).
    lo_alv_column->set_long_text( 'Diretor' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('15').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'DATA_CRIACAO' ).
    lo_alv_column->set_long_text( 'Data Criação' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('13').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'DATA_MODIFICACAO' ).
    lo_alv_column->set_long_text( 'Atualização' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('13').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'ALTERADO_POR' ).
    lo_alv_column->set_long_text( 'Alterado Por' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('15').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

    lo_alv_column ?= lo_alv_columns->get_column( 'STATUS_C' ).
    lo_alv_column->set_long_text( 'Em Atividade' ).
    lo_alv_column->set_medium_text( '' ).
    lo_alv_column->set_short_text( '' ).
    lo_alv_column->set_output_length('14').
    lo_alv_column->set_optimized( abap_true ).
    lo_alv_column->set_alignment(
    value = if_salv_c_alignment=>centered
    ).

endform.

form display_hospitais.

  "preenche a tabela interna
  select * from zhospitais into table it_hospitais.

  "passa os dados da tabela interna para a tabela do alv
  loop at it_hospitais into ls_hospital_alv.
    move-corresponding ls_hospital_alv to ls_output.
    if ls_hospital_alv-status eq 'X'.
      ls_output-status_c = icon_green_light.
    else.
      ls_output-status_c = icon_red_light.
    endif.
    append ls_output to it_output.
  endloop.

  "organiza a tabela por id
  sort it_output by id_hospital ascending.

  cl_salv_table=>factory(
  importing
    r_salv_table   = lo_alv
  changing
    t_table        = it_output
  ).

  "rotina para setup das colunas
  perform build_alv_columns.

  "exibicao do alv
  lo_alv->display( ).

  clear it_output.
  clear ls_hospital_alv.
  clear it_hospitais.
  clear ls_output.

endform.


