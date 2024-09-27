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
    hora     type sy-uzeit,
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

endmodule.
