CREATE OR REPLACE PROCEDURE STUDENT4.predict_3_5 
(
--user+
 p_id_thing number,
 p_id_order number,
 p_return_curs OUT sys_refcursor,
 p_status OUT number
)
IS

BEGIN
   open p_return_curs for 
   select 
    id_thing  
   from 
    Carts 
   where 
    id_order in 
    (select 
        id_order 
     from 
        carts 
     where 
        id_thing = p_id_thing and id_order <> p_id_order and del_date is null) 
    and id_thing <> p_id_thing and del_date is null;
    p_status:=0;
END predict_3_5;
/
CREATE OR REPLACE PROCEDURE STUDENT4.add_logs
(
 p_function varchar2,
 p_text_err varchar2
)

as

begin
    insert into STUDENT4.logs (function_err,text_err) values (p_function,p_text_err);
    
end;
/


GRANT EXECUTE ON STUDENT4.ADD_LOGS TO STUDENT1
/

GRANT EXECUTE ON STUDENT4.ADD_LOGS TO STUDENT2
/

GRANT EXECUTE ON STUDENT4.ADD_LOGS TO STUDENT3
/
