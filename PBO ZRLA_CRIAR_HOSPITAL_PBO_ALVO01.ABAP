*----------------------------------------------------------------------*
***INCLUDE ZRLA_CRIAR_HOSPITAL_PBO_ALVO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module pbo_alv output.

  "tabela e estrutura da dropdown
  data: it_dropdown_alv type vrm_values,
        ls_dropdown_alv like line of it_list.

  "tabela para guardar os dados do paciente
  data: it_alv_table type table of ol_paciente->wa_pct,
        ls_alv       type ol_paciente->wa_pct.

  "informacoes do historico do paciente
  types: begin of hst_struct,
           mensagem type zhistorico_pct-mensagem,
           data_msg type zhistorico_pct-data_msg,
           hora_msg type zhistorico_pct-hora_msg,
           new_date type string, "data formatada
           new_hour type string, "hora formatada
         end of hst_struct.

  data: it_hst_alv type table of hst_struct, "tabela de historico
        ls_hst_alv type hst_struct.          "estrutura de historico

  "estrutura com ids e nomes do hospital
  types: begin of wa_ddown,
           id_hospital   type zhospitais-id_hospital,
           nome_hospital type zhospitais-nome_hospital,
         end of wa_ddown.

  "tabela e estrutura da estrutura types
  data: it_ddown type table of wa_ddown with key id_hospital,
        ls_ddown type wa_ddown.

  "estrutura para retorno de mensagens
  data: result_103 type zapr_result.

  "-----------------------------------------------------------------------------
  "ALV - CONTAINER 1

  "dropdown de hospitais
  data in_001 type zhospitais-nome_hospital.

  data: ol_alvgrid     type ref to cl_gui_alv_grid,          "instancia da alv grid
        ol_container   type ref to cl_gui_custom_container,  "instancia do container
        custom_control type scrfname.                        "nome do custom control

  data: it_fieldcat type lvc_t_fcat, "tabela do fieldcatalog
        ls_fieldcat type lvc_s_fcat, "estrutura do fieldcatalog
        ls_layout   type lvc_s_layo. "estrutura do layout

  "estrutura que guarda apenas os ids do paciente
  types: begin of wa_struct_pct,
           id_paciente type zpacientes-id_paciente,
         end of wa_struct_pct.

  data: it_paciente103 type table of wa_struct_pct. "tabela de ids de pacientes.

  data ol_event_handler type ref to zcl_event_handler. "instancia da classe de eventos

  data id_hotspot type zpacientes-id_paciente. "recebe o id do hotspot

  "-----------------------------------------------------------------------------
  "ALV - CONTAINER 2

  data: ol_alvgrid2     type ref to cl_gui_alv_grid,          "instancia da alv grid
        ol_container2   type ref to cl_gui_custom_container,  "instancia do container
        custom_control2 type scrfname.                        "nome do custom control

  data: it_fieldcat2 type lvc_t_fcat, "tabela do fieldcatalog
        ls_fieldcat2 type lvc_s_fcat, "estrutura do fieldcatalog
        ls_layout2   type lvc_s_layo. "estrutura do layout

  "-----------------------------------------------------------------------------
  "TABELA INTERNA PARA EXCEL

  data: it_csv      type table of ol_paciente->wa_pct, "tabela interna
        lr_data_ref type ref to data,                  "referencia para a tabela interna
        lv_xstring  type xstring,                      "recebe xstring
        lt_binary   type table of x255,                "armazena dados binarios
        lv_path     type string,                       "caminho selecionado pelo usuário
        lv_filename type string.                       "caminho para arquivo no pc

  "-----------------------------------------------------------------------------
  "TABELAS E ESTRUTURAS PARA ARQUIVOS PDF E CAMPOS DE MULTISELEÇÃO

  types: begin of wa_pdf,
           nome_paciente       type zpacientes-nome_paciente,
           sexo                type zpacientes-sexo,
           data_nascimento     type zpacientes-data_nascimento,
           new_data_nascimento type string,
           estado_civil        type zpacientes-estado_civil,
           new_estado_civil    type string,
           telefone_principal  type zpac_contactos-telefone_principal,
           telefone_secundario type zpac_contactos-telefone_secundario,
           email_paciente      type zpac_contactos-email_paciente,
           contacto_emergencia type zpac_contactos-contacto_emergencia,
           nome_contacto_e     type zpac_contactos-nome_contacto_e,
           nif                 type zpac_docs-nif,
           cartao_cidadao      type zpac_docs-cartao_cidadao,
           numero_utente       type zpac_docs-numero_utente,
           subsistema_saude    type zpac_docs-subsistema_saude,
           numero_seguro       type zpac_docs-numero_seguro,
           validade_seguro     type zpac_docs-validade_seguro,
           new_validade_seguro type string,
           morada_paciente     type zpac_enderecos-morada_paciente,
           codigo_postal       type zpac_enderecos-codigo_postal,
           concelho            type zpac_enderecos-concelho,
           nacionalidade       type zpac_enderecos-nacionalidade,
           peso                type zpac_infopac-peso,
           altura              type zpac_infopac-altura,
           data_inscricao      type zpac_infopac-data_inscricao,
           new_data_inscricao  type string,
           ultima_consulta     type zpac_infopac-ultima_consulta,
           new_ultima_consulta type string,
           tipo_sangue         type zpac_infopac-tipo_sangue,
           alergias            type zpac_infopac-alergias,
           doencas_cronicas    type zpac_infopac-doencas_cronicas,
           medicacao_atual     type zpac_infopac-medicacao_atual,
           historico_cirurgico type zpac_infopac-historico_cirurgico,
           habitos_drogas      type zpac_infopac-habitos_drogas,
           observacoes         type zpac_infopac-observacoes,
         end of wa_pdf.

  data: it_pdf type table of wa_pdf, "tabela para receber os dados do pdf
        ls_pdf type wa_pdf.          "estrutura

  data: lt_rows type lvc_t_row,       "tabela para campos de multiselecao na alv
        ls_rows like line of lt_rows. "linha de multiselecao

endmodule.
