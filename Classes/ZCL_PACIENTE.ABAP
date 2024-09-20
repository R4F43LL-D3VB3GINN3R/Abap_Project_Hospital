class zcl_paciente definition
  public
  final
  create public .

  public section.

    types: begin of wa_pct,
             id_paciente         type zpacientes-id_paciente,
             id_hospital         type zpacientes-id_hospital,
             id_contacto         type zpac_contactos-id_contacto,
             id_documento        type zpac_docs-id_documento,
             id_localizacao      type zpac_enderecos-id_localizacao,
             id_info_paciente    type zpac_infopac-id_info_paciente,
             nome_paciente       type zpacientes-nome_paciente,
             sexo                type zpacientes-sexo,
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
           end of wa_pct.

    data: paciente  type zpacientes,
          contactos type zpac_contactos,
          docs      type zpac_docs,
          enderecos type zpac_enderecos,
          info      type zpac_infopac,
          it_pct    type table of wa_pct,
          ls_pct    type wa_pct.

    methods constructor
      importing
        !id_paciente type zpacientes-id_paciente
      exceptions
        invalid_pct .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_PACIENTE IMPLEMENTATION.


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

    "retorna a excessao caso nao tenha achado a linha
    if sy-subrc ne 0.
      raise invalid_pct.
      return.
    endif.

    "seleciona todas as informacoes adjascentes ao paciente.
    select single * from zpac_contactos into contactos where id_paciente eq id_paciente.
    select single * from zpac_docs      into docs      where id_paciente eq id_paciente.
    select single * from zpac_enderecos into enderecos where id_paciente eq id_paciente.
    select single * from zpac_infopac   into info      where id_paciente eq id_paciente.

    "preenche a estrutura personalizada do paciente
    SELECT SINGLE
       p~id_paciente,
       p~id_hospital,
       c~id_contacto,
       d~id_documento,
       e~id_localizacao,
       i~id_info_paciente,
       p~nome_paciente,
       p~sexo,
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
     FROM zpacientes AS p
     INNER JOIN zpac_contactos AS c ON p~id_paciente = c~id_paciente
     INNER JOIN zpac_docs      AS d ON p~id_paciente = d~id_paciente
     INNER JOIN zpac_enderecos AS e ON p~id_paciente = e~id_paciente
     INNER JOIN zpac_infopac   AS i ON p~id_paciente = i~id_paciente
     INTO CORRESPONDING FIELDS OF @ls_pct
     WHERE p~id_paciente = @id_paciente.


  endmethod.
ENDCLASS.
