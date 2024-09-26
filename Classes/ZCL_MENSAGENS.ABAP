class ZCL_MENSAGENS definition
  public
  final
  create public .

public section.

  class-data LS_MSG type ZHISTORICO_PCT .

  class-methods SET_MSG
    importing
      !ID_PCT type ZPACIENTES-ID_PACIENTE
      !MENSAGEM type ZAPR_RESULT-MENSAGEM
      !DATA_MSG type ZHISTORICO_PCT-DATA_MSG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MENSAGENS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MENSAGENS=>SET_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PCT                         TYPE        ZPACIENTES-ID_PACIENTE
* | [--->] MENSAGEM                       TYPE        ZAPR_RESULT-MENSAGEM
* | [--->] DATA_MSG                       TYPE        ZHISTORICO_PCT-DATA_MSG
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_MSG.

    "auto incremento da chave de identificacao das mensagens
    data: id_num type zhistorico_pct-id_msg.

    select max( id_msg )
      from zhistorico_pct
      into id_num.

    if id_num is initial.
      ls_msg-id_msg = id_num = 1.
    else.
      add 1 to id_num.
      ls_msg-id_msg = id_num.
    endif.

    "o resto da estrutura recebe os parametros
    ls_msg-id_paciente = id_pct.
    ls_msg-mensagem    = mensagem.
    ls_msg-data_msg    = data_msg.

    "verifica se algum parametro foi enviado como vazio
    if ls_msg-id_paciente is initial
      or ls_msg-mensagem is initial
      or ls_msg-data_msg is initial.
      return.
    endif.

    "se tudo estiver ok, insere na base de dados.
    insert zhistorico_pct from ls_msg.

  endmethod.
ENDCLASS.
