CREATE TABLE IF NOT EXISTS Branch (
  name VARCHAR(10),
  repo_id CHAR(40),
  commit_id CHAR(40),
  PRIMARY KEY (repo_id, name)
);

CREATE TABLE IF NOT EXISTS FileLockTimestamp (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(40),
  update_time BIGINT NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS filelocktimestamp_repo_id_idx ON FileLockTimestamp(repo_id);

CREATE TABLE IF NOT EXISTS FileLocks (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(40) NOT NULL,
  path TEXT NOT NULL,
  user_name VARCHAR(255) NOT NULL,
  lock_time BIGINT,
  expire BIGINT
);
CREATE INDEX IF NOT EXISTS filelocks_repo_id_idx ON FileLocks(repo_id);

CREATE TABLE IF NOT EXISTS FolderGroupPerm (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36) NOT NULL,
  path TEXT NOT NULL,
  permission CHAR(15),
  group_id INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS foldergroupperm_repo_id_idx ON FolderGroupPerm(repo_id);

CREATE TABLE IF NOT EXISTS FolderPermTimestamp (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  timestamp BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS folderpermtimestamp_repo_id_idx ON FolderPermTimestamp(repo_id);

CREATE TABLE IF NOT EXISTS FolderUserPerm (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36) NOT NULL,
  path TEXT NOT NULL,
  permission CHAR(15),
  "user" VARCHAR(255) NOT NULL
);
CREATE INDEX IF NOT EXISTS folderuserperm_repo_id_idx ON FolderUserPerm(repo_id);

CREATE TABLE IF NOT EXISTS GCID (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  gc_id CHAR(36)
);
CREATE UNIQUE INDEX IF NOT EXISTS gcid_repo_id_idx ON GCID(repo_id);

CREATE TABLE IF NOT EXISTS GarbageRepos (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36)
);
CREATE UNIQUE INDEX IF NOT EXISTS garbagerepos_repo_id_idx ON GarbageRepos(repo_id);

CREATE TABLE IF NOT EXISTS InnerPubRepo (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  permission CHAR(15)
);
CREATE UNIQUE INDEX IF NOT EXISTS innerpubrepo_repo_id_idx ON InnerPubRepo(repo_id);

CREATE TABLE IF NOT EXISTS LastGCID (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  client_id VARCHAR(128),
  gc_id CHAR(36)
);
CREATE UNIQUE INDEX IF NOT EXISTS lastgcid_repo_id_client_id_idx ON LastGCID(repo_id, client_id);

CREATE TABLE IF NOT EXISTS OrgGroupRepo (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  repo_id CHAR(37),
  group_id INTEGER,
  owner VARCHAR(255),
  permission CHAR(15)
);
CREATE UNIQUE INDEX IF NOT EXISTS orggrouprepo_org_id_group_id_repo_id_idx ON OrgGroupRepo(org_id, group_id, repo_id);
CREATE INDEX IF NOT EXISTS orggrouprepo_repo_id_idx ON OrgGroupRepo(repo_id);
CREATE INDEX IF NOT EXISTS orggrouprepo_owner_idx ON OrgGroupRepo(owner);

CREATE TABLE IF NOT EXISTS OrgInnerPubRepo (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  repo_id CHAR(37),
  permission CHAR(15)
);
CREATE UNIQUE INDEX IF NOT EXISTS orginnerpubrepo_org_id_repo_id_idx ON OrgInnerPubRepo(org_id, repo_id);

