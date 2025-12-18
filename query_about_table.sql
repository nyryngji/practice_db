-- 회원

-- 1. 활성 회원 목록
SELECT 회원ID, 회원명, 이메일, 전화번호, 회원등급, 포인트
FROM 회원
WHERE 탈퇴여부 = 'N';

-- 2. 최근 가입 회원
SELECT 회원ID, 회원명, 이메일, 가입일
FROM 회원
ORDER BY 가입일 DESC
FETCH FIRST 20 ROWS ONLY;

-- 3. 포인트 상위 회원
SELECT 회원ID, 회원명, 포인트
FROM 회원
ORDER BY 포인트 DESC;

-- 4. 특정 등급 회원 조회
SELECT 회원ID, 회원명, 이메일
FROM 회원
WHERE 회원등급 = 'Family';

-- 상품 

-- 1. 전체 상품 목록 (가격 계산 포함)
SELECT 상품ID,
       상품명,
       원가,
       할인율,
       원가 * ((100 - 할인율) / 100) AS 판매가
FROM 상품;

-- 2. 카테고리별 상품
SELECT 상품ID, 상품명
FROM 상품
WHERE 상품분류 = '넘버 시리즈';

-- 3. 배송비 무료 상품
SELECT 상품ID, 상품명
FROM 상품
WHERE 배송비 = 0;

-- 4. 리뷰 평점 높은 상품
SELECT 상품ID, AVG(별점) AS 평균별점
FROM 리뷰
GROUP BY 상품ID
HAVING AVG(별점) >= 4.5;

-- 5. 가장 싼 상품 조회하기
select 상품ID from
(SELECT 상품ID, 원가 * ((100 - 할인율)/100) as 실제가 
from 상품
where 상품분류 = '넘버 시리즈'
order by 실제가)
where rownum <= 1;

-- 재고 

-- 1. 품절 임박 상품
SELECT 상품ID, 잔여수량
FROM 재고
WHERE 잔여수량 <= 10;

-- 2. 장기 미입고 상품
SELECT 상품ID, 마지막입고일
FROM 재고
WHERE 마지막입고일 < ADD_MONTHS(SYSDATE, -3);

-- 주문 

-- 1. 최근 주문 내역
SELECT 주문ID, 회원ID, 주문상태, 주문날짜
FROM 주문
ORDER BY 주문날짜 DESC;

-- 2. 회원별 주문 수
SELECT 회원ID, COUNT(*) AS 주문건수
FROM 주문
GROUP BY 회원ID;

-- 3. 미배송 주문
SELECT 주문ID, 주문날짜
FROM 주문
WHERE 주문상태 = '결제완료';



-- 주문상세

-- 1. 총 상품가격 계산하기
select 원가 * ((100 - 할인율)/100) * 주문수량 + 
case when 쇼핑백선택여부 = 'Y' then 300 else 0 end as 총상품가격, 배송비
from
(select * from 주문상세
where 주문상세ID = 1000001) a
join 상품 
on a.상품ID = 상품.상품ID;

-- 2. 쇼핑백 선택 상품
SELECT 주문ID, 상품ID
FROM 주문상세
WHERE 쇼핑백선택여부 = 'Y';

-- 결제

-- 1. 쿠폰 사용 결제
SELECT 결제ID, 주문ID, 적용쿠폰할인금액
FROM 결제
WHERE 적용쿠폰할인금액 > 0;

-- 배송

-- 1. 택배사별 배송 건수
SELECT 택배사명, COUNT(*) AS 배송건수
FROM 배송
GROUP BY 택배사명;

-- 장바구니

-- 1. 회원 장바구니 조회
SELECT 상품ID, 상품수량
FROM 장바구니
WHERE 회원ID = :member_id;

-- 리뷰 

-- 1. 상품별 리뷰 수
SELECT 상품ID, COUNT(*) AS 리뷰수
FROM 리뷰
WHERE 리뷰삭제여부 = 'N'
GROUP BY 상품ID;

