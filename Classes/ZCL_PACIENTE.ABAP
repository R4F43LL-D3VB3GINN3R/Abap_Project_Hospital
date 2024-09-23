class zcl_paciente definition
  public
  final
  create public .

  public section.

    types:
      begin of wa_pct,
        id_paciente         type zpacientes-id_paciente,
        id_hospital         type zpacientes-id_hospital,
        id_contacto         type zpac_contactos-id_contacto,
        id_documento        type zpac_docs-id_documento,
        id_localizacao      type zpac_enderecos-id_localizacao,
        id_info_paciente    type zpac_infopac-id_info_paciente,
        nome_paciente       type zpacientes-nome_paciente,
        sexo                type zpacientes-sexo,
        data_nascimento     type zpacientes-data_nascimento,
        estado_civil        type zpacientes-estado_civil,
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
        morada_paciente     type zpac_enderecos-morada_paciente,
        codigo_postal       type zpac_enderecos-codigo_postal,
        concelho            type zpac_enderecos-concelho,
        nacionalidade       type zpac_enderecos-nacionalidade,
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
        data_alteracao      type zpacientes-data_alteracao,
        alterado_por        type zpacientes-alterado_por,
      end of wa_pct .

    data paciente type zpacientes .
    data contactos type zpac_contactos .
    data docs type zpac_docs .
    data enderecos type zpac_enderecos .
    data info type zpac_infopac .
    data:
      it_pct    type table of wa_pct .
    data ls_pct type wa_pct .

    methods constructor
      importing
        !id_paciente type zpacientes-id_paciente
      exceptions
        invalid_pct .
    class-methods insert_paciente
      importing
        !id_hospital type zhospitais-id_hospital
        !paciente    type zpacientes
        !contactos   type zpac_contactos
        !docs        type zpac_docs
        !enderecos   type zpac_enderecos
        !info        type zpac_infopac
      exporting
        !e_result    type zapr_result .
    class-methods edit_paciente
      importing
        !id_hospital type zhospitais-id_hospital
        !paciente    type zpacientes
        !contactos   type zpac_contactos
        !docs        type zpac_docs
        !enderecos   type zpac_enderecos
        !info        type zpac_infopac
      exporting
        !e_result    type zapr_result .
  protected section.
private section.

  class-methods GET_NEXT
    returning
      value(ID_PCT) type ZPACIENTES-ID_PACIENTE .
  class-methods CHECK_PACIENTE
    importing
      !ID_HSP type ZPACIENTES-ID_HOSPITAL
      !ID_PCT type ZPACIENTES-ID_PACIENTE
    exporting
      !E_RESULT type ZAPR_RESULT .
  class-methods GET_ID
    importing
      !NIF type ZPAC_DOCS-NIF
    exporting
      !ID_PACIENTE type ZPAC_DOCS-ID_PACIENTE
      !ID_DOCS type ZPAC_DOCS-ID_DOCUMENTO
      !ID_CONTACTO type ZPAC_CONTACTOS-ID_CONTACTO
      !ID_INFO type ZPAC_INFOPAC-ID_INFO_PACIENTE
      !ID_ENDERECO type ZPAC_ENDERECOS-ID_LOCALIZACAO
      !E_RESULT type ZAPR_RESULT .
ENDCLASS.



CLASS ZCL_PACIENTE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PACIENTE=>CHECK_PACIENTE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_HSP                         TYPE        ZPACIENTES-ID_HOSPITAL
* | [--->] ID_PCT                         TYPE        ZPACIENTES-ID_PACIENTE
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method check_paciente.

    data id_paciente type zpacientes-id_paciente.
    data id_hospital type zhospitais-id_hospital.

    "verifica se o paciente existe.
    select single id_paciente
                  id_hospital
      from zpacientes
      into ( id_paciente, id_hospital )
      where id_paciente eq id_pct
      and id_hospital eq id_hsp.

    if sy-subrc ne 0.
      e_result-rc = 1.
      e_result-mensagem = | Paciente não existe no sistema |.
    else.
      e_result-rc = 0.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PACIENTE->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PACIENTE                    TYPE        ZPACIENTES-ID_PACIENTE
