PRAGMA foreign_keys = ON;
CREATE TABLE fixture_collections (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL);
CREATE TABLE fixture_items (id TEXT NOT NULL PRIMARY KEY, collection_id TEXT NOT NULL REFERENCES fixture_collections(id), title TEXT NOT NULL, notes TEXT NOT NULL DEFAULT '');
INSERT INTO fixture_collections VALUES ('older-parent', 'Preserved collection');
INSERT INTO fixture_items VALUES ('older-child', 'older-parent', 'Preserved text', 'Version two notes');
PRAGMA user_version = 2;
