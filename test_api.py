# -*- coding: utf-8 -*-
"""本地接口自测。

用法（先启动 app.py）：

    python test_api.py [数据目录]

数据目录默认为当前目录下的 `开发` 文件夹，可用环境变量 SAMPLE_ROOT 覆盖。
"""
import os
import sys
import tempfile

import requests

BASE_URL = os.environ.get('BASE_URL', 'http://127.0.0.1:5000').rstrip('/')
SAMPLE_ROOT = os.environ.get('SAMPLE_ROOT') or (sys.argv[1] if len(sys.argv) > 1 else '开发')

SECTIONS = {'谐波': 'harmonic', '间谐波': 'interharmonic', '电能质量': 'power_quality'}


def main():
    sess = requests.Session()

    for name, section in SECTIONS.items():
        path = os.path.join(SAMPLE_ROOT, name)
        if not os.path.isdir(path):
            print(f'[skip] {section}: 目录不存在 {path}')
            continue
        r = sess.post(f'{BASE_URL}/api/import-folder',
                      json={'section': section, 'path': path}, timeout=120)
        data = r.json()
        print(f'[upload] {section}: {len(data.get("matched", []))} files')

    r = sess.post(f'{BASE_URL}/api/generate',
                  json={'sections': list(SECTIONS.values())}, timeout=300)
    print(f'[generate] HTTP {r.status_code}, {len(r.content)} bytes')
    if r.status_code != 200:
        print(r.get_data(as_text=True)[:500] if hasattr(r, 'get_data') else r.text[:500])
        raise SystemExit(1)

    out = os.path.join(tempfile.gettempdir(), 'pq-web-test.docx')
    with open(out, 'wb') as f:
        f.write(r.content)

    from docx import Document
    doc = Document(out)
    print(f'[check] tables={len(doc.tables)}, paragraphs={len(doc.paragraphs)} -> {out}')


if __name__ == '__main__':
    main()
