

*&---------------------------------------------------------------------*
*& Report ZRLA_CRIAR_HOSPITAL
*&---------------------------------------------------------------------*
*&reference link: https://github.com/R4F43LL-D3VB3GINN3R/Abap_Project_Hospital/blob/main/ZRLA_CRIAR_HOSPITAL.ABAP
*&---------------------------------------------------------------------*
report zrla_criar_hospital.

set pf-status 'MAIN_STATUS'.

"INCLUDES HOSPITAIS
include zrla_hosp_top.
include zrla_screens.
include zrla_hosp_rot.
include zrla_hosp_alv.

"INCLUDES PACIENTES
include zrla_pct_top.
include zrla_pct_rot.

"CLASSE PARA MANIPULACAO DE EVENTOS EM ALV.
include zcl_event_handler.
"CLASSE PARA TRANFORMAR TABELA INTERNA EM EXCEL.
include zcl_itab_to_excel.

"ALV CONTAINER
include zrla_criar_hospital_pbo_alvo01.
include zrla_criar_hospital_pai_alvi01.

at selection-screen output.

at selection-screen.

  "------------------------------------------------------------------------------------------------------
  "SCREEN 100 - HOSPITAIS

  if sy-dynnr = 100.

    "se a dropdown nao estiver vazia
    if sy-ucomm ne 'EDIT' and sy-ucomm ne 'INSERT' and sy-ucomm ne 'READ'.
      perform fill_fields.
    endif.

    "se algum botao for pressionado...
    if sy-ucomm eq 'INSERT' or
       sy-ucomm eq 'EDIT'.
      perform field_validations. "validacao de campos
    endif.

    "se todos os campos estiverem validados
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
        when 'BACK'.
          leave program.
      endcase.

      "se houver algum campo invalidade
    else.
      message return_validation-mensagem type 'S' display like 'E'.
      clear: return_validation-rc. "limpa a variavel
    endif.

  endif.

  "------------------------------------------------------------------------------------------------------
  "SCREEN 101 - PACIENTES

  if sy-dynnr = 101.

    "se a dropdown de hospitais estiver vazia e nenhum botao for apertado...
    if p_nomesh is not initial and
       p_nomesp is initial and
       sy-ucomm ne 'P_EDIT' and sy-ucomm ne 'P_INSERT' and sy-ucomm ne 'P_READ'.
      perform clear_fields.
      perform fill_pct_dropdown_names.
      "se a dropdown de hospitais estiver preenchida e nenhum botao for apertado...
    elseif p_nomesh is not initial and
           p_nomesp is not initial and
           sy-ucomm ne 'P_EDIT' and sy-ucomm ne 'P_INSERT' and sy-ucomm ne 'P_READ'.
      perform clear_fields.
      perform fill_pct_dropdown_names.
    endif.

    if p_nomesp is not initial and
       p_nomesh is not initial and
       sy-ucomm ne 'P_EDIT'    and
       lv_search eq abap_true.
      perform fill_fields_pct.
    endif.

    "se algum botao for pressionado...
    if sy-ucomm eq 'P_INSERT' or
       sy-ucomm eq 'P_EDIT'.
      perform field_pct_validations. "validacao de campos
    endif.

    "se todos os campos estiverem validados
    if return_validation_p-rc eq 0.

      perform get_pct_data. "preenche a estrutura

      case sy-ucomm.
        when 'P_INSERT'.
          perform insert_paciente.
        when 'P_EDIT'.
          perform edit_paciente.
        when 'P_READ'.
          call transaction 'ZPCTREE'.
        when 'BACK'.
          leave program.
      endcase.

      "se houver algum campo invalidade
    else.
      message return_validation_p-mensagem type 'S' display like 'E'.
      clear: return_validation_p-rc."limpa a variavel
    endif.

  endif.

*"------------------------------------------------------------------------------------------------------
  "INICIALIZACAO DE DADOS

initialization.

  perform fill_dropdown_names. "preenche as dropdowns da tela 100.
  perform fill_hosp_dropdown_names. "preenche as dropdowns da tela 101.
  perform fill_dropdown_alv. "preenche a dropdown da tela 103.

  "nomes das tabs
  tab1 = '@0U@' && 'Hospitais'.
  tab2 = '@0U@' && 'Pacientes'.
  tab3 = '@0U@' && 'Gerenciamento'.