CREATE TABLE IF NOT EXISTS OrgQuota (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  quota BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS orgquota_org_id_idx ON OrgQuota(org_id);

CREATE TABLE IF NOT EXISTS OrgRepo (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  repo_id CHAR(37),
  "user" VARCHAR(255)
);
CREATE UNIQUE INDEX IF NOT EXISTS orgrepo_org_id_repo_id_idx ON OrgRepo(org_id, repo_id);
CREATE UNIQUE INDEX IF NOT EXISTS orgrepo_repo_id_idx ON OrgRepo(repo_id);
CREATE INDEX IF NOT EXISTS orgrepo_org_id_user_idx ON OrgRepo(org_id, "user");
CREATE INDEX IF NOT EXISTS orgrepo_user_idx ON OrgRepo("user");

CREATE TABLE IF NOT EXISTS OrgSharedRepo (
  id SERIAL PRIMARY KEY,
  org_id INTEGER,
  repo_id CHAR(37),
  from_email VARCHAR(255),
  to_email VARCHAR(255),
  permission CHAR(15)
);
CREATE INDEX IF NOT EXISTS orgsharedrepo_repo_id_idx ON OrgSharedRepo(repo_id);
CREATE INDEX IF NOT EXISTS orgsharedrepo_org_id_repo_id_idx ON OrgSharedRepo(org_id, repo_id);
CREATE INDEX IF NOT EXISTS orgsharedrepo_from_email_idx ON OrgSharedRepo(from_email);
CREATE INDEX IF NOT EXISTS orgsharedrepo_to_email_idx ON OrgSharedRepo(to_email);

CREATE TABLE IF NOT EXISTS OrgUserQuota (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  "user" VARCHAR(255),
  quota BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS orguserquota_org_id_user_idx ON OrgUserQuota(org_id, "user");

CREATE TABLE IF NOT EXISTS Repo (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37)
);
CREATE UNIQUE INDEX IF NOT EXISTS repo_repo_id_idx ON Repo(repo_id);

CREATE TABLE IF NOT EXISTS RepoFileCount (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  file_count BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS repofilecount_repo_id_idx ON RepoFileCount(repo_id);

CREATE TABLE IF NOT EXISTS RepoGroup (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  group_id INTEGER,
  user_name VARCHAR(255),
  permission CHAR(15)
);
CREATE UNIQUE INDEX IF NOT EXISTS repogroup_group_id_repo_id_idx ON RepoGroup(group_id, repo_id);
CREATE INDEX IF NOT EXISTS repogroup_repo_id_idx ON RepoGroup(repo_id);
CREATE INDEX IF NOT EXISTS repogroup_user_name_idx ON RepoGroup(user_name);

CREATE TABLE IF NOT EXISTS RepoHead (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  branch_name VARCHAR(10)
);
CREATE UNIQUE INDEX IF NOT EXISTS repohead_repo_id_idx ON RepoHead(repo_id);

CREATE TABLE IF NOT EXISTS RepoHistoryLimit (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  days INTEGER
);
CREATE UNIQUE INDEX IF NOT EXISTS repohistorylimit_repo_id_idx ON RepoHistoryLimit(repo_id);

CREATE TABLE IF NOT EXISTS RepoInfo (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  name VARCHAR(255) NOT NULL,
  update_time BIGINT,
  version INTEGER,
  is_encrypted INTEGER,
  last_modifier VARCHAR(255),
  status INTEGER DEFAULT 0,
  type VARCHAR(10)
);
CREATE UNIQUE INDEX IF NOT EXISTS repoinfo_repo_id_idx ON RepoInfo(repo_id);
CREATE INDEX IF NOT EXISTS repoinfo_type_idx ON RepoInfo(type);

CREATE TABLE IF NOT EXISTS RepoOwner (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  owner_id VARCHAR(255)
);
CREATE UNIQUE INDEX IF NOT EXISTS repoowner_repo_id_idx ON RepoOwner(repo_id);
CREATE INDEX IF NOT EXISTS repoowner_owner_id_idx ON RepoOwner(owner_id);

CREATE TABLE IF NOT EXISTS RepoSize (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  "size" BIGINT,
  head_id CHAR(41)
);
CREATE UNIQUE INDEX IF NOT EXISTS reposize_repo_id_idx ON RepoSize(repo_id);

CREATE TABLE IF NOT EXISTS RepoStorageId (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(40) NOT NULL,
  storage_id VARCHAR(255) NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS repostorageid_repo_id_idx ON RepoStorageId(repo_id);

CREATE TABLE IF NOT EXISTS RepoSyncError (
  id BIGSERIAL PRIMARY KEY,
  token CHAR(41),
  error_time BIGINT,
  error_con VARCHAR(1024)
);
CREATE UNIQUE INDEX IF NOT EXISTS reposyncerror_token_idx ON RepoSyncError(token);

CREATE TABLE IF NOT EXISTS RepoTokenPeerInfo (
  id BIGSERIAL PRIMARY KEY,
  token CHAR(41),
  peer_id CHAR(41),
  peer_ip VARCHAR(50),
  peer_name VARCHAR(255),
  sync_time BIGINT,
  client_ver VARCHAR(20)
);
CREATE UNIQUE INDEX IF NOT EXISTS repotokenpeerinfo_token_idx ON RepoTokenPeerInfo(token);
CREATE INDEX IF NOT EXISTS repotokenpeerinfo_peer_id_idx ON RepoTokenPeerInfo(peer_id);

CREATE TABLE IF NOT EXISTS RepoTrash (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  repo_name VARCHAR(255),
  head_id CHAR(40),
  owner_id VARCHAR(255),
  "size" BIGINT,
  org_id INTEGER,
  del_time BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS repotrash_repo_id_idx ON RepoTrash(repo_id);
CREATE INDEX IF NOT EXISTS repotrash_owner_id_idx ON RepoTrash(owner_id);
CREATE INDEX IF NOT EXISTS repotrash_org_id_idx ON RepoTrash(org_id);

CREATE TABLE IF NOT EXISTS RepoUserToken (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  email VARCHAR(255),
  token CHAR(41)
);
CREATE UNIQUE INDEX IF NOT EXISTS repousertoken_repo_id_token_idx ON RepoUserToken(repo_id, token);
CREATE INDEX IF NOT EXISTS repousertoken_token_idx ON RepoUserToken(token);
CREATE INDEX IF NOT EXISTS repousertoken_email_idx ON RepoUserToken(email);

CREATE TABLE IF NOT EXISTS RepoValidSince (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  timestamp BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS repovalidsince_repo_id_idx ON RepoValidSince(repo_id);

CREATE TABLE IF NOT EXISTS RoleQuota (
  id BIGSERIAL PRIMARY KEY,
  role VARCHAR(255),
  quota BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS rolequota_role_idx ON RoleQuota(role);

CREATE TABLE IF NOT EXISTS SeafileConf (
  id BIGSERIAL PRIMARY KEY,
  cfg_group VARCHAR(255) NOT NULL,
  cfg_key VARCHAR(255) NOT NULL,
  value VARCHAR(255),
  property INTEGER
);

CREATE TABLE IF NOT EXISTS SharedRepo (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  from_email VARCHAR(255),
  to_email VARCHAR(255),
  permission CHAR(15)
);
CREATE INDEX IF NOT EXISTS sharedrepo_repo_id_idx ON SharedRepo(repo_id);
CREATE INDEX IF NOT EXISTS sharedrepo_from_email_idx ON SharedRepo(from_email);
CREATE INDEX IF NOT EXISTS sharedrepo_to_email_idx ON SharedRepo(to_email);

CREATE TABLE IF NOT EXISTS SystemInfo (
  id SERIAL PRIMARY KEY,
  info_key VARCHAR(256),
  info_value VARCHAR(1024)
);

CREATE TABLE IF NOT EXISTS UserQuota (
  "user" VARCHAR(255) PRIMARY KEY,
  quota BIGINT
);

CREATE TABLE IF NOT EXISTS UserShareQuota (
  "user" VARCHAR(255) PRIMARY KEY,
  quota BIGINT
);

CREATE TABLE IF NOT EXISTS VirtualRepo (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(36),
  origin_repo CHAR(36),
  path TEXT,
  base_commit CHAR(40)
);
CREATE UNIQUE INDEX IF NOT EXISTS virtualrepo_repo_id_idx ON VirtualRepo(repo_id);
CREATE INDEX IF NOT EXISTS virtualrepo_origin_repo_idx ON VirtualRepo(origin_repo);

CREATE TABLE IF NOT EXISTS WebAP (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(37),
  access_property CHAR(10)
);
CREATE UNIQUE INDEX IF NOT EXISTS webap_repo_id_idx ON WebAP(repo_id);

CREATE TABLE IF NOT EXISTS WebUploadTempFiles (
  id BIGSERIAL PRIMARY KEY,
  repo_id CHAR(40) NOT NULL,
  file_path TEXT NOT NULL,
  tmp_file_path TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS webuploadtempfiles_repo_id_idx ON WebUploadTempFiles(repo_id);

CREATE TABLE IF NOT EXISTS RoleUploadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  role VARCHAR(255),
  upload_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS roleuploadratelimit_role_idx ON RoleUploadRateLimit(role);

CREATE TABLE IF NOT EXISTS RoleDownloadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  role VARCHAR(255),
  download_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS roledownloadratelimit_role_idx ON RoleDownloadRateLimit(role);

CREATE TABLE IF NOT EXISTS UserUploadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  "user" VARCHAR(255),
  upload_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS useruploadratelimit_user_idx ON UserUploadRateLimit("user");

CREATE TABLE IF NOT EXISTS UserDownloadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  "user" VARCHAR(255),
  download_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS userdownloadratelimit_user_idx ON UserDownloadRateLimit("user");

CREATE TABLE IF NOT EXISTS OrgUserDefaultQuota (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  quota BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS orguserdefaultquota_org_id_idx ON OrgUserDefaultQuota(org_id);

CREATE TABLE IF NOT EXISTS OrgDownloadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  download_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS orgdownloadratelimit_org_id_idx ON OrgDownloadRateLimit(org_id);

CREATE TABLE IF NOT EXISTS OrgUploadRateLimit (
  id BIGSERIAL PRIMARY KEY,
  org_id INTEGER,
  upload_limit BIGINT
);
CREATE UNIQUE INDEX IF NOT EXISTS orguploadratelimit_org_id_idx ON OrgUploadRateLimit(org_id);
