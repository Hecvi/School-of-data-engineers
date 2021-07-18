                 -- Выполяем инкрементальную загрузку --
                         
                        -- Очищаем данные в STG --
                       
DELETE FROM itde1.hecv_stg_psprt_blst;
DELETE FROM itde1.hecv_stg_trnsctions;
DELETE FROM itde1.hecv_stg_terminals;
DELETE FROM itde1.hecv_stg_cards;
DELETE FROM itde1.hecv_stg_accounts;
DELETE FROM itde1.hecv_stg_clients;

DELETE FROM itde1.hecv_stg_terminals_del;
DELETE FROM itde1.hecv_stg_cards_del;
DELETE FROM itde1.hecv_stg_accounts_del;
DELETE FROM itde1.hecv_stg_clients_del;

                 -- Захватываем данные из источника в STG --
                    
INSERT INTO itde1.hecv_stg_psprt_blst(passport_num, entry_dt)
SELECT 
    passport_num,
    entry_dt
FROM itde1.hecv_passport_blacklist
WHERE entry_dt > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'ITDE1' AND table_name = 'HECV_DWH_FACT_PSPRT_BLST');
    
INSERT INTO itde1.hecv_stg_trnsctions(trans_id, trans_date, card_num, oper_type,
            amt, oper_result, terminal)
SELECT 
    trans_id,
    trans_date,
    card_num,
    oper_type,
    amt,
    oper_result,
    terminal
FROM itde1.hecv_transactions
WHERE trans_date > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'ITDE1' AND table_name = 'HECV_DWH_FACT_TRNSCTIONS');

INSERT INTO itde1.hecv_stg_terminals(terminal_id, terminal_type, terminal_city,
            terminal_address, create_dt)
SELECT 
	terminal_id,
    terminal_type,
    terminal_city,
    terminal_address,
    create_dt
FROM itde1.hecv_terminals
WHERE create_dt > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'ITDE1' AND table_name = 'HECV_DWH_DIM_TERMINALS');

INSERT INTO itde1.hecv_stg_cards(card_num, account_num, create_dt, update_dt)
SELECT 
    card_num,
    account,
    create_dt,
    update_dt
FROM bank.cards
WHERE COALESCE(update_dt, create_dt) > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'BANK' AND table_name = 'CARDS');

INSERT INTO itde1.hecv_stg_accounts(account_num, valid_to, client, create_dt,
            update_dt)
SELECT 
    account,
    valid_to,
    client,
    create_dt,
    update_dt
FROM bank.accounts
WHERE COALESCE(update_dt, create_dt) > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'BANK' AND table_name = 'ACCOUNTS');

INSERT INTO itde1.hecv_stg_clients(client_id, last_name, first_name, patronymic,
            date_of_birth, passport_num, passport_valid_to, phone, create_dt,
            update_dt)
SELECT 
    client_id,
    last_name,
    first_name,
    patronymic,
    date_of_birth,
    passport_num,
    passport_valid_to,
    phone,
    create_dt,
    update_dt
FROM bank.clients
WHERE COALESCE(update_dt, create_dt) > (
	SELECT last_update FROM itde1.hecv_meta_updates
    WHERE db_name = 'BANK' AND table_name = 'CLIENTS');

                   -- Вливаем данные в хранилище --

INSERT INTO itde1.hecv_dwh_fact_psprt_blst(passport_num, entry_dt)
SELECT
    passport_num,
    entry_dt
FROM itde1.hecv_stg_psprt_blst;

INSERT INTO itde1.hecv_dwh_fact_trnsctions(trans_id, trans_date, card_num,
            oper_type, amt, oper_result, terminal)
SELECT 
    trans_id,
    trans_date,
    card_num,
    oper_type,
    amt,
    oper_result,
    terminal
FROM itde1.hecv_stg_trnsctions;

MERGE INTO itde1.hecv_dwh_dim_terminals dwh
USING itde1.hecv_stg_terminals stg
ON (dwh.terminal_id = stg.terminal_id)
WHEN MATCHED THEN UPDATE SET
    dwh.terminal_type = stg.terminal_type,
    dwh.terminal_city = stg.terminal_city,
    dwh.terminal_address = stg.terminal_address,
    dwh.update_dt = stg.create_dt
WHEN NOT MATCHED THEN INSERT(terminal_id, terminal_type, terminal_city,
                            terminal_address, create_dt, update_dt)
VALUES (stg.terminal_id, stg.terminal_type, stg.terminal_city,
        stg.terminal_address, stg.create_dt, NULL);
        
MERGE INTO itde1.hecv_dwh_dim_cards dwh
USING itde1.hecv_stg_cards stg
ON (dwh.card_num = stg.card_num)
WHEN MATCHED THEN UPDATE SET
    dwh.account_num = stg.account_num,
    dwh.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT(card_num, account_num, create_dt, update_dt)
VALUES (stg.card_num, stg.account_num, stg.create_dt, NULL);

