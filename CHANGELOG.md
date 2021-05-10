## Version: 0.4.3 (10.05.2021)
### Bugfix
- [Saving settings path](https://github.com/noshutdown-ru/vault/pull/67)
- Fixed saving settings if key empty

## Version: 0.4.2 (10.05.2021)
### Improvements
- Added support of Redmine 4.2.1.stable, tested on 2.7.3-p183
- Updated English translation Keys changed to Passwords
- Error handling for Encryption Key (VaultEencryption) now must be exact 16 symbols

## Version: 0.4.1 (04.01.2020)
### Improvements
- [Redmine 4.1 compatibility.](https://github.com/noshutdown-ru/vault/issues/57)
- Added CHANGELOG.md

## Version: 0.4.0 (22.12.2019)
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

## Version: 0.3.11 (10.02.2019)
### Improvements
- [Support Redmine 4.0.* .](https://github.com/noshutdown-ru/vault/pull/45)
### Bugfixes 
- [Menu admin no icon.](https://github.com/noshutdown-ru/vault/issues/46)

## Version: 0.3.10 (10.12.2018)
### Improvements
- [Added Spanish translation.](https://github.com/noshutdown-ru/vault/pull/42)
### Bugfixes
- [Whitelist cannot be modifyed.](https://github.com/noshutdown-ru/vault/issues/41)
- [Redmine encryption, password cannot be longer 32 characters.](https://github.com/noshutdown-ru/vault/issues/43)

## Version: 0.3.9 (23.05.2018)
### Bugfixes
- [Incompatible character encodings.](https://github.com/noshutdown-ru/vault/issues/37)

## Version: 0.3.8 (21.05.2018)
### Improvements
- [Added German translation.](https://github.com/noshutdown-ru/vault/pull/33)
- [Added Portugal translation.](https://github.com/noshutdown-ru/vault/pull/26)
### Bugfixes
- [Double icon.](https://github.com/noshutdown-ru/vault/pull/31)
- [Copy to clipboard.](https://github.com/noshutdown-ru/vault/issues/28)

## Version: 0.3.7 (20.02.2018)
### Bugfixes 
- [Search not working.](https://github.com/noshutdown-ru/vault/issues/24)

## Version: 0.3.6 (13.02.2018)
### Bugfixes 
- [Undefined method 'offset'.](https://github.com/noshutdown-ru/vault/issues/23)

## Version: 0.3.5 (06.02.2018)
### Bugfixes
- [White lists not block user by direct link.](https://github.com/noshutdown-ru/vault/issues/22)
## Version: 0.3.4 (17.01.2018)
- [Error on searching by Name/URL (PostgreSQL).](https://github.com/noshutdown-ru/vault/issues/13) 
- [Right click no url (Redmine 3.4).](https://github.com/noshutdown-ru/vault/issues/17)

## Version: 0.3.3 (19.10.2017)
### Improvements
- Updated Chinese translation.

## Version: 0.3.2 (17.09.2017)
### Features
- Added support Redmine 3.4 .
- Added copy by click on the fields: url, login.
- Added China translation. 
- Added Dutch translation.
- Added Italian translation.
### Bugfixes
- Fixed error uploading small files.

## Version: 0.3.1 (11.12.2016)
### Bugfixes
- Edit whitelists problem.

## Version: 0.3.0 (07.12.2016)
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

## Version: 0.2.0 (08.07/2016)
### Features
- Added ability to search by Name, URL, Tag.
- Added auto-complete for tags.
- Added functionality of creating backup copies of keys (no tags).
- Supports Redmine 3.2 .

## Version: 0.1.2 (27.02.2016)
### Features
- Added the ability to attach any file.
- Added the ability to copy to the clipboard, each key field.
### Improvements
- Improved user interface display tags.
- Improved key list display interface.
### Bugfixes
- Fixed an issue when you add a key file.

## Version: 0.1.0 (18.01.2016)
### Improvements
- Update version.

## Version: 0.0.6 (31.12.2015)
### Features
- Added the ability to specify a tag to the keys.
- Added preview mode key card (without editing).
- Added the ability to encrypt through redmine (database_cipher_key).
### Improvements
- Code refactoring.

## Version: 0.0.5 (01.11.2015)
### Features
- Added pagination.
- Added ability to sort the keys by name.
- Added a more flexible system of separation of access rights by role.
- Added the ability to clone a key (it helps to create the same type of keys).
- Added ability to print a list of passwords to PDF.
### Improvements
- Updated field at the keys: Name, URL, User Name, Password, Comment.

## Version: 0.0.4 (01.10.2015)
### Features
- Adding ssh keys file.
### Improvements
- Updated design.
- Separation of access by role.
- Compatible with Redmine 2.6 .

## Version: 0.0.3 (02.09.2015)
### Improvements
- Compatible with Ruby 1.9.1 .

## Version: 0.0.2 (01.09.2015)
### Features
- Delete keys.
- Encryption keys.

## Version: 0.0.1 (20.08.2015)
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