import jaydebeapi as pi


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
Выполняем скрипт "delete_tables.sql" на удаление таблиц из СУБД
'''


def delete_tables(con, sql_ls):
    curs = con.cursor()
    for elem in sql_ls:
        curs.execute(elem)
    con.commit()
    curs.close()


if __name__ == "__main__":
    con = connection_to_server()
    con.jconn.setAutoCommit(False)  # Отключаем автокоммит. Надеюсь команда правильная
    sql_ls = sql_script_parser('/home/itde1/HECV/sql_scripts/delete_tables.sql')
    delete_tables(con, sql_ls)
    con.close()
