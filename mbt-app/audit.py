import os
import re

SCREEN_DIR = r"d:\mbt-lms\mbt-app\mbt-app\lib\screens"
ROUTER_FILE = r"d:\mbt-lms\mbt-app\mbt-app\lib\router\app_router.dart"

def parse_routes():
    with open(ROUTER_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    routes = set()
    matches = re.findall(r"GoRoute\(\s*path:\s*['\"](.*?)['\"]", content)
    for m in matches:
        routes.add(m)
        
    named_matches = re.findall(r"GoRoute\(\s*path:\s*RouteNames\.([a-zA-Z0-9_]+)", content)
    for m in named_matches:
        routes.add(f"RouteNames.{m}")
    return routes

def audit_screens():
    report_data = []
    total_interactive = 0
    working = 0
    broken = 0
    
    for root, _, files in os.walk(SCREEN_DIR):
        for file in files:
            if not file.endswith('.dart'): continue
            
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'onPressed:' in line or 'onTap:' in line:
                    total_interactive += 1
                    widget_type = "Unknown Widget"
                    for j in range(i, max(-1, i-5), -1):
                        if 'Button' in lines[j] or 'IconButton' in lines[j] or 'GestureDetector' in lines[j] or 'InkWell' in lines[j] or 'ListTile' in lines[j]:
                            m = re.search(r'([A-Za-z]+Button|IconButton|GestureDetector|InkWell|ListTile)', lines[j])
                            if m:
                                widget_type = m.group(1)
                                break
                    
                    status = "Working"
                    issue = "None"
                    fix = "No"
                    
                    clean_line = line.replace(' ', '')
                    if '(){}' in clean_line or '=>{}' in clean_line or 'TODO' in line or 'TODO' in "\n".join(lines[i:min(len(lines), i+3)]):
                        status = "Broken"
                        issue = "Empty callback or TODO"
                        fix = "Implement navigation"
                        broken += 1
                    elif 'context.push' not in line and 'context.go' not in line and 'context.pop' not in line and 'setState' not in line and 'show' not in line and 'Navigator' not in line and 'launch' not in line and 'ref.read' not in line and 'FilterBottomSheet' not in line and 'auth.signOut' not in line:
                        if '{' in line and '}' not in line:
                            block = "\n".join(lines[i:min(len(lines), i+10)])
                            if 'context.push' not in block and 'context.go' not in block and 'context.pop' not in block and 'setState' not in block and 'Navigator' not in block and 'show' not in block and 'ref.read' not in block and 'auth' not in block:
                                status = "Broken"
                                issue = "No navigation detected in block"
                                fix = "Verify intent / Add navigation"
                                broken += 1
                            else:
                                working += 1
                        else:
                            status = "Broken"
                            issue = "No navigation detected"
                            fix = "Verify intent"
                            broken += 1
                    else:
                        working += 1
                        
                    report_data.append({
                        'screen': file,
                        'widget': widget_type,
                        'line': i + 1,
                        'status': status,
                        'issue': issue,
                        'fix': fix
                    })
    
    return report_data, total_interactive, working, broken

routes = parse_routes()
report_data, total, working, broken = audit_screens()

with open("audit_report_raw.md", "w", encoding='utf-8') as f:
    f.write("# Navigation Audit Report\n\n")
    f.write(f"**Overall navigation completion percentage:** {int((working/total)*100) if total > 0 else 0}%\n\n")
    f.write("## Registered Routes\n")
    for r in routes:
        f.write(f"- `{r}`\n")
    f.write("\n## Interactive Elements Audit\n")
    f.write("| Screen Name | Widget | Expected Action | Current Status | Issue | Fix Required |\n")
    f.write("|-------------|--------|-----------------|----------------|-------|--------------|\n")
    for d in report_data:
        status_icon = "✅ Working" if d['status'] == "Working" else "❌ Broken"
        f.write(f"| {d['screen']} | {d['widget']} (Line {d['line']}) | Navigate/Action | {status_icon} | {d['issue']} | {d['fix']} |\n")
