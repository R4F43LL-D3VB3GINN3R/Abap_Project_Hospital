*----------------------------------------------------------------------*
*INCLUDE ZRLA_CRIAR_HOSPITAL_PAI_ALVI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_ALV  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

module pai_alv input.

  "se estiver na tela 103...
  if sy-dynnr = 103.

    case sy-ucomm.
      when 'BACK'.
        leave program.
      when 'FCT_PROCURAR'.
        perform get_data_alv.
        perform build_alv.
      when 'FCT_DOWNLOAD'.
        perform get_data_excel.
        perform set_download.
    endcase.

  endif.

endmodule.
"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form set_download.

  if lr_data_ref is not initial.

    data(lo_excel) = new zcl_itab_to_excel( ). "instancia da classe

    "chama o método itab_to_xstring para converter a tabela interna em xstring (XLSX)
    lv_xstring = lo_excel->itab_to_xstring( lr_data_ref ).

    "caixa de dialogo para escolher caminho do download
    call method cl_gui_frontend_services=>file_save_dialog
      exporting
        window_title         = 'Salvar Arquivo XLSX'
        default_extension    = 'xlsx'
        file_filter          = 'Arquivos Excel (*.xlsx)|*.xlsx|'
      changing
        filename             = lv_filename
        fullpath             = lv_path
        path                 = lv_path
      exceptions
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        others               = 4.

    if lv_xstring is not initial.
      "converte xstring em uma tabela de binario (necessária para download)
      call function 'SCMS_XSTRING_TO_BINARY'
        exporting
          buffer     = lv_xstring
        tables
          binary_tab = lt_binary.

      " Baixar o arquivo para o PC
      call function 'GUI_DOWNLOAD'
        exporting
          bin_filesize            = xstrlen( lv_xstring )
          filename                = lv_filename
          filetype                = 'BIN'
        tables
          data_tab                = lt_binary
        exceptions
          file_write_error        = 1
          no_batch                = 2
          gui_refuse_filetransfer = 3
          invalid_type            = 4
          no_authority            = 5
          unknown_error           = 6
          header_not_allowed      = 7
          separator_not_allowed   = 8
          filesize_not_allowed    = 9
          header_too_long         = 10
          dp_error_create         = 11
          dp_error_send           = 12
          dp_error_write          = 13
          unknown_dp_error        = 14
          access_denied           = 15
          dp_out_of_memory        = 16
          disk_full               = 17
          dp_timeout              = 18
          file_not_found          = 19
          dataprovider_exception  = 20
          control_flush_error     = 21
          others                  = 22.

    endif.

  endif.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form get_data_excel.

  if it_alv_table is initial.
    message | Carregue os dados de um paciente antes de baixar um arquivo | type 'S' display like 'E'.
    return.
  endif.

  refresh: it_csv.
  clear lr_data_ref.

  it_csv = it_alv_table.

  get reference of it_csv into lr_data_ref.   "cria a referência para a tabela interna

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form handle_data_changed using ir_data_changed type ref to cl_alv_changed_data_protocol. "atualizacao de celula do alv

  data: ls_mod_cell type lvc_s_modi,  "celula modificada
        lv_value    type lvc_value.   "valor da alturacao

  data: ls_cell_inf type zpac_infopac. "estrutura contento as partes editaveis do alv
  data: lv_nome_cell type zpacientes-nome_paciente. "nome do paciente

  sort ir_data_changed->mt_mod_cells by row_id. "ordena a tabela

  "flag para aviso de celula editada
  data: flag_update type flag.
  flag_update = abap_false.

  "itera sobre a tabela de celulas editadas
  loop at ir_data_changed->mt_mod_cells into ls_mod_cell. "itera sobre a tabela

    "busca o id do paciente
    read table it_paciente103 into data(ls_pct103) index ls_mod_cell-row_id.

    "pega a linha referente ao id do paciente
    select single *
      from zpac_infopac
      into ls_cell_inf
      where id_paciente eq ls_pct103-id_paciente.

    "pega o nome do paciente
    select single nome_paciente
      from zpacientes
      into lv_nome_cell
      where id_paciente eq ls_pct103-id_paciente.

    "verifica qual celula foi editada do alv
    "sendo ela estidada, trocamos o valor dela na estrutura
    "ativamos nossa flag
    case ls_mod_cell-fieldname.
      when 'ALERGIAS'.
        ls_cell_inf-alergias = ls_mod_cell-value.
        flag_update = abap_true.
      when 'DOENCAS_CRONICAS'.
        ls_cell_inf-doencas_cronicas = ls_mod_cell-value.
        flag_update = abap_true.
      when 'MEDICACAO_ATUAL'.
        ls_cell_inf-medicacao_atual = ls_mod_cell-value.
        flag_update = abap_true.
      when 'HISTORICO_CIRURGICO'.
        ls_cell_inf-historico_cirurgico = ls_mod_cell-value.
        flag_update = abap_true.
      when 'HABITOS_DROGAS'.
        ls_cell_inf-habitos_drogas = ls_mod_cell-value.
        flag_update = abap_true.
      when 'OBSERVACOES'.
        ls_cell_inf-observacoes = ls_mod_cell-value.
        flag_update = abap_true.
    endcase.

    "se houve alteracao...
    if flag_update eq abap_true.

      ls_cell_inf-alterado_por = sy-uname.
      ls_cell_inf-data_alteracao = sy-datum.

      update zpac_infopac from ls_cell_inf. "atualiza a tabela de informacoes

      if sy-subrc ne 0.
        message | Não foi possível alterar as informações na célula | type 'S' display like 'E'.
        return.
      endif.

      "instancia e objeto da classe de mensagens
      data: ol_msg type ref to zcl_mensagens.
      create object ol_msg.

      result_103-rc = 0.
      result_103-mensagem = | Alterações em: [{ ls_mod_cell-fieldname }] do Paciente' { lv_nome_cell } |.

      "alimenta o historico
      ol_msg->set_msg(
        exporting
          id_pct   = ls_pct103-id_paciente      " ID do Paciente
          mensagem = result_103-mensagem        " Mensagem
      ).

      flag_update = abap_false. "desativa a flag.

      if result_p-rc ne 0.
        message result_103-mensagem type 'S' display like 'E'.
      else.
        message result_103-mensagem type 'S'.
      endif.

    endif.

    clear: ls_cell_inf, lv_nome_cell.
    free ol_msg.

  endloop.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form handle_hotspot_click using p_e_row_id
                                p_e_column_id
                                p_es_row_no.

  "itera sobre a tabela do alv
  read table it_alv_table into ls_alv index p_e_row_id.

  id_hotspot = ls_alv-id_paciente. "recebe o id enviado por hotspot

  perform get_data_hst. "preenche a tabela interna que será apresentada no alv
  perform build_alv2.   "preenche o container com o historico do paciente

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form build_alv2.

  custom_control2 = 'MAIN_CONTAINER2'. "atribui o container

  "se o container ainda nao foi criado...
  if ol_alvgrid2 is initial.

    "cria o container
    create object ol_container2
      exporting
        container_name              = custom_control2
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6.

    "cria o alvgrid
    create object ol_alvgrid2
      exporting
        i_parent          = ol_container2
      exceptions
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5.

  endif.

  "limpa o fieldcatalog
  clear it_fieldcat2.
  clear ls_fieldcat2.

  perform prepare_catalog2 changing it_fieldcat2. "prepara o fieldcatalog

  "metodo para receber o container com alv
  call method ol_alvgrid2->set_table_for_first_display
    exporting
      is_layout       = ls_layout2
    changing
      it_outtab       = it_hst_alv
      it_fieldcatalog = it_fieldcat2
    exceptions
      others          = 1.

  "atualiza o alv
  call method ol_alvgrid2->refresh_table_display
    exceptions
      others = 1.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form get_data_hst.

  refresh it_hst_alv.
  .
  data: new_date type char10.

  "preenche a tabela interna que será apresentada no alv
  select mensagem
         data_msg
         hora_msg
    from zhistorico_pct
    into table it_hst_alv
    where id_paciente eq ls_alv-id_paciente.

  "itera sobre a tabela para pegar a data e hora
  loop at it_hst_alv into ls_hst_alv.

    "funcao para tratamento de data e hora.
    call function 'RFC_FORMAT_TIME'
      exporting
        time        = ls_hst_alv-data_msg
        hour        = ls_hst_alv-hora_msg
      importing
        time_output = ls_hst_alv-new_date
        hour_output = ls_hst_alv-new_hour.

    modify it_hst_alv from ls_hst_alv. "atualiza a estrutura

  endloop.

  sort it_hst_alv by data_msg descending hora_msg descending. "ordena por ordem cronologica

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form get_data_alv.

  refresh: it_alv_table.

  create object ol_event_handler. "objeto da classe de eventos.

  "procura os pacientes internados no hospital
  select id_paciente
    from zpacientes
    into table @it_paciente103
    where id_hospital eq @in_001.

  sort it_paciente103 by id_paciente ascending. "organiza a tabela por id.

  "itera sobre a tabela populada
  loop at it_paciente103 into data(ls_paciente103).

    "cria um objeto relacionado ao id do paciente enviado
    create object ol_paciente
      exporting
        id_paciente = ls_paciente103-id_paciente. " Id do Paciente

    ls_alv = ol_paciente->ls_pct.  "preenche a estrutura com o objeto do paciente

    "funcao para tratamento de data e hora.
    call function 'RFC_FORMAT_TIME'
      exporting
        time        = ls_alv-data_inscricao
      importing
        time_output = ls_alv-new_data_inscricao.

    "funcao para tratamento de data e hora.
    call function 'RFC_FORMAT_TIME'
      exporting
        time        = ls_alv-data_nascimento
      importing
        time_output = ls_alv-new_data_nascimento.

    "funcao para tratamento de data e hora.
    call function 'RFC_FORMAT_TIME'
      exporting
        time        = ls_alv-validade_seguro
      importing
        time_output = ls_alv-new_validade_seguro.

    "funcao para tratamento de data e hora.
    call function 'RFC_FORMAT_TIME'
      exporting
        time        = ls_alv-ultima_consulta
      importing
        time_output = ls_alv-new_ultima_consulta.

    append ls_alv to it_alv_table. "insere o paciente na tabela

    clear ls_alv.
    free ol_paciente.

  endloop.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form fill_dropdown_alv.

  refresh it_dropdown_alv.

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
      ls_dropdown_alv-key = id_char.
      ls_dropdown_alv-text = ls_ddown-nome_hospital.
      append ls_dropdown_alv to it_dropdown_alv.
      clear ls_ddown.
    endloop.

    "chama a funcao que preenche a dropdown
    call function 'VRM_SET_VALUES'
      exporting
        id     = 'IN_001'
        values = it_dropdown_alv.

  endif.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form build_alv.

  custom_control = 'MAIN_CONTAINER'. "atribui o container

  "se o container ainda nao foi criado...
  if ol_alvgrid is initial.

    "cria o container
    create object ol_container
      exporting
        container_name              = custom_control
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6.

    "cria o alvgrid
    create object ol_alvgrid
      exporting
        i_parent          = ol_container
      exceptions
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5.

  endif.

  "limpa o fieldcatalog
  clear it_fieldcat.
  clear ls_fieldcat.

  perform prepare_catalog changing it_fieldcat. "prepara o fieldcatalog

  "fica a escuta do evento hostspot no alv
  set handler ol_event_handler->handle_hotspot_click for ol_alvgrid.

  "fica a escuta do evento de edicao do alv
  set handler ol_event_handler->handle_data_changed for ol_alvgrid.

  "metodo para registar qualquer edição efetuada no alv
  call method ol_alvgrid->register_edit_event
    exporting
      "constante obrigatoria como parametro
      "esta constante so aparece aqui no programa e nao está declarada em nenhum outro lado
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    exceptions
      error      = 1
      others     = 2.

  "metodo para receber o container com alv
  call method ol_alvgrid->set_table_for_first_display
    exporting
      is_layout       = ls_layout
    changing
      it_outtab       = it_alv_table
      it_fieldcatalog = it_fieldcat
    exceptions
      others          = 1.

  "atualiza o alv
  call method ol_alvgrid->refresh_table_display
    exceptions
      others = 1.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form prepare_catalog changing it_fieldcat type lvc_t_fcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'ID_PACIENTE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-coltext   = 'ID'.
  ls_fieldcat-seltext   = 'ID'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NOME_PACIENTE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Nome'.
  ls_fieldcat-seltext   = 'Nome'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-hotspot   = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'SEXO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-coltext   = 'Sexo'.
  ls_fieldcat-seltext   = 'Sexo'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NEW_DATA_NASCIMENTO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-coltext   = 'Data de Nascimento'.
  ls_fieldcat-seltext   = 'Data de Nascimento'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'ESTADO_CIVIL'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 12.
  ls_fieldcat-coltext   = 'Estado Civil'.
  ls_fieldcat-seltext   = 'Estado Civil'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'TELEFONE_PRINCIPAL'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Telefone Principal'.
  ls_fieldcat-seltext   = 'Telefone Principal'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'TELEFONE_SECUNDARIO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-coltext   = 'Telefone Secundário'.
  ls_fieldcat-seltext   = 'Telefone Secundário'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'EMAIL_PACIENTE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Email'.
  ls_fieldcat-seltext   = 'Email'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'CONTACTO_EMERGENCIA'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-coltext   = 'Contacto de Emergência'.
  ls_fieldcat-seltext   = 'Contacto de Emergência'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NOME_CONTACTO_E'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-coltext   = 'Nome do Contacto'.
  ls_fieldcat-seltext   = 'Nome do Contacto'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NIF'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-coltext   = 'NIF'.
  ls_fieldcat-seltext   = 'NIF'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'CARTAO_CIDADAO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-coltext   = 'Cartão Cidadão'.
  ls_fieldcat-seltext   = 'Cartão Cidadão'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NUMERO_UTENTE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-coltext   = 'Número do Utente'.
  ls_fieldcat-seltext   = 'Número do Utente'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'SUBSISTEMA_SAUDE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Subsistema Saúde'.
  ls_fieldcat-seltext   = 'Subsistema Saúde'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NUMERO_SEGURO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Número do Seguro'.
  ls_fieldcat-seltext   = 'Número do Seguro'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NEW_VALIDADE_SEGURO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Validade do Seguro'.
  ls_fieldcat-seltext   = 'Validade do Seguro'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'MORADA_PACIENTE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Morada'.
  ls_fieldcat-seltext   = 'Morada'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'CODIGO_POSTAL'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-coltext   = 'Código Postal'.
  ls_fieldcat-seltext   = 'Código Postal'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'CONCELHO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 12.
  ls_fieldcat-coltext   = 'Concelho'.
  ls_fieldcat-seltext   = 'Concelho'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NACIONALIDADE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Nacionalidade'.
  ls_fieldcat-seltext   = 'Nacionalidade'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'PESO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-coltext   = 'Peso'.
  ls_fieldcat-seltext   = 'Peso'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'ALTURA'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 8.
  ls_fieldcat-coltext   = 'Altura'.
  ls_fieldcat-seltext   = 'Altura'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NEW_DATA_INSCRICAO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 12.
  ls_fieldcat-coltext   = 'Data de Inscrição'.
  ls_fieldcat-seltext   = 'Data de Insccrição'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'NEW_ULTIMA_CONSULTA'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 16.
  ls_fieldcat-coltext   = 'Última Consulta'.
  ls_fieldcat-seltext   = 'Última Consulta'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'TIPO_SANGUE'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 12.
  ls_fieldcat-coltext   = 'Tipo Sanguíneo'.
  ls_fieldcat-seltext   = 'Tipo Sanguíneo'.
  ls_fieldcat-just      = 'C'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'ALERGIAS'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Alergias'.
  ls_fieldcat-seltext   = 'Alergias'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'DOENCAS_CRONICAS'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Doênças Crônicas'.
  ls_fieldcat-seltext   = 'Doênças Crônicas'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'MEDICACAO_ATUAL'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Medicação Atual'.
  ls_fieldcat-seltext   = 'Medicação Atual'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'HISTORICO_CIRURGICO'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Histórico Cirúrgico'.
  ls_fieldcat-seltext   = 'Histórico Cirúrgico'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'HABITOS_DROGAS'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Hábitos Drogas'.
  ls_fieldcat-seltext   = 'Hábitos Drogas'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'OBSERVACOES'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-outputlen = 25.
  ls_fieldcat-coltext   = 'Observações'.
  ls_fieldcat-seltext   = 'Observações'.
  ls_fieldcat-just      = 'C'.
  ls_fieldcat-edit      = 'X'.
  append ls_fieldcat to it_fieldcat.

