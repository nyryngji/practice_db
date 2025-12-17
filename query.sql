CREATE TABLE "1:1문의" 
    ( 
     문의ID  NUMBER  NOT NULL , 
     회원ID  NUMBER , 
     문의제목  VARCHAR2 (200)  NOT NULL , 
     작성일   DATE  NOT NULL , 
     답변상태  VARCHAR2 (15)  NOT NULL , 
     관리자ID NUMBER , 
     문의내용  VARCHAR2 (500) 
    ) 
;

ALTER TABLE "1:1문의" 
    ADD CONSTRAINT "1:1문의_PK" PRIMARY KEY ( 문의ID ) ;

CREATE TABLE 결제 
    ( 
     결제ID       NUMBER  NOT NULL , 
     주문ID       NUMBER  NOT NULL , 
     결제상태       VARCHAR2 (20)  NOT NULL , 
     결제수단       VARCHAR2 (20)  NOT NULL , 
     총결제금액      NUMBER  NOT NULL , 
     배송비        NUMBER  NOT NULL , 
     사용가능쿠폰ID   NUMBER , 
     추가사용가능쿠폰ID NUMBER 
    ) 
;

ALTER TABLE 결제 
    ADD CONSTRAINT 결제_PK PRIMARY KEY ( 결제ID ) ;

ALTER TABLE 결제 
    ADD CONSTRAINT 결제__UN UNIQUE ( 주문ID ) ;

CREATE TABLE 관리자 
    ( 
     관리자ID   NUMBER  NOT NULL , 
     관리자이름   VARCHAR2 (20)  NOT NULL , 
     이메일     VARCHAR2 (100)  NOT NULL , 
     비밀번호    VARCHAR2 (50)  NOT NULL , 
     권한      VARCHAR2 (100)  NOT NULL , 
     계정생성일   DATE  NOT NULL , 
     계정상태    VARCHAR2 (20)  NOT NULL , 
     최근로그인시간 DATE  NOT NULL 
    ) 
;

ALTER TABLE 관리자 
    ADD CONSTRAINT 관리자_PK PRIMARY KEY ( 관리자ID ) ;

CREATE TABLE 리뷰 
    ( 
     리뷰ID   NUMBER  NOT NULL , 
     상품ID   NUMBER , 
     회원ID   NUMBER , 
     별점     NUMBER (1)  NOT NULL , 
     리뷰내용   VARCHAR2 (500)  NOT NULL , 
     작성날짜   DATE  NOT NULL , 
     리뷰삭제여부 CHAR (1)  NOT NULL 
    ) 
;

ALTER TABLE 리뷰 
    ADD CONSTRAINT 리뷰_PK PRIMARY KEY ( 리뷰ID ) ;

CREATE TABLE 배송 
    ( 
     배송ID   NUMBER  NOT NULL , 
     주문ID   NUMBER  NOT NULL , 
     송장번호   VARCHAR2 (15)  NOT NULL , 
     택배사명   VARCHAR2 (20)  NOT NULL , 
     우편번호   VARCHAR2 (5)  NOT NULL , 
     배송주소   VARCHAR2 (200)  NOT NULL , 
     배송상세주소 VARCHAR2 (100)  NOT NULL , 
     수취인명   VARCHAR2 (20)  NOT NULL , 
     수취인연락처 VARCHAR2 (13)  NOT NULL , 
     배송메모   VARCHAR2 (200) 
    ) 
;

ALTER TABLE 배송 
    ADD CONSTRAINT delivery_PK PRIMARY KEY ( 배송ID ) ;

ALTER TABLE 배송 
    ADD CONSTRAINT 배송_주문ID_UNIQUE UNIQUE ( 주문ID ) ;

CREATE TABLE 상품 
    ( 
     상품ID NUMBER  NOT NULL , 
     상품분류 VARCHAR2 (100)  NOT NULL , 
     상품명  VARCHAR2 (200)  NOT NULL , 
     원가   NUMBER  NOT NULL , 
     할인율  NUMBER (2)  NOT NULL , 
     상품설명 VARCHAR2 (500)  NOT NULL , 
     원산지  VARCHAR2 (30)  NOT NULL , 
     배송방법 VARCHAR2 (30)  NOT NULL , 
     배송비  NUMBER  NOT NULL 
    ) 
;

ALTER TABLE 상품 
    ADD CONSTRAINT 상품_PK PRIMARY KEY ( 상품ID ) ;

CREATE TABLE 상품문의 
    ( 
     상품문의ID NUMBER  NOT NULL , 
     상품ID   NUMBER , 
     회원ID   NUMBER , 
     제목     VARCHAR2 (200)  NOT NULL , 
     공개여부   CHAR (1)  NOT NULL , 
     내용     VARCHAR2 (500) 
    ) 
