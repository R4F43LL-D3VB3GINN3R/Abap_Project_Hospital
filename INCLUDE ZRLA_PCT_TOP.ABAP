*&---------------------------------------------------------------------*
*& Include          ZRLA_PCT_TOP
*&---------------------------------------------------------------------*
"------------------------------------------------------------------------------------------------------
"VARIÁVEIS - ESTRUTURAS - TABELAS - HOSPITAIS

tables: zpacientes, zpac_contactos, zpac_docs, zpac_enderecos, zpac_infopac.

"-----------------

data: ol_paciente type ref to zcl_paciente. "instacia da classe paciente

data: ls_paciente  type zpacientes,
      ls_contactos type zpac_contactos,
      ls_docs      type zpac_docs,
      ls_enderecos type zpac_enderecos,
      ls_info      type zpac_infopac,
      it_pct       type table of ol_paciente->wa_pct,
      ls_pct       type ol_paciente->wa_pct,
      id_paciente  type zpacientes-id_paciente. "id do hospital

"-----------------

data: result_p type zapr_result. "estrutura de retorno de mensagens
data: return_validation_p type zapr_result. "flag de validacao de campos

"-----------------

"tabela e estrutura das dropdowns

"pacientes
data: it_list_pct type vrm_values,
      ls_list_pct like line of it_list.
"hospitais
data: it_list_hosp  type vrm_values,
      ls_list_hosp  like line of it_list_hosp.

"-----------------
