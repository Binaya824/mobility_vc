import os
from langchain.tools import tool

BASE_OUTPUT_DIR = "output"


def _safe_path(*paths):
    """
    Force all paths into BASE_OUTPUT_DIR.
    Prevents directory traversal or absolute path writes.
    """
    joined = os.path.join(*paths)
    joined = joined.lstrip("/\\")  # strip absolute attempts
    full_path = os.path.join(BASE_OUTPUT_DIR, joined)
    return os.path.normpath(full_path)


@tool
def ensure_folder_and_file(folder_path: str, file_name: str) -> str:
    """
    Always creates folder + file INSIDE output directory.
    """

    safe_folder = _safe_path(folder_path)
    safe_file = _safe_path(folder_path, file_name)

    actions = []

    # Folder
    if not os.path.exists(safe_folder):
        os.makedirs(safe_folder, exist_ok=True)
        actions.append(f"Folder created: {safe_folder}")
    else:
        actions.append(f"Folder exists: {safe_folder}")

    # File
    if not os.path.exists(safe_file):
        with open(safe_file, "w", encoding="utf-8"):
            pass
        actions.append(f"File created: {safe_file}")
    else:
        actions.append(f"File exists: {safe_file}")

    return " | ".join(actions)


@tool
def write_content_to_file(file_path: str, content: str, mode: str = "overwrite") -> str:
    """
    Writes ONLY inside output directory.
    """

    safe_file = _safe_path(file_path)

    if mode not in ["overwrite", "append"]:
        return "Error: mode must be 'overwrite' or 'append'"

    folder = os.path.dirname(safe_file)
    os.makedirs(folder, exist_ok=True)

    write_mode = "w" if mode == "overwrite" else "a"

    with open(safe_file, write_mode, encoding="utf-8") as f:
        f.write(content)

    return f"Content written to {safe_file} using mode={mode}"
