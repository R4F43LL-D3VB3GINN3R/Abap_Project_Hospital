*&---------------------------------------------------------------------*
*& Report ZTREE_PCT
*&---------------------------------------------------------------------*
*&reference link: https://github.com/R4F43LL-D3VB3GINN3R/Abap_Project_Hospital/new/main
*&---------------------------------------------------------------------*
report ztree_pct.

"estrutura dos nodes
types: begin of wa_struct,
         nome_hospital       type zhospitais-nome_hospital,
         nome_paciente       type zpacientes-nome_paciente,
         contactos           type string,
         telefone_principal  type zpac_contactos-telefone_principal,
         telefone_secundario type zpac_contactos-telefone_secundario,
         email_paciente      type zpac_contactos-email_paciente,
         contacto_emergencia type zpac_contactos-contacto_emergencia,
         nome_contacto_e     type zpac_contactos-nome_contacto_e,
         documentos          type string,
         nif                 type zpac_docs-nif,
         cartao_cidadao      type zpac_docs-cartao_cidadao,
         numero_utente       type zpac_docs-numero_utente,
         subsistema_saude    type zpac_docs-subsistema_saude,
         numero_seguro       type zpac_docs-numero_seguro,
         validade_seguro     type zpac_docs-validade_seguro,
         enderecos           type string,
         morada_paciente     type zpac_enderecos-morada_paciente,
         codigo_postal       type zpac_enderecos-codigo_postal,
         concelho            type zpac_enderecos-concelho,
         nacionalidade       type zpac_enderecos-nacionalidade,
         infos               type string,
         peso                type zpac_infopac-peso,
         altura              type zpac_infopac-altura,
         data_inscricao      type zpac_infopac-data_inscricao,
         ultima_consulta     type zpac_infopac-ultima_consulta,
         tipo_sangue         type zpac_infopac-tipo_sangue,
         alergias            type zpac_infopac-alergias,
         doencas_cronicas    type zpac_infopac-doencas_cronicas,
         medicacao_atual     type zpac_infopac-medicacao_atual,
         historico_cirurgico type zpac_infopac-historico_cirurgico,
         habitos_drogas      type zpac_infopac-habitos_drogas,
         observacoes         type zpac_infopac-observacoes,
       end of wa_struct.

"estrutura do alv tree e por onde começa a tree
types: begin of wa_struct2,
         informacoes_pct type zinfop,
       end of wa_struct2.

"tabelas internas
data: it_data      type table of wa_struct2,
      it_data_tree type table of wa_struct.

"objetos de referencia
data: obj_tree           type ref to cl_salv_tree,          "node principal
      obj_nodes          type ref to cl_salv_nodes,         "criacao dos nodes
      obj_node_hosp      type ref to cl_salv_node,          "node dos hospitais
      obj_node_pac       type ref to cl_salv_node,          "node dos pacientes
      obj_node_contacto  type ref to cl_salv_node,          "node dos contactos
      obj_node_docs      type ref to cl_salv_node,          "node dos documentos
      obj_node_enderecos type ref to cl_salv_node,          "node dos enderecos
      obj_node_infos     type ref to cl_salv_node,          "node das informacoes
      obj_settings       type ref to cl_salv_tree_settings. "opcoes gerais do alv tree

"variavel para concatenar nomes às colunas do alv tree
data: lv_text type lvc_value.

start-of-selection.

  perform alv_tree_setup. "configuracoes da alv tree
  perform get_data_tree.  "query principal
  perform run_alv_tree.   "processamento da arvore
  perform display_tree.   "exibicao da arvore

form alv_tree_setup.

  "implementa a tabela de referencia na arvore.
  call method cl_salv_tree=>factory
    importing
      r_salv_tree = obj_tree
    changing
      t_table     = it_data.

  "opcoes do cabecalho.
  obj_settings = obj_tree->get_tree_settings( ).
  obj_settings->set_header( 'Hospitais / Pacientes' ).
  obj_settings->set_hierarchy_header( 'Hospitais' ).
  obj_settings->set_hierarchy_tooltip( 'Hospital' ).
  obj_settings->set_hierarchy_icon( '@3Z@' ).
  obj_settings->set_hierarchy_size( 35 ).

  "leitura dos nodes
  obj_nodes = obj_tree->get_nodes( ).

