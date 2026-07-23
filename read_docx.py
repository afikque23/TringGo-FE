import zipfile
import xml.etree.ElementTree as ET
import sys
import io

# Reconfigure stdout to use utf-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def read_docx(path):
    try:
        with zipfile.ZipFile(path) as docx:
            xml_content = docx.read('word/document.xml')
            tree = ET.fromstring(xml_content)
            
            text = []
            for elem in tree.iter():
                if elem.tag.endswith('}t') and elem.text:
                    text.append(elem.text)
            return '\n'.join(text)
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    with open("docx_output.txt", "w", encoding="utf-8") as f:
        f.write(read_docx(sys.argv[1]))
    print("Done")