* | [EXC!] INVALID_PCT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    "verifica se o id foi enviado
    if id_paciente is initial.
      return.
    endif.

    "seleciona a linha da tabela referente ao id
    select single * from zpacientes
      into paciente
      where id_paciente eq id_paciente.

    "seleciona todas as informacoes adjascentes ao paciente.
    select single * from zpac_contactos into contactos where id_paciente eq id_paciente.
    select single * from zpac_docs      into docs      where id_paciente eq id_paciente.
    select single * from zpac_enderecos into enderecos where id_paciente eq id_paciente.
    select single * from zpac_infopac   into info      where id_paciente eq id_paciente.

    "preenche a estrutura personalizada do paciente
    select single
       p~id_paciente,
       p~id_hospital,
       c~id_contacto,
       d~id_documento,
       e~id_localizacao,
       i~id_info_paciente,
       p~nome_paciente,
       p~sexo,
       p~data_nascimento,
       p~estado_civil,
       c~telefone_principal,
       c~telefone_secundario,
       c~email_paciente,
       c~contacto_emergencia,
       c~nome_contacto_e,
       d~nif,
       d~cartao_cidadao,
       d~numero_utente,
       d~subsistema_saude,
       d~numero_seguro,
       d~validade_seguro,
       e~morada_paciente,
       e~codigo_postal,
       e~concelho,
       e~nacionalidade,
       i~peso,
       i~altura,
       i~data_inscricao,
       i~ultima_consulta,
       i~tipo_sangue,
       i~alergias,
       i~doencas_cronicas,
       i~medicacao_atual,
       i~historico_cirurgico,
       i~habitos_drogas,
       i~observacoes,
       p~data_alteracao,
       p~alterado_por
     from zpacientes as p
     inner join zpac_contactos as c on p~id_paciente = c~id_paciente
     inner join zpac_docs      as d on p~id_paciente = d~id_paciente
     inner join zpac_enderecos as e on p~id_paciente = e~id_paciente
     inner join zpac_infopac   as i on p~id_paciente = i~id_paciente
     into corresponding fields of @ls_pct
     where p~id_paciente = @id_paciente.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PACIENTE=>EDIT_PACIENTE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_HOSPITAL                    TYPE        ZHOSPITAIS-ID_HOSPITAL
