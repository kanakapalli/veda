BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "module_progress" (
    "id" bigserial PRIMARY KEY,
    "userId" uuid NOT NULL,
    "moduleId" bigint NOT NULL,
    "module" json,
    "courseId" bigint NOT NULL,
    "course" json,
    "completed" boolean NOT NULL DEFAULT false,
    "completedAt" timestamp without time zone,
    "startedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "module_progress_user_id_idx" ON "module_progress" USING btree ("userId");
CREATE INDEX "module_progress_module_id_idx" ON "module_progress" USING btree ("moduleId");
CREATE INDEX "module_progress_course_id_idx" ON "module_progress" USING btree ("courseId");
CREATE UNIQUE INDEX "module_progress_user_module_idx" ON "module_progress" USING btree ("userId", "moduleId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "module_progress"
    ADD CONSTRAINT "module_progress_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "module_progress"
    ADD CONSTRAINT "module_progress_fk_1"
    FOREIGN KEY("moduleId")
    REFERENCES "modules"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "module_progress"
    ADD CONSTRAINT "module_progress_fk_2"
    FOREIGN KEY("courseId")
    REFERENCES "courses"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260210205504632', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260210205504632', "timestamp" = now();

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
