import sys
import re
import os

files_to_clean = [
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\wishlist_screen.dart",
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\recent_recordings_screen.dart",
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\profile_screen.dart",
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\my_courses_screen.dart",
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\live_classes_screen.dart",
    r"d:\mbt-lms\mbt-app\mbt-app\lib\screens\global_search_screen.dart",
]

for file_path in files_to_clean:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The pattern matches "bottomNavigationBar: BottomNavigationBar(" 
    # and we need to balance the parentheses to remove the whole block.
    # Alternatively, we can use a simpler approach: 
    # find "bottomNavigationBar: BottomNavigationBar(", find the matching closing bracket for it, and remove the substring.
    start_idx = content.find("bottomNavigationBar: BottomNavigationBar(")
    if start_idx != -1:
        end_idx = start_idx + len("bottomNavigationBar: BottomNavigationBar(")
        paren_count = 1
        while paren_count > 0 and end_idx < len(content):
            if content[end_idx] == '(':
                paren_count += 1
            elif content[end_idx] == ')':
                paren_count -= 1
            end_idx += 1
        
        # also remove the trailing comma if it exists
        if end_idx < len(content) and content[end_idx] == ',':
            end_idx += 1
            
        new_content = content[:start_idx] + content[end_idx:]
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Cleaned {file_path}")
