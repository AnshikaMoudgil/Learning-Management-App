import os
import re

SCREEN_DIR = r"d:\mbt-lms\mbt-app\mbt-app\lib\screens"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    modified = False

    # 1. Shopping cart
    pattern_cart = r"IconButton\(\s*icon:\s*(const\s+)?Icon\(Icons\.shopping_cart[a-zA-Z_]*\s*(,\s*color:\s*[^)]+)?\)\s*,\s*onPressed:\s*\(\)\s*\{\}\s*\)"
    def repl_cart(m):
        color_part = m.group(2) or ", color: AppColors.textDark"
        return f"IconButton(icon: {m.group(1) or ''}Icon(Icons.shopping_cart_outlined{color_part}), onPressed: () => context.push('/cart'))"
    
    if re.search(pattern_cart, content):
        content = re.sub(pattern_cart, repl_cart, content)
        modified = True

    # 2. Notifications
    pattern_notify = r"IconButton\(\s*icon:\s*(const\s+)?Icon\(Icons\.notifications[a-zA-Z_]*\s*(,\s*color:\s*[^)]+)?\)\s*,\s*onPressed:\s*\(\)\s*\{\}\s*\)"
    def repl_notify(m):
        color_part = m.group(2) or ", color: AppColors.textDark"
        return f"IconButton(icon: {m.group(1) or ''}Icon(Icons.notifications_outlined{color_part}), onPressed: () => context.push('/notifications'))"
    
    if re.search(pattern_notify, content):
        content = re.sub(pattern_notify, repl_notify, content)
        modified = True

    # 3. Search
    pattern_search = r"IconButton\(\s*icon:\s*(const\s+)?Icon\(Icons\.search[a-zA-Z_]*\s*(,\s*color:\s*[^)]+)?\)\s*,\s*onPressed:\s*\(\)\s*\{\}\s*\)"
    def repl_search(m):
        color_part = m.group(2) or ", color: AppColors.textDark"
        return f"IconButton(icon: {m.group(1) or ''}Icon(Icons.search{color_part}), onPressed: () => context.push('/search'))"
    
    if re.search(pattern_search, content):
        content = re.sub(pattern_search, repl_search, content)
        modified = True

    # 4. Filter
    pattern_filter = r"IconButton\(\s*icon:\s*(const\s+)?Icon\(Icons\.filter[a-zA-Z_]*\s*(,\s*color:\s*[^)]+)?\)\s*,\s*onPressed:\s*\(\)\s*\{\}\s*\)"
    def repl_filter(m):
        color_part = m.group(2) or ", color: AppColors.textDark"
        return f"IconButton(icon: {m.group(1) or ''}Icon(Icons.filter_alt_outlined{color_part}), onPressed: () => FilterBottomSheet.show(context))"
    
    if re.search(pattern_filter, content):
        content = re.sub(pattern_filter, repl_filter, content)
        modified = True

    # 5. Buy Now buttons
    # Elevated / Outlined button with 'Buy Now' text
    # Finding onPressed: () {}, and then replacing it if it has 'Buy Now' or 'Enroll' nearby.
    # Let's just do a naive replace: `onPressed: () {}` inside an ElevatedButton that has `Text('Buy Now')`
    # We can regex the entire block if we are careful.
    pattern_buy = r"(ElevatedButton|OutlinedButton|TextButton)\(\s*onPressed:\s*\(\)\s*\{\}\s*,\s*.*?child:\s*(const\s+)?Text\('Buy Now'"
    # The dotall flag is needed
    if re.search(r"onPressed:\s*\(\)\s*\{\}", content):
        # We can just manually find and replace in string because regex with dotall might be too greedy.
        pass

    # A safer way to replace Buy Now is string replace.
    # For now, let's also look for `Icons.more_vert`
    pattern_more = r"IconButton\(\s*icon:\s*(const\s+)?Icon\(Icons\.more_vert\s*(,\s*color:\s*[^)]+)?\)\s*,\s*onPressed:\s*\(\)\s*\{\}\s*\)"
    def repl_more(m):
        color_part = m.group(2) or ", color: AppColors.textDark"
        return f"IconButton(icon: {m.group(1) or ''}Icon(Icons.more_vert{color_part}), onPressed: () => context.push('/more'))"
    
    if re.search(pattern_more, content):
        content = re.sub(pattern_more, repl_more, content)
        modified = True

    if modified:
        if "context.push" in content and "import 'package:go_router/go_router.dart';" not in content:
            # find last import
            imports = re.findall(r"^import\s+.*?;", content, re.MULTILINE)
            if imports:
                content = content.replace(imports[-1], imports[-1] + "\nimport 'package:go_router/go_router.dart';")
            else:
                content = "import 'package:go_router/go_router.dart';\n" + content
        if "FilterBottomSheet.show" in content and "filter_bottom_sheet.dart" not in content:
            imports = re.findall(r"^import\s+.*?;", content, re.MULTILINE)
            if imports:
                content = content.replace(imports[-1], imports[-1] + "\nimport '../widgets/filter_bottom_sheet.dart';")
            else:
                content = "import '../widgets/filter_bottom_sheet.dart';\n" + content

    if modified and content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Modified {filepath}")

for root, _, files in os.walk(SCREEN_DIR):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
