"""SQL 파일을 SQLite DB(data/defects.db)에 실행하고 SELECT 결과를 표로 출력합니다.

사용법 (프로젝트 폴더에서):
    python sql/run.py sql/schema.sql
    python sql/run.py sql/sample_data.sql
    python sql/run.py sql/analysis.sql
"""
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent.parent / "data" / "defects.db"


def print_table(cursor, rows):
    headers = [d[0] for d in cursor.description]
    widths = [len(h) for h in headers]
    for row in rows:
        for i, v in enumerate(row):
            widths[i] = max(widths[i], len(str(v)))
    line = " | ".join(h.ljust(widths[i]) for i, h in enumerate(headers))
    print(line)
    print("-" * len(line))
    for row in rows:
        print(" | ".join(str(v).ljust(widths[i]) for i, v in enumerate(row)))
    print(f"({len(rows)} rows)\n")


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)

    sql_text = Path(sys.argv[1]).read_text(encoding="utf-8")
    DB_PATH.parent.mkdir(exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")  # FOREIGN KEY 검사 켜기
    cur = conn.cursor()

    for stmt in sql_text.split(";"):
        # 주석(--) 줄 제거 후 빈 문장은 건너뜀
        body = "\n".join(l for l in stmt.splitlines() if not l.strip().startswith("--")).strip()
        if not body:
            continue
        try:
            cur.execute(body)
        except sqlite3.Error as e:
            print(f"[에러] {e}\n--- 문제의 쿼리 ---\n{body}\n")
            conn.rollback()
            conn.close()
            sys.exit(1)
        if cur.description:  # SELECT처럼 결과가 있는 쿼리
            print(f">>> {body.splitlines()[0]} ...")
            print_table(cur, cur.fetchall())

    conn.commit()
    conn.close()
    print(f"완료: {DB_PATH}")


if __name__ == "__main__":
    main()