endform.

form get_data_tree.

  "preenche a tabela com todas as informacoes pertinentes ao paciente
  select h~nome_hospital
         p~nome_paciente
         c~telefone_principal
         c~telefone_secundario
         c~email_paciente
         c~contacto_emergencia
         c~nome_contacto_e
         d~nif
         d~cartao_cidadao
         d~numero_utente
         d~subsistema_saude
         d~numero_seguro
         d~validade_seguro
         e~morada_paciente
         e~codigo_postal
         e~concelho
         e~nacionalidade
         i~peso
         i~altura
         i~data_inscricao
         i~ultima_consulta
         i~tipo_sangue
         i~alergias
         i~doencas_cronicas
         i~medicacao_atual
         i~historico_cirurgico
         i~habitos_drogas
         i~observacoes
    from zhospitais as h
    inner join zpacientes     as p on h~id_hospital eq p~id_hospital
    inner join zpac_contactos as c on c~id_paciente eq p~id_paciente
    inner join zpac_docs      as d on d~id_paciente eq p~id_paciente
    inner join zpac_enderecos as e on e~id_paciente eq p~id_paciente
    inner join zpac_infopac   as i on i~id_paciente eq p~id_paciente
    into corresponding fields of table it_data_tree.

endform.

form run_alv_tree.

  "criacao da tree e seus respectivos nodes
  loop at it_data_tree into data(wa_data).

    "HOSPITAL -------------------------------------------------------------------------------------

    "instrucao para nao repetir os nomes dos hospitais
    on change of wa_data-nome_hospital.

      "node do hospital
      lv_text = wa_data-nome_hospital.
      obj_node_hosp = obj_nodes->add_node( related_node = ' ' " node raiz
                                           text = lv_text
                                           relationship = ' ' ).
    endon.

    data(lv_hosp_key) = obj_node_hosp->get_key( ). "guarda o node do hospital

    "HOSPITAL -------------------------------------------------------------------------------------

    "PACIENTE -------------------------------------------------------------------------------------

    "node do paciente
    lv_text = wa_data-nome_paciente.
    obj_node_pac = obj_nodes->add_node( related_node = lv_hosp_key "relativo ao node do hospital
                                        folder = 'X'
                                        text = lv_text
                                        relationship = cl_gui_column_tree=>relat_first_child ).

    data(lv_pac_key) = obj_node_pac->get_key( ). "guarda o node do paciente

    "PACIENTE -------------------------------------------------------------------------------------

    "CONTACTOS ------------------------------------------------------------------------------------

    "node de contactos
    lv_text = 'Contactos'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_pac_key "relativo ao node do paciente
                                             folder = 'X'
                                             text = lv_text
                                             relationship = cl_gui_column_tree=>relat_first_child ).

    data(lv_contact_key) = obj_node_contacto->get_key( ). "guarda o node do contacto

    "--------------- // ---------------"

    lv_text = 'Telefone Principal'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_contact_key "relacionado ao contacto
                                             text = lv_text
                                             data_row = wa_data-telefone_principal
                                             relationship = cl_gui_column_tree=>relat_first_child ).
    lv_text = 'Telefone Secundário'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_contact_key "relacionado ao contacto
                                             text = lv_text
                                             data_row = wa_data-telefone_secundario
                                             relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Email'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_contact_key "relacionado ao contacto
                                             text = lv_text
                                             data_row = wa_data-email_paciente
                                             relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Número Emergência'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_contact_key "relacionado ao contacto
                                             text = lv_text
                                             data_row = wa_data-contacto_emergencia
                                             relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Contacto Emergência'.
    obj_node_contacto = obj_nodes->add_node( related_node = lv_contact_key "relacionado ao contacto
                                             text = lv_text
                                             data_row = wa_data-nome_contacto_e
                                             relationship = cl_gui_column_tree=>relat_last_child ).

    "CONTACTOS ------------------------------------------------------------------------------------

    "DOCUMENTOS -----------------------------------------------------------------------------------

    "node de documentos
    lv_text = 'Documentos'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_pac_key "relativo ao node do paciente
                                         folder = 'X'
                                         text = lv_text
                                         relationship = cl_gui_column_tree=>relat_last_child ).

    data(lv_document_key) = obj_node_docs->get_key( ). "guarda o node dos documentos

    "--------------- // ---------------"

    lv_text = 'Nif'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-nif
                                         relationship = cl_gui_column_tree=>relat_first_child ).
    lv_text = 'Cartão Cidadão'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-cartao_cidadao
                                         relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Numero do Utente'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-numero_utente
                                         relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Subsistema de Saúde'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-subsistema_saude
                                         relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Número do Seguro'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-numero_seguro
                                         relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Validade do Seguro'.
    obj_node_docs = obj_nodes->add_node( related_node = lv_document_key "relacionado aos documentos
                                         text = lv_text
                                         data_row = wa_data-validade_seguro
                                         relationship = cl_gui_column_tree=>relat_last_child ).

    "DOCUMENTOS -----------------------------------------------------------------------------------

    "ENDEREÇOS ------------------------------------------------------------------------------------

    "node de documentos
    lv_text = 'Localização'.
    obj_node_enderecos = obj_nodes->add_node( related_node = lv_pac_key "relativo ao node do paciente
                                              folder = 'X'
                                              text = lv_text
                                              relationship = cl_gui_column_tree=>relat_last_child ).

    data(lv_enderecos_key) = obj_node_enderecos->get_key( ). "guarda o node dos enderecos

    "--------------- // ---------------"

    lv_text = 'Morada'.
    obj_node_enderecos = obj_nodes->add_node( related_node = lv_enderecos_key "relacionado ao endereço
                                              text = lv_text
                                              data_row = wa_data-morada_paciente
                                              relationship = cl_gui_column_tree=>relat_first_child ).
    lv_text = 'Código Postal'.
    obj_node_enderecos = obj_nodes->add_node( related_node = lv_enderecos_key "relacionado ao endereço
                                              text = lv_text
                                              data_row = wa_data-codigo_postal
                                              relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Concelho'.
    obj_node_enderecos = obj_nodes->add_node( related_node = lv_enderecos_key "relacionado ao endereço
                                              text = lv_text
                                              data_row = wa_data-concelho
                                              relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Nacionalidade'.
    obj_node_enderecos = obj_nodes->add_node( related_node = lv_enderecos_key "relacionado ao endereço
                                              text = lv_text
                                              data_row = wa_data-nacionalidade
                                              relationship = cl_gui_column_tree=>relat_last_child ).

    "ENDEREÇOS ------------------------------------------------------------------------------------

    "INFORMAÇÕES PESSOAIS -------------------------------------------------------------------------

    "node de documentos
    lv_text = 'Informações Pessoais'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_pac_key "relativo ao node do paciente
                                          folder = 'X'
                                          text = lv_text
                                          relationship = cl_gui_column_tree=>relat_last_child ).

    data(lv_info_key) = obj_node_infos->get_key( ). "guarda o node das informacoes pessoais

    "--------------- // ---------------"

    lv_text = 'Peso'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-peso
                                          relationship = cl_gui_column_tree=>relat_first_child ).
    lv_text = 'Altura'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-altura
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Data de Inscrição'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-data_inscricao
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Última Consulta'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-ultima_consulta
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Tipo Sanguíneo'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-tipo_sangue
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Alergias'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-alergias
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Doenças Crônicas'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-doencas_cronicas
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Medicação Atual'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoas
                                          text = lv_text
                                          data_row = wa_data-medicacao_atual
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Histórico Cirúrgico'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-historico_cirurgico
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Hábitos Drogas'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-habitos_drogas
                                          relationship = cl_gui_column_tree=>relat_last_child ).
    lv_text = 'Observações Adicionais'.
    obj_node_infos = obj_nodes->add_node( related_node = lv_info_key "relacionado às informacoes pessoais
                                          text = lv_text
                                          data_row = wa_data-observacoes
                                          relationship = cl_gui_column_tree=>relat_last_child ).

    "INFORMAÇÕES PESSOAIS -------------------------------------------------------------------------

  endloop.
endform.

form display_tree.

  "exibe o alv tree.
  obj_tree->display( ).

endform.
