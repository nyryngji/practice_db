-- 1. 회원가입
INSERT INTO 회원 VALUES(회원_seq.nextval,
			'가상회원','010-1111-2222','대한민국 서울','어딘가',
			'welcome',2000,
			'email@naver.com','pwd',
			sysdate,'F',NULL,NULL);

select * from 회원 where 회원명 = '가상회원'; -- 회원ID = 99952 


-- 2. 쿠폰 다운받기
insert into 쿠폰이력 values (쿠폰이력_seq.nextval, 1, 99952, 'N');
insert into 쿠폰이력 values (쿠폰이력_seq.nextval, 4, 99952, 'N');
insert into 쿠폰이력 values (쿠폰이력_seq.nextval, 8, 99952, 'N');
insert into 쿠폰이력 values (쿠폰이력_seq.nextval, 10, 99952, 'N');
insert into 쿠폰이력 values (쿠폰이력_seq.nextval, 12, 99952, 'N');
commit;

-- 3. 가장 싼 거 조회하기
select 상품ID from
(SELECT 상품ID, 원가 * ((100 - 할인율)/100) as 실제가 
from 상품
where 상품분류 = '넘버 시리즈'
order by 실제가)
where rownum <= 1;

-- 4. 제품 10개 주문하기
insert into 주문 values -- 35002
(주문_seq.nextval, 99952, 결제_seq.nextval, '주문완료', 1000, sysdate);

insert into 주문상세 values -- 1000001
(주문상세_seq.nextval, 21033, 주문_seq.CURRVAL, 10, 'Y');

-- 5. 포인트 차감

insert into 포인트 values
(포인트_seq.nextval, 99952, 350002, 1000, sysdate, '사용');
update 회원
set 포인트 = 포인트 - 1000
where 회원ID = 99952;
commit;


-- 6. 총상품가격 계산하기
select 원가 * ((100 - 할인율)/100) * 주문수량 + 
case when 쇼핑백선택여부 = 'Y' then 300 else 0 end as 총상품가격, 배송비
from
(select * from 주문상세
where 주문상세ID = 1000001) a
join 상품 
on a.상품ID = 상품.상품ID;

-- 7. 사용자가 쓸 수 있는 쿠폰 조회 - 1번
select * from
((select * from 쿠폰이력 
where 회원ID = 99952) a
join 쿠폰 
on a.쿠폰ID = 쿠폰.쿠폰ID and sysdate BETWEEN 시작날짜 and 만료날짜);


-- 8. 결제
select * from 결제;
insert into 결제 values
(결제_seq.nextval, 350002, '결제완료', sysdate, '네이버페이', 37500, 0, 1, null, 7000);

update 쿠폰이력
set 사용여부 = 'Y'
where 회원ID = 99952 and 쿠폰ID = 1;

commit;

-- 9. 배송

select * from 주문 
where 주문ID = 350002;

insert into 배송 values
(배송_seq.nextval, 350002, '003849494', '한진택배', '55678', '대한민국 서울', '어딘가', '가상회원', '010-1111-2222', '');
commit;

-- 10. 회원이 최근 본 상품 조회
SELECT p.상품ID, p.상품명, r.조회일자
FROM 최근본상품 r
JOIN 상품 p ON r.상품ID = p.상품ID
WHERE r.회원ID = :회원ID
ORDER BY r.조회일자 DESC;

-- 11. 장바구니 기준 주문 총 금액 계산
SELECT SUM(c.상품수량 * p.원가 * (1 - p.할인율))
FROM 장바구니 c
JOIN 상품 p ON c.상품ID = p.상품ID
WHERE c.회원ID = :회원ID;

-- 12. 최근 3개월 내 구매금액이 150,000원을 넘어가서 다음 달 1일에 welcome -> family로 등급업하는
--     회원 조회
-- 배송 완료일이 없어서 일단은 주문 날짜 3일 뒤로 함 (날짜가 없어서 그런지 조회는 안 됨)

SELECT
    m.회원ID,
    m.회원등급 AS 현재등급,
    SUM(p.총상품금액 + p.배송비) AS 최근3개월구매금액,
    'Family' AS 변경예정등급,
    TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM') AS 등급반영일
FROM 회원 m
JOIN 주문 o   ON m.회원ID = o.회원ID
JOIN 결제 p   ON o.주문ID = p.주문ID
JOIN 배송 d   ON o.주문ID = d.주문ID
WHERE p.결제날짜 + 3 <= SYSDATE - 7
  AND p.결제날짜 + 3 >= ADD_MONTHS(TRUNC(SYSDATE), -3)
  AND m.회원등급 IN ('Welcome', 'Welcome(신규회원)')
GROUP BY m.회원ID, m.회원등급
HAVING SUM(p.총상품금액 + p.배송비) >= 600000;

-- 13. 오늘 기준 최근 3개월 동안 주문 건수가 가장 많은 회원 TOP 5
SELECT
    m.회원ID,
    COUNT(o.주문ID) AS 주문건수
FROM 회원 m
JOIN 주문 o
  ON m.회원ID = o.회원ID
WHERE o.주문날짜 >= ADD_MONTHS(TRUNC(SYSDATE), -3)
GROUP BY m.회원ID
ORDER BY 주문건수 DESC
FETCH FIRST 5 ROWS ONLY;


