CREATE OR REPLACE package ADMSALUD.svcpreselwcups_pkg as
    type cur is ref cursor;
    
    procedure svcpreselwcups(
        in_filters in varchar
      , in_order in varchar
      , out_cursor out cur
      );
end svcpreselwcups_pkg; 
/

