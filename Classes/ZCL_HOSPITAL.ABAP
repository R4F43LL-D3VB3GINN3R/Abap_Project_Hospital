class ZCL_HOSPITAL definition
  public
  final
  create public .

public section.

  data HOSPITAL type ZHOSPITAIS .

  methods CONSTRUCTOR
    importing
      !ID_HOSPITAL type ZHOSPITAIS-ID_HOSPITAL.
  class-methods INSERT_HOSPITAL
    importing
      !HOSPITAL type ZHOSPITAIS
    exporting
      !E_RESULT type ZAPR_RESULT .
  protected section.
  private section.

    class-methods get_next
      returning
        value(id_hospital) type zhospitais-id_hospital .
ENDCLASS.



CLASS ZCL_HOSPITAL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HOSPITAL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_HOSPITAL                    TYPE        ZHOSPITAIS-ID_HOSPITAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    data: e_result type zapr_result.

    select single * from zhospitais
      into me->hospital
      where id_hospital eq id_hospital.

    if sy-subrc ne 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Não foi encontrado um Hospital com o id { id_hospital } |.
    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_HOSPITAL=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID_HOSPITAL                    TYPE        ZHOSPITAIS-ID_HOSPITAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_next.

    select max( id_hospital ) from zhospitais into id_hospital.
    add 1 to id_hospital.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HOSPITAL=>INSERT_HOSPITAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] HOSPITAL                       TYPE        ZHOSPITAIS
* | [<---] E_RESULT                       TYPE        ZAPR_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method insert_hospital.

    data: ls_hospital type zhospitais.
    ls_hospital = hospital.

    ls_hospital-id_hospital      = zcl_hospital=>get_next( ).
    ls_hospital-data_criacao     = sy-datum.
    ls_hospital-data_modificacao = sy-datum.

    insert zhospitais from hospital.

    if sy-subrc eq 0.
      e_result-rc = sy-subrc.
      e_result-mensagem = | O Hospital foi cadastrado com sucesso. |.
    else.
      e_result-rc = sy-subrc.
      e_result-mensagem = | Não foi possível cadastrar o Hospital. |.
    endif.

  endmethod.
ENDCLASS.
