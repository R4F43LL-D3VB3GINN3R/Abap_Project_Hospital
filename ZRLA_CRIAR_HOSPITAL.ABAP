*&---------------------------------------------------------------------*
*& Report ZRLA_CRIAR_HOSPITAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zrla_criar_hospital.

tables: zhospitais. "tabela z de hospitais

"------------------------------------------------------------------------------------------------------
"SCREEN001
selection-screen: begin of block a1 with frame title text-001.
parameters: p_nome type zhospitais-nome_hospital,                     "nome
            p_nifh type zhospitais-nif default '000000000',           "nif
            p_mord type zhospitais-morada,                            "morada
            p_codp type zhospitais-codigo_postal default '00000000',  "codigo postal
            p_fone type zhospitais-telefone default '000000000',      "telefone
            p_mail type zhospitais-email_contacto,                    "email
            p_tipo type zhospitais-tipo_hospital,                     "tipo de hospital
            p_cama type zhospitais-capacidade_cama,                   "capacidade de camas
            p_spec type zhospitais-especialidades,                    "especialidades
            p_fndc type zhospitais-data_fundacao,                     "data de fundacao
            p_dirt type zhospitais-diretor_resp.                      "diretor responsavel
selection-screen: end of block a1.

"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS

data: ol_hospital type ref to zcl_hospital. "instacia da classe hospital

data: ls_hospital type zhospitais. "estrutura da tabela z de hospitais

data: result type zapr_result. "estrutura de retorno de mensagens

"------------------------------------------------------------------------------------------------------
"PROCESSAMENTO

start-of-selection.

perform field_validations. "validacao de campos
perform get_data.          "preenchimento de estrutura
perform insert_hospital.   "cadastro à base de dados

"------------------------------------------------------------------------------------------------------
"ROTINAS

form field_validations.

  "se o nif nao tiver 9 digitos...
  if strlen( p_nifh ) ne 9.
    message | O campo NIF deve respeitar a quantidade de 9 dígitos. | type 'S' display like 'E'.
    return.
  "se o codigo postal nao tiver 8 digitos...
  elseif strlen( p_codp ) ne 8.
    message | O campo Código Postal deve respeitar a quantidade de 8 dígitos. | type 'S' display like 'E'.
    return.
  "se o telefone nao tiver 9 digitos...
  elseif strlen( p_fone ) ne 9.
    message | O campo Telefone deve respeitar a quantidade de 9 dígitos. | type 'S' display like 'E'.
    return.
  "se o numero de camas for igual ou menor que zero...
  elseif p_cama le 0.
    message | O campo Capacidade de Leitos deve ser preenchido com um valor válido e positivo. | type 'S' display like 'E'.
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
  ls_hospital-especialidades  = p_spec.
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
