"""Tint Rose Pine's SVG cursors and build matching Hyprcursor/Xcursor themes."""

from pathlib import Path
import re
import shutil
import subprocess
import sys
from tempfile import TemporaryDirectory
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED


def build(source, target, foreground, outline):
    (target / "hyprcursors").mkdir(parents=True)
    (target / "cursors").mkdir()
    palette = {"#191724": foreground, "#e0def4": outline}
    aliases = {}
    archives = sorted((source / "hyprcursors").glob("*.hlc"))
    if not archives:
        raise ValueError("The source theme contains no cursor shapes")

    with TemporaryDirectory() as temporary:
        for archive in archives:
            files = {}
            with ZipFile(archive) as original:
                for name in original.namelist():
                    data = original.read(name)
                    if name.endswith(".svg"):
                        data = re.sub(
                            r"#[0-9a-fA-F]{6}",
                            lambda match: palette.get(match[0].lower(), match[0]),
                            data.decode(),
                        ).encode()
                    files[name] = data

            with ZipFile(target / "hyprcursors" / archive.name, "w") as packed:
                for name, data in sorted(files.items()):
                    # Fixed timestamps keep the generated archives reproducible.
                    info = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                    info.compress_type = ZIP_DEFLATED
                    packed.writestr(info, data)

            meta = files["meta.hl"].decode()
            x = float(re.search(r"^hotspot_x\s*=\s*(\S+)", meta, re.M)[1])
            y = float(re.search(r"^hotspot_y\s*=\s*(\S+)", meta, re.M)[1])
            frames = re.findall(r"^define_size\s*=\s*(.+)$", meta, re.M)
            entries = []
            # Render the same tinted vector artwork for applications using Xcursor.
            for size in (24, 32, 48, 64):
                for index, frame in enumerate(frames):
                    fields = [value.strip() for value in frame.split(",")]
                    svg = fields[1]
                    delay = fields[2] if len(fields) > 2 else "0"
                    image = Path(temporary) / f"{archive.stem}-{size}-{index}.png"
                    subprocess.run(
                        ["rsvg-convert", "-w", str(size), "-h", str(size), "-o", str(image)],
                        input=files[svg], check=True,
                    )
                    entries.append(f"{size} {round(x * size)} {round(y * size)} {image} {delay}")
            subprocess.run(
                ["xcursorgen", "-", str(target / "cursors" / archive.stem)],
                input=("\n".join(entries) + "\n").encode(), check=True,
            )
            for alias in re.findall(r"^define_override\s*=\s*(\S+)", meta, re.M):
                aliases[alias] = archive.stem

    for alias, name in aliases.items():
        path = target / "cursors" / alias
        if not path.exists():
            path.symlink_to(name)

    (target / "manifest.hl").write_text(
        "name = Softlight-Purple\n"
        "description = Rose Pine cursors with Softlight foreground and outline\n"
        "version = 1\ncursors_directory = hyprcursors\n"
    )
    (target / "index.theme").write_text(
        "[Icon Theme]\nName=Softlight Purple\n"
        "Comment=Dark purple cursor with cream outline\nInherits=Adwaita\n"
    )
    shutil.copyfile(source / "LICENSE", target / "LICENSE")
    print(f"Built {len(archives)} tinted cursor shapes in both formats")


if __name__ == "__main__":
    build(Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3], sys.argv[4])
