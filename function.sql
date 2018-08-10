CREATE OR REPLACE FUNCTION STUDENT4.predict_3_5_func (
    p_id_user        NUMBER,
    p_id_thing       NUMBER,
    p_id_order       NUMBER,
    p_status     OUT NUMBER,
    p_message    OUT VARCHAR2)
    RETURN CLOB
IS
    v_return_clob   CLOB;
BEGIN
    apex_json.free_output;
    apex_json.initialize_clob_output;
    apex_json.open_array ('things');

    FOR i
        IN (SELECT c.id_thing, t.NAME_THING, t.PRICE_thing
              FROM student4.Carts  c
                   JOIN student4.things t ON t.ID_THING = c.ID_THING
             WHERE     c.id_order IN
                           (SELECT c.id_order
                              FROM student4.carts  c
                                   JOIN student4.orders o
                                       ON o.ID_ORDER = c.ID_ORDER
                             WHERE     c.id_thing = p_id_thing
                                   AND c.id_order <> p_id_order
                                   AND c.del_date IS NULL
                                   AND o.ID_USER <> p_id_user)
                   AND c.id_thing <> p_id_thing
                   AND c.del_date IS NULL
                   AND t.del_date IS NULL)
    LOOP
        apex_json.open_object ();
        apex_json.write ('id', i.id_thing);
        apex_json.write ('name_thing', i.NAME_THING);
        apex_json.write ('price_thing', i.PRICE_thing);
        apex_json.close_object ();
    END LOOP;

    apex_json.close_array ();
    v_return_clob := apex_json.get_clob_output;
    apex_json.free_output;
    p_status:=0;
    p_message:='Все гуд!';
    RETURN v_return_clob;

    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            p_status:=1;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.predict_3_5_func',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN null;
END;
/* */
/


GRANT EXECUTE ON STUDENT4.PREDICT_3_5_FUNC TO JKH
/
