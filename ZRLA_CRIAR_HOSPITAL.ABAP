*&---------------------------------------------------------------------*
*& Report ZRLA_CRIAR_HOSPITAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zrla_criar_hospital.

tables: zhospitais. "tabela z de hospitais

"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS

data: ol_hospital type ref to zcl_hospital. "instacia da classe hospital

data: ls_hospital type zhospitais,             "estrutura da tabela z de hospitais
      id_hospital type zhospitais-id_hospital. "id do hospital

data: result type zapr_result. "estrutura de retorno de mensagens

data: return_validation type zapr_result. "flag de validacao de campos

data: lv_spec type string, "especializacoes
      it_specs type table of string. "especializacoes checadas.

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
"------------------------------------------------------------------------------------------------------
"COMANDOS DE TELA DE SELEÇÃO

at selection-screen.

      "---------------
      " PROCESSAMENTO
      "---------------

  "se algum botao for pressionado...
  if sy-ucomm eq 'INSERT' or
     sy-ucomm eq 'EDIT' or
     sy-ucomm eq 'INSERT' or
     sy-ucomm eq 'READ'.
    perform field_validations. "validacao de campos
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
        perform insert_hospital.                  "inserir
      when 'EDIT'.
        message 'BUTTOM EDIT PRESSED' type 'S'.   "editar
      when 'DELETE'.
        message 'BUTTOM DELETE PRESSED' type 'S'. "remover
      when 'READ'.
        message 'BUTTOM READ PRESSED' type 'S'.   "listar
    endcase.
  else.
    message return_validation-mensagem type 'S' display like 'E'.
    clear: return_validation-rc.
  endif.

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
  elseif p_mail ne '@'.
    return_validation-rc = 1.
    return_validation-mensagem = | O campo Email deve conter @ no endereço. |.
    return.
  endif.

  perform get_especializacoes.

  if lv_spec is initial.
    return_validation-rc = 1.
    return_validation-mensagem = | Prencha as informações sobre Especializações. |.
    return.
  endif.

endform.

form get_data.

  "estrutura recebe os valores dos campos preenchidos.
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

endform.
