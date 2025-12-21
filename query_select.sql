SELECT
    P.상품ID,
    P.상품명,
    COUNT(DISTINCT OD.주문ID) AS 주문건수,
    COUNT(DISTINCT R.리뷰ID) AS 리뷰수,
    COUNT(DISTINCT Q.상품문의ID) AS 문의수
FROM 상품 P
LEFT JOIN 주문상세 OD ON P.상품ID = OD.상품ID
LEFT JOIN 주문 O ON OD.주문ID = O.주문ID
LEFT JOIN 리뷰 R ON P.상품ID = R.상품ID
LEFT JOIN 상품문의 Q ON P.상품ID = Q.상품ID
WHERE O.주문날짜 >= ADD_MONTHS(SYSDATE, -6)
GROUP BY P.상품ID, P.상품명
ORDER BY 주문건수 DESC;