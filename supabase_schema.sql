-- Schema export generated from Supabase
-- Schema only: tables, constraints, indexes, views, functions, triggers, policies, and sequences.

BEGIN;

SET client_min_messages TO WARNING;

CREATE SCHEMA IF NOT EXISTS "auth";
CREATE SCHEMA IF NOT EXISTS "extensions";
CREATE SCHEMA IF NOT EXISTS "graphql";
CREATE SCHEMA IF NOT EXISTS "graphql_public";
CREATE SCHEMA IF NOT EXISTS "pgbouncer";
CREATE SCHEMA IF NOT EXISTS "public";
CREATE SCHEMA IF NOT EXISTS "realtime";
CREATE SCHEMA IF NOT EXISTS "storage";
CREATE SCHEMA IF NOT EXISTS "supabase_migrations";
CREATE SCHEMA IF NOT EXISTS "vault";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "supabase_vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE "auth"."aal_level" AS ENUM ('aal1', 'aal2', 'aal3');
CREATE TYPE "auth"."code_challenge_method" AS ENUM ('s256', 'plain');
CREATE TYPE "auth"."factor_status" AS ENUM ('unverified', 'verified');
CREATE TYPE "auth"."factor_type" AS ENUM ('totp', 'webauthn', 'phone');
CREATE TYPE "auth"."oauth_authorization_status" AS ENUM ('pending', 'approved', 'denied', 'expired');
CREATE TYPE "auth"."oauth_client_type" AS ENUM ('public', 'confidential');
CREATE TYPE "auth"."oauth_registration_type" AS ENUM ('dynamic', 'manual');
CREATE TYPE "auth"."oauth_response_type" AS ENUM ('code');
CREATE TYPE "auth"."one_time_token_type" AS ENUM ('confirmation_token', 'reauthentication_token', 'recovery_token', 'email_change_token_new', 'email_change_token_current', 'phone_change_token');
CREATE TYPE "realtime"."action" AS ENUM ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'ERROR');
CREATE TYPE "realtime"."equality_op" AS ENUM ('eq', 'neq', 'lt', 'lte', 'gt', 'gte', 'in');
CREATE TYPE "storage"."buckettype" AS ENUM ('STANDARD', 'ANALYTICS', 'VECTOR');

CREATE SEQUENCE "auth"."refresh_tokens_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."app_role_app_role_id_seq" AS integer START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."app_user_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."attachment_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."audit_log_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."category_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."comment_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."role_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."task_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."task_users_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."todolist_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."todolist_users_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;
CREATE SEQUENCE "public"."user_settings_id_seq" AS bigint START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 NO CYCLE;

CREATE TABLE "auth"."audit_log_entries" (
    "instance_id" uuid,
    "id" uuid NOT NULL,
    "payload" json,
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);

CREATE TABLE "auth"."custom_oauth_providers" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "provider_type" text NOT NULL,
    "identifier" text NOT NULL,
    "name" text NOT NULL,
    "client_id" text NOT NULL,
    "client_secret" text NOT NULL,
    "acceptable_client_ids" text[] DEFAULT '{}'::text[] NOT NULL,
    "scopes" text[] DEFAULT '{}'::text[] NOT NULL,
    "pkce_enabled" boolean DEFAULT true NOT NULL,
    "attribute_mapping" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "authorization_params" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "email_optional" boolean DEFAULT false NOT NULL,
    "issuer" text,
    "discovery_url" text,
    "skip_nonce_check" boolean DEFAULT false NOT NULL,
    "cached_discovery" jsonb,
    "discovery_cached_at" timestamp with time zone,
    "authorization_url" text,
    "token_url" text,
    "userinfo_url" text,
    "jwks_uri" text,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "auth"."flow_state" (
    "id" uuid NOT NULL,
    "user_id" uuid,
    "auth_code" text,
    "code_challenge_method" auth.code_challenge_method,
    "code_challenge" text,
    "provider_type" text NOT NULL,
    "provider_access_token" text,
    "provider_refresh_token" text,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" text NOT NULL,
    "auth_code_issued_at" timestamp with time zone,
    "invite_token" text,
    "referrer" text,
    "oauth_client_state_id" uuid,
    "linking_target_id" uuid,
    "email_optional" boolean DEFAULT false NOT NULL
);

CREATE TABLE "auth"."identities" (
    "provider_id" text NOT NULL,
    "user_id" uuid NOT NULL,
    "identity_data" jsonb NOT NULL,
    "provider" text NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    "id" uuid DEFAULT gen_random_uuid() NOT NULL
);

CREATE TABLE "auth"."instances" (
    "id" uuid NOT NULL,
    "uuid" uuid,
    "raw_base_config" text,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);

CREATE TABLE "auth"."mfa_amr_claims" (
    "session_id" uuid NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" text NOT NULL,
    "id" uuid NOT NULL
);

CREATE TABLE "auth"."mfa_challenges" (
    "id" uuid NOT NULL,
    "factor_id" uuid NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" inet NOT NULL,
    "otp_code" text,
    "web_authn_session_data" jsonb
);

CREATE TABLE "auth"."mfa_factors" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "friendly_name" text,
    "factor_type" auth.factor_type NOT NULL,
    "status" auth.factor_status NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" text,
    "phone" text,
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" jsonb,
    "web_authn_aaguid" uuid,
    "last_webauthn_challenge_data" jsonb
);

CREATE TABLE "auth"."oauth_authorizations" (
    "id" uuid NOT NULL,
    "authorization_id" text NOT NULL,
    "client_id" uuid NOT NULL,
    "user_id" uuid,
    "redirect_uri" text NOT NULL,
    "scope" text NOT NULL,
    "state" text,
    "resource" text,
    "code_challenge" text,
    "code_challenge_method" auth.code_challenge_method,
    "response_type" auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    "status" auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    "authorization_code" text,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    "approved_at" timestamp with time zone,
    "nonce" text
);

CREATE TABLE "auth"."oauth_client_states" (
    "id" uuid NOT NULL,
    "provider_type" text NOT NULL,
    "code_verifier" text,
    "created_at" timestamp with time zone NOT NULL
);

CREATE TABLE "auth"."oauth_clients" (
    "id" uuid NOT NULL,
    "client_secret_hash" text,
    "registration_type" auth.oauth_registration_type NOT NULL,
    "redirect_uris" text NOT NULL,
    "grant_types" text NOT NULL,
    "client_name" text,
    "client_uri" text,
    "logo_uri" text,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
    "deleted_at" timestamp with time zone,
    "client_type" auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    "token_endpoint_auth_method" text NOT NULL
);

CREATE TABLE "auth"."oauth_consents" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "client_id" uuid NOT NULL,
    "scopes" text NOT NULL,
    "granted_at" timestamp with time zone DEFAULT now() NOT NULL,
    "revoked_at" timestamp with time zone
);

