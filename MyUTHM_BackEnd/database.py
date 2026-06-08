import sqlite3
from contextlib import contextmanager

DATABASE = "MyUTHM.db"

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row   # 让查询结果像 dict 一样访问
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        yield conn
    finally:
        conn.close()