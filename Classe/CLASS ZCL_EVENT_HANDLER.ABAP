*----------------------------------------------------------------------*
***INCLUDE ZCL_EVENT_HANDLER.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class zcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
class zcl_event_handler definition final.

  public section.

    methods:

      "metodo para mudanca de evento ao duplo clique
      handle_hotspot_click
        for event hotspot_click of cl_gui_alv_grid
        importing
          e_row_id
          e_column_id
          es_row_no,

      "metodo para registar alteracoes feitas diretamente na celula
      handle_data_changed
        for event data_changed of cl_gui_alv_grid
        importing
          er_data_changed.

endclass.

class zcl_event_handler implementation.

  method handle_hotspot_click.
    perform handle_hotspot_click using e_row_id e_column_id es_row_no.
  endmethod.

  method handle_data_changed.
    perform handle_data_changed using er_data_changed.
  endmethod.

endclass.
