import os
import re

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Could not read {filepath}: {e}")
        return

    new_content = content.replace("MotoTracker", "TringGo")
    new_content = new_content.replace("mototracker", "tringgo")
    new_content = new_content.replace("Mototracker", "Tringgo")
    new_content = new_content.replace("MOTOTRACKER", "TRINGGO")

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.dart', '.arb', '.xml', '.json', '.md', '.php', '.blade.php')):
                replace_in_file(os.path.join(root, file))

if __name__ == '__main__':
    print("Processing mobile app lib folder...")
    process_directory(r"d:\TA\TA\motorcycle-management-mobile\lib")
    print("Processing mobile app android folder...")
    process_directory(r"d:\TA\TA\motorcycle-management-mobile\android\app\src\main")
    print("Processing laravel backend...")
    process_directory(r"c:\laragon\www\motorcycle_management\resources")
    process_directory(r"c:\laragon\www\motorcycle_management\app")
    process_directory(r"c:\laragon\www\motorcycle_management\docs")
    process_directory(r"c:\laragon\www\motorcycle_management\database")
    print("Done!")
