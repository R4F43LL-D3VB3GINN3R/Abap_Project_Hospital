*----------------------------------------------------------------------*
***INCLUDE ZCL_ITAB_TO_EXCEL.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class zcl_itab_to_excel
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
class zcl_itab_to_excel definition.
  public section.
    methods:
      itab_to_xstring
        importing
          ir_data_ref       type ref to data
        returning
          value(rv_xstring) type xstring.
endclass.

class zcl_itab_to_excel implementation.
  method itab_to_xstring.

    field-symbols: <fs_data> type any table.
    clear rv_xstring.
    assign ir_data_ref->* to <fs_data>.

    try.
        " Criação da instância SALV Table
        cl_salv_table=>factory(
          importing r_salv_table = data(lo_table)
          changing  t_table      = <fs_data> ).

        " Obtenção do field catalog (catálogo de campos)
        data(lt_fcat)    = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
          r_columns      = lo_table->get_columns( )
          r_aggregations = lo_table->get_aggregations( ) ).

        " Criação do resultado para a exportação
        data(lo_result)  = cl_salv_ex_util=>factory_result_data_table(
          r_data         = ir_data_ref
          t_fieldcatalog = lt_fcat ).

        " Transformação dos dados para formato XML (XLSX)
        cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
          exporting
            xml_type      = if_salv_bs_xml=>c_type_xlsx
            xml_version   = cl_salv_bs_a_xml_base=>get_version( )
            r_result_data = lo_result
            xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
            gui_type      = if_salv_bs_xml=>c_gui_type_gui
          importing
            xml           = rv_xstring ).

      catch cx_root.
        clear rv_xstring.
    endtry.

  endmethod.
endclass.
