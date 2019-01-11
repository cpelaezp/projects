CREATE OR REPLACE package body ADMSALUD.svcpreselwcups_pkg as
    procedure svcpreselwcups(
        in_filters in varchar
      , in_order in varchar
      , out_cursor out cur
      ) as
      
      v_select varchar2(2000);
      v_from varchar2(2000);
      v_where varchar2(2000);
      v_orderby varchar2(2000);
      
      v_count_items number;
      v_filtro varchar2(200);
      v_campo varchar2(200);
      v_valor varchar2(200);
      v_tag varchar2(200);
      v_tipocampo varchar2(1);
      v_condicion varchar2(50);
      v_symbol varchar2(10);
      
    begin
        begin -- forma sql 
            v_select := 'select * ';
            v_from := chr(10) || 
                       'from pre_prestacion p
                         , pre_tipo pt
                         , pre_subtipo pst
                         , TAB_PatCatastroficas tc
                         , PRE_Pabellon pb';
        
                v_where := chr(10) || 
                           'where p.pre_pre_tipo = PT.PRE_TIP_TIPO
                                and p.pre_pre_tipo = PST.PRE_TIP_TIPO
                                and P.PRE_PRE_SUBTIPO = PST.PRE_SUB_SUBTIPO
                                and P.PRE_PRE_CATASTROFICA = TC.PATCATASTROFICACODIGO (+)
                                and P.PATCATASTROFICACODIGO = PB.PRE_PAB_CODIGO (+)
                            ';
                                  
--                                and (trim(''{in_pre_pre_codigo}'') is null or (trim(''{in_pre_pre_codigo}'') is not null and p.pre_pre_codigo like ''%{in_pre_pre_codigo}%'') )
--                                and (trim(''{in_pre_pre_descripcio}'') is null or (trim(''{in_pre_pre_descripcio}'') is not null and p.pre_pre_descripcio like ''%{in_pre_pre_descripcio}%'') )
--                                and (trim(''{in_pre_pre_tipo}'') is null or (trim(''{in_pre_pre_tipo}'') is not null and p.pre_pre_tipo like ''%{in_pre_pre_tipo}%'') )
--                                and (trim(''{in_pre_pre_subtipo}'') is null or (trim(''{in_pre_pre_subtipo}'') is not null and p.pre_pre_subtipo like ''%{in_pre_pre_subtipo}%'') )
--                                and (trim(''{in_pre_pre_CATASTROFICA}'') is null or (trim(''{in_pre_pre_CATASTROFICA}'') is not null and p.pre_pre_CATASTROFICA like ''%{in_pre_pre_CATASTROFICA}%'') )
--                                and (trim(''{in_PATCATASTROFICACODIGO}'') is null or (trim(''{in_PATCATASTROFICACODIGO}'') is not null and p.PATCATASTROFICACODIGO like ''%{in_PATCATASTROFICACODIGO}%'') )
--                                ';
                
            if trim(in_filters) is not null then
            begin -- forma filtros y orden
                dbms_output.put_line('filtros:'||in_filters);
                -- recorre filtros
                for i in
                  (select trim(regexp_substr(in_filters, '[^,]+', 1, level)) filtro
                  from dual connect by level <= regexp_count(in_filters, ',')+1
                  )
                loop
                   dbms_output.put_line('filtro:'||i.filtro);
                   
                   select regexp_count(i.filtro, ',') + 1 into v_count_items from dual;
 
                   if v_count_items = 2 then
                   begin 
                       -- forma filtro 
                       v_tag := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 1);
                       v_filtro := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 2);
                       dbms_output.put_line('v_campo:'||v_campo||', v_filtro:'||v_filtro);
                       
                       v_where := replace(v_where, v_campo, v_filtro);
                   end; 
                   else
                   begin
                        v_symbol := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 1);
                        v_tipocampo := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 2);
                        
                        if v_tipocampo = 'N' then
                            v_filtro := 'and (trim(''{valor}'') is null or (trim(''{valor}'') is not null and {condicion}) )';
                        elsif v_tipocampo = 'D' then
                            v_filtro := 'and (trim(''{valor}'') is null or (trim(''{valor}'') is not null and {condicion}) )';
                        else 
                            v_filtro := 'and (trim(''{valor}'') is null or (trim(''{valor}'') is not null and {condicion}) )';
                        end if;
                        
                        if v_symbol    = 'EQ' then
                            v_condicion := '{campo} = ''{valor}''';
                        elsif v_symbol = 'LK' then
                            v_condicion := '{campo} like ''%{valor}%''';
                        elsif v_symbol = 'IN' then
                            v_condicion := '{campo} like ''%{valor}%''';
                        end if;
                        
                        v_campo := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 3);
                        v_valor := REGEXP_SUBSTR (i.filtro, '[^|]+', 1, 4);
                        dbms_output.put_line('v_campo:'||v_campo||', v_valor:'||v_valor);
                                                
                        v_filtro := replace(v_filtro, '{condicion}', v_condicion);
                        v_filtro := replace(v_filtro, '{campo}', v_campo);
                        v_filtro := replace(v_filtro, '{valor}', v_valor);
                        dbms_output.put_line('v_filtro:'||v_filtro);
                        
                        v_where := v_where || chr(10) || v_filtro;
                   end;
                   end if;    
                end loop;
                
            end;
            end if;
        end;
        
        dbms_output.put_line('sql: '||v_select || v_from || v_where || v_orderby);
        open out_cursor for v_select || v_from || v_where || v_orderby;
        
            
    end;  
end svcpreselwcups_pkg; 
/

