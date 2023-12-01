-- Persistent generated migration.

CREATE FUNCTION migrate() RETURNS void AS $$
DECLARE
  next_version int ;
BEGIN
  SELECT stage_two + 1 INTO next_version FROM schema_version ;
  IF next_version = 32 THEN
    EXECUTE 'ALTER TABLE "committee_de_registration" ADD COLUMN "cold_key" bytea NOT NULL' ;
    EXECUTE 'ALTER TABLE "committee_de_registration" DROP COLUMN "hot_key"' ;
    EXECUTE 'CREATe TABLE "off_chain_vote_data"("id" SERIAL8  PRIMARY KEY UNIQUE,"voting_anchor_id" INT8 NOT NULL,"hash" BYTEA NOT NULL,"json" jsonb NOT NULL,"bytes" bytea NOT NULL)' ;
    EXECUTE 'CREATe TABLE "off_chain_vote_fetch_error"("id" SERIAL8  PRIMARY KEY UNIQUE,"voting_anchor_id" INT8 NOT NULL,"fetch_error" VARCHAR NOT NULL,"fetch_time" timestamp NOT NULL,"retry_count" word31type NOT NULL)' ;
    EXECUTE 'ALTER TABLE "off_chain_vote_data" ADD CONSTRAINT "unique_off_chain_vote_data" UNIQUE("voting_anchor_id","hash")' ;
    EXECUTE 'ALTER TABLE "off_chain_vote_fetch_error" ADD CONSTRAINT "unique_off_chain_vote_fetch_error" UNIQUE("voting_anchor_id","retry_count")' ;
    -- Hand written SQL statements can be added here.
    UPDATE schema_version SET stage_two = next_version ;
    RAISE NOTICE 'DB has been migrated to stage_two version %', next_version ;
  END IF ;
END ;
$$ LANGUAGE plpgsql ;

SELECT migrate() ;

DROP FUNCTION migrate() ;
