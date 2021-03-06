CREATE OR REPLACE TRIGGER STUDENT4.CARTS_ID_TRG
before insert ON STUDENT4.CARTS
for each row
begin
  if :new.ID_LINE is null then
    select CARTS_seq.nextval into :new.ID_LINE from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.CITY_ID_TRG
before insert ON STUDENT4.CITY
for each row
begin
  if :new.ID_CITY is null then
    select CITY_seq.nextval into :new.ID_CITY from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.DELIVERY_ID_TRG
before insert ON STUDENT4.DELIVERY
for each row
begin
  if :new.ID_DELIVERY is null then
    select DELIVERY_seq.nextval into :new.ID_DELIVERY from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.LOGES_ID_TRG
before insert ON "STUDENT4"."LOGS"
for each row
begin
  if :new.ID_LOG is null then
    select LOGES_SEQ.nextval into :new.ID_LOG from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.ORDERS_ID_TRG
before insert ON STUDENT4.ORDERS
for each row
begin
  if :new.ID_ORDER is null then
    select ORDERS_seq.nextval into :new.ID_ORDER from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.REMNANTS_ID_TRG
before insert ON STUDENT4.REMNANTS
for each row
begin
  if :new.ID_REMAINDER is null then
    select REMNANTS_seq.nextval into :new.ID_REMAINDER from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.THINGS_ID_TRG
before insert ON STUDENT4.THINGS
for each row
begin
  if :new.ID_THING is null then
    select THINGS_seq.nextval into :new.ID_THING from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.USERS_ID_TRG
before insert ON STUDENT4.USERS
for each row
begin
  if :new.ID_USER is null then
    select USERS_seq.nextval into :new.ID_USER from dual;
  end if;
end;
/
CREATE OR REPLACE TRIGGER STUDENT4.WAREHOUSES_ID_TRG
before insert ON STUDENT4.WAREHOUSES
for each row
begin
  if :new.ID_WAREHOUSE is null then
    select WAREHOUSES_seq.nextval into :new.ID_WAREHOUSE from dual;
  end if;
end;
/
