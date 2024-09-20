*&---------------------------------------------------------------------*
*& Include          ZRLA_HOSP_TOP
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
