BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "veda_user_profile" ADD COLUMN "subscriptionStatus" text;
ALTER TABLE "veda_user_profile" ADD COLUMN "subscriptionPlan" text;
ALTER TABLE "veda_user_profile" ADD COLUMN "subscriptionExpiryDate" timestamp without time zone;
ALTER TABLE "veda_user_profile" ADD COLUMN "subscriptionProductId" text;

--
-- MIGRATION VERSION FOR veda
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('veda', '20260212085351209', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260212085351209', "timestamp" = now();

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
