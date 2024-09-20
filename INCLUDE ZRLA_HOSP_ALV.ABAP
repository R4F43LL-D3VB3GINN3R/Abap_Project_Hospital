*&---------------------------------------------------------------------*
*& Include          ZRLA_HOSP_ALV
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