-- 2. 최근 리뷰
SELECT 리뷰ID, 상품ID, 별점, 작성날짜
FROM 리뷰
ORDER BY 작성날짜 DESC;

-- 쿠폰 

-- 1. 사용 가능 쿠폰
SELECT 쿠폰ID, 쿠폰이름
FROM 쿠폰
WHERE SYSDATE BETWEEN 시작날짜 AND 만료날짜;

-- 포인트 

-- 1. 주문 적립 포인트
SELECT 주문ID, SUM(변동포인트)
FROM 포인트
WHERE 변동사유 = '적립'
GROUP BY 주문ID;

-- 통합 실무 조인

-- 1. 회원 주문 + 결제 상태
SELECT m.회원명, o.주문ID, o.주문상태, p.결제상태
FROM 회원 m
JOIN 주문 o ON m.회원ID = o.회원ID
JOIN 결제 p ON o.주문ID = p.주문ID;

-- 2. 주문별 배송 정보
SELECT o.주문ID, d.송장번호, d.택배사명
FROM 주문 o
JOIN 배송 d ON o.주문ID = d.주문ID;

-- 3. 상품 + 재고 상태
SELECT p.상품명, i.잔여수량
FROM 상품 p
JOIN 재고 i ON p.상품ID = i.상품ID;

-- 4. 회원별 총 구매금액
SELECT o.회원ID, SUM(p.총상품금액) AS 총구매금액
FROM 주문 o
JOIN 결제 p ON o.주문ID = p.주문ID
GROUP BY o.회원ID;

-- 5. 일별 주문 건수
SELECT TRUNC(주문날짜), COUNT(*)
FROM 주문
GROUP BY TRUNC(주문날짜);

-- 6. 월별 매출
SELECT TO_CHAR(결제날짜, 'YYYY-MM') AS 월,
       SUM(총상품금액)
FROM 결제
GROUP BY TO_CHAR(결제날짜, 'YYYY-MM');

-- 7. 상품별 판매 수량
SELECT 상품ID, SUM(주문수량)
FROM 주문상세
GROUP BY 상품ID;



-- 버벅거리는 쿼리

-- 1. 최근 3개월 회원별 실결제 금액 + 주문 수 + 평균 주문금액
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

-- 2. 최근 6개월간 재구매율
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

-- 3. 쿠폰 발급 대비 실제 사용률
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

-- 4. 상품별 “장바구니 담김 → 구매 전환율”
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

-- 5. 회원별 쿠폰 사용으로 절감한 총 금액
SELECT
    m.회원ID,
    SUM(c.할인금액) AS 쿠폰절감액
FROM 회원 m
JOIN 쿠폰이력 h ON m.회원ID = h.회원ID
JOIN 쿠폰 c ON h.쿠폰ID = c.쿠폰ID
WHERE h.사용여부 = 'Y'
GROUP BY m.회원ID;

-- 6. 상품별 리뷰 작성률 (구매 대비)
SELECT
    p.상품ID,
    COUNT(DISTINCT r.리뷰ID) / COUNT(DISTINCT od.주문상세ID) * 100
        AS 리뷰작성률
FROM 상품 p
JOIN 주문상세 od ON p.상품ID = od.상품ID
LEFT JOIN 리뷰 r ON od.상품ID = r.상품ID
GROUP BY p.상품ID;

-- 7. 장바구니에 담고 구매 안 한 회원 (최근 30일)
SELECT DISTINCT
    c.회원ID
FROM 장바구니 c
LEFT JOIN 주문 o
  ON c.회원ID = o.회원ID
 AND o.주문날짜 >= c.추가날짜
WHERE c.추가날짜 >= SYSDATE - 30
  AND o.주문ID IS NULL;

-- 8. 회원별 쿠폰 사용 / 미사용 평균 결제금액
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

-- [결론]

-- 주문 테이블이 가장 많이 참조됨
