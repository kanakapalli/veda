BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "file_creation_drafts" (
    "id" bigserial PRIMARY KEY,
    "creatorId" uuid NOT NULL,
    "courseId" bigint,
    "title" text NOT NULL,
    "content" text NOT NULL,
    "chatHistory" text,
    "fileType" text NOT NULL DEFAULT 'md'::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "file_creation_drafts_creator_idx" ON "file_creation_drafts" USING btree ("creatorId");
CREATE INDEX "file_creation_drafts_course_idx" ON "file_creation_drafts" USING btree ("courseId");
CREATE INDEX "file_creation_drafts_updated_idx" ON "file_creation_drafts" USING btree ("updatedAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "file_creation_drafts"
    ADD CONSTRAINT "file_creation_drafts_fk_0"
    FOREIGN KEY("creatorId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260209185754797', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260209185754797', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
