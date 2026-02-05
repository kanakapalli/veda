BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "knowledge_files" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "knowledge_files" (
    "id" bigserial PRIMARY KEY,
    "fileName" text NOT NULL,
    "fileUrl" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "fileType" text,
    "uploadedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "courseId" bigint NOT NULL,
    "course" json,
    "_coursesKnowledgefilesCoursesId" bigint
);

-- Indexes
CREATE INDEX "knowledge_files_course_id_idx" ON "knowledge_files" USING btree ("courseId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "knowledge_files"
    ADD CONSTRAINT "knowledge_files_fk_0"
    FOREIGN KEY("courseId")
    REFERENCES "courses"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "knowledge_files"
    ADD CONSTRAINT "knowledge_files_fk_1"
    FOREIGN KEY("_coursesKnowledgefilesCoursesId")
    REFERENCES "courses"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260205143638913', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260205143638913', "timestamp" = now();

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
