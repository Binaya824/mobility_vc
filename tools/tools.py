import os
from langchain.tools import tool

@tool
def ensure_folder_and_file(folder_path: str, file_name: str) -> str:
    """
    Ensure a folder exists, and ensure a file exists inside it.
    
    - If the folder does not exist, it will be created.
    - If the file does not exist, it will be created as an empty file.
    - If both already exist, nothing is changed.
    
    Returns a status message describing what was done.
    """
    actions = []

    # Folder
    if not os.path.exists(folder_path):
        os.makedirs(folder_path, exist_ok=True)
        actions.append(f"Folder created: {folder_path}")
    else:
        actions.append(f"Folder already exists: {folder_path}")

    # File
    file_path = os.path.join(folder_path, file_name)
    if not os.path.exists(file_path):
        with open(file_path, "w", encoding="utf-8") as f:
            pass
        actions.append(f"File created: {file_path}")
    else:
        actions.append(f"File already exists: {file_path}")

    return " | ".join(actions)


@tool
def write_content_to_file(file_path: str, content: str, mode: str = "overwrite") -> str:
    """
    Write content into an existing file.
    
    Parameters:
    - file_path: Full path of the file.
    - content: Text content to write.
    - mode: 
        - 'overwrite' → replaces file content
        - 'append' → appends to file
    
    Edge cases:
    - If file does not exist → returns an error message.
    - If mode is invalid → returns an error message.
    """
    if not os.path.exists(file_path):
        return f"Error: File does not exist: {file_path}"

    if mode not in ["overwrite", "append"]:
        return "Error: mode must be 'overwrite' or 'append'"

    write_mode = "w" if mode == "overwrite" else "a"

    with open(file_path, write_mode, encoding="utf-8") as f:
        f.write(content)

    return f"Content written to {file_path} using mode={mode}"