CREATE TABLE "auth"."one_time_tokens" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "token_type" auth.one_time_token_type NOT NULL,
    "token_hash" text NOT NULL,
    "relates_to" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE "auth"."refresh_tokens" (
    "instance_id" uuid,
    "id" bigint DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass) NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" uuid
);

CREATE TABLE "auth"."saml_providers" (
    "id" uuid NOT NULL,
    "sso_provider_id" uuid NOT NULL,
    "entity_id" text NOT NULL,
    "metadata_xml" text NOT NULL,
    "metadata_url" text,
    "attribute_mapping" jsonb,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" text
);

CREATE TABLE "auth"."saml_relay_states" (
    "id" uuid NOT NULL,
    "sso_provider_id" uuid NOT NULL,
    "request_id" text NOT NULL,
    "for_email" text,
    "redirect_to" text,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" uuid
);

CREATE TABLE "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);

CREATE TABLE "auth"."sessions" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" uuid,
    "aal" auth.aal_level,
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" text,
    "ip" inet,
    "tag" text,
    "oauth_client_id" uuid,
    "refresh_token_hmac_key" text,
    "refresh_token_counter" bigint,
    "scopes" text
);

CREATE TABLE "auth"."sso_domains" (
    "id" uuid NOT NULL,
    "sso_provider_id" uuid NOT NULL,
    "domain" text NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);

CREATE TABLE "auth"."sso_providers" (
    "id" uuid NOT NULL,
    "resource_id" text,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "disabled" boolean
);

CREATE TABLE "auth"."users" (
    "instance_id" uuid,
    "id" uuid NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" jsonb,
    "raw_user_meta_data" jsonb,
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" text DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" text DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL
);

CREATE TABLE "auth"."webauthn_challenges" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "user_id" uuid,
    "challenge_type" text NOT NULL,
    "session_data" jsonb NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL
);

CREATE TABLE "auth"."webauthn_credentials" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "user_id" uuid NOT NULL,
    "credential_id" bytea NOT NULL,
    "public_key" bytea NOT NULL,
    "attestation_type" text DEFAULT ''::text NOT NULL,
    "aaguid" uuid,
    "sign_count" bigint DEFAULT 0 NOT NULL,
    "transports" jsonb DEFAULT '[]'::jsonb NOT NULL,
    "backup_eligible" boolean DEFAULT false NOT NULL,
    "backed_up" boolean DEFAULT false NOT NULL,
    "friendly_name" text DEFAULT ''::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
    "last_used_at" timestamp with time zone
);

CREATE TABLE "public"."app_role" (
    "app_role_id" integer DEFAULT nextval('app_role_app_role_id_seq'::regclass) NOT NULL,
    "role_name" text NOT NULL
);

CREATE TABLE "public"."app_user" (
    "user_id" integer DEFAULT nextval('app_user_id_seq'::regclass) NOT NULL,
    "email" text,
    "name" text,
    "surname" text,
    "auth_id" uuid,
    "app_role_id" integer
);

CREATE TABLE "public"."attachment" (
    "attachment_id" integer DEFAULT nextval('attachment_id_seq'::regclass) NOT NULL,
    "file_name" text,
    "file_path" text,
    "task_id" integer
);

CREATE TABLE "public"."audit_log" (
    "audit_log_id" integer DEFAULT nextval('audit_log_id_seq'::regclass) NOT NULL,
    "action" text,
    "log_time" timestamp without time zone,
    "user_id" integer,
    "task_id" integer
);

CREATE TABLE "public"."category" (
    "category_id" integer DEFAULT nextval('category_id_seq'::regclass) NOT NULL,
    "color_hex" text,
    "name" text
);

CREATE TABLE "public"."comment" (
    "comment_id" integer DEFAULT nextval('comment_id_seq'::regclass) NOT NULL,
    "created_at" timestamp without time zone,
    "text" text,
    "user_id" integer,
    "task_id" integer
);

CREATE TABLE "public"."group_role" (
    "role_id" integer DEFAULT nextval('role_id_seq'::regclass) NOT NULL,
    "role_name" text
);

CREATE TABLE "public"."task" (
    "task_id" integer DEFAULT nextval('task_id_seq'::regclass) NOT NULL,
    "deadline" timestamp without time zone,
    "description" text,
    "state" text,
    "name" text,
    "task_creator" integer,
    "updated_by" text,
    "category_id" integer,
    "todolist_id" integer
);

CREATE TABLE "public"."task_users" (
    "task_users_id" integer DEFAULT nextval('task_users_id_seq'::regclass) NOT NULL,
    "task_id" integer,
    "user_id" integer
);

CREATE TABLE "public"."todolist" (
    "todolist_id" integer DEFAULT nextval('todolist_id_seq'::regclass) NOT NULL,
    "list_type" text,
    "name" text
);

CREATE TABLE "public"."todolist_users" (
    "todolist_users_id" integer DEFAULT nextval('todolist_users_id_seq'::regclass) NOT NULL,
    "role_id" integer NOT NULL,
    "todolist_id" integer,
    "user_id" integer,
    "is_list_creator" boolean
);

CREATE TABLE "public"."user_settings" (
    "user_settings_id" integer DEFAULT nextval('user_settings_id_seq'::regclass) NOT NULL,
    "preferences" character varying(600),
    "user_id" integer
);

CREATE TABLE "realtime"."messages" (
    "topic" text NOT NULL,
    "extension" text NOT NULL,
    "payload" jsonb,
    "event" text,
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT now() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT now() NOT NULL,
    "id" uuid DEFAULT gen_random_uuid() NOT NULL
);

CREATE TABLE "realtime"."schema_migrations" (
    "version" bigint NOT NULL,
    "inserted_at" timestamp(0) without time zone
);

CREATE TABLE "realtime"."subscription" (
    "id" bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    "subscription_id" uuid NOT NULL,
    "entity" regclass NOT NULL,
    "filters" realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    "claims" jsonb NOT NULL,
    "claims_role" regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    "created_at" timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    "action_filter" text DEFAULT '*'::text
);

CREATE TABLE "storage"."buckets" (
    "id" text NOT NULL,
    "name" text NOT NULL,
    "owner" uuid,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" text[],
    "owner_id" text,
    "type" storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);

CREATE TABLE "storage"."buckets_analytics" (
    "name" text NOT NULL,
    "type" storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    "format" text DEFAULT 'ICEBERG'::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "deleted_at" timestamp with time zone
);

CREATE TABLE "storage"."buckets_vectors" (
    "id" text NOT NULL,
    "type" storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "storage"."objects" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "bucket_id" text,
    "name" text,
    "owner" uuid,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "last_accessed_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb,
    "path_tokens" text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    "version" text,
    "owner_id" text,
    "user_metadata" jsonb
);