* | [--->] PACIENTE                       TYPE        ZPACIENTES
* | [--->] CONTACTOS                      TYPE        ZPAC_CONTACTOS
* | [--->] DOCS                           TYPE        ZPAC_DOCS
* | [--->] ENDERECOS                      TYPE        ZPAC_ENDERECOS
* | [--->] INFO                           TYPE        ZPAC_INFOPAC
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method edit_paciente.

    data: msg type string. "guarda qual ou quais das informacoes do paciente foram alteradas

    "estruturas e variaveis do paciente
    data: id_hsp       type zhospitais-id_hospital,
          ls_paciente  type zpacientes,
          ls_contactos type zpac_contactos,
          ls_docs      type zpac_docs,
          ls_enderecos type zpac_enderecos,
          ls_info      type zpac_infopac.

    "estruturas e variaveis recebem os valores da entrada
    id_hsp       = id_hospital.
    ls_paciente  = paciente.
    ls_contactos = contactos.
    ls_docs      = docs.
    ls_enderecos = enderecos.
    ls_info      = info.

    ls_paciente-id_hospital = id_hsp. "recebe o id do hospital.

    "pega os ids do paciente referente ao nif.
    zcl_paciente=>get_id(
      exporting
        nif         = ls_docs-nif                 " Nif do Paciente
      importing
        id_paciente = ls_paciente-id_paciente     " Id do Paciente
        id_docs     = ls_docs-id_documento        " Id dos Documentos
        id_contacto = ls_contactos-id_contacto    " Id de Contacto
        id_info     = ls_info-id_info_paciente    " Id de Informações Adicionais
        id_endereco = ls_enderecos-id_localizacao " Id da Localização
        e_result    = e_result                    " Estrutura de resultados de operações
    ).

    "se nao existir...
    if e_result-rc ne 0.
      return.
    endif.

    "atribui os ids do paciente nas estruturas
    ls_contactos-id_paciente = ls_paciente-id_paciente.
    ls_docs-id_paciente      = ls_paciente-id_paciente.
    ls_enderecos-id_paciente = ls_paciente-id_paciente.
    ls_info-id_paciente      = ls_paciente-id_paciente.

    "verifica se o paciente existe
    zcl_paciente=>check_paciente(
      exporting
        id_hsp   = id_hsp                  " Id do Hospital
        id_pct   = ls_paciente-id_paciente " Id do Paciente
      importing
        e_result = e_result                " Estrutura de resultados de operações
    ).

    "se nao existir...
    if e_result-rc eq 1.
      return.
    endif.

    "verifica se há necessidade de alterar as informacoes da tabela zpacientes
    data: ls_pac type zpacientes.

    select single nome_paciente,
                  data_nascimento,
                  sexo,
                  estado_civil
      from zpacientes
      into corresponding fields of @ls_pac
      where nome_paciente eq @ls_paciente-nome_paciente
      and data_nascimento eq @ls_paciente-data_nascimento
      and sexo            eq @ls_paciente-sexo
      and estado_civil    eq @ls_paciente-estado_civil.

      if sy-subrc ne 0.
        e_result-rc = 0.
        concatenate msg 'Informações Gerais' into msg separated by space.
        ls_paciente-data_alteracao = sy-datum.
        ls_paciente-alterado_por   = sy-uname.
        update zpacientes from ls_paciente.
      endif.

    "verifica se há necessidade de alterar as informacoes da tabela zpac_contactos
    data: ls_cnt type zpac_contactos.

    select single telefone_principal,
                  telefone_secundario,
                  email_paciente,
                  contacto_emergencia,
                  nome_contacto_e
      from zpac_contactos
      into corresponding fields of @ls_cnt
      where telefone_principal  eq @ls_contactos-telefone_principal
      and telefone_secundario   eq @ls_contactos-telefone_secundario
      and email_paciente        eq @ls_contactos-email_paciente
      and contacto_emergencia   eq @ls_contactos-contacto_emergencia
      and nome_contacto_e       eq @ls_contactos-nome_contacto_e.

      if sy-subrc ne 0.
        e_result-rc = 0.
        concatenate msg 'Contactos' into msg separated by space.
        ls_contactos-data_alteracao = sy-datum.
        ls_contactos-alterado_por   = sy-uname.
        update zpac_contactos from ls_contactos.
      endif.

     "verifica se há necessidade de alterar as informacoes da tabela zpac_docs
     data: ls_documentos type zpac_docs.

     select single nif,
                   cartao_cidadao,
                   numero_utente,
                   subsistema_saude,
                   numero_seguro,
                   validade_seguro
       from zpac_docs
       into corresponding fields of @ls_documentos
       where nif            eq @ls_docs-nif
       and cartao_cidadao   eq @ls_docs-cartao_cidadao
       and numero_utente    eq @ls_docs-numero_utente
       and subsistema_saude eq @ls_docs-subsistema_saude
       and numero_seguro    eq @ls_docs-numero_seguro
       and validade_seguro  eq @ls_docs-validade_seguro.

       if sy-subrc ne 0.
         e_result-rc = 0.
         concatenate msg 'Documentos' into msg separated by space.
         ls_docs-data_alteracao = sy-datum.
         ls_docs-alterado_por   = sy-uname.
         update zpac_docs from ls_docs.
       endif.

     "verifica se há necessidade de alterar as informacoes da tabela zpac_enderecos
     data: ls_endr type zpac_enderecos.

     select single morada_paciente,
                   codigo_postal,
                   concelho,
                   nacionalidade
       from zpac_enderecos
       into corresponding fields of @ls_endr
       where morada_paciente eq @ls_enderecos-morada_paciente
       and codigo_postal     eq @ls_enderecos-codigo_postal
       and concelho          eq @ls_enderecos-concelho
       and nacionalidade     eq @ls_enderecos-nacionalidade.

       if sy-subrc ne 0.
         e_result-rc = 0.
         concatenate msg 'Endereços' into msg separated by space.
         ls_enderecos-data_alteracao = sy-datum.
         ls_enderecos-alterado_por   = sy-uname.
         update zpac_enderecos from ls_enderecos.
       endif.

     "verifica se há necessidade de alterar as informacoes da tabela zpac-infopac
     data: ls_inf type zpac_infopac.

     select single peso,
                   altura,
                   data_inscricao,
                   ultima_consulta,
                   tipo_sangue,
                   alergias,
                   doencas_cronicas,
                   medicacao_atual,
                   historico_cirurgico,
                   habitos_drogas,
                   observacoes
       from zpac_infopac
       into corresponding fields of @ls_inf
       where peso              eq @ls_info-peso
       and altura              eq @ls_info-altura
       and ultima_consulta     eq @ls_info-ultima_consulta
       and tipo_sangue         eq @ls_info-tipo_sangue
       and alergias            eq @ls_info-alergias
       and doencas_cronicas    eq @ls_info-doencas_cronicas
       and medicacao_atual     eq @ls_info-medicacao_atual
       and historico_cirurgico eq @ls_info-historico_cirurgico
       and habitos_drogas      eq @ls_info-habitos_drogas
       and observacoes         eq @ls_info-observacoes.

       if sy-subrc ne 0.
         e_result-rc = 0.
         concatenate msg 'Informações Pessoais' into msg separated by space.
         ls_info-data_alteracao = sy-datum.
         ls_info-alterado_por   = sy-uname.
         update zpac_infopac from ls_info.
       endif.

     "se alguma informacao foi alterada
     if e_result-rc eq 0.
       concatenate msg 'do Paciente foram alteradas. ' into msg separated by space.
       e_result-mensagem = msg.
     else.
       e_result-mensagem = | Não houveram alterações |.
     endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PACIENTE=>GET_ID
