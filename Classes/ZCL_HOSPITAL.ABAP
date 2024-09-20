class ZCL_HOSPITAL definition
  public
  final
  create public .

public section.

  data HOSPITAL type ZHOSPITAIS .

  methods CONSTRUCTOR
    importing
      !ID_HOSPITAL type ZHOSPITAIS-ID_HOSPITAL .
  class-methods INSERT_HOSPITAL
    importing
      !HOSPITAL type ZHOSPITAIS
    exporting
      !E_RESULT type ZAPR_RESULT .
  class-methods EDIT_HOSPITAL
    importing
      !HOSPITAL type ZRLA_HOSPITAL
    exporting
      !E_RESULT type ZAPR_RESULT .
  protected section.
  private section.

    class-methods get_next
      returning
        value(id_hosp) type zhospitais-id_hospital .
    class-methods check_hospital
      importing
        !nif_hospital type zhospitais-nif
      exporting
        !e_result     type zapr_result .
ENDCLASS.



CLASS ZCL_HOSPITAL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_HOSPITAL=>CHECK_HOSPITAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] NIF_HOSPITAL                   TYPE        ZHOSPITAIS-NIF
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method check_hospital.

    data lv_nif_hospital type zhospitais-nif. "nif
    lv_nif_hospital = nif_hospital. "recebe o nif enviado

    "procura o nif na tabela
    select single nif
      from zhospitais
      into lv_nif_hospital
      where nif eq lv_nif_hospital.

    "se for achado o nif na base de dados
    if sy-subrc eq 1 or lv_nif_hospital eq '000000000'.
      e_result-rc = 1.
      e_result-mensagem = | O Hospital já existe no sistema. |.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HOSPITAL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_HOSPITAL                    TYPE        ZHOSPITAIS-ID_HOSPITAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    data: e_result type zapr_result.

    "seleciona um hospital referente ao id enviado
    select single * from zhospitais
      into me->hospital
      where id_hospital eq id_hospital.

    "se nao houver um id relacionado...
    if sy-subrc ne 0.
      hospital-id_hospital = zcl_hospital=>get_next( ).
      hospital-nome_hospital    = 'unamed'.
      hospital-nif              = '000000000'.
      hospital-morada           = 'anywhere'.
      hospital-codigo_postal    = '00000000'.
      hospital-telefone         = '000000000'.
      hospital-email_contacto   = 'noemail'.
      hospital-tipo_hospital    = 'unknow'.
      hospital-capacidade_cama  = '0'.
      hospital-especialidades   = 'unknow'.
      hospital-data_fundacao    = '00000000'.
      hospital-diretor_resp     = 'unamed'.
      hospital-data_criacao     = '00000000'.
      hospital-data_modificacao = '00000000'.
      hospital-alterado_por     = 'uname'.
      hospital-status           = 'X'.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HOSPITAL=>EDIT_HOSPITAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] HOSPITAL                       TYPE        ZRLA_HOSPITAL
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method edit_hospital.

    data: id_hosp type zhospitais-id_hospital,            "id do hospital
          ls_hosp type zhospitais,                        "estrutura do hospital
          data_criacao_hosp type zhospitais-data_criacao, "data_criacao
          nif_hosp type zhospitais-nif.                   "nif

    "procura o id do hospital e a data de criacao do mesmo
    select single id_hospital
                  data_criacao
                  nif
      from zhospitais
      into ( id_hosp, data_criacao_hosp, nif_hosp )
      where nif eq hospital-nif.

    "metodo para validar se hospital existe.
    zcl_hospital=>check_hospital(
      exporting
        nif_hospital = nif_hosp         " Caractere 9
      importing
        e_result     = e_result         " Estrutura de resultados de operações
    ).

    "se nao for encontrado
    if sy-subrc ne 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | O Hospital { hospital-nome_hospital } não existe no cadasttro. |.
      return.
    else.
      ls_hosp = hospital. "estrutura recebe o valor da estrutura
      ls_hosp-id_hospital = id_hosp. "recebe o id obtido da consulta.
      ls_hosp-data_criacao = data_criacao_hosp. "recebe a data de criacao
      ls_hosp-data_modificacao = sy-datum. "atualiza a data de modificacao
      ls_hosp-status = hospital-status. "recebe o status
      ls_hosp-alterado_por = sy-uname. "recebe o nome no sistema
    endif.

    update zhospitais from ls_hosp. "atualiza o hospital

    if sy-subrc ne 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Não foi possível atualizar as informações do Hospital { hospital-nome_hospital }. |.
      return.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | As informações do Hospital { hospital-nome_hospital } foram atualizadas. |.
      return.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_HOSPITAL=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID_HOSP                        TYPE        ZHOSPITAIS-ID_HOSPITAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    "auto incremento do id do hospital
    select max( id_hospital ) from zhospitais into id_hosp.

    "se houver dados retornados...
    if sy-subrc eq 0.
      add 1 to id_hosp. "incrementa o id
    else.
      id_hosp = 1. "define o id como o primeiro
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HOSPITAL=>INSERT_HOSPITAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] HOSPITAL                       TYPE        ZHOSPITAIS
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_hospital.

    data: ls_hospital type zhospitais.
    ls_hospital = hospital. "recebe a estrutura enviada

    "metodo para validar se hospital existe.
    zcl_hospital=>check_hospital(
      exporting
        nif_hospital = ls_hospital-nif     " Caractere 9
      importing
        e_result     = e_result         " Estrutura de resultados de operações
    ).

    "se nao houver um hospital com o mesmo nif...
    if e_result-rc ne 1.

      ls_hospital-id_hospital      = zcl_hospital=>get_next( ). "recebe o auto incremento do id
      ls_hospital-data_criacao     = sy-datum.                  "recebe a data de hoje
      ls_hospital-data_modificacao = sy-datum.                  "recebe a data de hoje
      ls_hospital-alterado_por     = sy-uname.                  "recebe username

      insert zhospitais from ls_hospital. "insere a estrutura na base de dados
      clear ls_hospital.

      if sy-subrc eq 0.
        e_result-rc = sy-subrc.
        e_result-mensagem = | O Hospital foi cadastrado com sucesso. |.
      else.
        e_result-rc = sy-subrc.
        e_result-mensagem = | Não foi possível cadastrar o Hospital. |.
      endif.

    endif.

  endmethod.
ENDCLASS.
