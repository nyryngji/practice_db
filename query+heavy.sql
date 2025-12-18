-- 2026년 회원 구매행태 통계 리포트

SELECT
    m.회원ID,
    m.회원명,
    m.회원등급,

    /* 주문 통계 */
    COUNT(DISTINCT o.주문ID)                AS 전체주문수,
    SUM(
        CASE
            WHEN o.주문상태 = '주문취소'
            THEN 1
            ELSE 0
        END
    )                                        AS 취소주문수,

    /* 결제 금액 */
    SUM(p.총상품금액)                       AS 누적결제금액,

    /* 상품군별 매출 */
    SUM(
        CASE
            WHEN pr.상품분류 = '넘버 시리즈'
            THEN od.주문수량 * pr.원가 * (1 - pr.할인율 / 100)
            ELSE 0
        END
    )                                        AS 커피매출,

    SUM(
        CASE
            WHEN pr.상품분류 = '악세서리'
            THEN od.주문수량 * pr.원가 * (1 - pr.할인율 / 100)
            ELSE 0
        END
    )                                        AS 악세서리매출,

    /* 최근 주문 정보 (JOIN으로 해결) */
    lo.주문날짜                              AS 최근주문일,
    lo.주문상태                              AS 최근주문상태

FROM 회원 m

JOIN 주문 o
    ON m.회원ID = o.회원ID

JOIN 결제 p
    ON o.주문ID = p.주문ID

JOIN 주문상세 od
    ON o.주문ID = od.주문ID

JOIN 상품 pr
    ON od.상품ID = pr.상품ID

/* 🔥 최근 주문을 미리 계산 (ORA-01427 완전 제거) */
LEFT JOIN (
    SELECT
        회원ID,
        주문날짜,
        주문상태
    FROM (
        SELECT
            o2.회원ID,
            o2.주문날짜,
            o2.주문상태,
            ROW_NUMBER() OVER (
                PARTITION BY o2.회원ID
                ORDER BY o2.주문날짜 DESC, o2.주문ID DESC
            ) AS rn
        FROM 주문 o2
    )
    WHERE rn = 1
) lo
    ON lo.회원ID = m.회원ID

WHERE 1 = 1

  /* 탈퇴 안 한 회원 (대부분) */
  AND NVL(m.탈퇴여부, 'N') = 'N'

  /* 날짜 밀집 + 함수 사용 (인덱스 무효 유지) */
  AND TO_CHAR(o.주문날짜, 'YYYY-MM-DD')
      BETWEEN '2025-01-01' AND '2025-12-31'

  /* 결제 완료 (대부분) */
  AND p.결제상태 = '결제완료'

  /* 쿠폰 미사용 유저가 대부분 → 상관 서브쿼리 유지 */
  AND NOT EXISTS (
        SELECT 1
        FROM 결제 px
        WHERE px.주문ID = o.주문ID
          AND NVL(px.적용쿠폰할인금액, 0) > 0
  )

  /* 선택도 거의 없는 조건 */
  AND (
        m.회원등급 <> 'VIP'
        OR m.회원등급 IS NULL
  )

GROUP BY
    m.회원ID,
    m.회원명,
    m.회원등급,
    lo.주문날짜,
    lo.주문상태

HAVING
    SUM(p.총상품금액) >= 500000
    AND COUNT(DISTINCT o.주문ID) >= 3

ORDER BY
    누적결제금액 DESC,
    커피매출 DESC;