;

ALTER TABLE 상품문의 
    ADD CONSTRAINT 상품문의_PK PRIMARY KEY ( 상품문의ID ) ;

CREATE TABLE 이벤트 
    ( 
     이벤트ID  NUMBER  NOT NULL , 
     관리자ID  NUMBER  NOT NULL , 
     이벤트명   VARCHAR2 (200)  NOT NULL , 
     이벤트시작일 DATE  NOT NULL , 
     이벤트종료일 DATE  NOT NULL , 
     이벤트내용  VARCHAR2 (500)  NOT NULL 
    ) 
;

ALTER TABLE 이벤트 
    ADD CONSTRAINT 이벤트_PK PRIMARY KEY ( 이벤트ID ) ;

CREATE TABLE 장바구니 
    ( 
     장바구니ID NUMBER  NOT NULL , 
     회원ID   NUMBER , 
     상품ID   NUMBER , 
     상품수량   NUMBER  NOT NULL , 
     추가날짜   DATE  NOT NULL 
    ) 
;

ALTER TABLE 장바구니 
    ADD CONSTRAINT 장바구니_PK PRIMARY KEY ( 장바구니ID ) ;

CREATE TABLE 재고 
    ( 
     상품ID   NUMBER  NOT NULL , 
     잔여수량   NUMBER  NOT NULL , 
     마지막입고일 DATE  NOT NULL , 
     입고예상일  DATE  NOT NULL 
    ) 
;

ALTER TABLE 재고 
    ADD CONSTRAINT 재고_PK PRIMARY KEY ( 상품ID ) ;

CREATE TABLE 주문 
    ( 
     주문ID  NUMBER  NOT NULL , 
     회원ID  NUMBER , 
     결제ID  NUMBER  NOT NULL , 
     주문상태  VARCHAR2 (15)  NOT NULL , 
     사용포인트 NUMBER  NOT NULL 
    ) 
;

COMMENT ON COLUMN 주문.주문상태 IS '주문완료/주문취소/환불?' 
;

ALTER TABLE 주문 
    ADD CONSTRAINT 주문_PK PRIMARY KEY ( 주문ID ) ;

CREATE TABLE 주문상세 
    ( 
     주문상세ID  NUMBER  NOT NULL , 
     상품ID    NUMBER  NOT NULL , 
     주문ID    NUMBER  NOT NULL , 
     주문수량    NUMBER  NOT NULL , 
     쇼핑백선택여부 CHAR (1)  NOT NULL 
    ) 
;

ALTER TABLE 주문상세 
    ADD CONSTRAINT order_detail_PK PRIMARY KEY ( 주문상세ID, 상품ID ) ;

CREATE TABLE "최근 본 상품" 
    ( 
     최근본상품ID NUMBER  NOT NULL , 
     회원ID    NUMBER , 
     상품ID    NUMBER , 
     조회일자    DATE  NOT NULL 
    ) 
;

ALTER TABLE "최근 본 상품" 
    ADD CONSTRAINT "최근 본 상품_PK" PRIMARY KEY ( 최근본상품ID ) ;

CREATE TABLE 쿠폰 
    ( 
     쿠폰ID   NUMBER  NOT NULL , 
     관리자ID  NUMBER  NOT NULL , 
     쿠폰이름   VARCHAR2 (100)  NOT NULL , 
     최대할인금액 NUMBER  NOT NULL , 
     시작기간   DATE  NOT NULL , 
     할인율    NUMBER , 
     할인금액   NUMBER 
    ) 
;

ALTER TABLE 쿠폰 
    ADD CONSTRAINT 쿠폰_PK PRIMARY KEY ( 쿠폰ID ) ;

CREATE TABLE 쿠폰이력 
    ( 
     쿠폰이력ID NUMBER  NOT NULL , 
     쿠폰ID   NUMBER , 
     회원ID   NUMBER , 
     사용여부   CHAR (1)  NOT NULL 
    ) 
;

ALTER TABLE 쿠폰이력 
    ADD CONSTRAINT 쿠폰이력_PK PRIMARY KEY ( 쿠폰이력ID ) ;

CREATE TABLE 포인트 
    ( 
     포인트ID NUMBER  NOT NULL , 
     회원ID  NUMBER , 
     주문ID  NUMBER  NOT NULL , 
     변동포인트 NUMBER  NOT NULL , 
     변동날짜  DATE  NOT NULL , 
     변동사유  VARCHAR2 (10)  NOT NULL 
    ) 
;

