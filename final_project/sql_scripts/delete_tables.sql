               -- Удаляем все созданные нами таблицы --
 
DROP TABLE itde1.hecv_passport_blacklist;

DROP TABLE itde1.hecv_transactions;
    
DROP TABLE itde1.hecv_terminals;

DROP TABLE itde1.hecv_stg_psprt_blst;
    
DROP TABLE itde1.hecv_stg_trnsctions;

DROP TABLE itde1.hecv_stg_terminals;

DROP TABLE itde1.hecv_stg_cards;

DROP TABLE itde1.hecv_stg_accounts;

DROP TABLE itde1.hecv_stg_clients;

DROP TABLE itde1.hecv_stg_terminals_del;

DROP TABLE itde1.hecv_stg_cards_del;

DROP TABLE itde1.hecv_stg_accounts_del;

DROP TABLE itde1.hecv_stg_clients_del;

DROP TABLE itde1.hecv_dwh_fact_psprt_blst;
  
DROP TABLE itde1.hecv_dwh_fact_trnsctions;

DROP TABLE itde1.hecv_dwh_dim_terminals;
 
DROP TABLE itde1.hecv_dwh_dim_cards;

DROP TABLE itde1.hecv_dwh_dim_accounts;

DROP TABLE itde1.hecv_dwh_dim_clients;

DROP TABLE itde1.hecv_meta_updates;

                -- Сохраняем транзакцию, фиксируя изменения --

COMMIT;