CREATE TABLE "storage"."s3_multipart_uploads" (
    "id" text NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" text NOT NULL,
    "bucket_id" text NOT NULL,
    "key" text NOT NULL,
    "version" text NOT NULL,
    "owner_id" text,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "user_metadata" jsonb,
    "metadata" jsonb
);

CREATE TABLE "storage"."s3_multipart_uploads_parts" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "upload_id" text NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" text NOT NULL,
    "key" text NOT NULL,
    "etag" text NOT NULL,
    "owner_id" text,
    "version" text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "storage"."vector_indexes" (
    "id" text DEFAULT gen_random_uuid() NOT NULL,
    "name" text NOT NULL,
    "bucket_id" text NOT NULL,
    "data_type" text NOT NULL,
    "dimension" integer NOT NULL,
    "distance_metric" text NOT NULL,
    "metadata_configuration" jsonb,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "supabase_migrations"."schema_migrations" (
    "version" text NOT NULL,
    "statements" text[],
    "name" text,
    "created_by" text,
    "idempotency_key" text,
    "rollback" text[]
);

CREATE TABLE "vault"."secrets" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "name" text,
    "description" text DEFAULT ''::text NOT NULL,
    "secret" text NOT NULL,
    "key_id" uuid,
    "nonce" bytea DEFAULT vault._crypto_aead_det_noncegen(),
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY "auth"."audit_log_entries" ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_authorization_url_https" CHECK (authorization_url IS NULL OR authorization_url ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_authorization_url_length" CHECK (authorization_url IS NULL OR char_length(authorization_url) <= 2048);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_client_id_length" CHECK (char_length(client_id) >= 1 AND char_length(client_id) <= 512);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_discovery_url_length" CHECK (discovery_url IS NULL OR char_length(discovery_url) <= 2048);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_identifier_format" CHECK (identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_identifier_key" UNIQUE (identifier);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_issuer_length" CHECK (issuer IS NULL OR char_length(issuer) >= 1 AND char_length(issuer) <= 2048);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_jwks_uri_https" CHECK (jwks_uri IS NULL OR jwks_uri ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_jwks_uri_length" CHECK (jwks_uri IS NULL OR char_length(jwks_uri) <= 2048);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_name_length" CHECK (char_length(name) >= 1 AND char_length(name) <= 100);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_oauth2_requires_endpoints" CHECK (provider_type <> 'oauth2'::text OR authorization_url IS NOT NULL AND token_url IS NOT NULL AND userinfo_url IS NOT NULL);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_oidc_discovery_url_https" CHECK (provider_type <> 'oidc'::text OR discovery_url IS NULL OR discovery_url ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_oidc_issuer_https" CHECK (provider_type <> 'oidc'::text OR issuer IS NULL OR issuer ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_oidc_requires_issuer" CHECK (provider_type <> 'oidc'::text OR issuer IS NOT NULL);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_provider_type_check" CHECK (provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]));
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_token_url_https" CHECK (token_url IS NULL OR token_url ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_token_url_length" CHECK (token_url IS NULL OR char_length(token_url) <= 2048);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_userinfo_url_https" CHECK (userinfo_url IS NULL OR userinfo_url ~~ 'https://%'::text);
ALTER TABLE ONLY "auth"."custom_oauth_providers" ADD CONSTRAINT "custom_oauth_providers_userinfo_url_length" CHECK (userinfo_url IS NULL OR char_length(userinfo_url) <= 2048);
ALTER TABLE ONLY "auth"."flow_state" ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."identities" ADD CONSTRAINT "identities_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."identities" ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE (provider_id, provider);
ALTER TABLE ONLY "auth"."identities" ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."instances" ADD CONSTRAINT "instances_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."mfa_amr_claims" ADD CONSTRAINT "amr_id_pk" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."mfa_amr_claims" ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE (session_id, authentication_method);
ALTER TABLE ONLY "auth"."mfa_amr_claims" ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."mfa_challenges" ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."mfa_challenges" ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."mfa_factors" ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE (last_challenged_at);
ALTER TABLE ONLY "auth"."mfa_factors" ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."mfa_factors" ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_authorization_code_key" UNIQUE (authorization_code);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_authorization_code_length" CHECK (char_length(authorization_code) <= 255);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_authorization_id_key" UNIQUE (authorization_id);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_client_id_fkey" FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_code_challenge_length" CHECK (char_length(code_challenge) <= 128);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_expires_at_future" CHECK (expires_at > created_at);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_nonce_length" CHECK (char_length(nonce) <= 255);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_redirect_uri_length" CHECK (char_length(redirect_uri) <= 2048);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_resource_length" CHECK (char_length(resource) <= 2048);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_scope_length" CHECK (char_length(scope) <= 4096);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_state_length" CHECK (char_length(state) <= 4096);
ALTER TABLE ONLY "auth"."oauth_authorizations" ADD CONSTRAINT "oauth_authorizations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."oauth_client_states" ADD CONSTRAINT "oauth_client_states_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."oauth_clients" ADD CONSTRAINT "oauth_clients_client_name_length" CHECK (char_length(client_name) <= 1024);
ALTER TABLE ONLY "auth"."oauth_clients" ADD CONSTRAINT "oauth_clients_client_uri_length" CHECK (char_length(client_uri) <= 2048);
ALTER TABLE ONLY "auth"."oauth_clients" ADD CONSTRAINT "oauth_clients_logo_uri_length" CHECK (char_length(logo_uri) <= 2048);
ALTER TABLE ONLY "auth"."oauth_clients" ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."oauth_clients" ADD CONSTRAINT "oauth_clients_token_endpoint_auth_method_check" CHECK (token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text]));
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_client_id_fkey" FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_revoked_after_granted" CHECK (revoked_at IS NULL OR revoked_at >= granted_at);
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_scopes_length" CHECK (char_length(scopes) <= 2048);
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_scopes_not_empty" CHECK (char_length(TRIM(BOTH FROM scopes)) > 0);
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_user_client_unique" UNIQUE (user_id, client_id);
ALTER TABLE ONLY "auth"."oauth_consents" ADD CONSTRAINT "oauth_consents_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."one_time_tokens" ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."one_time_tokens" ADD CONSTRAINT "one_time_tokens_token_hash_check" CHECK (char_length(token_hash) > 0);
ALTER TABLE ONLY "auth"."one_time_tokens" ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."refresh_tokens" ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."refresh_tokens" ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."refresh_tokens" ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE (token);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "entity_id not empty" CHECK (char_length(entity_id) > 0);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "metadata_url not empty" CHECK (metadata_url = NULL::text OR char_length(metadata_url) > 0);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "metadata_xml not empty" CHECK (char_length(metadata_xml) > 0);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE (entity_id);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."saml_providers" ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."saml_relay_states" ADD CONSTRAINT "request_id not empty" CHECK (char_length(request_id) > 0);
ALTER TABLE ONLY "auth"."saml_relay_states" ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."saml_relay_states" ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."saml_relay_states" ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."schema_migrations" ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY (version);
ALTER TABLE ONLY "auth"."sessions" ADD CONSTRAINT "sessions_oauth_client_id_fkey" FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."sessions" ADD CONSTRAINT "sessions_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."sessions" ADD CONSTRAINT "sessions_scopes_length" CHECK (char_length(scopes) <= 4096);
ALTER TABLE ONLY "auth"."sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."sso_domains" ADD CONSTRAINT "domain not empty" CHECK (char_length(domain) > 0);
ALTER TABLE ONLY "auth"."sso_domains" ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."sso_domains" ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."sso_providers" ADD CONSTRAINT "resource_id not empty" CHECK (resource_id = NULL::text OR char_length(resource_id) > 0);
ALTER TABLE ONLY "auth"."sso_providers" ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."users" ADD CONSTRAINT "users_email_change_confirm_status_check" CHECK (email_change_confirm_status >= 0 AND email_change_confirm_status <= 2);
ALTER TABLE ONLY "auth"."users" ADD CONSTRAINT "users_phone_key" UNIQUE (phone);
ALTER TABLE ONLY "auth"."users" ADD CONSTRAINT "users_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."webauthn_challenges" ADD CONSTRAINT "webauthn_challenges_challenge_type_check" CHECK (challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text]));
ALTER TABLE ONLY "auth"."webauthn_challenges" ADD CONSTRAINT "webauthn_challenges_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."webauthn_challenges" ADD CONSTRAINT "webauthn_challenges_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "auth"."webauthn_credentials" ADD CONSTRAINT "webauthn_credentials_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "auth"."webauthn_credentials" ADD CONSTRAINT "webauthn_credentials_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "public"."app_role" ADD CONSTRAINT "app_role_pkey" PRIMARY KEY (app_role_id);
ALTER TABLE ONLY "public"."app_role" ADD CONSTRAINT "app_role_role_name_key" UNIQUE (role_name);
ALTER TABLE ONLY "public"."app_user" ADD CONSTRAINT "app_user_app_role_id_fkey" FOREIGN KEY (app_role_id) REFERENCES app_role(app_role_id);
ALTER TABLE ONLY "public"."app_user" ADD CONSTRAINT "pk_app_user" PRIMARY KEY (user_id);
ALTER TABLE ONLY "public"."attachment" ADD CONSTRAINT "fk_attachment_task" FOREIGN KEY (task_id) REFERENCES task(task_id);
ALTER TABLE ONLY "public"."attachment" ADD CONSTRAINT "pk_attachment" PRIMARY KEY (attachment_id);
ALTER TABLE ONLY "public"."audit_log" ADD CONSTRAINT "fk_audit_log_task" FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE;
ALTER TABLE ONLY "public"."audit_log" ADD CONSTRAINT "fk_audit_log_user" FOREIGN KEY (user_id) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."audit_log" ADD CONSTRAINT "pk_audit_log" PRIMARY KEY (audit_log_id);
ALTER TABLE ONLY "public"."category" ADD CONSTRAINT "pk_category" PRIMARY KEY (category_id);
ALTER TABLE ONLY "public"."comment" ADD CONSTRAINT "fk_comment_task" FOREIGN KEY (task_id) REFERENCES task(task_id);
ALTER TABLE ONLY "public"."comment" ADD CONSTRAINT "fk_comment_user" FOREIGN KEY (user_id) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."comment" ADD CONSTRAINT "pk_comment" PRIMARY KEY (comment_id);
ALTER TABLE ONLY "public"."group_role" ADD CONSTRAINT "pk_role" PRIMARY KEY (role_id);
ALTER TABLE ONLY "public"."task" ADD CONSTRAINT "fk_task_category" FOREIGN KEY (category_id) REFERENCES category(category_id);
ALTER TABLE ONLY "public"."task" ADD CONSTRAINT "fk_task_creator" FOREIGN KEY (task_creator) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."task" ADD CONSTRAINT "fk_task_todolist" FOREIGN KEY (todolist_id) REFERENCES todolist(todolist_id);
ALTER TABLE ONLY "public"."task" ADD CONSTRAINT "pk_task" PRIMARY KEY (task_id);
ALTER TABLE ONLY "public"."task_users" ADD CONSTRAINT "fk_user_task_task" FOREIGN KEY (task_id) REFERENCES task(task_id);
ALTER TABLE ONLY "public"."task_users" ADD CONSTRAINT "fk_user_task_user" FOREIGN KEY (user_id) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."task_users" ADD CONSTRAINT "pk_user_task" PRIMARY KEY (task_users_id);
ALTER TABLE ONLY "public"."todolist" ADD CONSTRAINT "pk_todolist" PRIMARY KEY (todolist_id);
ALTER TABLE ONLY "public"."todolist_users" ADD CONSTRAINT "fk_user_todolist_list" FOREIGN KEY (todolist_id) REFERENCES todolist(todolist_id);
ALTER TABLE ONLY "public"."todolist_users" ADD CONSTRAINT "fk_user_todolist_role" FOREIGN KEY (role_id) REFERENCES group_role(role_id);
ALTER TABLE ONLY "public"."todolist_users" ADD CONSTRAINT "fk_user_todolist_user" FOREIGN KEY (user_id) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."todolist_users" ADD CONSTRAINT "pk_user_todolist" PRIMARY KEY (todolist_users_id);
ALTER TABLE ONLY "public"."user_settings" ADD CONSTRAINT "fk_user_settings_user" FOREIGN KEY (user_id) REFERENCES app_user(user_id);
ALTER TABLE ONLY "public"."user_settings" ADD CONSTRAINT "pk_user_settings" PRIMARY KEY (user_settings_id);
ALTER TABLE ONLY "realtime"."messages" ADD CONSTRAINT "messages_pkey" PRIMARY KEY (id, inserted_at);
ALTER TABLE ONLY "realtime"."schema_migrations" ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY (version);
ALTER TABLE ONLY "realtime"."subscription" ADD CONSTRAINT "pk_subscription" PRIMARY KEY (id);
ALTER TABLE ONLY "realtime"."subscription" ADD CONSTRAINT "subscription_action_filter_check" CHECK (action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text]));
ALTER TABLE ONLY "storage"."buckets" ADD CONSTRAINT "buckets_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."buckets_analytics" ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."buckets_vectors" ADD CONSTRAINT "buckets_vectors_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."migrations" ADD CONSTRAINT "migrations_name_key" UNIQUE (name);
ALTER TABLE ONLY "storage"."migrations" ADD CONSTRAINT "migrations_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."objects" ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE ONLY "storage"."objects" ADD CONSTRAINT "objects_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."s3_multipart_uploads" ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE ONLY "storage"."s3_multipart_uploads" ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts" ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts" ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts" ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;
ALTER TABLE ONLY "storage"."vector_indexes" ADD CONSTRAINT "vector_indexes_bucket_id_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);
ALTER TABLE ONLY "storage"."vector_indexes" ADD CONSTRAINT "vector_indexes_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "supabase_migrations"."schema_migrations" ADD CONSTRAINT "schema_migrations_idempotency_key_key" UNIQUE (idempotency_key);
ALTER TABLE ONLY "supabase_migrations"."schema_migrations" ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY (version);
ALTER TABLE ONLY "vault"."secrets" ADD CONSTRAINT "secrets_pkey" PRIMARY KEY (id);

ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."app_role" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."app_user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."attachment" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."audit_log" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."category" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."comment" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."group_role" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."task" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."task_users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."todolist" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."todolist_users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."user_settings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "realtime"."messages" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."buckets_vectors" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "storage"."vector_indexes" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON "public"."app_role" FOR SELECT TO "public" USING (true);
CREATE POLICY "dev_app_user_insert" ON "public"."app_user" FOR INSERT TO "public" WITH CHECK (true);
CREATE POLICY "dev_app_user_select" ON "public"."app_user" FOR SELECT TO "public" USING (true);
CREATE POLICY "dev_app_user_update" ON "public"."app_user" FOR UPDATE TO "public" USING (true) WITH CHECK (true);
CREATE POLICY "dev_role_select" ON "public"."group_role" FOR SELECT TO "public" USING (true);
CREATE POLICY "delete_tasks" ON "public"."task" FOR DELETE TO "public" USING ((EXISTS ( SELECT 1
   FROM ((todolist_users ut
     JOIN app_user u ON ((u.user_id = ut.user_id)))
     JOIN group_role r ON ((ut.role_id = r.role_id)))
  WHERE ((ut.todolist_id = task.todolist_id) AND (u.auth_id = auth.uid()) AND (r.role_name = 'spravce'::text)))));
