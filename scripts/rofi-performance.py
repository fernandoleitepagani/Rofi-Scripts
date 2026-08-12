#!/usr/bin/env python3
import json
import os
import subprocess
import sys

BUS_NAME = "net.hadess.PowerProfiles"
OBJ_PATH = "/net/hadess/PowerProfiles"
IFACE = "net.hadess.PowerProfiles"

ACTIVE_COLOR = "#3daee9"
ACTIVE_MARK = "*"


def busctl_get(prop: str):
    """Fetch a property via busctl --json=short and return its decoded value."""
    result = subprocess.run(
        ["busctl", "--json=short", "get-property", BUS_NAME, OBJ_PATH, IFACE, prop],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)["data"]


def get_active_profile() -> str:
    return busctl_get("ActiveProfile")


def get_profiles() -> list[str]:
    # Profiles is aa{sv}: a list of dicts, each dict mapping property
    # names ("Profile", "Driver", "CpuDriver", "PlatformDriver", ...)
    # to {"type": ..., "data": ...} variants.
    raw = busctl_get("Profiles")
    names = []
    for entry in raw:
        variant = entry.get("Profile")
        if variant and variant.get("data"):
            names.append(variant["data"])
    return names


def set_active_profile(name: str) -> None:
    subprocess.run(
        ["busctl", "set-property", BUS_NAME, OBJ_PATH, IFACE, "ActiveProfile", "s", name],
        check=True,
    )


def handle_selection(selected_text: str) -> None:
    # Rofi puts the selected row's "info" field (the raw profile name we
    # attach below) into ROFI_INFO, so we don't need to strip markup
    # or the asterisk back out of the display text.
    target = os.environ.get("ROFI_INFO")
    if not target:
        target = selected_text.lstrip(ACTIVE_MARK).strip()
        # crude fallback: drop a leading pango span if ROFI_INFO is missing
        if target.startswith("<span"):
            target = target.split(">")[-1].strip()
    try:
        set_active_profile(target)
    except subprocess.CalledProcessError as e:
        # Surface the failure instead of failing silently.
        sys.stderr.write(f"Failed to set profile '{target}': {e}\n")


def print_row(name: str, active: bool) -> None:
    if active:
        print(
            f'<span foreground="{ACTIVE_COLOR}"><b>{ACTIVE_MARK}</b></span> {name}'
            f"\0info\x1f{name}"
        )
    else:
        print(f"  {name}\0info\x1f{name}")


def main() -> None:
    args = sys.argv[1:]

    if args:
        handle_selection(args[0])
        return

    # Header options (only need to be sent once, on the first call).
    print("\0markup-rows\x1ftrue")
    print("\0no-custom\x1ftrue")

    try:
        active = get_active_profile()
        profiles = get_profiles()
    except FileNotFoundError:
        print("busctl not found -- is systemd installed?\0nonselectable\x1ftrue")
        return
    except subprocess.CalledProcessError as e:
        stderr = (e.stderr or "").strip().splitlines()
        detail = stderr[-1] if stderr else str(e)
        print(f"DBus error: {detail}\0nonselectable\x1ftrue")
        print(
            "Is power-profiles-daemon or tuned-ppd running? "
            "Try: systemctl status power-profiles-daemon tuned-ppd"
            "\0nonselectable\x1ftrue"
        )
        return

    if not profiles:
        print("No power profiles reported\0nonselectable\x1ftrue")
        return

    for name in profiles:
        print_row(name, name == active)


if __name__ == "__main__":
    main()
