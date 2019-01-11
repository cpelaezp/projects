CREATE OR REPLACE package ADMSALUD.svcpreprccopiacups_pkg as
    type cur is ref cursor;
    
    procedure svcpreprcinscopia(
        in_accion                  in varchar2
      , in_pre_prc_id              in number
      , in_pre_pre_codigo          in varchar2
      , in_pre_pre_descripcio      in varchar2
      , in_pre_pre_codigo_new      in varchar2
      , in_pre_pre_descripcio_new  in varchar2
      --, in_pre_prc_resumen         in varchar2
      , out_pre_prc_id             out varchar2
      , out_error                  out number
      , out_message                out varchar2
      );

    procedure svcpreprcselcopia(
        in_filters in varchar
      , in_order in varchar
      , out_cursor out cur
      );
      
    procedure svcpreprccopiar(
        in_pre_prc_id              in number
      , out_error                  out number
      , out_message                out varchar2
      , out_cursor out cur
      );
end svcpreprccopiacups_pkg; 
/

