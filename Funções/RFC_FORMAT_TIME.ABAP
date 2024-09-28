FUNCTION RFC_FORMAT_TIME.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(TIME) TYPE  DATUM DEFAULT SY-DATUM
*"     REFERENCE(HOUR) TYPE  UZEIT DEFAULT SY-UZEIT
*"  EXPORTING
*"     REFERENCE(TIME_OUTPUT) TYPE  STRING
*"     REFERENCE(HOUR_OUTPUT) TYPE  STRING
*"----------------------------------------------------------------------

"-----------------------------------------------------------------------
"HORA

    data: hrs type string,
          min type string,
          sec type string.

    hrs = hour+0(2).
    min = hour+2(2).
    sec = hour+4(2).

    hour_output = hrs && ':' && min && ':' && sec. "nova hora

    if hour_output is initial.
      hour_output = sy-uzeit.
    endif.

"-----------------------------------------------------------------------
"DATA

    data: year  type string,
          month type string,
          day   type string.

    year  = time+0(4).
    month = time+4(2).
    day   = time+6(2).

    time_output = day && '.' && month && '.' && year. "nova data

    if time_output is initial.
      time_output = sy-datum.
    endif.

ENDFUNCTION.
