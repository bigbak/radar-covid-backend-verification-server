CREATE SCHEMA VERIFICATION;

CREATE SEQUENCE VERIFICATION.SQ_NM_ID_TAN;

CREATE TABLE VERIFICATION.CCAA (
    DE_CCAA_ID         CHAR (2),
    DE_CCAA_NAME       CHAR VARYING(128),
    DE_CCAA_PUBLIC_KEY CHAR VARYING(1024),
    DE_CCAA_ISSUER     CHAR VARYING(128),
    CONSTRAINT PK_CCAA
        PRIMARY KEY (DE_CCAA_ID)
);

CREATE TABLE VERIFICATION.TAN (
    NM_ID_TAN             INTEGER DEFAULT nextval('VERIFICATION.SQ_NM_ID_TAN'),
    NM_VERSION            INTEGER DEFAULT 0,
    FC_CREATION_DATE      TIMESTAMP DEFAULT now(),
    DE_CCAA_ID            CHAR (2),
    IN_CCAA_CREATION      BOOLEAN DEFAULT TRUE,
    FC_CODE_VALID_FROM    DATE DEFAULT now(),
    FC_CODE_VALID_UNTIL   DATE DEFAULT '9999-12-31',
    DE_CODE_HASH          CHAR VARYING(64),
    IN_CODE_REDEEMED      BOOLEAN DEFAULT FALSE,
    FC_CODE_REDEEMED_DATE TIMESTAMP,
    FC_TAN_VALID_FROM     TIMESTAMP DEFAULT now(),
    FC_TAN_VALID_UNTIL    TIMESTAMP DEFAULT '9999-12-31',
    DE_TAN_HASH           CHAR VARYING(64),
    IN_TAN_REDEEMED       BOOLEAN DEFAULT FALSE,
    FC_TAN_REDEEMED_DATE  TIMESTAMP,
    CONSTRAINT PK_TAN
        PRIMARY KEY (NM_ID_TAN, IN_TAN_REDEEMED),
    CONSTRAINT UNQ_CODE_HASH
        UNIQUE (DE_CODE_HASH, IN_TAN_REDEEMED),
    CONSTRAINT UNQ_TAN_HASH
        UNIQUE (DE_TAN_HASH, IN_TAN_REDEEMED),
    CONSTRAINT FK_TAN_CCAA
        FOREIGN KEY (DE_CCAA_ID)
            REFERENCES VERIFICATION.CCAA (DE_CCAA_ID)
) PARTITION BY LIST (IN_TAN_REDEEMED);

ALTER SEQUENCE VERIFICATION.SQ_NM_ID_TAN
    OWNED BY VERIFICATION.TAN.NM_ID_TAN;

CREATE INDEX IN_VERIFICATION_CODE_HASH
    ON VERIFICATION.TAN(DE_CODE_HASH);

CREATE INDEX IN_VERIFICATION_TAN_HASH
    ON VERIFICATION.TAN(DE_TAN_HASH);

CREATE INDEX IN_VERIFICATION_CREATION_DATE
    ON VERIFICATION.TAN(FC_CREATION_DATE);

CREATE INDEX IN_VERIFICATION_CODE_HASH_REDEEMED
    ON VERIFICATION.TAN(DE_CODE_HASH, IN_CODE_REDEEMED);

CREATE INDEX IN_VERIFICATION_TAN_HASH_REDEEMED
    ON VERIFICATION.TAN(DE_TAN_HASH, IN_TAN_REDEEMED);

CREATE TABLE VERIFICATION.TAN_REDEEMED
    PARTITION OF VERIFICATION.TAN FOR VALUES IN (TRUE);

CREATE TABLE VERIFICATION.TAN_NO_REDEEMED
    PARTITION OF VERIFICATION.TAN FOR VALUES IN (FALSE);
