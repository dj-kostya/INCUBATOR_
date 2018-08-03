CREATE OR REPLACE PACKAGE STUDENT4.Reports_3_4
AS
    FUNCTION GET_delivery_3_4_1_pipe (p_status    OUT NUMBER,
                                      p_message   OUT VARCHAR2)
        RETURN t_delivery_table
        PIPELINED;


    FUNCTION GET_delivery_3_4_1 (p_status OUT NUMBER, p_message OUT VARCHAR2)
        RETURN SYS_REFCURSOR;

    FUNCTION GET_delivery_3_4_1_JSON (p_status    OUT NUMBER,
                                      p_message   OUT VARCHAR2)
        RETURN CLOB;

    /***************************************************************************

    ***************************************************************************/

    FUNCTION get_quantity_3_4_2_PIPE (p_quantity       NUMBER,
                                      p_status     OUT NUMBER,
                                      p_message    OUT VARCHAR2)
        RETURN t_quantity_table
        PIPELINED;

    FUNCTION get_quantity_3_4_2_JSON (p_quantity       NUMBER,
                                      p_status     OUT NUMBER,
                                      p_message    OUT VARCHAR2)
        RETURN CLOB;

    FUNCTION get_quantity_3_4_2 (p_quantity       NUMBER,
                                 p_status     OUT NUMBER,
                                 p_message    OUT VARCHAR2)
        RETURN SYS_REFCURSOR;
END Reports_3_4;
/
CREATE OR REPLACE PACKAGE STUDENT4.THING_3_1
IS
    FUNCTION "GET_THING_3_1_1" (p_message OUT VARCHAR2, p_status OUT NUMBER)
        RETURN SYS_REFCURSOR;

    FUNCTION "GET_THING_3_1_1_PIPE" (p_message   OUT VARCHAR2,
                                     p_status    OUT NUMBER)
        RETURN t_THING_table
        PIPELINED;

    FUNCTION "GET_THING_3_1_1_JSON" (p_message   OUT VARCHAR2,
                                     p_status    OUT NUMBER)
        RETURN CLOB;

    FUNCTION "ADD_THING_3_1_2" (p_NAME      IN     VARCHAR2,
                                p_PRICE     IN     NUMBER,
                                p_message      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "EDIT_THING_3_1_3" (p_ID          IN     NUMBER,
                                 p_NEW_NAME    IN     VARCHAR2,
                                 p_NEW_PRICE   IN     NUMBER,
                                 p_message        OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "DELETE_THING_3_1_4" (p_ID        IN     NUMBER,
                                   p_WHO_DEL   IN     VARCHAR2,
                                   p_message      OUT VARCHAR2)
        RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE STUDENT4.USERS_3_2
AS
    FUNCTION "LOG_IN_3_2_1" (p_NAME       IN     VARCHAR2,
                             p_PASSWORD   IN     VARCHAR2,
                             p_message       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "EDIT_USER_3_2_2" (p_ID         IN     NUMBER,
                                p_NEW_NAME   IN     VARCHAR2,
                                p_NEW_PASS   IN     VARCHAR2,
                                p_message       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "DEL_USER_3_2_3" (P_ID_USER   IN     NUMBER,
                               P_WHO_DEL   IN     VARCHAR2,
                               p_message      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "ADD_THING_TO_CART_3_2_4_1" (p_ID_order   IN     NUMBER,
                                          p_thing      IN     NUMBER,
                                          p_message       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "DEL_THING_FROM_CART_3_2_4_2" (p_ORDER_    IN     NUMBER,
                                            p_THING     IN     NUMBER,
                                            p_WHO_DEL   IN     VARCHAR2,
                                            p_message      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "ADD_DELIVERY_3_2_5" (
        p_SURNAME      IN     VARCHAR2 DEFAULT NULL,
        p_NAME         IN     VARCHAR2 DEFAULT NULL,
        p_PATRONYMIC   IN     VARCHAR2 DEFAULT NULL,
        p_ADRESS       IN     VARCHAR2 DEFAULT NULL,
        p_TELEFON      IN     VARCHAR2 DEFAULT NULL,
        p_ID_ORDER     IN     NUMBER,
        p_CITY         IN     NUMBER,
        p_message         OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "GET_ORDERS_3_2_6" (p_id_usr        NUMBER,
                                 p_status    OUT NUMBER,
                                 p_message   OUT VARCHAR2)
        RETURN SYS_REFCURSOR;

    FUNCTION "GET_ORDERS_3_2_6_JSON" (p_id_usr        NUMBER,
                                      p_message   OUT VARCHAR2,
                                      p_status    OUT NUMBER)
        RETURN CLOB;

    FUNCTION "GET_ORDERS_3_2_6_PIPE" (p_id_usr        NUMBER,
                                      p_message   OUT VARCHAR2,
                                      p_status    OUT NUMBER)
        RETURN t_orders_table
        PIPELINED;

    FUNCTION ADD_ORDER_3_2_7 (p_id_usr             NUMBER,
                              p_status_order       VARCHAR2,
                              p_message        OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION DEL_ORDER_3_2_7 (p_order              NUMBER,
                              p_status_order       VARCHAR2,
                              p_del_user           VARCHAR2,
                              p_message        OUT VARCHAR2)
        RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE STUDENT4.WAREHOUSE_3_3
AS
    FUNCTION "ADD_WAREHOUSE_3_3_1" (p_city          NUMBER,
                                    p_adress        VARCHAR2,
                                    p_message   OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION "DEL_WAREHOUSE_3_3_1" (p_id            NUMBER,
                                    p_WHO_DEL       VARCHAR2,
                                    p_message   OUT VARCHAR2)
        RETURN NUMBER;
    FUNCTION "TRANS_FROM_WAREHOUSE_3_3_3" (P_WAREHOUSE_IN        NUMBER,
                                         P_WAREHOUSE_OUT       NUMBER,
                                         P_THING               NUMBER,
                                         p_quantity            NUMBER,
                                         p_message         OUT VARCHAR2 -- 0-все хорошо 1- не сработало(
                                                                       )
        RETURN NUMBER;    
END WAREHOUSE_3_3;
/
