import oracledb
import pandas as pd
import random
import string
import requests
from datetime import datetime, timedelta
import csv
from multiprocessing import Pool, cpu_count

name_df = pd.read_csv('한국인이름.csv')
address = pd.read_csv('주소.csv')

oracledb.init_oracle_client(lib_dir=r"D:\\instantclient_23_9")

conn = oracledb.connect(
    user="KMJ",          # 사용자명
    password="DBStudy2025!",      # 비밀번호
    dsn="dbstudy1205_medium" # 접속 정보 (SQL Developer와 동일)
)
cur = conn.cursor()

# 현재 시퀀스 값 반환하기
def return_sequence_value(sequence_name):
	query = f'select {sequence_name}.nextval from dual'
	sequence = pd.read_sql(query, conn)
	return sequence.iat[0, 0]

# 한국 이름 반환
def return_korean_name():
	return random.choice(name_df['한국인이름'])

# 랜덤으로 이메일 생성
def random_email():
    domains = ["gmail.com", "naver.com", "daum.net", "hotmail.com", "yahoo.com"]
    name_length = random.randint(6, 12)  # 아이디 길이
    name = ''.join(random.choices(string.ascii_lowercase + string.digits, k=name_length))
    domain = random.choice(domains)
    return f"{name}@{domain}"

# 랜덤으로 전화번호 생성
def random_phone_number():
    f = str(random.randint(1,9999))
    s = str(random.randint(1,9999))
    middle = '0' * (4-len(f)) + f
    last = '0' * (4-len(s)) + s
    phone_number = f'010-{middle}-{last}'
    return phone_number

# 랜덤으로 비밀번호 생성
def random_pwd():
    len_pwd = random.randint(12,16)  # 비밀번호 길이
    pwd = ''.join(random.choices(string.ascii_lowercase + string.digits + random.choice(string.punctuation), k=len_pwd))
    return pwd

def random_address():
	return random.choice(address['address'])

def random_birthday():
	return datetime.today() - timedelta(random.randint(5000,20000))

def random_gender():
    return random.choice(['F','M'])

def generate_user(cols):
    try:
        data = [
            0,
            return_korean_name(),
            random_phone_number(),
            random_address(),
            '.',
            random.choices(
                ['Welcome', 'Family', 'Vip', 'Platinum'],
                weights=[0.7, 0.15, 0.1, 0.05],
                k=1
            )[0],
            random.choices(range(0, 10001, 50), k=1)[0],
            random_email(),
            random_pwd(),
            random_birthday(),
            random_gender(),
            None,
            None
        ]
        return dict(zip(cols, data))
    except Exception:
        return None

COLS = ['회원ID', '회원명', '전화번호', '주소', '상세주소', '회원등급', '포인트', '이메일', '비밀번호',
       '생년월일', '성별', '탈퇴여부', '탈퇴날짜']

def task(_):
    return generate_user(COLS)

if __name__ == "__main__":
    with open("users.csv", "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=COLS)
        writer.writeheader()

        with Pool(cpu_count()) as pool:
            for result in pool.imap_unordered(
                task,
                range(100000),
                chunksize=200
            ):
                if result is not None:
                    writer.writerow(result)