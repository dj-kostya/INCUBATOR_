CREATE OR REPLACE PACKAGE BODY STUDENT4.THING_3_1
AS
    FUNCTION "GET_THING_3_1_1" (p_message OUT VARCHAR2, p_status OUT NUMBER)
        RETURN SYS_REFCURSOR
    IS
        v_return   SYS_REFCURSOR;
    BEGIN
        OPEN v_return FOR SELECT NAME_THING, PRICE_THING
                            FROM student4.THINGS
                           WHERE DEL_DATE IS NULL;

        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN v_return;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END;

    FUNCTION GET_THING_3_1_1_PIPE (p_message   OUT VARCHAR2,
                                   p_status    OUT NUMBER)
        RETURN t_THING_table
        PIPELINED
    AS
        v_rec   t_THING_record;
    BEGIN
        FOR i IN (SELECT id_thing, NAME_THING, PRICE_THING
                    FROM student4.THINGS
                   WHERE DEL_DATE IS NULL)
        LOOP
            v_rec := t_THING_record (i.NAME_THING, i.id_thing, i.PRICE_THING);
            PIPE ROW (v_rec);
        END LOOP;

        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1_pipe',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1_pipe',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN;
    END;

    FUNCTION "GET_THING_3_1_1_JSON" (p_message   OUT VARCHAR2,
                                     p_status    OUT NUMBER)
        RETURN CLOB
    IS
        v_table          CLOB;
        v_sum_quantity   NUMBER;
    BEGIN
        apex_json.free_output;
        apex_json.initialize_clob_output;
        apex_json.open_object ();
        apex_json.open_array ('THINGS');

        FOR i IN (SELECT id_thing, NAME_THING, PRICE_THING
                    FROM student4.THINGS
                   WHERE DEL_DATE IS NULL)
        LOOP
            apex_json.open_object ();
            apex_json.write ('Id', i.id_thing);
            apex_json.write ('NAME', i.NAME_THING);
            apex_json.write ('PRICE', i.PRICE_THING);
            v_sum_quantity := 0;

            SELECT SUM (quantity)
              INTO v_sum_quantity
              FROM student4.remnants
             WHERE i.id_thing = id_thing AND DEL_DATE IS NULL;

            apex_json.write ('Quantity', NVL (v_sum_quantity, 0));
            apex_json.close_object ();
        END LOOP;

        apex_json.close_array ();
        apex_json.close_object ();
