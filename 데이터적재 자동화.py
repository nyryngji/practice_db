import pandas as pd
from datetime import datetime, timedelta
import random
from multiprocessing import Pool, cpu_count
import csv
from functools import partial
import oracledb

oracledb.init_oracle_client(lib_dir=r"D:\\instantclient_23_9")

conn = oracledb.connect(
    user="KMJ",
    password="DBStudy2025!",
    dsn="dbstudy1205_medium"
)

# 테이블 불러오기

# condi_df = pd.read_sql('''SELECT 주문.주문ID, 회원.주소, 회원.상세주소, 회원.회원명, 회원.전화번호 from 주문
#                     join 회원
#                     on 주문.회원ID = 회원.회원ID''', conn)
# condi_df.reset_index(drop=True)

# condi_df = pd.read_sql('''SELECT * from
#                         (SELECT a.주문ID, sum(a.상품금액) - sum(a.사용포인트) / COUNT(a.사용포인트) 상품금액,
#                         case when sum(a.상품금액) >= 30000 then 0 else 3000 end as 배송비
#                         from
#                         (SELECT o.주문ID, o.사용포인트, 원가 * ((100-할인율)/100) * od.주문수량 상품금액
#                         from 주문 o
#                             join 주문상세 od
#                                 on o.주문ID = od.주문ID
#                             join 상품 p
#                                 on od.상품ID = p.상품ID) a
#                         GROUP by a.주문ID) b''',conn)
# condi_df.reset_index(drop=True)

# delivery_df = pd.read_sql('select * from 배송', conn)
# pay_df = pd.read_sql('select * from 결제', conn)
review_df = pd.read_sql('select * from 리뷰', conn)
o_od = pd.read_sql('''
                   SELECT 주문상세.상품ID, 주문.회원ID, 주문.주문날짜 
                   from 주문상세
				   JOIN 주문
				   on 주문.주문ID = 주문상세.주문ID
                   where rownum <=500000
                   ''',conn)


conn.close()

# order_ids = order_df['주문ID'].tolist()
# product_ids = product_df['상품ID'].tolist()
        

# order_detail_df_cols = list(order_detail_df.columns)

# delivery_df_cols = list(delivery_df.columns)

review_df_cols = list(review_df.columns)

# def generate_personal_q(seq, cols):
#     data = [
# 		int(seq),
# 		int(random.choice(user_ids)),
# 		random.choice(['문의합니다','문의문의','문의무니','문의']),
# 		datetime.today() - timedelta(days=random.randint(600,1200)),
# 		random.choice(['문의내용111111111','배송 언제와여','','재고 언제 들어와여'])
# 	] + random.choice([['답변완료',int(random.choice(manager_ids)), random.choice(['관리자 답변내용','때되면 재고 들어옵니다', '배송 좀만 기달리셈'])],
#                        ['답변대기중',int(random.choice(manager_ids)),None]])

#     return dict(zip(cols, data))

# def cart(seq, cols):
#     # user_ids = user_df['회원ID'].tolist()
#     # product_ids = product_df['상품ID'].tolist()
    
#     data = [
# 		int(seq),	
# 		int(random.choice(user_ids)),
# 		int(random.choice(product_ids)),
# 		int(random.randint(1,10)),
# 		datetime.today() + timedelta(seconds=random.randint(500, 1000))
# 	]
#     return dict(zip(cols, data))


# def product_q(seq, cols):
#     data = [
# 		int(seq),
# 		int(random.choice(product_ids)),
# 		int(random.choice(user_ids)),
# 		random.choice(['상품문의','문의 드립니다','문의문의']),
# 		random.choice(['Y','N']),
# 		random.choice(['재고 언제 들어와요','유통기한 언제까지에요','카페인 몇 그램이에요?',''])
# 	] + random.choice([['답변완료',int(random.choice(manager_ids)),'안녕하세요 고객님 문의내역 어쩌구'], ['답변대기중',None, None]])
    
#     return dict(zip(cols, data))

# def coupon_record(seq, cols):
#     data = [
# 			int(seq),
# 			int(random.choice(coupon_ids)),
# 			int(random.choice(user_ids)),
# 			'N'			
# 	]
#     return dict(zip(cols, data))

# def order(seq, cols):
#     data = [
# 			int(seq), # 주문ID
# 			int(random.choice(user_ids)), # 회원ID
#             int(seq), # 결제ID
#             '주문완료', # 주문상태
#             int(random.choice(range(0, 10000, 100))), # 사용포인트
#             coupon_min_date['MIN(시작날짜)'].iloc[0] + timedelta(days=random.randint(10,35)) # 주문날짜
# 	]
#     return dict(zip(cols, data))

# def point(seq, cols):
#     data = [
#             int(seq),
#             order_df['회원ID'].iloc[seq-1],
#             order_df['주문ID'].iloc[seq-1],
#             order_df['사용포인트'].iloc[seq-1],
#             order_df['주문날짜'].iloc[seq-1],
#             '사용'
# 			]
#     return dict(zip(cols, data))

# def order_detail(seq, cols):
#     data = [
#             int(seq),
#             int(random.choice(product_ids)),
#             int(random.choice(order_ids)),
#             int(random.randint(1,5)),
#             random.choice(['Y','N'])
# 			]
#     return dict(zip(cols, data))

import random

# def delivery(record, cols):
#     seq = record['seq']
#     order_id = record['주문ID']
#     address = record['주소']
#     address_d = record['상세주소']
#     username = record['회원명']
#     telephone = record['전화번호']

#     data = [
#         seq,                # seq 유지
#         order_id,           # 주문ID (중복 불가)
#         ''.join(str(random.randint(0, 9)) for _ in range(9)),
#         random.choice(['롯데택배','CJ대한통운','한진택배','로젠택배','우체국택배']),
#         ''.join(str(random.randint(0, 9)) for _ in range(5)),
#         address,
#         address_d,
#         username,
#         telephone,
#         random.choice([
#             '문 앞에 놔주세요',
#             '집 앞에 놔주세요',
#             '택배함에 놔주세요',
#             '경비실에 맡겨주세요',
#             '배송 전에 미리 연락바랍니다',
#             ''
#         ])
#     ]
#     return dict(zip(cols, data))

records = [
    {'seq': i + 1, **row}
    for i, row in enumerate(o_od.to_dict('records')) # seq, 결제ID, 주문ID, 주문날짜
]

def review(record, cols):
    data = [
        int(record['seq']),
        int(record['상품ID']),
        int(record['회원ID']),
        random.randint(1,5),
        '리뷰 내용',
        pd.to_datetime(record['주문날짜']),
        'N'
    ]
    return dict(zip(cols, data))
    

if __name__ == "__main__":
    gen_func = partial(review, cols=review_df_cols)

    with open(
        "데이터_리뷰테이블.csv",
        "w",
        newline="",
        encoding="utf-8-sig"
    ) as f:
        writer = csv.DictWriter(f, fieldnames=review_df_cols)
        writer.writeheader()
        
        with Pool(processes=cpu_count() // 2) as pool:
            for result in pool.imap_unordered(
                gen_func,
                records,
                chunksize=500
            ):
                writer.writerow(result)