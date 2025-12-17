SELECT
    o.결제ID,
    o.주문ID,
    '결제완료' AS 결제상태,
    o.주문날짜
        + NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(10, 20)), 'SECOND')
        AS 결제날짜,
    CASE MOD(o.주문ID, 3)
        WHEN 0 THEN '네이버페이'
        WHEN 1 THEN '카카오페이'
        ELSE '토스페이'
    END AS 결제수단,

    /* 상품금액 */
    NVL(
        SUM(p.원가 * ((100 - p.할인율) / 100) * od.주문수량),
        0
    ) - NVL(MAX(o.사용포인트), 0) AS 총상품금액,

    /* 배송비 */
    CASE
        WHEN NVL(SUM(p.원가 * ((100 - p.할인율) / 100) * od.주문수량), 0) >= 30000
            THEN 0
        ELSE 3000
    END AS 배송비,

    c.쿠폰ID as 사용가능쿠폰ID,
    c.할인율 as 적용쿠폰할인율,
    c.할인금액 as 적용쿠폰할인금액
FROM 주문 o
    LEFT JOIN 주문상세 od ON o.주문ID = od.주문ID
    LEFT JOIN 상품 p ON od.상품ID = p.상품ID
    LEFT JOIN (
        SELECT
            ch.회원ID,
            ch.쿠폰ID,
            c.할인율,
            c.할인금액,
            c.시작날짜,
            c.만료날짜,
            ROW_NUMBER() OVER (
                PARTITION BY ch.회원ID
                ORDER BY DBMS_RANDOM.VALUE
            ) rn
        FROM 쿠폰이력 ch
            JOIN 쿠폰 c ON ch.쿠폰ID = c.쿠폰ID
        WHERE ch.사용여부 = 'N'
    ) c
        ON o.회원ID = c.회원ID
        AND c.rn = 1
        AND o.주문날짜 BETWEEN c.시작날짜 AND c.만료날짜
GROUP BY
    o.결제ID,
    o.주문ID,
    o.주문날짜,
    o.회원ID,
    c.쿠폰ID,
    c.할인율,
    c.할인금액