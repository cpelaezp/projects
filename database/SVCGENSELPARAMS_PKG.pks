CREATE OR REPLACE package ADMSALUD.svcgenselparams_pkg as
    type cur is ref cursor;
    
    procedure svcgenselparams(
        in_param in varchar
      , in_filters in varchar
      , in_order in varchar
      , out_cursor out cur
      );
end svcgenselparams_pkg; 
/