MERGE INTO itde1.hecv_dwh_dim_accounts dwh
USING itde1.hecv_stg_accounts stg
ON (dwh.account_num = stg.account_num)
WHEN MATCHED THEN UPDATE SET
    dwh.valid_to = stg.valid_to,
    dwh.client = stg.client,
    dwh.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT(account_num, valid_to, client, create_dt, update_dt)
VALUES (stg.account_num, stg.valid_to, stg.client, stg.create_dt, NULL);

MERGE INTO itde1.hecv_dwh_dim_clients dwh
USING itde1.hecv_stg_clients stg
ON (dwh.client_id = stg.client_id)
WHEN MATCHED THEN UPDATE SET
    dwh.last_name = stg.last_name,
    dwh.first_name = stg.first_name,
    dwh.patronymic = stg.patronymic,
    dwh.date_of_birth = stg.date_of_birth,
    dwh.passport_num = stg.passport_num,
    dwh.passport_valid_to = stg.passport_valid_to,
    dwh.phone = stg.phone,
    dwh.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT(client_id, last_name, first_name, patronymic,
                            date_of_birth, passport_num, passport_valid_to,
                            phone, create_dt, update_dt)
VALUES (stg.client_id, stg.last_name, stg.first_name, stg.patronymic,
        stg.date_of_birth, stg.passport_num, stg.passport_valid_to, stg.phone,
        stg.create_dt, NULL);

              -- Захватываем ключи для проверки удалений --

INSERT INTO itde1.hecv_stg_terminals_del(terminal_id)
SELECT terminal_id FROM itde1.hecv_terminals;

INSERT INTO itde1.hecv_stg_cards_del(card_num)
SELECT card_num FROM bank.cards;

INSERT INTO itde1.hecv_stg_accounts_del(account_num)
SELECT account FROM bank.accounts;

INSERT INTO itde1.hecv_stg_clients_del(client_id)
SELECT client_id FROM bank.clients;

           -- Удаляем удаленные записи в целевой таблице --

DELETE FROM itde1.hecv_dwh_dim_terminals
WHERE terminal_id IN (
SELECT
    dwh.terminal_id
FROM itde1.hecv_dwh_dim_terminals dwh
LEFT JOIN itde1.hecv_terminals sour
ON dwh.terminal_id = sour.terminal_id
WHERE sour.terminal_id IS NULL);

DELETE FROM itde1.hecv_dwh_dim_cards
WHERE card_num IN (
SELECT
    dwh.card_num
FROM itde1.hecv_dwh_dim_cards dwh
LEFT JOIN bank.cards sour
ON dwh.card_num = sour.card_num
WHERE sour.card_num IS NULL);

DELETE FROM itde1.hecv_dwh_dim_accounts
WHERE account_num IN (
SELECT
    dwh.account_num
FROM itde1.hecv_dwh_dim_accounts dwh
LEFT JOIN bank.accounts sour
ON dwh.account_num = sour.account
WHERE sour.account IS NULL);

DELETE FROM itde1.hecv_dwh_dim_clients
WHERE client_id IN (
SELECT
    dwh.client_id
FROM itde1.hecv_dwh_dim_clients dwh
LEFT JOIN bank.clients sour
ON dwh.client_id = sour.client_id
WHERE sour.client_id IS NULL);

             -- Обновляем метаданные (дату максимальной загрузуки) --

UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(entry_dt) FROM itde1.hecv_stg_psprt_blst)
WHERE 1=1
	AND db_name = 'ITDE1' 
	AND table_name = 'HECV_DWH_FACT_PSPRT_BLST' 
	AND (SELECT MAX(entry_dt) FROM itde1.hecv_stg_psprt_blst) IS NOT NULL;

UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(trans_date) FROM itde1.hecv_stg_trnsctions)
WHERE 1=1
	AND db_name = 'ITDE1' 
	AND table_name = 'HECV_DWH_FACT_TRNSCTIONS' 
	AND (SELECT MAX(trans_date) FROM itde1.hecv_stg_trnsctions) IS NOT NULL;

UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(create_dt) FROM itde1.hecv_dwh_dim_terminals)
WHERE 1=1
	AND db_name = 'ITDE1' 
	AND table_name = 'HECV_DWH_DIM_TERMINALS' 
	AND (SELECT MAX(create_dt) FROM itde1.hecv_dwh_dim_terminals) IS NOT NULL;

UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_cards)
WHERE 1=1
	AND db_name = 'BANK' 
	AND table_name = 'CARDS' 
	AND (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_cards) IS NOT NULL;
    
UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_accounts)
WHERE 1=1
	AND db_name = 'BANK' 
	AND table_name = 'ACCOUNTS' 
	AND (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_accounts) IS NOT NULL;
    
UPDATE itde1.hecv_meta_updates
SET last_update = (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_clients)
WHERE 1=1
	AND db_name = 'BANK' 
	AND table_name = 'CLIENTS' 
	AND (SELECT MAX(COALESCE(update_dt, create_dt)) FROM itde1.hecv_stg_clients) IS NOT NULL;

                -- Сохраняем транзакцию, фиксируя изменения --

COMMIT;
