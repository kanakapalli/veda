BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "course_indices" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text,
    "imageUrl" text,
    "tags" json,
    "sortOrder" bigint NOT NULL,
    "courseId" bigint NOT NULL,
    "course" json,
    "_coursesCourseindicesCoursesId" bigint
);

-- Indexes
CREATE INDEX "course_indices_course_id_idx" ON "course_indices" USING btree ("courseId");
CREATE INDEX "course_indices_title_idx" ON "course_indices" USING btree ("title");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "courses" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text,
    "courseImageUrl" text,
    "bannerImageUrl" text,
    "videoUrl" text,
    "visibility" text NOT NULL,
    "systemPrompt" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "courses_visibility_idx" ON "courses" USING btree ("visibility");
CREATE INDEX "courses_created_at_idx" ON "courses" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "knowledge_files" (
    "id" bigserial PRIMARY KEY,
    "fileName" text NOT NULL,
    "fileUrl" text NOT NULL,
    "fileType" text,
    "uploadedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "courseId" bigint NOT NULL,
    "course" json,
    "_coursesKnowledgefilesCoursesId" bigint
);

-- Indexes
CREATE INDEX "knowledge_files_course_id_idx" ON "knowledge_files" USING btree ("courseId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "module_items" (
    "id" bigserial PRIMARY KEY,
    "sortOrder" bigint NOT NULL,
    "contextualDescription" text,
    "moduleId" bigint NOT NULL,
    "module" json,
    "topicId" bigint NOT NULL,
    "topic" json,
    "_modulesItemsModulesId" bigint
);

-- Indexes
CREATE INDEX "module_items_module_id_idx" ON "module_items" USING btree ("moduleId");
CREATE INDEX "module_items_topic_id_idx" ON "module_items" USING btree ("topicId");
CREATE INDEX "module_items_sort_order_idx" ON "module_items" USING btree ("sortOrder");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "modules" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text,
    "sortOrder" bigint NOT NULL,
    "imageUrl" text,
    "bannerImageUrl" text,
    "videoUrl" text,
    "courseId" bigint NOT NULL,
    "course" json,
    "_coursesModulesCoursesId" bigint
);

-- Indexes
CREATE INDEX "modules_course_id_idx" ON "modules" USING btree ("courseId");
CREATE INDEX "modules_sort_order_idx" ON "modules" USING btree ("sortOrder");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "topics" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text,
    "videoUrl" text,
    "imageUrl" text,
    "bannerImageUrl" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "topics_title_idx" ON "topics" USING btree ("title");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "course_indices"
    ADD CONSTRAINT "course_indices_fk_0"
    FOREIGN KEY("courseId")
    REFERENCES "courses"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "course_indices"
    ADD CONSTRAINT "course_indices_fk_1"
    FOREIGN KEY("_coursesCourseindicesCoursesId")
    REFERENCES "courses"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "module_items"
    ADD CONSTRAINT "module_items_fk_0"
    FOREIGN KEY("moduleId")
    REFERENCES "modules"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "module_items"
    ADD CONSTRAINT "module_items_fk_1"
    FOREIGN KEY("topicId")
    REFERENCES "topics"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "module_items"
    ADD CONSTRAINT "module_items_fk_2"
    FOREIGN KEY("_modulesItemsModulesId")
    REFERENCES "modules"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "modules"
    ADD CONSTRAINT "modules_fk_0"
    FOREIGN KEY("courseId")
    REFERENCES "courses"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "modules"
    ADD CONSTRAINT "modules_fk_1"
    FOREIGN KEY("_coursesModulesCoursesId")
    REFERENCES "courses"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260205125828538', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260205125828538', "timestamp" = now();

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
