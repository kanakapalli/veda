BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "courses" ADD COLUMN "courseTopics" json;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "enrollments" (
    "id" bigserial PRIMARY KEY,
    "userId" uuid NOT NULL,
    "courseId" bigint NOT NULL,
    "course" json,
    "enrolledAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "enrollments_user_id_idx" ON "enrollments" USING btree ("userId");
CREATE INDEX "enrollments_course_id_idx" ON "enrollments" USING btree ("courseId");
CREATE UNIQUE INDEX "enrollments_user_course_idx" ON "enrollments" USING btree ("userId", "courseId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "enrollments"
    ADD CONSTRAINT "enrollments_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "enrollments"
    ADD CONSTRAINT "enrollments_fk_1"
    FOREIGN KEY("courseId")
    REFERENCES "courses"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260210202644305', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260210202644305', "timestamp" = now();

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