ALTER TABLE 포인트 
    ADD CONSTRAINT 포인트_PK PRIMARY KEY ( 포인트ID ) ;

CREATE TABLE 회원 
    ( 
     회원ID NUMBER  NOT NULL , 
     회원명  VARCHAR2 (30)  NOT NULL , 
     전화번호 VARCHAR2 (13)  NOT NULL , 
     주소   VARCHAR2 (400)  NOT NULL , 
     상세주소 VARCHAR2 (200)  NOT NULL , 
     회원등급 VARCHAR2 (20)  NOT NULL , 
     포인트  NUMBER  NOT NULL , 
     이메일  VARCHAR2 (200)  NOT NULL , 
     비밀번호 VARCHAR2 (100)  NOT NULL , 
     생년월일 DATE , 
     성별   CHAR (1) , 
     탈퇴여부 CHAR (1) , 
     탈퇴날짜 DATE 
    ) 
;

ALTER TABLE 회원 
    ADD CONSTRAINT 회원_PK PRIMARY KEY ( 회원ID ) ;

ALTER TABLE 회원 
    ADD CONSTRAINT 회원__UN UNIQUE ( 전화번호 , 이메일 , 비밀번호 ) ;

ALTER TABLE "1:1문의" 
    ADD CONSTRAINT "1:1문의_회원_FK" FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 결제 
    ADD CONSTRAINT 결제_주문_FK FOREIGN KEY 
    ( 
     주문ID
    ) 
    REFERENCES 주문 
    ( 
     주문ID
    ) 
;

ALTER TABLE 리뷰 
    ADD CONSTRAINT 리뷰_상품_FK FOREIGN KEY 
    ( 
     상품ID
    ) 
    REFERENCES 상품 
    ( 
     상품ID
    ) 
;

ALTER TABLE 리뷰 
    ADD CONSTRAINT 리뷰_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 배송 
    ADD CONSTRAINT 배송_주문_FK FOREIGN KEY 
    ( 
     주문ID
    ) 
    REFERENCES 주문 
    ( 
     주문ID
    ) 
;

ALTER TABLE 상품문의 
    ADD CONSTRAINT 상품문의_상품_FK FOREIGN KEY 
    ( 
     상품ID
    ) 
    REFERENCES 상품 
    ( 
     상품ID
    ) 
;

ALTER TABLE 상품문의 
    ADD CONSTRAINT 상품문의_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 이벤트 
    ADD CONSTRAINT 이벤트_관리자_FK FOREIGN KEY 
    ( 
     관리자ID
    ) 
    REFERENCES 관리자 
    ( 
     관리자ID
    ) 
;

ALTER TABLE 장바구니 
    ADD CONSTRAINT 장바구니_상품_FK FOREIGN KEY 
    ( 
     상품ID
    ) 
    REFERENCES 상품 
    ( 
     상품ID
    ) 
;

ALTER TABLE 장바구니 
    ADD CONSTRAINT 장바구니_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 재고 
    ADD CONSTRAINT 재고_상품_FK FOREIGN KEY 
    ( 
     상품ID
    ) 
    REFERENCES 상품 
    ( 
     상품ID
    ) 
;

ALTER TABLE 주문 
    ADD CONSTRAINT 주문_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 주문상세 
    ADD CONSTRAINT 주문상세_주문_FK FOREIGN KEY 
    ( 
     주문ID
    ) 
    REFERENCES 주문 
    ( 
     주문ID
    ) 
;

ALTER TABLE "최근 본 상품" 
    ADD CONSTRAINT "최근 본 상품_상품_FK" FOREIGN KEY 
    ( 
     상품ID
    ) 
    REFERENCES 상품 
    ( 
     상품ID
    ) 
;

ALTER TABLE 쿠폰 
    ADD CONSTRAINT 쿠폰_관리자_FK FOREIGN KEY 
    ( 
     관리자ID
    ) 
    REFERENCES 관리자 
    ( 
     관리자ID
    ) 
;

ALTER TABLE 쿠폰이력 
    ADD CONSTRAINT 쿠폰이력_쿠폰_FK FOREIGN KEY 
    ( 
     쿠폰ID
    ) 
    REFERENCES 쿠폰 
    ( 
     쿠폰ID
    ) 
;

ALTER TABLE 쿠폰이력 
    ADD CONSTRAINT 쿠폰이력_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE 포인트 
    ADD CONSTRAINT 포인트_회원_FK FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

ALTER TABLE "최근 본 상품" 
    ADD CONSTRAINT 회원_최근본상품1N FOREIGN KEY 
    ( 
     회원ID
    ) 
    REFERENCES 회원 
    ( 
     회원ID
    ) 
;

CREATE SEQUENCE 회원_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