CREATE POLICY "dev_task_all" ON "public"."task" TO "public" USING (true) WITH CHECK (true);
CREATE POLICY "insert_tasks" ON "public"."task" FOR INSERT TO "public" WITH CHECK ((EXISTS ( SELECT 1
   FROM (todolist_users ut
     JOIN app_user u ON ((u.user_id = ut.user_id)))
  WHERE ((ut.todolist_id = task.todolist_id) AND (u.auth_id = auth.uid())))));
CREATE POLICY "select_tasks" ON "public"."task" FOR SELECT TO "public" USING ((EXISTS ( SELECT 1
   FROM (todolist_users ut
     JOIN app_user u ON ((u.user_id = ut.user_id)))
  WHERE ((ut.todolist_id = task.todolist_id) AND (u.auth_id = auth.uid())))));
CREATE POLICY "update_tasks" ON "public"."task" FOR UPDATE TO "public" USING ((EXISTS ( SELECT 1
   FROM ((todolist_users ut
     JOIN app_user u ON ((u.user_id = ut.user_id)))
     JOIN group_role r ON ((ut.role_id = r.role_id)))
  WHERE ((ut.todolist_id = task.todolist_id) AND (u.auth_id = auth.uid()) AND (r.role_name = ANY (ARRAY['koordinator'::text, 'spravce'::text]))))));
