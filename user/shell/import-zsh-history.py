"""Import Zsh entries without evaluating them or touching the source file."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]).expanduser()
target = Path(sys.argv[2]).expanduser()
backup = target.with_name(target.name + ".before-zsh-import")
marker = target.with_name(target.name + ".zsh-imported")

if marker.exists():
    sys.exit("Zsh history has already been imported into this history file.")
if not source.is_file():
    sys.exit(f"Zsh history file not found: {source}")
if target.is_symlink():
    sys.exit("Refusing to replace a symlinked Bash history file.")
if backup.exists():
    sys.exit(f"Backup already exists; move it before retrying: {backup}")

# Let Zsh decode its own history format, including extended history, multiline
# commands and metafied Unicode. Export entries separated by NUL, never execute.
export = r'''
zmodload zsh/parameter
HISTSIZE=1000000
fc -p /dev/null 1000000 1000000
fc -R -- "$1" || exit
for event in ${(on)${(k)history}}; do
  print -rn -- "${history[$event]}"$'\0'
done
'''
result = subprocess.run(
    ["zsh", "-f", "-c", export, "import-zsh-history", str(source)],
    check=True, stdout=subprocess.PIPE,
)
entries = [entry for entry in result.stdout.split(b"\0") if entry]
if not entries:
    sys.exit("No Zsh history entries found; nothing changed.")

target.parent.mkdir(parents=True, exist_ok=True)
existing = target.read_bytes() if target.exists() else b""
if target.exists():
    shutil.copy2(target, backup)
    backup.chmod(0o600)

# Bash timestamp delimiters preserve multiline entry boundaries. Original Zsh
# timestamps are not exported: epoch 1 denotes an unknown original timestamp.
payload = b"".join(b"#1\n" + entry + b"\n" for entry in entries)
if existing:
    payload += b"#1\n" + existing
fd, temporary = tempfile.mkstemp(prefix=".bash-history-import-", dir=target.parent)
try:
    with os.fdopen(fd, "wb") as stream:
        stream.write(payload)
    os.replace(temporary, target)
finally:
    if os.path.exists(temporary):
        os.unlink(temporary)
marker.touch(mode=0o600)
print(f"Imported {len(entries)} Zsh entries. Original Zsh history is unchanged.")
if backup.exists():
    print(f"Previous Bash history backed up to {backup}")
