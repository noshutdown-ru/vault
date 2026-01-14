## Version: 0.8.2
### Improvements
- 

# Changelog
## Version: 0.8.1
### Improvements
- Github Actions CI workflow improved to support auto release on merge in master

## Version: 0.8.0
### Improvements
- Added generation of password and encryption key
- [Encryption key generation in proper format](https://github.com/noshutdown-ru/vault/issues/88)
### Bugfix
- [During view/edit key no link to download file](https://github.com/noshutdown-ru/vault/issues/92)
- [Json format export fixed to Redmine standard](https://github.com/noshutdown-ru/vault/issues/90)
- Fixed broken filter by tags 
- Translation fixes 

## Version: 0.7.3 
### Bugfix
- [Fixing error viewing Key File types](https://github.com/noshutdown-ru/vault/issues/110)

## Version: 0.7.2
### Improvements
- Removed search filed and added filters per column.
- Context menu removed since it have duplications in table.
### Bugfix
- Project search fixed [issue](https://github.com/noshutdown-ru/vault/issues/108)
- Removed link from password type [issue](https://github.com/noshutdown-ru/vault/issues/107)

## Version: 0.7.1
### Improvements
- Improved View All keys view
- Added option to move orphaned keys to another project

## Version: 0.7.0
### Improvements
- Added Project ID column for into All keys view [issue](https://github.com/noshutdown-ru/vault/issues/100)
- Added api for create,update,delete keys
### Bugfix
- View all keys permissions issue fixed [PR](https://github.com/noshutdown-ru/vault/pull/103)

## Version: 0.6.0
### Improvements
- [Redmine 6.0 compatibility.](https://github.com/noshutdown-ru/vault/issues/96)

## Version: 0.5.0
### Improvements
- [Redmine 5.0 compatibility.](https://github.com/noshutdown-ru/vault/issues/91)
- Added view of all keys
- Key tags view improved, tags are colored now
- Keys search improved for all and per project
- Added copy to clipboard for login
- Added browser title for plugin page
- Added new type of key SFTP
- Fixed compatibility issue with the new Zeitwerk loader
- Improved translation
- Code refactoring
- Added Github Actions for CI

### Braking changes
- Deleted code which checks Redmine version  
  - `Redmine::VERSION.to_s.start_with?`
  - 3.1/3.2/3.3/3.4/4

## Version: 0.4.3
### Bugfix
- [Saving settings path](https://github.com/noshutdown-ru/vault/pull/67)
- Fixed saving settings if key empty

## Version: 0.4.2
### Improvements
- Added support of Redmine 4.2.1.stable, tested on 2.7.3-p183
- Updated English translation Keys changed to Passwords
- Error handling for Encryption Key (VaultEencryption) now must be exact 16 symbols

## Version: 0.4.1
### Improvements
- [Redmine 4.1 compatibility.](https://github.com/noshutdown-ru/vault/issues/57)
- Added CHANGELOG.md

## Version: 0.4.0
### Features
- [Get keys from project by api call.](https://github.com/noshutdown-ru/vault/pull/54) `http --json GET http://redmine.server/projects/test1/keys.json key=...`
### Improvements
- [Added validation of encryption key length.](https://github.com/noshutdown-ru/vault/pull/49)
- [Updated Portuguese - Brazil translation.](https://github.com/noshutdown-ru/vault/pull/50)
- Added Japanese translation.
- Added French translation.
- [Import from backup update existing keys by name instead of create new ones.](https://github.com/noshutdown-ru/vault/pull/53)
- [Whitelists support groups.](https://github.com/noshutdown-ru/vault/pull/51)
### Bugfixes                   
- [Export keys not working on Windows.](https://github.com/noshutdown-ru/vault/pull/52)
- [Error in redmine subdir icons display.](https://github.com/noshutdown-ru/vault/pull/47)

## Version: 0.3.11
### Improvements
- [Support Redmine 4.0.* .](https://github.com/noshutdown-ru/vault/pull/45)
### Bugfixes 
- [Menu admin no icon.](https://github.com/noshutdown-ru/vault/issues/46)

## Version: 0.3.10
### Improvements
- [Added Spanish translation.](https://github.com/noshutdown-ru/vault/pull/42)
### Bugfixes
- [Whitelist cannot be modifyed.](https://github.com/noshutdown-ru/vault/issues/41)
- [Redmine encryption, password cannot be longer 32 characters.](https://github.com/noshutdown-ru/vault/issues/43)

## Version: 0.3.9
### Bugfixes
- [Incompatible character encodings.](https://github.com/noshutdown-ru/vault/issues/37)

## Version: 0.3.8
### Improvements
- [Added German translation.](https://github.com/noshutdown-ru/vault/pull/33)
- [Added Portugal translation.](https://github.com/noshutdown-ru/vault/pull/26)
### Bugfixes
- [Double icon.](https://github.com/noshutdown-ru/vault/pull/31)
- [Copy to clipboard.](https://github.com/noshutdown-ru/vault/issues/28)

## Version: 0.3.7
### Bugfixes 
- [Search not working.](https://github.com/noshutdown-ru/vault/issues/24)

## Version: 0.3.6
### Bugfixes 
- [Undefined method 'offset'.](https://github.com/noshutdown-ru/vault/issues/23)

## Version: 0.3.5
### Bugfixes
- [White lists not block user by direct link.](https://github.com/noshutdown-ru/vault/issues/22)

## Version: 0.3.4
- [Error on searching by Name/URL (PostgreSQL).](https://github.com/noshutdown-ru/vault/issues/13) 
- [Right click no url (Redmine 3.4).](https://github.com/noshutdown-ru/vault/issues/17)

## Version: 0.3.3
### Improvements
- Updated Chinese translation.

## Version: 0.3.2
### Features
- Added support Redmine 3.4 .
- Added copy by click on the fields: url, login.
- Added China translation. 
- Added Dutch translation.
- Added Italian translation.
### Bugfixes
- Fixed error uploading small files.

## Version: 0.3.1
### Bugfixes
- Edit whitelists problem.

## Version: 0.3.0
### Features
- Added separation of access rights for users (whitelist).
- Supports Redmine 3.3 .
- Supports PostgreSQL.
- Added context menu to the list of keys.
### Improvements
- Improved mechanism for creating backups: added tags.
- http/https url open in new tabs.
### Deprecated
- Supports Redmine 2.6 terminated.

## Version: 0.2.0
### Features
- Added ability to search by Name, URL, Tag.
- Added auto-complete for tags.
- Added functionality of creating backup copies of keys (no tags).
- Supports Redmine 3.2 .

## Version: 0.1.2
### Features
- Added the ability to attach any file.
- Added the ability to copy to the clipboard, each key field.
### Improvements
- Improved user interface display tags.
- Improved key list display interface.
### Bugfixes
- Fixed an issue when you add a key file.

## Version: 0.1.0
### Improvements
- Update version.

## Version: 0.0.6
### Features
- Added the ability to specify a tag to the keys.
- Added preview mode key card (without editing).
- Added the ability to encrypt through redmine (database_cipher_key).
### Improvements
- Code refactoring.

## Version: 0.0.5
### Features
- Added pagination.
- Added ability to sort the keys by name.
- Added a more flexible system of separation of access rights by role.
- Added the ability to clone a key (it helps to create the same type of keys).
- Added ability to print a list of passwords to PDF.
### Improvements
- Updated field at the keys: Name, URL, User Name, Password, Comment.

## Version: 0.0.4
### Features
- Adding ssh keys file.
### Improvements
- Updated design.
- Separation of access by role.
- Compatible with Redmine 2.6 .

## Version: 0.0.3
### Improvements
- Compatible with Ruby 1.9.1 .

## Version: 0.0.2
### Features
- Delete keys.
- Encryption keys.

## Version: 0.0.1
### Features
- Support Redmine 3.1.0.stable.
- Support Ruby 2.2.2-p95,2.0.0-p598.
- Support Rails 4.2.3 .
- Support Database: SQLite, MySQL.
- Support OS: Linux, OS X, Windows.
- Support Browsers: Chrome, Safari, Internet Explorer, Firefox.
- Storage of keys for each project.
- Search keys.
- Adding keys.
- Edit keys.
- Saving the key to the clipboard.