v_table := apex_json.get_clob_output;
        apex_json.free_output;
        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN v_table;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1_JSON',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.GET_THING_3_1_1_JSON',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END;


    FUNCTION "ADD_THING_3_1_2" (p_NAME      IN     VARCHAR2,
                                p_PRICE     IN     NUMBER,
                                p_message      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        MERGE INTO student4.things t
             USING DUAL
                ON (t.NAME_THING = p_name)
        WHEN MATCHED
        THEN
            UPDATE SET t.PRICE_THING = p_PRICE
        WHEN NOT MATCHED
        THEN
            INSERT     ("NAME_THING", "PRICE_THING")
                VALUES (p_NAME, p_PRICE);

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.ADD_THING_3_1_2',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
    END;

    FUNCTION "EDIT_THING_3_1_3" (p_ID          IN     NUMBER,
                                 p_NEW_NAME    IN     VARCHAR2,
                                 p_NEW_PRICE   IN     NUMBER,
                                 p_message        OUT VARCHAR2) -- 0 - запись обновлена 1- запись не найдена 2- ВСЕ сломалось
        RETURN NUMBER
    AS
        v_thin_cou   NUMBER;
    BEGIN
        SELECT COUNT (ID_THING)
          INTO v_thin_cou
          FROM student4.THINGS
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        IF v_THIN_COU > 0
        THEN
            UPDATE student4.THINGS
               SET NAME_THING =
                       CASE
                           WHEN p_NEW_NAME IS NULL THEN NAME_THING
                           ELSE p_NEW_NAME
                       END,
                   PRICE_THING =
                       CASE
                           WHEN p_NEW_PRICE IS NULL THEN PRICE_THING
                           ELSE p_NEW_PRICE
                       END
             WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

            p_message := 'Все гуд';
            RETURN 0;
        ELSE
            p_message := 'Все записи удалены';
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.EDIT_THING_3_1_3',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.EDIT_THING_3_1_3',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 2;
    END;
FUNCTION "DELETE_THING_3_1_4" (p_ID        IN     NUMBER,
                                   p_WHO_DEL   IN     VARCHAR2,
                                   p_message      OUT VARCHAR2)
        RETURN NUMBER       -- 0- все хорошо 1 - id не найден 2- другая ошибка
    AS
        v_id_count   NUMBER;
        v_date       DATE;
        v_del_user   VARCHAR2 (200);
    BEGIN
        SELECT COUNT (ID_THING)
          INTO v_id_count
          FROM student4.THINGS
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        /*IF v_id_count > 0
        THEN*/
        v_date := SYSDATE;
        v_del_user :=
            CASE WHEN p_who_del IS NOT NULL THEN p_who_del ELSE 'UNKNOWN' END;

        UPDATE student4.REMNANTS
           SET DEL_DATE = v_date, DEL_USER = v_del_user
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        UPDATE student4.CARTS
           SET DEL_DATE = v_date, DEL_USER = v_del_user
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        UPDATE student4.THINGS
           SET DEL_DATE = v_date, DEL_USER = v_del_user
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    /*ELSE
        p_message := 'Данный товар уже удален';
        RETURN 1;
    END IF;*/
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.THING_3_1.DELETE_THING_3_1_4',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 2;
    END;
END;
/
CREATE OR REPLACE PACKAGE BODY STUDENT4.USERS_3_2
AS
    FUNCTION "LOG_IN_3_2_1" (p_NAME       IN     VARCHAR2,
                             p_PASSWORD   IN     VARCHAR2,
                             p_message       OUT VARCHAR2)
        RETURN NUMBER
    AS           --0 -все хорошо, 1 - пароль не верен 2-не найден пользователь
        v_pass   VARCHAR2 (200);
    BEGIN
        SELECT pass_user
          INTO v_pass
          FROM student4.USERS
         WHERE name_user = p_NAME AND DEL_DATE IS NULL;

        IF v_pass = p_PASSWORD
        THEN
            p_message := 'ВСЕ ГУД';
            RETURN 0;
        ELSE
            p_message := 'Пароль неверен';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_message := 'Пользователь не существует';
            RETURN 2;
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.LOG_IN_3_2_1',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 3;
    END;

    FUNCTION "EDIT_USER_3_2_2" (p_ID         IN     NUMBER,
                                p_NEW_NAME   IN     VARCHAR2,
                                p_NEW_PASS   IN     VARCHAR2,
                                p_message       OUT VARCHAR2)
        RETURN NUMBER     --0 -все хорошо, 1 -- запись польщователя не найдена
    AS
        COU_USER   NUMBER;
    BEGIN
        /*SELECT COUNT(ID_USER) into COU_USER  from USERS where id_user=p_ID and DEl_date is null;
        if COU_USER > 0 then*/
        UPDATE student4.USERS
           SET NAME_USER = p_NEW_NAME, PASS_USER = p_NEW_PASS
         WHERE id_user = p_ID AND DEl_date IS NULL;

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    /*else
    p_message:='Пользователь не существует';
    return 1;
    end if;*/
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.EDIT_USER_3_2_2',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 2;
    END;

    FUNCTION "DEL_USER_3_2_3" (P_ID_USER   IN     NUMBER,
                               P_WHO_DEL   IN     VARCHAR2,
                               p_message      OUT VARCHAR2)
        RETURN NUMBER --0 -все хорошо, 1 -- не найден пользователь 2 - не задан удаляющий
    AS
        V_COU_USER   NUMBER;
    BEGIN
        SELECT COUNT (ID_USER)
          INTO v_COU_USER
          FROM student4.USERS
         WHERE id_user = P_ID_USER;

        IF v_COU_USER > 0
        THEN
            UPDATE student4.CUSTOMERS
               SET DEl_date = SYSDATE, DEL_USER = P_WHO_DEL
             WHERE id_user = P_ID_USER;

            UPDATE (SELECT d.DEL_USER, d.DEL_DATE
                      FROM student4.DELIVERY  d
                           JOIN student4.ORDERS o ON d.ID_ORDER = o.ID_ORDER
                     WHERE o.ID_USER = p_ID_USER AND d.DEL_DATE IS NULL)
               SET DEl_date = SYSDATE, DEL_USER = P_WHO_DEL;

            UPDATE (SELECT d.DEL_USER, d.DEL_DATE
                      FROM student4.CARTS  d
                           JOIN student4.ORDERS o ON d.ID_ORDER = o.ID_ORDER
                     WHERE o.ID_USER = p_ID_USER AND d.DEL_DATE IS NULL)
               SET DEl_date = SYSDATE, DEL_USER = P_WHO_DEL;

            UPDATE student4.ORDERS
               SET DEl_date = SYSDATE, DEL_USER = P_WHO_DEL
             WHERE id_user = P_ID_USER;
p_message := 'ВСЕ ГУД';
            RETURN 0;
        ELSE
            p_message := 'Пользователь удален';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.DEL_USER_3_2_3',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 2;
    END;

    FUNCTION "ADD_THING_TO_CART_3_2_4_1" (p_ID_order   IN     NUMBER,
                                          p_thing      IN     NUMBER,
                                          p_message       OUT VARCHAR2)
        RETURN NUMBER --0 -все хорошо, 1 -- не найден пользователь 2 -- такой уже есть
    AS
        V_COU_USER     NUMBER;
        v_order_       NUMBER;
        v_count_line   NUMBER;
    BEGIN
        SELECT COUNT (ID_order)
          INTO v_COU_USER
          FROM student4.ORDERS                                        --order!
         WHERE p_id_order = id_order AND del_date IS NULL;

        IF v_COU_USER > 0
        THEN
            /*SELECT o.ID_order
              INTO v_order_
              FROM ORDERS o JOIN USERS u ON o.id_user = u.id_user
             WHERE u.id_user = p_id;*/

            SELECT COUNT (id_line)
              INTO v_count_line
              FROM student4.carts
             WHERE     id_order = p_id_order
                   AND id_thing = p_thing
                   AND del_date IS NULL;

            IF v_count_line = 0
            THEN
                INSERT INTO student4.carts (id_order, id_thing)
                     VALUES (v_order_, p_thing);

                p_message := 'ВСЕ ГУД';
                RETURN 0;
            ELSE
                p_message := 'Запись существует';
                RETURN 2;
            END IF;
        ELSE
            p_message := 'Пользователь не найден';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.USERS_3_2.ADD_THING_TO_CART_3_2_4_1',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 3;
    END;

    FUNCTION "DEL_THING_FROM_CART_3_2_4_2" (p_ORDER_    IN     NUMBER,
                                            p_THING     IN     NUMBER,
                                            p_WHO_DEL   IN     VARCHAR2,
                                            p_message      OUT VARCHAR2)
        RETURN NUMBER
    AS
        v_THING_COU     NUMBER;
        v_date          DATE;
        v_who_del       VARCHAR2 (200);
        v_count_thing   NUMBER;
    BEGIN
        v_date := SYSDATE;
        v_who_del := P_WHO_DEL;

        UPDATE student4.CARTS
           SET DEL_DATE = v_date, DEL_USER = v_who_del
         WHERE     ID_ORDER = P_order_
               AND id_thing = p_thing
               AND DEL_DATE IS NULL;



        SELECT COUNT (ID_LINE)
          INTO v_count_thing
          FROM student4.carts
         WHERE ID_ORDER = P_ORDER_ AND DEL_DATE IS NULL;

        IF v_count_thing = 0
        THEN
            UPDATE student4.ORDERS
               SET DEL_DATE = v_date, DEL_USER = 'auto'
             WHERE ID_ORDER = P_order_ AND del_date IS NULL;

            UPDATE student4.delivery
               SET DEL_DATE = v_date, DEL_USER = 'auto'
             WHERE ID_ORDER = P_order_ AND del_date IS NULL;
        END IF;
p_message := 'ВСЕ ГУД';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.USERS_3_2.DEL_THING_FROM_CART_3_2_4_2',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
    END;

    FUNCTION "ADD_DELIVERY_3_2_5" (
        p_SURNAME      IN     VARCHAR2 DEFAULT NULL,
        p_NAME         IN     VARCHAR2 DEFAULT NULL,
        p_PATRONYMIC   IN     VARCHAR2 DEFAULT NULL,
        p_ADRESS       IN     VARCHAR2 DEFAULT NULL,
        p_TELEFON      IN     VARCHAR2 DEFAULT NULL,
        p_ID_ORDER     IN     NUMBER,
        p_CITY         IN     NUMBER,
        p_message         OUT VARCHAR2)
        RETURN NUMBER
    AS                 --0 все хорошо 1 - не найден заказ 2 - Данные обновлены
        v_id_ord_cou    NUMBER;
        v_id_us         NUMBER;
        v_id_us_count   NUMBER;
    BEGIN
        SELECT COUNT (ID_ORDER), ID_USER          -- существует ли такой заказ
          INTO v_id_ord_cou, v_id_us
          FROM student4.ORDERS
         WHERE student4.ORDERS.ID_ORDER = p_ID_ORDER;

        IF v_id_ord_cou > 0
        THEN
            INSERT INTO student4.delivery (ID_ORDER)
                 VALUES (p_ID_ORDER);

            SELECT COUNT (ID_USER)
              INTO v_id_us_count
              FROM student4.CUSTOMERS
             WHERE student4.CUSTOMERS.ID_USER = v_id_us;

            IF v_id_us_count = 0
            THEN
                INSERT INTO student4.CUSTOMERS (ID_USER,
                                                SURNAME_CUSTOMER,
                                                NAME_CUSTOMER,
                                                PATRONYMIC_CUSTOMER,
                                                CITY_CUSTOMER,
                                                ADRESS_CUSTOMER,
                                                TELEFON_CUSTOMER)
                     VALUES (v_id_us,
                             p_SURNAME,
                             p_NAME,
                             p_PATRONYMIC,
                             p_CITY,
                             p_ADRESS,
                             p_TELEFON);
FUNCTION ADD_ORDER_3_2_7 (p_id_usr             NUMBER,
                              p_status_order       VARCHAR2,
                              p_message        OUT VARCHAR2)
        RETURN NUMBER
    AS
    BEGIN
        INSERT INTO student4.ORDERS (id_user,
                                     status_order,
                                     del_date,
                                     del_user)
             VALUES (p_id_usr,
                     p_status_order,
                     NULL,
                     NULL);

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.ADD_ORDER_3_2_7',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
    END;

    FUNCTION DEL_ORDER_3_2_7 (p_order              NUMBER,
                              p_status_order       VARCHAR2,
                              p_del_user           VARCHAR2,
                              p_message        OUT VARCHAR2)
        RETURN NUMBER
    AS
    BEGIN
        UPDATE student4.ORDERS
           SET del_date = SYSDATE, del_user = p_del_user
         WHERE id_order = p_order AND del_date IS NULL;

        UPDATE student4.carts
           SET del_date = SYSDATE, del_user = p_del_user
         WHERE id_order = p_order AND del_date IS NULL;

        UPDATE student4.delivery
           SET DEL_DATE = SYSDATE, DEL_USER = p_del_user
         WHERE ID_ORDER = P_order AND del_date IS NULL;

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.DEL_ORDER_3_2_7',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
    END;
END;
/
p_message := 'ВСЕ ГУД';
                RETURN 0;
            ELSE
                UPDATE student4.CUSTOMERS
                   SET ADRESS_CUSTOMER =
                           CASE
                               WHEN p_ADRESS IS NULL THEN ADRESS_CUSTOMER
                               ELSE p_ADRESS
                           END,
                       TELEFON_CUSTOMER =
                           CASE
                               WHEN p_TELEFON IS NULL THEN TELEFON_CUSTOMER
                               ELSE p_TELEFON
                           END,
                       SURNAME_CUSTOMER =
                           CASE
                               WHEN p_SURNAME IS NULL THEN SURNAME_CUSTOMER
                               ELSE p_SURNAME
                           END,
                       NAME_CUSTOMER =
                           CASE
                               WHEN p_NAME IS NULL THEN NAME_CUSTOMER
                               ELSE p_NAME
                           END,
                       PATRONYMIC_CUSTOMER =
                           CASE
                               WHEN p_PATRONYMIC IS NULL
                               THEN
                                   PATRONYMIC_CUSTOMER
                               ELSE
                                   p_PATRONYMIC
                           END,
                       CITY_CUSTOMER =
                           CASE
                               WHEN p_CITY IS NULL THEN CITY_CUSTOMER
                               ELSE p_CITY
                           END,
                       DEL_DATE = NULL,
                       DEL_USER = NULL
                 WHERE student4.CUSTOMERS.ID_USER = v_id_us;

                p_message := 'Данные обновлены';
                RETURN 2;
            END IF;

            COMMIT;
        ELSE
            p_message := 'Заказ не найден';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_message := 'Заказ не найден';
            RETURN 1;
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.ADD_DELIVERY_3_2_5',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 3;
    END;

    FUNCTION "GET_ORDERS_3_2_6" (p_id_usr        NUMBER,
                                 p_status    OUT NUMBER,
                                 p_message   OUT VARCHAR2)
        RETURN SYS_REFCURSOR
    AS                              --0 -все хорошо 1 - пользователь не найден
        v_id_usr_count   NUMBER;
        v_cart           SYS_REFCURSOR;
    BEGIN
        SELECT COUNT (id_user)
          INTO v_id_usr_count
          FROM student4.orders
         WHERE id_user = p_id_usr AND DEL_date IS NULL;

        IF v_id_usr_count > 0
        THEN
            OPEN v_cart FOR SELECT id_order
                              FROM student4.orders
                             WHERE id_user = p_id_usr AND DEL_date IS NULL;

            p_message := 'ВСЕ ГУД';
            p_status := 0;
        ELSE
            p_message := 'Пользователь не найден';
            p_status := 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.GET_ORDERS_3_2_6',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            p_status := 2;
            RETURN NULL;
    END;
FUNCTION "GET_ORDERS_3_2_6_JSON" (p_id_usr        NUMBER,
                                      p_message   OUT VARCHAR2,
                                      p_status    OUT NUMBER)
        RETURN CLOB
    AS                              --0 -все хорошо 1 - пользователь не найден
        v_user   VARCHAR2 (200);
        v_cart   CLOB;
    BEGIN
        apex_json.free_output;
        apex_json.initialize_clob_output;
        apex_json.open_object ();
        apex_json.write ('USER', p_id_usr);

        SELECT NAME_USER
          INTO v_user
          FROM student4.USERS
         WHERE id_user = p_id_usr AND del_date IS NULL;

        apex_json.write ('NAME', v_user);
        apex_json.open_array ('ORDERS');

        FOR i IN (SELECT ID_ORDER
                    FROM student4.ORDERS
                   WHERE id_user = p_id_usr)
        LOOP
            apex_json.open_object ();
            apex_json.write ('ORDER', i.ID_ORDER);
            apex_json.open_array ('THING');

            FOR j
                IN (SELECT t.NAME_thing, t.PRICE_THING
                      FROM student4.THINGS  t
                           JOIN student4.carts c ON t.id_thing = c.id_thing
                     WHERE     c.id_order = i.ID_ORDER
                           AND c.del_date IS NULL
                           AND t.del_date IS NULL)
            LOOP
                apex_json.open_object ();
                apex_json.write ('NAME', j.NAME_thing);
                apex_json.write ('PRICE', j.PRICE_THING);
                apex_json.close_object ();
            END LOOP;

            apex_json.close_array ();
            apex_json.close_object ();
        END LOOP;

        apex_json.close_array ();
        apex_json.close_object ();
        v_cart := apex_json.get_clob_output;
        apex_json.free_output;
        p_message := 'ВСЕ ГУД';
        p_status := 0;
        RETURN v_cart;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.GET_ORDERS_3_2_6_JSON',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            p_status := 2;
            RETURN NULL;
    END;

    FUNCTION "GET_ORDERS_3_2_6_PIPE" (p_id_usr        NUMBER,
                                      p_message   OUT VARCHAR2,
                                      p_status    OUT NUMBER)
        RETURN t_orders_table
        PIPELINED
    AS
        v_id_usr_count   NUMBER;
        v_rec            t_orders_record;
    BEGIN
        FOR i IN (SELECT id_order
                    FROM student4.orders
                   WHERE id_user = p_id_usr AND DEL_date IS NULL)
        LOOP
            v_rec := t_orders_record (p_id_usr, i.id_order);
            PIPE ROW (v_rec);
        END LOOP;

        p_message := 'ВСЕ ГУД';
        p_status := 0;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            RETURN;
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.USERS_3_2.GET_ORDERS_3_2_6_PIPE',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            p_status := 2;
            RETURN;
    END;
CREATE OR REPLACE PACKAGE BODY STUDENT4.WAREHOUSE_3_3
AS
    FUNCTION "ADD_WAREHOUSE_3_3_1" (p_city          NUMBER,
                                    p_adress        VARCHAR2,
                                    p_message   OUT VARCHAR2)
        RETURN NUMBER     -- 0- хорошо 1-не найден город 2- адресс не известен
    IS
        v_count_city   NUMBER;
    BEGIN
        INSERT INTO student4.WAREHOUSES (ADRESS_WAREHOUSE, CITY_WAREHOUSE)
             VALUES (p_adress, p_city);

        p_message := 'ВСЕ ГУД!';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.WAREHOUSE_3_3.ADD_WAREHOUSE_3_3_1',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 1;
    END;

    FUNCTION "DEL_WAREHOUSE_3_3_1" (p_id            NUMBER,
                                    p_WHO_DEL       VARCHAR2,
                                    p_message   OUT VARCHAR2)
        RETURN NUMBER  -- 0- хорошо 1-не найден склад 2- удаляющий не известен
    IS
        v_count_ware   NUMBER;
        v_quantity     NUMBER;
        v_date         DATE;
        v_who          VARCHAR2 (200);
    BEGIN
        SELECT COUNT (ID_WAREHOUSE)
          INTO v_count_ware
          FROM student4.WAREHOUSES
         WHERE p_id = ID_WAREHOUSE AND DEL_DATE IS NULL;

        IF v_count_ware > 0
        THEN
            SELECT SUM (QUANTITY)
              INTO v_quantity
              FROM student4.remnants
             WHERE del_date IS NULL AND p_id = ID_WAREHOUSE;

            IF v_quantity = 0
            THEN
                UPDATE student4.WAREHOUSES
                   SET DEL_date = SYSDATE, del_USER = p_WHO_DEL
                 WHERE p_id = ID_WAREHOUSE AND DEL_DATE IS NULL;

                p_message := 'ВСЕ ГУД!';
                RETURN 0;
            ELSE
                p_message :=
                       'На складе осталось еще  '
                    || v_quantity
                    || 'товаров';
                RETURN 2;
            END IF;
        ELSE
            p_message := 'Склад уже удален';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.WAREHOUSE_3_3.DEL_WAREHOUSE_3_3_1',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 3;
    END;

    FUNCTION TRANS_FROM_WAREHOUSE_3_3_3 (P_WAREHOUSE_IN        NUMBER,
                                         P_WAREHOUSE_OUT       NUMBER,
                                         P_THING               NUMBER,
                                         p_quantity            NUMBER,
                                         p_message         OUT VARCHAR2 -- 0-все хорошо 1- не сработало(
                                                                       )
        RETURN NUMBER
    IS
        v_quantity_in   NUMBER;
    BEGIN
        SELECT QUANTITY
          INTO v_quantity_in
          FROM student4.REMNANTS
         WHERE     id_thing = p_thing
               AND del_date IS NULL
               AND id_warehouse = p_warehouse_in;

        IF v_quantity_in < p_quantity
        THEN
            p_message:='На складе недостаточно тавара';
            return 1;
        ELSE
            UPDATE student4.REMNANTS
               SET QUANTITY = QUANTITY - p_quantity
             WHERE     id_thing = p_thing
                   AND del_date IS NULL
                   AND id_warehouse = p_warehouse_in;
MERGE INTO student4.REMNANTS r
                 USING DUAL d
                    ON (    r.id_thing = p_thing
                        AND r.id_warehouse = P_WAREHOUSE_OUT
                        AND r.DEL_DATE IS NULL)
            WHEN MATCHED
            THEN
                UPDATE SET r.Quantity = r.Quantity + p_quantity
            WHEN NOT MATCHED
            THEN
                INSERT     (id_thing, id_warehouse, quantity)
                    VALUES (p_thing, p_warehouse_out, p_quantity);
                    
            p_message := 'ВСЕ ГУД!';
            return 0;
        END IF;
        EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
                STUDENT4.add_logs  (P_FUNCTION   => 'STUDENT4.WAREHOUSE_3_3.TRANS_FROM_WAREHOUSE_3_3_3',
                      P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN 2;
    END TRANS_FROM_WAREHOUSE_3_3_3;
END WAREHOUSE_3_3;
/



CREATE OR REPLACE PACKAGE BODY STUDENT4.Reports_3_4
AS
    FUNCTION GET_delivery_3_4_1_pipe (p_status    OUT NUMBER,
                                      p_message   OUT VARCHAR2)
        RETURN t_delivery_table
        PIPELINED
    IS
        v_rec   t_delivery_record;
    BEGIN
        FOR i
            IN (  SELECT o.ID_ORDER, c.id_warehouse, c.id_thing
                    FROM STUDENT4.ORDERS o
                         JOIN STUDENT4.Delivery d ON d.id_order = o.ID_ORDER
                         JOIN STUDENT4.CARTS c ON c.id_order = o.id_order
                   WHERE     o.del_date IS NULL
                         AND d.del_date IS NULL
                         AND d.ID_DELIVERY IS NOT NULL
                         AND c.id_warehouse IS NOT NULL
                ORDER BY c.id_warehouse)
        LOOP
            v_rec :=
                t_delivery_record (i.id_warehouse, i.id_order, i.id_thing);
            PIPE ROW (v_rec);
        END LOOP;

        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все заказы удалены';
            RETURN;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.Reports_3_4.GET_delivery_3_4_1_pipe',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN;
    END;

    FUNCTION GET_delivery_3_4_1 (p_status OUT NUMBER, p_message OUT VARCHAR2)
        RETURN SYS_REFCURSOR
    IS
        v_out_ref_cursor   SYS_REFCURSOR;
    BEGIN
        OPEN v_out_ref_cursor FOR
              SELECT o.ID_ORDER, c.id_warehouse, c.id_thing
                FROM STUDENT4.ORDERS o
                     JOIN STUDENT4.Delivery d ON d.id_order = o.ID_ORDER
                     JOIN STUDENT4.CARTS c ON c.id_order = o.id_order
               WHERE     o.del_date IS NULL
                     AND d.del_date IS NULL
                     AND d.ID_DELIVERY IS NOT NULL
                     AND c.id_warehouse IS NOT NULL
            ORDER BY c.id_warehouse;

        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN v_out_ref_cursor;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все заказы удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.Reports_3_4.GET_delivery_3_4_1',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END;

    FUNCTION GET_delivery_3_4_1_JSON (p_status    OUT NUMBER,
                                      p_message   OUT VARCHAR2)
        RETURN CLOB
    IS
        v_OUTPUT_CLOB   CLOB;
        v_city          VARCHAR2 (200);
        v_adress        VARCHAR2 (200);
    BEGIN
        apex_json.free_output;
        apex_json.initialize_clob_output;
        apex_json.open_array ();
FOR i
            IN (SELECT DISTINCT c.id_warehouse
                  FROM STUDENT4.ORDERS  o
                       JOIN STUDENT4.Delivery d ON d.id_order = o.ID_ORDER
                       JOIN STUDENT4.CARTS c ON c.id_order = o.id_order
                 WHERE     o.del_date IS NULL
                       AND d.del_date IS NULL
                       AND d.ID_DELIVERY IS NOT NULL
                       AND c.id_warehouse IS NOT NULL)
        LOOP
            SELECT adress_warehouse, c.NAME_CITY
              INTO v_adress, v_city
              FROM STUDENT4.warehouses  w
                   JOIN STUDENT4.city c ON c.id_city = w.city_warehouse
             WHERE id_warehouse = i.id_warehouse AND del_date IS NULL;

            apex_json.open_object ('');
            apex_json.write ('id_warehouse', i.id_warehouse);
            apex_json.write ('adress_warehouse', v_adress);
            apex_json.write ('city_warehouse', v_city);
            apex_json.open_array ('ORDERS');

            FOR j
                IN (SELECT DISTINCT o.ID_ORDER,
                                    u.ADRESS_CUSTOMER,
                                    u.TELEFON_CUSTOMER,
                                    u.NAME_CUSTOMER,
                                    u.SURNAME_CUSTOMER,
                                    u.PATRONYMIC_CUSTOMER,
                                    g.NAME_CITY                  --,c.id_thing
                      FROM STUDENT4.ORDERS  o
                           JOIN STUDENT4.Delivery d
                               ON d.id_order = o.ID_ORDER
                           JOIN STUDENT4.CARTS c ON c.id_order = o.id_order
                           JOIN STUDENT4.CUSTOMERS u ON u.id_user = o.id_user
                           JOIN STUDENT4.city g
                               ON g.id_city = u.CITY_CUSTOMER
                     WHERE     o.del_date IS NULL
                           AND d.del_date IS NULL
                           AND u.del_date IS NULL
                           AND d.ID_DELIVERY IS NOT NULL
                           AND c.id_warehouse IS NOT NULL
                           AND c.id_warehouse = i.id_warehouse)
            LOOP
                apex_json.open_object ();
                apex_json.write ('ORDER', j.ID_ORDER);
                apex_json.write ('CITY', j.NAME_CITY);
                apex_json.write ('ADRESS', j.ADRESS_CUSTOMER);
                apex_json.write ('SURNAME', j.SURNAME_CUSTOMER);
                apex_json.write ('NAME', j.NAME_CUSTOMER);
                apex_json.write ('PATRONYMIC', j.PATRONYMIC_CUSTOMER);
                apex_json.write ('TELEFON', j.TELEFON_CUSTOMER);
                apex_json.open_array ('ORDER');

                FOR f
                    IN (SELECT c.id_thing, t.NAME_THING
                          FROM STUDENT4.ORDERS  o
                               JOIN STUDENT4.Delivery d
                                   ON d.id_order = o.ID_ORDER
                               JOIN STUDENT4.CARTS c
                                   ON c.id_order = o.id_order
                               JOIN STUDENT4.things t
                                   ON c.id_thing = t.id_thing
                         WHERE     o.del_date IS NULL
                               AND d.del_date IS NULL
                               AND c.del_date IS NULL
                               AND d.ID_DELIVERY IS NOT NULL
                               AND c.id_warehouse IS NOT NULL
                               AND c.id_warehouse = i.id_warehouse
                               AND o.ID_ORDER = j.id_order)
                LOOP
                    apex_json.open_object ();
                    apex_json.write ('ID_THING', f.id_thing);
                    apex_json.write ('NAME_THING', f.NAME_THING);
                    apex_json.close_object ();
                END LOOP;

                apex_json.close_array ();
                apex_json.close_object ();
            END LOOP;

            apex_json.close_array ();
            apex_json.close_object ();
        END LOOP;
apex_json.close_array ();
        v_OUTPUT_CLOB := apex_json.get_clob_output;
        apex_json.free_output;
        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN v_OUTPUT_CLOB;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все заказы удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.Reports_3_4.GET_delivery_3_4_1_JSON',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END;

    /***************************************************************************

    ***************************************************************************/
    FUNCTION get_quantity_3_4_2_PIPE (p_quantity       NUMBER,
                                      p_status     OUT NUMBER,
                                      p_message    OUT VARCHAR2)
        RETURN t_quantity_table
        PIPELINED
    IS
        v_rec   t_quantity_record;
    BEGIN
        FOR i IN (SELECT id_warehouse, id_thing, quantity
                    FROM STUDENT4.Remnants
                   WHERE quantity < p_quantity AND del_date IS NULL)
        LOOP
            v_rec :=
                t_quantity_record (i.id_warehouse, i.id_thing, i.quantity);
            PIPE ROW (v_rec);
        END LOOP;

        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.Reports_3_4.get_quantity_3_4_2_PIPE',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN;
    END;

    FUNCTION get_quantity_3_4_2_JSON (p_quantity       NUMBER,
                                      p_status     OUT NUMBER,
                                      p_message    OUT VARCHAR2)
        RETURN CLOB
    AS
        v_table   CLOB;
    BEGIN
        apex_json.free_output;
        apex_json.initialize_clob_output;
        apex_json.open_object ();
        apex_json.open_array ('THINGS');

        FOR i
            IN (SELECT DISTINCT t.id_thing, t.NAME_THING, t.PRICE_THING
                  FROM STUDENT4.THINGS  t
                       JOIN STUDENT4.REMNANTS r ON r.ID_THING = t.ID_THING
                 WHERE     t.DEL_DATE IS NULL
                       AND r.DEL_DATE IS NULL
                       AND r.QUANTITY < p_quantity)
        LOOP
            apex_json.open_object ();
            apex_json.write ('NAME', i.NAME_THING);
            apex_json.write ('PRICE', i.PRICE_THING);
            apex_json.open_array ('QUANTITY');
FOR j
                IN (SELECT r.QUANTITY, w.ADRESS_WAREHOUSE, c.NAME_CITY
                      FROM STUDENT4.REMNANTS  r
                           JOIN STUDENT4.WAREHOUSES w
                               ON w.ID_WAREHOUSE = r.ID_WAREHOUSE
                           JOIN STUDENT4.city c
                               ON c.ID_CITY = w.CITY_WAREHOUSE
                     WHERE     r.ID_THING = i.id_thing
                           AND w.DEL_DATE IS NULL
                           AND r.DEL_DATE IS NULL
                           AND r.QUANTITY < p_quantity)
            LOOP
                apex_json.open_object ();
                apex_json.write ('CITY', j.NAME_CITY);
                apex_json.write ('ADRESS', j.ADRESS_WAREHOUSE);
                apex_json.write ('QUANTITY', j.QUANTITY);
                apex_json.close_object ();
            END LOOP;

            apex_json.close_array ();
            apex_json.close_object ();
        END LOOP;

        apex_json.close_array ();
        apex_json.close_object ();

        v_table := apex_json.get_clob_output;
        apex_json.free_output;
        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN v_table;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (P_FUNCTION =>
                          'STUDENT4.Reports_3_4.get_quantity_3_4_2_JSON',
                      P_TEXT_ERR =>
                          TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END;

    FUNCTION get_quantity_3_4_2 (p_quantity       NUMBER,
                                 p_status     OUT NUMBER,
                                 p_message    OUT VARCHAR2)
        RETURN SYS_REFCURSOR
    IS
        v_out_cursor   SYS_REFCURSOR;
    BEGIN
        OPEN v_out_cursor FOR
            SELECT id_warehouse, id_thing, quantity
              FROM STUDENT4.Remnants
             WHERE quantity < p_quantity AND del_date IS NULL;

        p_status := 0;
        p_message := 'ВСЕ ГУД!';
        RETURN v_out_cursor;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            STUDENT4.add_logs  (
                P_FUNCTION   => 'STUDENT4.Reports_3_4.get_quantity_3_4_2',
                P_TEXT_ERR   => TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
            RETURN NULL;
    END get_quantity_3_4_2;
END Reports_3_4;
/