endform.

"--------------------------------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------------------------------

form prepare_catalog2 changing it_fieldcat2 type lvc_t_fcat..

  clear ls_fieldcat2.
  ls_fieldcat2-fieldname = 'MENSAGEM'.
  ls_fieldcat2-inttype   = 'C'.
  ls_fieldcat2-outputlen = 60.
  ls_fieldcat2-coltext   = 'Mensagem'.
  ls_fieldcat2-seltext   = 'Mensagem'.
  ls_fieldcat2-just      = 'C'.
  ls_fieldcat2-edit      = 'X'.
  append ls_fieldcat2 to it_fieldcat2.

  clear ls_fieldcat2.
  ls_fieldcat2-fieldname = 'NEW_DATE'.
  ls_fieldcat2-inttype   = 'C'.
  ls_fieldcat2-outputlen = 10.
  ls_fieldcat2-coltext   = 'Data'.
  ls_fieldcat2-seltext   = 'Data'.
  ls_fieldcat2-just      = 'C'.
  ls_fieldcat2-edit      = 'X'.
  append ls_fieldcat2 to it_fieldcat2.

  clear ls_fieldcat2.
  ls_fieldcat2-fieldname = 'NEW_HOUR'.
  ls_fieldcat2-inttype   = 'C'.
  ls_fieldcat2-outputlen = 10.
  ls_fieldcat2-coltext   = 'Hora'.
  ls_fieldcat2-seltext   = 'Hora'.
  ls_fieldcat2-just      = 'C'.
  ls_fieldcat2-edit      = 'X'.
  append ls_fieldcat2 to it_fieldcat2.

endform.

"--------------------------------------------------------------------------------------------------------------------------