* +-------------------------------------------------------------------------------------------------+
* | [--->] NIF                            TYPE        ZPAC_DOCS-NIF
* | [<---] ID_PACIENTE                    TYPE        ZPAC_DOCS-ID_PACIENTE
* | [<---] ID_DOCS                        TYPE        ZPAC_DOCS-ID_DOCUMENTO
* | [<---] ID_CONTACTO                    TYPE        ZPAC_CONTACTOS-ID_CONTACTO
* | [<---] ID_INFO                        TYPE        ZPAC_INFOPAC-ID_INFO_PACIENTE
* | [<---] ID_ENDERECO                    TYPE        ZPAC_ENDERECOS-ID_LOCALIZACAO
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_ID.

    "procura o id do paciente referente ao nif enviado
    select single id_paciente
      from zpac_docs
      into id_paciente
      where nif eq nif.

    if sy-subrc ne 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Não há um id referente ao nif do paciente |.
    else.
      e_result-rc = sy-subrc.
    endif.

    "seleciona todos os ids referente ao id do paciente
    select single d~id_documento,
                  c~id_contacto,
                  i~id_info_paciente,
                  e~id_localizacao
      from zpacientes           as p
      inner join zpac_docs      as d on d~id_paciente eq p~id_paciente
      inner join zpac_contactos as c on c~id_paciente eq p~id_paciente
      inner join zpac_infopac   as i on i~id_paciente eq i~id_paciente
      inner join zpac_enderecos as e on e~id_paciente eq i~id_paciente
      into ( @id_docs, @id_contacto, @id_info, @id_endereco )
      where p~id_paciente eq @id_paciente.

    if sy-subrc ne 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Identificação adicional do paciente não foi encontreada |.
    else.
      e_result-rc = sy-subrc.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_PACIENTE=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID_PCT                         TYPE        ZPACIENTES-ID_PACIENTE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    "auto incremento do id do hospital
    select max( id_paciente )
      from zpacientes
      into id_pct.

    "se houver dados retornados...
    if sy-subrc eq 0.
      add 1 to id_pct. "incrementa o id
    else.
      id_pct = 1. "define o id como o primeiro
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_PACIENTE=>INSERT_PACIENTE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_HOSPITAL                    TYPE        ZHOSPITAIS-ID_HOSPITAL
* | [--->] PACIENTE                       TYPE        ZPACIENTES
* | [--->] CONTACTOS                      TYPE        ZPAC_CONTACTOS
* | [--->] DOCS                           TYPE        ZPAC_DOCS
* | [--->] ENDERECOS                      TYPE        ZPAC_ENDERECOS
* | [--->] INFO                           TYPE        ZPAC_INFOPAC
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_paciente.

    "se nao houver hospital.
    if id_hospital is initial.
      e_result-rc = 1.
      e_result-mensagem = | Escolha um Hospital para Cadastrar o Paciente |.
      return.
    endif.

    "estruturas para receber os valores das estruturas enviadas como parametro
    data: ls_paciente  type zpacientes,
          ls_contactos type zpac_contactos,
          ls_docs      type zpac_docs,
          ls_enderecos type zpac_enderecos,
          ls_info      type zpac_infopac.

    "preenche as estruturas
    ls_paciente  = paciente.
    ls_contactos = contactos.
    ls_docs      = docs.
    ls_enderecos = enderecos.
    ls_info      = info.

    "verifica se alguma das estruturas estao vazias...
    if ls_paciente  is initial or
       ls_contactos is initial or
       ls_docs      is initial or
       ls_enderecos is initial or
       ls_info      is initial.
      e_result-rc = 1.
      e_result-mensagem = | Dados necessários faltam para realizar a operação de cadastro |.
      return.
    endif.

    "verifica se o paciente existe
    zcl_paciente=>check_paciente(
      exporting
        id_hsp   = ls_paciente-id_hospital
        id_pct   = ls_paciente-id_paciente
      importing
        e_result = e_result
    ).

    "se o paciente já existir no sistema
    if e_result-rc eq 1.
      e_result-rc = 1.
      e_result-mensagem = | O Paciente já existe em nosso sistema |.
      return.
    endif.

    "preenche estruturas individualmente.
    ls_paciente-id_paciente    = zcl_paciente=>get_next( ).
    ls_paciente-id_hospital    = id_hospital.
    ls_paciente-alterado_por   = sy-uname.
    ls_paciente-data_alteracao = sy-datum.

    "verifica o ultimo id inserido na tabela
    select max( id_contacto ) from zpac_contactos into ls_contactos-id_contacto.

    if sy-subrc eq 0.
      add 1 to ls_contactos-id_contacto.
      ls_contactos-id_paciente    = ls_paciente-id_paciente.
      ls_contactos-alterado_por   = sy-uname.
      ls_contactos-data_alteracao = sy-datum.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Houve um problema com a obtenção dos dados referente aos contactos do paciente  { ls_paciente-nome_paciente } |.
      return.
    endif.

    "verifica o ultimo id inserido na tabela
    select max( id_documento ) from zpac_docs into ls_docs-id_documento.

    if sy-subrc eq 0.
      add 1 to ls_docs-id_documento.
      ls_docs-id_paciente    = ls_paciente-id_paciente.
      ls_docs-alterado_por   = sy-uname.
      ls_docs-data_alteracao = sy-datum.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Houve um problema com a obtenção dos dados referente aos documentos do paciente  { ls_paciente-nome_paciente } |.
      return.
    endif.

    "verifica o ultimo id inserido na tabela
    select max( id_localizacao ) from zpac_enderecos into ls_enderecos-id_localizacao.

    if sy-subrc eq 0.
      add 1 to ls_enderecos-id_localizacao.
      ls_enderecos-id_paciente    = ls_paciente-id_paciente.
      ls_enderecos-alterado_por   = sy-uname.
      ls_enderecos-data_alteracao = sy-datum.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Houve um problema com a obtenção dos dados referente ao endereço do paciente  { ls_paciente-nome_paciente } |.
      return.
    endif.

    "verifica o ultimo id inserido na tabela
    select max( id_info_paciente ) from zpac_infopac into ls_info-id_info_paciente.

    if sy-subrc eq 0.
      add 1 to ls_info-id_info_paciente.
      ls_info-id_paciente    = ls_paciente-id_paciente.
      ls_info-alterado_por   = sy-uname.
      ls_info-data_alteracao = sy-datum.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Houve um problema com a obtenção dos dados referente às informações do paciente  { ls_paciente-nome_paciente } |.
      return.
    endif.

    "preenche todas as tabelas referentes ao paciente
    insert zpacientes from ls_paciente.
    if sy-subrc eq 0.
      insert zpac_contactos from ls_contactos.
      if sy-subrc eq 0.
        insert zpac_docs from ls_docs.
        if sy-subrc eq 0.
          insert zpac_enderecos from ls_enderecos.
          if sy-subrc eq 0.
            insert zpac_infopac from ls_info.
          else.
            rollback work.
          endif.
        else.
          rollback work.
        endif.
      else.
        rollback work.
      endif.
    else.
      rollback work.
    endif.

    "limpa as estruturas
    clear: ls_paciente, ls_contactos, ls_docs, ls_enderecos, ls_info.

    if sy-subrc eq 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | O Paciente foi cadastrado com sucesso. |.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Não foi possível cadastrar o Paciente. |.
    endif.

  endmethod.
ENDCLASS.
