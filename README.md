# Ruboty::Pdq

## Usage

```
#Gemfile
gem 'ruboty-pdq', :git => 'git://github.com/m-oomote/ruboty-pdq.git'
```

## ChatCommand

```
popy pdq count <ise|sdb>
popy pdq list [period]
popy pdq help
```

## ENV

```
RUBOTY_SDB_USER         - Sm@rtDB Account's username
RUBOTY_SDB_PASS         - Sm@rtDB Account's password
RUBOTY_SDB_URL          - Sm@rtDB URL
RUBOTY_SDB_LINK_URL     - Sm@rtDB Link URL
RUBOTY_ISE_AUTH_PATH    - Path to Get INSUITE session key (optional)
RUBOTY_SDB_AUTH_PATH    - Path to Get Sm@rtDB session key
RUBOTY_PDQ_LEADER_ISE   - Names of leaders of INSUITE team
RUBOTY_PDQ_LEADER_SDB   - Names of leaders of Sm@rtDB team
RUBOTY_PDQ_TARGET_ISE   - IDs of the target product handled by INSUITE team in the binder
RUBOTY_PDQ_TARGET_SDB   - IDs of the target product handled by Sm@rtDB team in the binder
```