CREATE POLICY "dev_user_task_delete" ON "public"."task_users" FOR DELETE TO "public" USING (true);
CREATE POLICY "dev_user_task_insert" ON "public"."task_users" FOR INSERT TO "public" WITH CHECK (true);
CREATE POLICY "dev_user_task_select" ON "public"."task_users" FOR SELECT TO "public" USING (true);
CREATE POLICY "dev_user_task_update" ON "public"."task_users" FOR UPDATE TO "public" USING (true) WITH CHECK (true);
CREATE POLICY "dev_todolist_delete" ON "public"."todolist" FOR DELETE TO "public" USING (true);
CREATE POLICY "dev_todolist_insert" ON "public"."todolist" FOR INSERT TO "public" WITH CHECK (true);
CREATE POLICY "dev_todolist_select" ON "public"."todolist" FOR SELECT TO "public" USING (true);
CREATE POLICY "dev_todolist_update" ON "public"."todolist" FOR UPDATE TO "public" USING (true) WITH CHECK (true);
CREATE POLICY "dev_user_todolist_delete" ON "public"."todolist_users" FOR DELETE TO "public" USING (true);
CREATE POLICY "dev_user_todolist_insert" ON "public"."todolist_users" FOR INSERT TO "public" WITH CHECK (true);
CREATE POLICY "dev_user_todolist_select" ON "public"."todolist_users" FOR SELECT TO "public" USING (true);
CREATE POLICY "dev_user_todolist_update" ON "public"."todolist_users" FOR UPDATE TO "public" USING (true) WITH CHECK (true);

CREATE OR REPLACE VIEW "extensions"."pg_stat_statements" AS
 SELECT userid,
    dbid,
    toplevel,
    queryid,
    query,
    plans,
    total_plan_time,
    min_plan_time,
    max_plan_time,
    mean_plan_time,
    stddev_plan_time,
    calls,
    total_exec_time,
    min_exec_time,
    max_exec_time,
    mean_exec_time,
    stddev_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written,
    local_blks_hit,
    local_blks_read,
    local_blks_dirtied,
    local_blks_written,
    temp_blks_read,
    temp_blks_written,
    shared_blk_read_time,
    shared_blk_write_time,
    local_blk_read_time,
    local_blk_write_time,
    temp_blk_read_time,
    temp_blk_write_time,
    wal_records,
    wal_fpi,
    wal_bytes,
    jit_functions,
    jit_generation_time,
    jit_inlining_count,
    jit_inlining_time,
    jit_optimization_count,
    jit_optimization_time,
    jit_emission_count,
    jit_emission_time,
    jit_deform_count,
    jit_deform_time,
    stats_since,
    minmax_stats_since
   FROM pg_stat_statements(true) pg_stat_statements(userid, dbid, toplevel, queryid, query, plans, total_plan_time, min_plan_time, max_plan_time, mean_plan_time, stddev_plan_time, calls, total_exec_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time, rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, shared_blk_read_time, shared_blk_write_time, local_blk_read_time, local_blk_write_time, temp_blk_read_time, temp_blk_write_time, wal_records, wal_fpi, wal_bytes, jit_functions, jit_generation_time, jit_inlining_count, jit_inlining_time, jit_optimization_count, jit_optimization_time, jit_emission_count, jit_emission_time, jit_deform_count, jit_deform_time, stats_since, minmax_stats_since);;

