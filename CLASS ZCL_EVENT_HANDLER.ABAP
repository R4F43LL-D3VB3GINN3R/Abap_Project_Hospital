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
      handle_user_command
        for event user_command of cl_gui_alv_grid
        importing
          e_ucomm,

      handle_hotspot_click
        for event hotspot_click of cl_gui_alv_grid
        importing
          e_row_id
          e_column_id
          es_row_no.

endclass.

class zcl_event_handler implementation.

  method handle_user_command.

  endmethod.

  method handle_hotspot_click.

  endmethod.

endclass.
