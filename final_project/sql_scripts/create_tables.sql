               -- Создаем таблицы-источники один раз --
 
CREATE TABLE itde1.hecv_passport_blacklist(
	passport_num VARCHAR2(16),
    entry_dt DATE);
    
CREATE TABLE itde1.hecv_transactions(
	trans_id VARCHAR2(16),
    trans_date DATE,
    card_num VARCHAR2(32),
    oper_type VARCHAR2(32),
    amt DECIMAL(18,2),
    oper_result VARCHAR2(16),
    terminal VARCHAR2(8));
    
CREATE TABLE itde1.hecv_terminals(
	terminal_id VARCHAR2(8),
    terminal_type CHAR(3),
    terminal_city VARCHAR2(64),
    terminal_address VARCHAR2(256),
    create_dt DATE);
    
      -- Создаем таблицы STG. Они в точности повторяют таблицы-источники --

CREATE TABLE itde1.hecv_stg_psprt_blst(
	passport_num VARCHAR2(16),
    entry_dt DATE);
    
CREATE TABLE itde1.hecv_stg_trnsctions(
	trans_id VARCHAR2(16),
    trans_date DATE,
    card_num VARCHAR2(32),
    oper_type VARCHAR2(32),
    amt DECIMAL(18,2),
    oper_result VARCHAR2(16),
    terminal VARCHAR2(8));

CREATE TABLE itde1.hecv_stg_terminals(
	terminal_id VARCHAR2(8),
    terminal_type CHAR(3),
    terminal_city VARCHAR2(64),
    terminal_address VARCHAR2(256),
    create_dt DATE);
    
CREATE TABLE itde1.hecv_stg_cards(
    card_num CHAR(20),
    account_num	CHAR(20),
    create_dt DATE,
    update_dt DATE);

CREATE TABLE itde1.hecv_stg_accounts(
    account_num CHAR(20),
    valid_to DATE,
    client VARCHAR2(20),
    create_dt DATE,
    update_dt DATE);

CREATE TABLE itde1.hecv_stg_clients(
    client_id VARCHAR2(20),
    last_name VARCHAR2(100),
    first_name VARCHAR2(100),
    patronymic VARCHAR2(100),
    date_of_birth DATE,
    passport_num VARCHAR2(15),
    passport_valid_to DATE,
    phone VARCHAR2(20),
    create_dt DATE,
    update_dt DATE);

-- Создаем таблицы STG_DEL для удаления удаленных из источника ключей в хранилище --
       
CREATE TABLE itde1.hecv_stg_terminals_del(terminal_id VARCHAR2(8));

CREATE TABLE itde1.hecv_stg_cards_del(card_num CHAR(20));  

CREATE TABLE itde1.hecv_stg_accounts_del(account_num CHAR(20));  

CREATE TABLE itde1.hecv_stg_clients_del(client_id VARCHAR2(20));  
                         
           -- Создаем таблицы-приемники(таблицы хранилища данных) --

CREATE TABLE itde1.hecv_dwh_fact_psprt_blst(
	passport_num VARCHAR2(16),
    entry_dt DATE);
    
CREATE TABLE itde1.hecv_dwh_fact_trnsctions(
	trans_id VARCHAR2(16),
    trans_date DATE,
    card_num VARCHAR2(32),
    oper_type VARCHAR2(32),
    amt DECIMAL(18,2),
    oper_result VARCHAR2(16),
    terminal VARCHAR2(8));

CREATE TABLE itde1.hecv_dwh_dim_terminals(
	terminal_id VARCHAR2(8),
    terminal_type CHAR(3),
    terminal_city VARCHAR2(64),
    terminal_address VARCHAR2(256),
    create_dt DATE,
    update_dt DATE);
    
CREATE TABLE itde1.hecv_dwh_dim_cards(
    card_num CHAR(20),
    account_num	CHAR(20),
    create_dt DATE,
    update_dt DATE);

CREATE TABLE itde1.hecv_dwh_dim_accounts(
    account_num CHAR(20),
    valid_to DATE,
    client VARCHAR2(20),
    create_dt DATE,
    update_dt DATE);

CREATE TABLE itde1.hecv_dwh_dim_clients(
    client_id VARCHAR2(20),
    last_name VARCHAR2(100),
    first_name VARCHAR2(100),
    patronymic VARCHAR2(100),
    date_of_birth DATE,
    passport_num VARCHAR2(15),
    passport_valid_to DATE,
    phone VARCHAR2(20),
    create_dt DATE,
    update_dt DATE);

    -- Создаем таблицу с метаданными и заполняем ее начальным решением --
    -- (пока данных не было, ставим заведомо минимальную дату - 1900 год) --

CREATE TABLE itde1.hecv_meta_updates(
	db_name VARCHAR2(16),
	table_name VARCHAR2(32),
	last_update DATE);

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('ITDE1', 'HECV_DWH_FACT_PSPRT_BLST', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('ITDE1', 'HECV_DWH_FACT_TRNSCTIONS', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('ITDE1', 'HECV_DWH_DIM_TERMINALS', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('BANK', 'CARDS', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('BANK', 'ACCOUNTS', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

INSERT INTO itde1.hecv_meta_updates(db_name, table_name, last_update)
VALUES ('BANK', 'CLIENTS', TO_DATE('1899-01-01', 'YYYY-MM-DD'));

                -- Сохраняем таблицы, фиксируя изменения --

COMMIT;