CREATE OR REPLACE VIEW "extensions"."pg_stat_statements_info" AS
 SELECT dealloc,
    stats_reset
   FROM pg_stat_statements_info() pg_stat_statements_info(dealloc, stats_reset);;

CREATE OR REPLACE VIEW "vault"."decrypted_secrets" AS
 SELECT id,
    name,
    description,
    secret,
    convert_from(vault._crypto_aead_det_decrypt(message => decode(secret, 'base64'::text), additional => convert_to(id::text, 'utf8'::name), key_id => 0::bigint, context => '\x7067736f6469756d'::bytea, nonce => nonce), 'utf8'::name) AS decrypted_secret,
    key_id,
    nonce,
    created_at,
    updated_at
   FROM vault.secrets s;;

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);
CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);
CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);
CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);
CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);
CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);
CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);
CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);
CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);
CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);
CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);
CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);
CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);
CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);
CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);
CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);
CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);
CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);
CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);
CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);
CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);
CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);
CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);
CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);
CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);
CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);
CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);
CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);
CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);
CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);
CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);
CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);
CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);
CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);
CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);
CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);
CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));
CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);
CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);
CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);
CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);
CREATE INDEX ix_fk_attachment_task ON public.attachment USING btree (task_id);
CREATE INDEX ix_fk_audit_log_user ON public.audit_log USING btree (user_id);
CREATE INDEX ix_fk_audit_log_task ON public.audit_log USING btree (task_id);
CREATE INDEX ix_audit_log_time ON public.audit_log USING btree (log_time);
CREATE INDEX ix_fk_comment_user ON public.comment USING btree (user_id);
CREATE INDEX ix_fk_comment_task ON public.comment USING btree (task_id);
CREATE INDEX ix_comment_created_at ON public.comment USING btree (created_at);
CREATE INDEX ix_fk_task_category ON public.task USING btree (category_id);
CREATE INDEX ix_fk_task_todolist ON public.task USING btree (todolist_id);
CREATE INDEX ix_fk_task_creator ON public.task USING btree (task_creator);
CREATE INDEX ix_task_state ON public.task USING btree (state);
CREATE INDEX ix_task_deadline ON public.task USING btree (deadline);
CREATE INDEX ix_fk_user_task_task ON public.task_users USING btree (task_id);
CREATE INDEX ix_fk_user_task_user ON public.task_users USING btree (user_id);
CREATE INDEX ix_fk_user_todolist_list ON public.todolist_users USING btree (todolist_id);
CREATE INDEX ix_fk_user_todolist_user ON public.todolist_users USING btree (user_id);
CREATE INDEX ix_fk_user_settings_user ON public.user_settings USING btree (user_id);
CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));
CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);
CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);
CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");
CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");
CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
CREATE TRIGGER trg_audit_task AFTER INSERT OR UPDATE ON task FOR EACH ROW EXECUTE FUNCTION log_task_change();
CREATE TRIGGER trg_check_task_permission BEFORE DELETE OR UPDATE ON task FOR EACH ROW EXECUTE FUNCTION check_task_permission();
CREATE TRIGGER trg_cleanup_task BEFORE DELETE ON task FOR EACH ROW EXECUTE FUNCTION cleanup_task_relations();
CREATE TRIGGER trg_set_task_creator BEFORE INSERT ON task FOR EACH ROW EXECUTE FUNCTION set_task_creator();
CREATE TRIGGER trg_set_task_updated BEFORE UPDATE ON task FOR EACH ROW EXECUTE FUNCTION set_task_updated();
CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();
CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();
CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();
CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();
CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();

CREATE OR REPLACE FUNCTION auth.email()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$function$

CREATE OR REPLACE FUNCTION auth.jwt()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$function$

CREATE OR REPLACE FUNCTION auth.role()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$function$

CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$function$

