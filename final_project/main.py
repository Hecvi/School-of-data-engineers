import os
import pandas as pd
import jaydebeapi as pi
from datetime import datetime


'''
Проверяем сначала на наличие файлов. Если файлов одного типа несколько, то делаем так: у паспортов берем последний файл,
у списка терминалов файл на текущий день, так как терминалы в теории могут как добавляться, так и быть исключенными,
например, из-за закрытия магазина с pos-терминалом или тц, где стоял банкомат, а также берем транзакции за этот день.
Создаем словарь из файлов, где ключ - день, а значения - это список файлов. Сохраняем их. Потом по очереди будем
вызывать эти файлы. Файл с паспортами будет один на все файлы. Сохраняем его отдельно
'''


def find_and_sort_files():
    files, f_dict, dict_f_types, f_name_pass = os.listdir('.'), {}, {'term': '', 'trans': ''}, 0
    first_date = datetime.strptime('01011900', '%d%m%Y')
    for file in files:
        f_name = file.split('_')
        dt = f_name[-1].split('.')[0]
        if f_name[0] == 'passport':
            date = datetime.strptime(dt, '%d%m%Y')
            if date > first_date:
                first_date = date
                f_name_pass = file
        elif f_name[0] == 'terminals':
            if dt not in f_dict:
                f_dict[dt] = dict_f_types.copy()
            f_dict[dt]['term'] = file
        elif f_name[0] == 'transactions':
            if dt not in f_dict:
                f_dict[dt] = dict_f_types.copy()
            f_dict[dt]['trans'] = file
    sort_f_dict = dict(sorted(f_dict.items(), key=lambda x: datetime.strptime(x[0], '%d%m%Y')))
    return sort_f_dict, f_name_pass


'''
Соединяемся с сервером
'''


def connection_to_server():
    con = pi.connect('oracle.jdbc.driver.OracleDriver',
                      'jdbc:oracle:thin:itde1/bilbobaggins@de-oracle.chronosavant.ru:1521/deoracle',
                      ['itde1', 'bilbobaggins'], '/home/itde1/ojdbc8.jar')
    return con


'''
Подаем на вход путь к файлу sql. Дробим запросы по ";", также отбрасываем комментарии (обратите внимание,
что это работает только с моим видом комментариев. Сохраняем обработанные запросы в список
'''


def sql_script_parser(sql_file):
    with open(sql_file, 'r') as f:
        file = f.read()
        sql_ls = list(map(lambda s: s.strip(), file.split(';')))
        for i in range(len(sql_ls)):
            search = sql_ls[i].rfind('--')
            if search != -1:
                sql_ls[i] = sql_ls[i][search + 2:].strip()
        sql_ls.pop()
    return sql_ls


'''
Выполняем скрипт "start.sql" по созданию шаблонов таблиц
'''


def run_sql(con, sql_ls):
    curs = con.cursor()
    for elem in sql_ls:
        curs.execute(elem)
    con.commit()
    curs.close()


'''
Загружаем данные из файла "terminals_...xlsx" в СУБД, добавляя столбец "create_dt"
'''


def prep_and_filling_terminals_file(con, file, dt):
    curs = con.cursor()
    df = pd.read_excel(file, sheet_name='terminals', header=0, index_col=None)
    df['create_dt'] = datetime.strptime(dt, '%d%m%Y')
    df = df.astype(str)
    curs.executemany("INSERT INTO itde1.hecv_terminals(terminal_id, terminal_type, terminal_city, terminal_address,"
                     "create_dt) VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS'))", df.values.tolist())
    curs.close()


'''
Загружаем данные из файла "transactions_...xlsx" в СУБД
'''


def prep_and_filling_transactions_file(con, file):
    curs = con.cursor()
    df = pd.read_csv(file, sep=';')
    df = df.reindex(columns=['transaction_id', 'transaction_date', 'card_num', 'oper_type', 'amount', 'oper_result',
                             'terminal'])
    df = df.astype(str)
    curs.executemany("INSERT INTO itde1.hecv_transactions(trans_id, trans_date, card_num, oper_type, amt, oper_result,"
                     "terminal) VALUES (?, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS'), ?, ?, ?, ?, ?)", df.values.tolist())
    curs.close()


'''
Отправляем все файлы, что нам пришли попарно в СУБД + делаем инкрементальную загрузку
'''


def sending_files_to_oracle(con, files):
    for elem in files:
        if files[elem]['term']:
            prep_and_filling_terminals_file(con, files[elem]['term'], elem)
        if files[elem]['trans']:
            prep_and_filling_transactions_file(con, files[elem]['trans'])
        sql_ls = sql_script_parser('/home/itde1/HECV/sql_scripts/incremental_scd1.sql')
        run_sql(con, sql_ls)


'''
Загружаем данные из файла "passport_blacklist_...xlsx" в СУБД
'''


def prep_and_filling_passports_file(con, passp):
    curs = con.cursor()
    df = pd.read_excel(passp, sheet_name='blacklist', header=0, index_col=None)
    df = df.reindex(columns=['passport', 'date'])
    df = df.astype(str)
    curs.executemany("INSERT INTO itde1.hecv_passport_blacklist(passport_num, entry_dt) VALUES (?, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS'))",
                     df.values.tolist())
    curs.close()


'''
Проверяем есть ли у нас на входе хотя бы один файл каждого типа. Эта проверка необходима потому, что нет уверенности,
что sql-скрипты будут работать корректно, если у нас одна из таблиц в хранилище окажется пустой
'''


def checking_for_existing_files(f_dict, passp):
    term, trans = 0, 0
    for elem in f_dict:
        if f_dict[elem]['term']:
            term += 1
        if f_dict[elem]['trans']:
            trans += 1
    if not term or not trans or not passp:
        if not passp:
            print('File "passport_blacklist.xlsx" not found')
        if not term:
            print('File "terminals.xlsx" not found')
        if not trans:
            print('File "transactions.txt" not found')
        exit(1)
    return None


'''
Создаем папку "archive", отправляем в нее отработанные файлы и переименовываем их
'''


def archiving_files():
    path = '/home/itde1/HECV/'
    folder = '/home/itde1/HECV/archive/'
    if not os.path.isdir(folder):
        try:
            os.mkdir(folder)
        except OSError:
            print('Failed to create a folder "archive"')
        else:
            print('Folder "archive" created successfully')
    for file in os.listdir(path):
        if file.endswith('.txt') or file.endswith('.xlsx'):
            os.replace(path + file, folder + file)
            os.rename(folder + file, folder + file + '.backup')


if __name__ == "__main__":
    f_dict, passports = find_and_sort_files()
    checking_for_existing_files(f_dict, passports)
    con = connection_to_server()
    con.jconn.setAutoCommit(False)  # Отключаем автокоммит. Надеюсь команда правильная
    prep_and_filling_passports_file(con, passports)
    sending_files_to_oracle(con, f_dict)
    archiving_files()
    con.close()
