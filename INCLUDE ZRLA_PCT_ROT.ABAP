*&---------------------------------------------------------------------*
*& Include          ZRLA_PCT_ROT
*&---------------------------------------------------------------------*

"------------------------------------------------------------------------------------------------------
"ROTINAS

form insert_paciente.

  "recebe o id da dropdown de hospitais.
  data: id_hosp type zhospitais-id_hospital.
  id_hosp = p_nomesh.

  "cria objetos de classe
  create object ol_hospital
    exporting
      id_hospital = id_hosp.
    .
  create object ol_paciente
    exporting
      id_paciente = 0                  " Id do Paciente
    exceptions
      invalid_pct = 1                " Paciente Inválido
      others      = 2
    .

  "Método para cadastrar pacientes
  ol_paciente->insert_paciente(
    exporting
      id_hospital = id_hosp
      paciente    = ls_paciente
      contactos   = ls_contactos
      docs        = ls_docs
      enderecos   = ls_enderecos
      info        = ls_info
    importing
      e_result    = result_p
  ).

  if result_p-rc ne 0.
    message result_p-mensagem type 'E' display like 'S'.
  else.
    message result_p-mensagem type 'S'.
  endif.

endform.

form get_pct_data.

  "preenche as estruturas com os valores dos campos.
  clear ls_paciente.
  ls_paciente-nome_paciente        = p_nomep.
  ls_paciente-data_nascimento      = p_datanp.
  ls_paciente-sexo                 = p_sexop.
  ls_paciente-estado_civil         = p_estcv.

  clear ls_contactos.
  ls_contactos-telefone_principal  = p_tel1.
  ls_contactos-telefone_secundario = p_tel2.
  ls_contactos-email_paciente      = p_mailp.
  ls_contactos-contacto_emergencia = p_ct_em.
  ls_contactos-nome_contacto_e     = p_nm_em.

  clear ls_docs.
  ls_docs-nif = p_nifp.
  ls_docs-cartao_cidadao           = p_cc.
  ls_docs-numero_utente            = p_utente.
  ls_docs-subsistema_saude         = p_sub_ss.
  ls_docs-numero_seguro            = p_nsecp.
  ls_docs-validade_seguro          = p_valsec.

  clear ls_enderecos.
  ls_enderecos-morada_paciente     = p_mordp.
  ls_enderecos-codigo_postal       = p_codpst.
  ls_enderecos-concelho            = p_cclh.
  ls_enderecos-nacionalidade       = p_nacio.

  clear ls_info.
  ls_info-peso                     = p_peso.
  ls_info-altura                   = p_alt.
  ls_info-data_inscricao           = p_dt_ins.
  ls_info-ultima_consulta          = p_ultc.
  ls_info-tipo_sangue              = p_tps.
  ls_info-alergias                 = p_alrg.
  ls_info-doencas_cronicas         = p_dncc.
  ls_info-medicacao_atual          = p_medc.
  ls_info-historico_cirurgico      = p_hstc.
  ls_info-habitos_drogas           = p_hbtd.
  ls_info-observacoes              = p_obsp.

endform.

form field_pct_validations.

  "se o campo sexo nao for preenchido corretamente...
  if p_sexop ne 'M' and p_sexop ne 'F'.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | Escolha M-> Masculino ou F-> Feminino. |.
    return.
  elseif '@' cn p_mailp.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | O campo Email deve conter @ no endereço. |.
    return.
  "se o codigo postal nao tiver 8 digitos...
  elseif strlen( p_codpst ) ne 8.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | O campo Código Postal deve respeitar a quantidade de 8 dígitos. |.
    return.
  "se o telefone nao tiver 9 digitos...
  elseif strlen( p_tel1 ) ne 9 or strlen( p_tel2 ) ne 9 or strlen( p_ct_em ) ne 9.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | O campo Telefone deve respeitar a quantidade de 9 dígitos. |.
    return.
  "se o cartao cidadao nao tiver 9 digitos...
  elseif strlen( p_cc ) ne 9.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | O campo Número do Cartão Cidadão deve respeitar a quantidade de 9 dígitos. |.
    return.
  "se o numero do utente nao tiver 9 digitos...
  elseif strlen( p_utente ) ne 9.
    return_validation_p-rc = 1.
    return_validation_p-mensagem = | O campo Número do Utente deve respeitar a quantidade de 9 dígitos. |.
    return.
  endif.

endform.

form fill_pct_dropdown_names.

  "estrutura com ids e nomes do hospital
  types: begin of wa_ddown2,
           id_hospital   type zhospitais-id_hospital,
           nome_hospital type zhospitais-nome_hospital,
         end of wa_ddown2.

  "tabela e estrutura da estrutura types
  data: it_ddown2 type table of wa_ddown2 with key id_hospital,
        ls_ddown2 type wa_ddown2.

  "preenche os campos da tabela interna com id e nome
  select * from zhospitais
    into corresponding fields of table it_ddown2.

  "se houverem dados retornados da consulta
  if sy-subrc eq 0.

    sort it_ddown2 by id_hospital. "ordena por id

    data: id_char type char10. "id em char

    "passa os dados da tabela para a tabela da dropdown
    loop at it_ddown2 into ls_ddown2.
      clear ls_list_hosp.
      id_char = ls_ddown2-id_hospital.
      ls_list_hosp-key = id_char.
      ls_list_hosp-text = ls_ddown2-nome_hospital.
      append ls_list_hosp to it_list_hosp.
      clear ls_ddown2.
    endloop.

    "se a tabela estiver vazia
    if it_list_hosp is initial.
      message | Não foi possível preencher a lista com os nomes dos Hospitais.  | type 'E' display like 'S'.
      return.
    endif.

    "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'P_NOMESH'
        values = it_list_hosp.

  endif.

  "estrutura com ids e nomes dos pacientes
  types: begin of wa_ddown3,
           id_paciente   type zpacientes-id_paciente,
           nome_paciente type zpacientes-nome_paciente,
         end of wa_ddown3.

  "tabela e estrutura da estrutura types
  data: it_ddown3 type table of wa_ddown3 with key id_paciente,
        ls_ddown3 type wa_ddown3.

  "preenche os campos da tabela interna com id e nome
  select * from zpacientes
    into corresponding fields of table it_ddown3.

  "se houverem dados retornados da consulta
  if sy-subrc eq 0.

    sort it_ddown3 by id_paciente. "ordena por id

    data: id_char2 type char10. "id em char

    "passa os dados da tabela para a tabela da dropdown
    loop at it_ddown3 into ls_ddown3.
      clear ls_list_pct.
      id_char2 = ls_ddown3-id_paciente.
      ls_list_pct-key = id_char2.
      ls_list_pct-text = ls_ddown3-nome_paciente.
      append ls_list_pct to it_list_pct.
      clear ls_ddown2.
    endloop.

    "se a tabela estiver vazia...
    if it_list_pct is initial.
      message | Não foi possível preencher a lista com os nomes dos Hospitais.  | type 'E' display like 'S'.
      return.
    endif.

    "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'P_NOMESP'
        values = it_list_pct.

  endif.

endform.

form fill_pct_fields.



endform.