CREATE OR REPLACE FUNCTION extensions.armor(bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_armor$function$

CREATE OR REPLACE FUNCTION extensions.armor(bytea, text[], text[])
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_armor$function$

CREATE OR REPLACE FUNCTION extensions.crypt(text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_crypt$function$

CREATE OR REPLACE FUNCTION extensions.dearmor(text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_dearmor$function$

CREATE OR REPLACE FUNCTION extensions.decrypt(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_decrypt$function$

CREATE OR REPLACE FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_decrypt_iv$function$

CREATE OR REPLACE FUNCTION extensions.digest(text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_digest$function$

CREATE OR REPLACE FUNCTION extensions.digest(bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_digest$function$

CREATE OR REPLACE FUNCTION extensions.encrypt(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_encrypt$function$

CREATE OR REPLACE FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_encrypt_iv$function$

CREATE OR REPLACE FUNCTION extensions.gen_random_bytes(integer)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_random_bytes$function$

CREATE OR REPLACE FUNCTION extensions.gen_random_uuid()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/pgcrypto', $function$pg_random_uuid$function$

CREATE OR REPLACE FUNCTION extensions.gen_salt(text)
 RETURNS text
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_gen_salt$function$

CREATE OR REPLACE FUNCTION extensions.gen_salt(text, integer)
 RETURNS text
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_gen_salt_rounds$function$

CREATE OR REPLACE FUNCTION extensions.grant_pg_cron_access()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$function$

CREATE OR REPLACE FUNCTION extensions.grant_pg_graphql_access()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$function$

CREATE OR REPLACE FUNCTION extensions.grant_pg_net_access()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$function$

CREATE OR REPLACE FUNCTION extensions.hmac(text, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_hmac$function$

CREATE OR REPLACE FUNCTION extensions.hmac(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_hmac$function$

CREATE OR REPLACE FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pg_stat_statements', $function$pg_stat_statements_1_11$function$

CREATE OR REPLACE FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone)
 RETURNS record
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pg_stat_statements', $function$pg_stat_statements_info$function$

CREATE OR REPLACE FUNCTION extensions.pg_stat_statements_reset(userid oid DEFAULT 0, dbid oid DEFAULT 0, queryid bigint DEFAULT 0, minmax_only boolean DEFAULT false)
 RETURNS timestamp with time zone
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pg_stat_statements', $function$pg_stat_statements_reset_1_11$function$

CREATE OR REPLACE FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_armor_headers$function$

CREATE OR REPLACE FUNCTION extensions.pgp_key_id(bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_key_id_w$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt(bytea, bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_encrypt(text, bytea)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_encrypt(text, bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_decrypt(bytea, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_decrypt(bytea, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_encrypt(text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_encrypt(text, text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_text$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_bytea$function$

CREATE OR REPLACE FUNCTION extensions.pgrst_ddl_watch()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $function$

CREATE OR REPLACE FUNCTION extensions.pgrst_drop_watch()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $function$

CREATE OR REPLACE FUNCTION extensions.set_graphql_placeholder()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$function$

CREATE OR REPLACE FUNCTION extensions.uuid_generate_v1()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1$function$

CREATE OR REPLACE FUNCTION extensions.uuid_generate_v1mc()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1mc$function$

CREATE OR REPLACE FUNCTION extensions.uuid_generate_v3(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v3$function$

CREATE OR REPLACE FUNCTION extensions.uuid_generate_v4()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v4$function$

CREATE OR REPLACE FUNCTION extensions.uuid_generate_v5(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v5$function$

CREATE OR REPLACE FUNCTION extensions.uuid_nil()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_nil$function$

CREATE OR REPLACE FUNCTION extensions.uuid_ns_dns()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_dns$function$

CREATE OR REPLACE FUNCTION extensions.uuid_ns_oid()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_oid$function$

CREATE OR REPLACE FUNCTION extensions.uuid_ns_url()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_url$function$

CREATE OR REPLACE FUNCTION extensions.uuid_ns_x500()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_x500$function$

CREATE OR REPLACE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $function$

CREATE OR REPLACE FUNCTION pgbouncer.get_auth(p_usename text)
 RETURNS TABLE(username text, password text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $function$

CREATE OR REPLACE FUNCTION public.add_user_to_todolist(p_user_id integer, p_todolist_id integer, p_role_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$begin
  -- kontrola, jestli už tam user není
  if exists (
    select 1
    from todolist_users
    where user_id = p_user_id
      and todolist_id = p_todolist_id
  ) then
    raise exception 'User už je v tomto ToDo listu';
  end if;

  -- vložení
  insert into todolist_users (user_id, todolist_id, role_id)
  values (p_user_id, p_todolist_id, p_role_id);
end;$function$

CREATE OR REPLACE FUNCTION public.assign_user_to_task(p_user_id integer, p_task_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$begin
  if exists (
    select 1 from task_users
    where user_id = p_user_id
      and task_id = p_task_id
  ) then
    raise exception 'User už je přiřazen k tasku';
  end if;

  insert into task_users (user_id, task_id)
  values (p_user_id, p_task_id);
end;$function$

CREATE OR REPLACE FUNCTION public.change_user_role(p_user_id integer, p_todolist_id integer, p_new_role_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$begin
  update user_todolist
  set role_id = p_new_role_id
  where user_id = p_user_id
    and todolist_id = p_todolist_id;

  if not found then
    raise exception 'User není v tomto ToDo listu';
  end if;
end;$function$

CREATE OR REPLACE FUNCTION public.check_task_permission()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if not exists (
    select 1
    from public.todolist_users ut
    join public.app_user u on u.user_id = ut.user_id
    join public.group_role r on r.role_id = ut.role_id
    join public.task t on t.todolist_id = ut.todolist_id
    where u.auth_id = auth.uid()
      and t.task_id = coalesce(new.task_id, old.task_id)
      and r.role_name in ('koordinator', 'spravce')
  ) then
    raise exception 'Nemas opravneni upravovat tento task';
  end if;

  return coalesce(new, old);
end;
$function$

CREATE OR REPLACE FUNCTION public.cleanup_task_relations()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  delete from public.task_users where task_id = old.task_id;
  delete from public.comment where task_id = old.task_id;
  delete from public.attachment where task_id = old.task_id;
  delete from public.audit_log where task_id = old.task_id;
  return old;
end;
$function$

CREATE OR REPLACE FUNCTION public.create_task(p_name text, p_description text, p_deadline timestamp without time zone, p_todolist_id integer, p_category_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  v_task_id int;
begin
  insert into task (name, description, deadline, state, todolist_id, category_id)
  values (p_name, p_description, p_deadline, 'nesplneno', p_todolist_id, p_category_id)
  returning task_id into v_task_id;

  return v_task_id;
end;
$function$

CREATE OR REPLACE FUNCTION public.create_todolist(p_name text, p_list_type text, p_user_id integer, p_role_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  v_todolist_id int;
begin
  insert into todolist (name, list_type)
  values (p_name, p_list_type)
  returning todolist_id into v_todolist_id;

  insert into user_todolist (user_id, todolist_id, role_id)
  values (p_user_id, v_todolist_id, p_role_id);

  return v_todolist_id;
end;
$function$

CREATE OR REPLACE FUNCTION public.delete_task(p_task_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  delete from task
  where task_id = p_task_id;

  if not found then
    raise exception 'Task neexistuje';
  end if;
end;
$function$

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$declare
  v_user_id integer;
  v_todolist_id integer;
  v_spravce_role_id integer;
  v_app_user_role_id integer;
begin
  -- Required role in group_role
  select role_id
    into v_spravce_role_id
  from public.group_role
  where lower(role_name) = 'spravce'
  limit 1;

  if v_spravce_role_id is null then
    raise exception 'Role "spravce" not found in public.group_role';
  end if;

  -- Optional app-level role ("user")
  select app_role_id
    into v_app_user_role_id
  from public.app_role
  where lower(role_name) = 'user'
  limit 1;

  -- Upsert app_user by email, keep auth_id/app_role_id in sync
  insert into public.app_user (auth_id, email, app_role_id)
  values (new.id, new.email, v_app_user_role_id)
  on conflict (email) do update
    set auth_id = excluded.auth_id,
        app_role_id = coalesce(public.app_user.app_role_id, excluded.app_role_id)
  returning user_id into v_user_id;

  -- Avoid duplicate personal list: reuse existing if already assigned
  select t.todolist_id
    into v_todolist_id
  from public.todolist_users ut
  join public.todolist t on t.todolist_id = ut.todolist_id
  where ut.user_id = v_user_id
    and lower(t.list_type) = 'personal'
  limit 1;

  -- Create personal list only if user has none
  if v_todolist_id is null then
    insert into public.todolist (name, list_type)
    values (coalesce(new.email, 'new user') || ' - osobni list', 'personal')
    returning todolist_id into v_todolist_id;

    insert into public.todolist_users (user_id, todolist_id, role_id)
    values (v_user_id, v_todolist_id, v_spravce_role_id);
  end if;

  return new;
end;$function$

CREATE OR REPLACE FUNCTION public.log_task_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id integer;
begin
  if tg_op = 'DELETE' then
    return old;
  end if;

  select au.user_id
    into v_user_id
  from public.app_user au
  where au.auth_id = auth.uid()
  limit 1;

  insert into public.audit_log(action, log_time, user_id, task_id)
  values (tg_op, now(), v_user_id, new.task_id);

  return new;
end;
$function$

CREATE OR REPLACE FUNCTION public.login_user(p_email text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$declare
  v_exists int;
begin
  select count(*) into v_exists
  from app_user
  where email = p_email;

  if v_exists = 0 then
    return 'USER_NOT_FOUND';
  else
    return 'OK';
  end if;
end;$function$

CREATE OR REPLACE FUNCTION public.register_user(p_email text, p_name text, p_surname text, p_auth_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  insert into app_user (email, name, surname, auth_id)
  values (p_email, p_name, p_surname, p_auth_id);
end;
$function$

CREATE OR REPLACE FUNCTION public.remove_user_from_todolist(p_user_id integer, p_todolist_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$begin
  delete from todolist_users
  where user_id = p_user_id
    and todolist_id = p_todolist_id;
end;$function$

CREATE OR REPLACE FUNCTION public.set_task_creator()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_user_id integer;
begin
  if new.task_creator is not null then
    return new;
  end if;

  select au.user_id
    into v_user_id
  from public.app_user au
  where au.auth_id = auth.uid()
  limit 1;

  if v_user_id is null then
    raise exception 'Authenticated user is not mapped in app_user';
  end if;

  new.task_creator := v_user_id;
  return new;
end;
$function$

CREATE OR REPLACE FUNCTION public.set_task_updated()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_by := auth.uid();
  return new;
end;
$function$

CREATE OR REPLACE FUNCTION public.unassign_user_from_task(p_user_id integer, p_task_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$begin
  delete from task_users
  where user_id = p_user_id
    and task_id = p_task_id;
end;$function$

CREATE OR REPLACE FUNCTION public.update_task_status(p_task_id integer, p_new_state text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  update task
  set state = p_new_state
  where task_id = p_task_id;

  if not found then
    raise exception 'Task neexistuje';
  end if;
end;
$function$

CREATE OR REPLACE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024))
 RETURNS SETOF realtime.wal_rls
 LANGUAGE plpgsql
AS $function$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$function$

CREATE OR REPLACE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$function$

CREATE OR REPLACE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[])
 RETURNS text
 LANGUAGE sql
AS $function$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $function$

CREATE OR REPLACE FUNCTION realtime."cast"(val text, type_ regtype)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$function$

CREATE OR REPLACE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $function$

CREATE OR REPLACE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[])
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $function$

CREATE OR REPLACE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer)
 RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
 LANGUAGE sql
 SET log_min_messages TO 'fatal'
AS $function$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL AND ppt.tablename NOT LIKE '% %'),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  -- Count raw slot entries before apply_rls/subscription filter
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  -- Apply RLS and filter as before
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  -- Real rows with slot count attached
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  -- Sentinel row: always returned when no real rows exist so Elixir can
  -- always read slot_changes_count. Identified by wal IS NULL.
  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$function$

CREATE OR REPLACE FUNCTION realtime.quote_wal2json(entity regclass)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $function$

CREATE OR REPLACE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$function$

CREATE OR REPLACE FUNCTION realtime.subscription_check_filters()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $function$

CREATE OR REPLACE FUNCTION realtime.to_regrole(role_name text)
 RETURNS regrole
 LANGUAGE sql
 IMMUTABLE
AS $function$ select role_name::regrole $function$

CREATE OR REPLACE FUNCTION realtime.topic()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
select nullif(current_setting('realtime.topic', true), '')::text;
$function$

CREATE OR REPLACE FUNCTION storage.allow_any_operation(expected_operations text[])
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$function$

CREATE OR REPLACE FUNCTION storage.allow_only_operation(expected_operation text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$function$

CREATE OR REPLACE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$function$

CREATE OR REPLACE FUNCTION storage.enforce_bucket_name_length()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$function$

CREATE OR REPLACE FUNCTION storage.extension(name text)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$function$

CREATE OR REPLACE FUNCTION storage.filename(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$function$

CREATE OR REPLACE FUNCTION storage.foldername(name text)
 RETURNS text[]
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$function$

CREATE OR REPLACE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$function$

CREATE OR REPLACE FUNCTION storage.get_size_by_bucket()
 RETURNS TABLE(size bigint, bucket_id text)
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$function$

CREATE OR REPLACE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text)
 RETURNS TABLE(key text, id text, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$function$

CREATE OR REPLACE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text)
 RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$function$

CREATE OR REPLACE FUNCTION storage.operation()
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$function$

CREATE OR REPLACE FUNCTION storage.protect_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$function$

CREATE OR REPLACE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text)
 RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$function$

CREATE OR REPLACE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text)
 RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$function$

CREATE OR REPLACE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text)
 RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$function$

CREATE OR REPLACE FUNCTION storage.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$function$

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea DEFAULT '\x7067736f6469756d'::bytea, nonce bytea DEFAULT NULL::bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_decrypt_by_id$function$

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea DEFAULT '\x7067736f6469756d'::bytea, nonce bytea DEFAULT NULL::bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_encrypt_by_id$function$

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_noncegen()
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_noncegen$function$

CREATE OR REPLACE FUNCTION vault.create_secret(new_secret text, new_name text DEFAULT NULL::text, new_description text DEFAULT ''::text, new_key_id uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  rec record;
BEGIN
  INSERT INTO vault.secrets (secret, name, description)
  VALUES (
    new_secret,
    new_name,
    new_description
  )
  RETURNING * INTO rec;
  UPDATE vault.secrets s
  SET secret = encode(vault._crypto_aead_det_encrypt(
    message := convert_to(rec.secret, 'utf8'),
    additional := convert_to(s.id::text, 'utf8'),
    key_id := 0,
    context := 'pgsodium'::bytea,
    nonce := rec.nonce
  ), 'base64')
  WHERE id = rec.id;
  RETURN rec.id;
END
$function$

CREATE OR REPLACE FUNCTION vault.update_secret(secret_id uuid, new_secret text DEFAULT NULL::text, new_name text DEFAULT NULL::text, new_description text DEFAULT NULL::text, new_key_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  decrypted_secret text := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE id = secret_id);
BEGIN
  UPDATE vault.secrets s
  SET
    secret = CASE WHEN new_secret IS NULL THEN s.secret
                  ELSE encode(vault._crypto_aead_det_encrypt(
                    message := convert_to(new_secret, 'utf8'),
                    additional := convert_to(s.id::text, 'utf8'),
                    key_id := 0,
                    context := 'pgsodium'::bytea,
                    nonce := s.nonce
                  ), 'base64') END,
    name = coalesce(new_name, s.name),
    description = coalesce(new_description, s.description),
    updated_at = now()
  WHERE s.id = secret_id;
END
$function$


ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";
ALTER SEQUENCE "public"."app_role_app_role_id_seq" OWNED BY "public"."app_role"."app_role_id";

COMMIT;
