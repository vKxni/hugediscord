PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
CREATE TABLE messages (
msg_id INTEGER NOT NULL PRIMARY KEY,
channel_id INTEGER NOT NULL,
label TEXT NOT NULL,
msg_body TEXT NOT NULL
);
CREATE TABLE prereqs (role_id1 INTEGER NOT NULL, role_id2 INTEGER NOT NULL, PRIMARY KEY (role_id1, role_id2));
CREATE TABLE contradicts (role_id1 INTEGER NOT NULL, role_id2 INTEGER NOT NULL, PRIMARY KEY (role_id1, role_id2));
CREATE TABLE removes (role_id1 INTEGER NOT NULL, role_id2 INTEGER NOT NULL, PRIMARY KEY (role_id1, role_id2));

CREATE TABLE reamojis (
msg_id INTEGER NOT NULL,
emoji TEXT NOT NULL,
role_id INTEGER NOT NULL,
PRIMARY KEY (msg_id, role_id),
FOREIGN KEY (msg_id) REFERENCES messages(msg_id) ON DELETE CASCADE
);
COMMIT;
