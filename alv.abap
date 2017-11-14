*&---------------------------------------------------------------------*
*& Report  Z1275_P008
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z1275_P008.
DATA: BEGIN OF gt_data OCCURS 0,
  rowcolor(4) TYPE c,
  mark,
  pernr LIKE pa0001-pernr, "Personelno
  vorna LIKE pa0002-vorna, "Personelno
  nachn LIKE pa0002-nachn, "Personelno
  begda LIKE pa0001-begda, "Başlangıç Tar.
  endda LIKE pa0001-endda, "Bitiş Tar.
  kostl LIKE pa0001-kostl, "Masraf Yeri
  orgeh LIKE pa0001-orgeh, "ORganizasyon
  stell LIKE pa0001-stell, "İş Alanı
  gesch LIKE pa0002-gesch, "Cinsiyet
  lga01 LIKE pa0008-lga01, "İş Alanı Anahtarı
  bet01 LIKE pa0008-bet01, "Maaş Tutarı
END OF gt_data.
data:gt_pernr like TABLE OF pa0001-pernr WITH HEADER LINE.
data: gt_fieldcat type SLIS_T_FIELDCAT_ALV,
      gs_fieldcat type SLIS_FIELDCAT_ALV.
data: gs_layout type SLIS_LAYOUT_ALV.
PERFORM getdata.
PERFORM fieldmerge.
PERFORM fieldcat.
PERFORM layout.
PERFORM alvgrid.
*&---------------------------------------------------------------------*
*&      Form  GETDATA
*&---------------------------------------------------------------------*
*       datalar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETDATA .
SELECT DISTINCT pernr
  INTO TABLE gt_pernr
  from pa0001.

  LOOP AT gt_pernr.
   SELECT SINGLE *
     INTO CORRESPONDING FIELDS OF gt_data
     from pa0001
     LEFT OUTER JOIN pa0002 on pa0002~pernr EQ pa0001~pernr
     LEFT OUTER JOIN pa0008 on pa0008~pernr EQ pa0001~pernr
     WHERE pa0001~pernr EQ gt_pernr.
     APPEND gt_data.

  ENDLOOP.

ENDFORM.                    " GETDATA
*&---------------------------------------------------------------------*
*&      Form  FIELDMERGE
*&---------------------------------------------------------------------*
*       FİELD MERGE FONKSİYONU
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDMERGE .
CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
 EXPORTING
   I_PROGRAM_NAME               = sy-repid
   I_INTERNAL_TABNAME           = 'GT_DATA'
*   I_STRUCTURE_NAME             =
*   I_CLIENT_NEVER_DISPLAY       = 'X'
   I_INCLNAME                   = sy-repid
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
  CHANGING
    CT_FIELDCAT                  = gt_fieldcat
* EXCEPTIONS
*   INCONSISTENT_INTERFACE       = 1
*   PROGRAM_ERROR                = 2
*   OTHERS                       = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.                    " FIELDMERGE
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
*       fieldcat ayarları
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDCAT .
LOOP AT gt_fieldcat INTO gs_fieldcat.
   IF gs_fieldcat-fieldname EQ 'BET01'.
     gs_fieldcat-do_sum = 'X'.
      gs_fieldcat-edit = 'X'.
     MODIFY gt_fieldcat FROM gs_fieldcat.

   ENDIF.
 ENDLOOP.
ENDFORM.                    " FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       layout ayarları
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT .
gs_layout-zebra = 'X'.
gs_layout-box_fieldname = 'MARK'.
gs_layout-info_fieldname = 'ROWCOLOR'.
ENDFORM.       " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  ALVGRID
*&---------------------------------------------------------------------*
*       alv basımı
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALVGRID .
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = sy-repid
   I_CALLBACK_PF_STATUS_SET          = 'GUI_STATUS'
   I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         = gs_layout
   IT_FIELDCAT                       = gt_fieldcat
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = gt_data
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.                    " ALVGRID
 FORM gui_status USING rt_extab TYPE slis_t_extab.
   set PF-STATUS 'ZGUI'.
   ENDFORM. "GUİ
 FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
   data: ls_data LIKE LINE OF gt_data.
   BREAK-POINT.
  CASE r_ucomm .
    WHEN '&SAVE'.
     DATA: lv_value(60) type c.

     IF rs_selfield-SEL_TAB_FIELD EQ 'GT_DATA-BET01'.

       READ TABLE gt_data INTO ls_data INDEX rs_selfield-tabindex.
       lv_value = rs_selfield-value.
       REPLACE ',' WITH '.'
            INTO lv_value.
     ls_data-bet01 = lv_value.
     ls_data-mark ='X'.
     ls_data-rowcolor ='C410'.


     MODIFY gt_data from ls_data index rs_selfield-tabindex.

     IF SY-SUBRC EQ 0.
       MESSAGE 'kaydedildi' TYPE 'I'.

     ENDIF.
     else.
       MESSAGE 'lütfen tutar satırını seçiniz' type 'I'.


     ENDIF.

      rs_selfield-refresh = 'X'.




  ENDCASE.


  ENDFORM.