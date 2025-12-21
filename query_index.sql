-- 주문 : (주문ID,주문날짜) -> 복합 b트리
DROP INDEX 주문_idx;
CREATE INDEX 주문_idx on 주문(주문ID,주문날짜); -- 이건 생성됨

-- 회원 : 회원ID(b트리)
DROP INDEX 회원ID_idx;
CREATE INDEX 회원ID_idx on 회원(회원ID); -- 이미 인덱싱되어있음

-- 결제 : 결제ID(b트리)
DROP INDEX 결제ID_idx;
CREATE INDEX 결제ID_idx on 결제(결제ID); -- 이미 인덱싱되어있음

DROP INDEX 주문상세복합_idx;
CREATE INDEX 주문상세복합_idx on 주문상세(주문ID, 상품ID); -- 이건 성공

-- 주문상세 : 주문ID, 상품ID (IOT) -- 써보고 싶었는데 
-- DatabaseError: ORA-30036: unable to extend segment by 8 in undo tablespace 'UNDOTBS1'
-- 언두 사용량이 급증해서 못 써먹음

-- CREATE TABLE 주문상세_iot (
--     주문상세ID   NUMBER NOT NULL,
--     상품ID   NUMBER NOT NULL,
--     주문ID     NUMBER NOT NULL,
--     주문수량     NUMBER NOT NULL,
--     쇼핑백선택여부 CHAR(1),
--     CONSTRAINT 주문상세_pk PRIMARY KEY (주문ID, 상품ID)
-- )
-- ORGANIZATION INDEX;

-- INSERT INTO 주문상세_iot
-- SELECT *
-- FROM   주문상세
-- WHERE  (주문ID, 상품ID) IN (
--     SELECT 주문ID, 상품ID
--     FROM   주문상세
--     GROUP  BY 주문ID, 상품ID
--     HAVING COUNT(*) = 1
-- );

-- COMMIT;

-- 락걸린 세션 확인 
-- SELECT
--   lo.session_id sid,
--   s.serial#,
--   s.username,
--   o.object_name,
--   o.object_type,
--   s.status
-- FROM v$locked_object lo
-- JOIN dba_objects o ON o.object_id = lo.object_id
-- JOIN v$session s ON s.sid = lo.session_id;


-- 상품 : 상품ID(b트리)
DROP INDEX 상품ID_idx;
CREATE INDEX 상품ID_idx on 상품(상품ID); -- 이미 인덱싱되어있음
