CREATE OR REPLACE package body ADMSALUD.svcgenselparams_pkg as
    procedure svcgenselparams(
        in_param in varchar
      , in_filters in varchar
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
            if    in_param = 'PRE_TIPO' then
            begin
                v_select := 'select pre_tip_tipo PARAM_CODIGO, pre_tip_descripcio PARAM_DESCRIPCION';
                v_from := chr(10) || 'from pre_tipo p';
                v_where := chr(10) || 'where 1 = 1 ';
            end;
            elsif in_param = 'PRE_SUBTIPO' then
            begin
                v_select := 'select pre_sub_subtipo PARAM_CODIGO, pre_sub_descripcio PARAM_DESCRIPCION';
                v_from := chr(10) || 'from pre_tipo p';
                v_where := chr(10) || 'where 1 = 1 ';
            end;
            elsif in_param = 'TAB_PATCATASTROFICAS' then
            begin
                v_select := 'select patcatastroficacodigo param_codigo, patcatastroficanombre param_descripcion';
                v_from := chr(10) || 'from tab_patcatastroficas p';
                v_where := chr(10) || 'where 1 = 1 ';
            end;
            elsif in_param = 'PRE_PABELLON' then
            begin
                v_select := 'select pre_pab_codigo PARAM_CODIGO, pre_pab_descripcio PARAM_DESCRIPCION';
                v_from := chr(10) || 'from pre_pabellon p';
                v_where := chr(10) || 'where 1 = 1 ';
            end;
            end if;
        
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
end svcgenselparams_pkg; 
/

