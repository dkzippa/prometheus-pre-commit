# Pre-commit hook that detects and prevents using hardcoded secrets like passwords, api keys, and tokens in git commit files

```
┌─○───┐
│ │╲  │
│ │ ○ │
│ ○ ░ │
└─░───┘
```

### Description:
- uses Gitleaks under the hood
- standart Gitleaks rules applied
- checks only the latest commit
- gets Gitleaks in 4 ways:
  - checks for already installed in system $PATH 
  - if not found, checks for gitleaks in repo/bin folder
  - if not found, uses binary release for current OS and ARCH. 
  - if not found, checks for go and compiles from the sources

### Install
  > \* Warning: it will overwrite `.git/hooks/pre-commit`
- use curl pipe method - go to repo folder and run 
  - `curl /precommit-hook.sh | sh -s -- install`

- or download to repo folder and run 
    - `sh ./precommit-hook.sh install`
    

### Usage:

- turn pre-commit off or on with: 
  - `git config user.gitleaks-enable 0`

  - check current value: 
    - `git config --get --default 1 --int user.gitleaks-enable`
  - delete value(user.gitleaks-enable=1 is used by default)
    - `git config --unset user.gitleaks-enable`

<br/>
<br/>
<br/>

_License
This module is licensed under the MIT License. See the LICENSE file for details._
