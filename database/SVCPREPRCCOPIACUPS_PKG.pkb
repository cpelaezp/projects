CREATE OR REPLACE package body ADMSALUD.svcpreprccopiacups_pkg as
    
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
      ) as
      
      v_pre_prc_id number;
      v_exists number := 0;
      v_procesado number := 0;
    begin
        out_error := -1;
        out_message := '[svcpreprcinscopia]';
        out_pre_prc_id := 0;
        
        begin
            select 1 
                 , PRE_PRC_PROCESADO
              into v_exists, v_procesado 
              from pre_prc_copia 
              where pre_prc_id = in_pre_prc_id
              ;
                                      
            exception 
              when others then 
                v_exists := 0;  
        end;   
            
        if v_procesado = 1 then 
        begin
            out_error := 9;
            out_message := 'Error, [svcpreprcinscopia] No puede modificar el ID [' || in_pre_prc_id || '], fue procesado';     
        end;
        elsif in_accion = 'I' then            
        begin            
            if v_exists = 0 then
            begin
                begin
                    select nvl(max(pre_prc_id), 0) + 1 
                      into v_pre_prc_id
                      from pre_prc_copia
                      ;
                    
                    exception
                      when others then
                        v_pre_prc_id := 1;  
                end;      
              
                insert into pre_prc_copia (pre_prc_id, pre_pre_codigo, pre_pre_descripcio, pre_pre_codigo_new, pre_pre_descripcio_new)
                  values (v_pre_prc_id, in_pre_pre_codigo, in_pre_pre_descripcio, in_pre_pre_codigo_new, in_pre_pre_descripcio_new)
                  ;

                  out_error := 0;
                  out_message := 'OK, [svcpreprcinscopia] se ingreso registro [' || v_pre_prc_id || ']'; 
                  out_pre_prc_id := v_pre_prc_id;  
                
                exception
                    when others then
                      out_error := 9;
                      out_message := 'Error, [svcpreprcinscopia] problemas al insertar, ' || sqlerrm;
            end;
            else
            begin   
                update pre_prc_copia
                  set pre_pre_codigo         = in_pre_pre_codigo
                    , pre_pre_descripcio     = in_pre_pre_descripcio
                    , pre_pre_codigo_new     = in_pre_pre_codigo_new
                    , pre_pre_descripcio_new = in_pre_pre_descripcio_new
                  where pre_prc_id = in_pre_prc_id 
                  ;
                  
                  out_error := 0;
                  out_message := 'OK, [svcpreprcinscopia] se actualizo registro [' || in_pre_prc_id || ']'; 
                  out_pre_prc_id := in_pre_prc_id;  
                  
                exception
                    when others then
                      out_error := 9;
                      out_message := 'Error, [svcpreprcinscopia] problemas al actualizar, ' || sqlerrm;      
            end;
            end if;
        end;
        /*elsif in_accion = 'P' then            
        begin            
            if v_exists = 1 then
            begin
                update pre_prc_copia
                  set pre_prc_procesado   = 1
                    , pre_prc_resumen     = in_pre_prc_resumen
                    , pre_prc_prcusuario  = user
                    , pre_prc_fecprc      = sysdate
                  where pre_prc_id = in_pre_prc_id 
                  ;
                  
                  out_error := 0;
                  out_message := 'OK, [svcpreprcinscopia] se proceso registro [' || in_pre_prc_id || ']'; 
                  
                exception
                    when others then
                      out_error := 9;
                      out_message := 'Error, [svcpreprcinscopia] problemas al procesar, ' || sqlerrm;    
            end;
            end if;
        end;
        */elsif in_accion = 'D' then
        begin
            delete from pre_prc_copia
              where pre_prc_id = in_pre_prc_id
              ;
              
            out_error := 0;
            out_message := 'OK, [svcpreprcinscopia] se elimino registro [' || in_pre_prc_id || ']';   
            
            exception
              when others then
                  out_error := 9;
                  out_message := 'Error, [svcpreprcinscopia] error generenal, ' || sqlerrm;
        end;
        end if; 
        
        dbms_output.put_line(out_error || ' ' || out_message);
    end svcpreprcinscopia;  

 
    procedure svcpreprcselcopia(
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
            v_select := 'select c.*, p1.pre_pre_tipo pre_pre_tipo1, pt1.pre_tip_descripcio pre_tip_descripcio1, p1.pre_pre_subtipo pre_pre_subtipo1, pst1.pre_sub_descripcio pre_sub_descripcio1
                                , p2.pre_pre_tipo pre_pre_tipo2, pt2.pre_tip_descripcio pre_tip_descripcio2, p2.pre_pre_subtipo pre_pre_subtipo2, pst2.pre_sub_descripcio pre_sub_descripcio2
                                ';
            v_from := chr(10) || 
                       'from pre_prc_copia c
                         , pre_prestacion p1
                         , pre_prestacion p2
                         , pre_tipo pt1
                         , pre_tipo pt2
                         , pre_subtipo pst1
                         , pre_subtipo pst2';
        
                v_where := chr(10) || 
                           'where c.pre_pre_codigo     = p1.pre_pre_codigo
                              and c.pre_pre_codigo_new = p2.pre_pre_codigo (+)
                              and p1.pre_pre_tipo      = pt1.pre_tip_tipo 
                              and p1.pre_pre_tipo      = pst1.pre_tip_tipo
                              and p1.pre_pre_subtipo   = pst1.pre_sub_subtipo  
                              and p2.pre_pre_tipo      = pt2.pre_tip_tipo (+)
                              and p2.pre_pre_tipo      = pst2.pre_tip_tipo (+)
                              and p2.pre_pre_subtipo   = pst2.pre_sub_subtipo (+)
                            ';
                                  
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
                       v_tag := regexp_substr (i.filtro, '[^|]+', 1, 1);
                       v_filtro := regexp_substr (i.filtro, '[^|]+', 1, 2);
                       dbms_output.put_line('v_campo:'||v_campo||', v_filtro:'||v_filtro);
                       
                       v_where := replace(v_where, v_campo, v_filtro);
                   end; 
                   else
                   begin
                        v_symbol := regexp_substr (i.filtro, '[^|]+', 1, 1);
                        v_tipocampo := regexp_substr (i.filtro, '[^|]+', 1, 2);
                        
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
                        
                        v_campo := regexp_substr (i.filtro, '[^|]+', 1, 3);
                        v_valor := regexp_substr (i.filtro, '[^|]+', 1, 4);
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
    
    procedure svcpreprccopiar(
        in_pre_prc_id              in number
      , out_error                  out number
      , out_message                out varchar2
      , out_cursor out cur
      ) as
      
      v_querylog varchar2(500) := 'select * from pre_prc_copiadetalle';
    begin
        out_error := -1;
        out_message := '[svcpreprccopiar]';
        
        
        
        out_error := 0;
        out_message := '[svcpreprccopiar]';
        open out_cursor for v_querylog;
        
        exception
          when others then
            open out_cursor for v_querylog;
    end svcpreprccopiar;  
end svcpreprccopiacups_pkg; 
/