-- 여기부터는 인덱스 없으니깐 버벅거림

-- 14. 최근 3개월 회원별 실결제 금액 + 주문 수 + 평균 주문금액
SELECT
    m.회원ID,
    COUNT(DISTINCT o.주문ID)              AS 주문건수,
    SUM(p.총상품금액 + p.배송비)           AS 총구매금액,
    AVG(p.총상품금액 + p.배송비)           AS 평균주문금액
FROM 회원 m
JOIN 주문 o   ON m.회원ID = o.회원ID
JOIN 결제 p   ON o.주문ID = p.주문ID
JOIN 배송 d   ON o.주문ID = d.주문ID
  AND p.결제날짜 + 3 <= SYSDATE - 7
  AND p.결제날짜 + 3 >= ADD_MONTHS(TRUNC(SYSDATE), -3)
GROUP BY m.회원ID;

-- 15. 최근 6개월간 재구매율
SELECT
    COUNT(DISTINCT CASE WHEN 주문횟수 >= 2 THEN 회원ID END)
    / COUNT(DISTINCT 회원ID) * 100 AS 재구매율
FROM (
    SELECT
        m.회원ID,
        COUNT(o.주문ID) AS 주문횟수
    FROM 회원 m
    JOIN 주문 o ON m.회원ID = o.회원ID
    WHERE o.주문날짜 >= ADD_MONTHS(TRUNC(SYSDATE), -6)
    GROUP BY m.회원ID
);

-- 16. 쿠폰 발급 대비 실제 사용률
SELECT
    k.쿠폰ID,
    COUNT(h.쿠폰이력ID)                           AS 발급수,
    COUNT(CASE WHEN h.사용여부 = 'Y' THEN 1 END) AS 사용수,
    ROUND(
        COUNT(CASE WHEN h.사용여부 = 'Y' THEN 1 END)
        / COUNT(h.쿠폰이력ID) * 100, 2
    ) AS 사용률
FROM 쿠폰 k
JOIN 쿠폰이력 h ON k.쿠폰ID = h.쿠폰ID
GROUP BY k.쿠폰ID;

-- 17. 상품별 “장바구니 담김 → 구매 전환율”
SELECT
    p.상품ID,
    COUNT(DISTINCT c.회원ID) AS 장바구니담김회원수,
    COUNT(DISTINCT o.회원ID) AS 구매회원수,
    case when COUNT(DISTINCT o.회원ID) > 0 and
    COUNT(DISTINCT c.회원ID) > 0 then 
    ROUND(
        COUNT(DISTINCT o.회원ID)
        / COUNT(DISTINCT c.회원ID) * 100, 2
    ) else 0 end as 전환율
FROM 상품 p
LEFT JOIN 장바구니 c ON p.상품ID = c.상품ID
LEFT JOIN 주문상세 od ON p.상품ID = od.상품ID
LEFT JOIN 주문 o ON od.주문ID = o.주문ID
GROUP BY p.상품ID;

-- 18. 회원별 쿠폰 사용으로 절감한 총 금액
SELECT
    m.회원ID,
    SUM(c.할인금액) AS 쿠폰절감액
FROM 회원 m
JOIN 쿠폰이력 h ON m.회원ID = h.회원ID
JOIN 쿠폰 c ON h.쿠폰ID = c.쿠폰ID
WHERE h.사용여부 = 'Y'
GROUP BY m.회원ID;

-- 19. 상품별 리뷰 작성률 (구매 대비)
SELECT
    p.상품ID,
    COUNT(DISTINCT r.리뷰ID) / COUNT(DISTINCT od.주문상세ID) * 100
        AS 리뷰작성률
FROM 상품 p
JOIN 주문상세 od ON p.상품ID = od.상품ID
LEFT JOIN 리뷰 r ON od.상품ID = r.상품ID
GROUP BY p.상품ID;

-- 20. 장바구니에 담고 구매 안 한 회원 (최근 30일)
SELECT DISTINCT
    c.회원ID
FROM 장바구니 c
LEFT JOIN 주문 o
  ON c.회원ID = o.회원ID
 AND o.주문날짜 >= c.추가날짜
WHERE c.추가날짜 >= SYSDATE - 30
  AND o.주문ID IS NULL;

-- 21. 회원별 쿠폰 사용 / 미사용 평균 결제금액
WITH 쿠폰사용회원 AS (
    SELECT DISTINCT 회원ID
    FROM 쿠폰이력
    WHERE 사용여부 = 'Y'
),
회원주문 AS (
    SELECT
        o.회원ID,
        p.총상품금액 + p.배송비 as 실결제금액,
        CASE
            WHEN cs.회원ID IS NOT NULL THEN 'Y'
            ELSE 'N'
        END AS 쿠폰사용여부
    FROM 주문 o
    JOIN 결제 p ON o.주문ID = p.주문ID
    LEFT JOIN 쿠폰사용회원 cs
           ON o.회원ID = cs.회원ID
)
SELECT
    회원ID,
    AVG(CASE WHEN 쿠폰사용여부 = 'Y' THEN 실결제금액 END)
        AS 쿠폰사용평균결제금액,
    AVG(CASE WHEN 쿠폰사용여부 = 'N' THEN 실결제금액 END)
        AS 쿠폰미사용평균결제금액
FROM 회원주문
GROUP BY 회원ID;

