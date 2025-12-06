#!/usr/bin/env python3
import os
import sys
import json

import django

# Ensure project path (project root may be nested as `/app/sarasedu_backend`)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = os.path.join(BASE_DIR, 'sarasedu_backend')
if os.path.isdir(PROJECT_DIR):
    sys.path.insert(0, PROJECT_DIR)
else:
    sys.path.insert(0, BASE_DIR)

# The inner Django package is named `sarasedu_backend`, so use that module path
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sarasedu_backend.settings')
django.setup()

from django.apps import apps
from django.db import connection

out_lines = []
out_lines.append('# Schema Diff Report\n')

models = apps.get_models()
cursor = connection.cursor()

db_name = os.environ.get('DB_NAME') or os.environ.get('MYSQL_DATABASE') or 'sarasedu'

for model in models:
    meta = model._meta
    table = meta.db_table
    out_lines.append(f'## Model: {meta.app_label}.{meta.object_name} -> table `{table}`\n')
    # model fields
    model_fields = [f.name for f in meta.concrete_fields]
    out_lines.append(f'- model fields ({len(model_fields)}): {model_fields}\n')
    # get columns from information_schema
    cursor.execute("SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s ORDER BY ORDINAL_POSITION", (db_name, table))
    cols = cursor.fetchall()
    db_columns = [r[0] for r in cols]
    out_lines.append(f'- db columns ({len(db_columns)}): {db_columns}\n')

    # diffs
    missing = [f for f in model_fields if f not in db_columns]
    extra = [c for c in db_columns if c not in model_fields]
    out_lines.append(f'- missing in db (in model not in db): {missing}\n')
    out_lines.append(f'- extra in db (in db not in model): {extra}\n')

    # type mismatches (best-effort)
    type_mismatches = []
    for f in meta.concrete_fields:
        name = f.name
        if name in db_columns:
            # attempt to compare db_type
            try:
                dt = f.db_type(connection)
            except Exception:
                dt = None
            # find column type
            col_info = next((r for r in cols if r[0] == name), None)
            if col_info:
                col_type = col_info[1]
                if dt and dt.lower() not in col_type.lower():
                    type_mismatches.append((name, dt, col_type))
    out_lines.append(f'- type mismatches: {type_mismatches}\n')
    out_lines.append('\n---\n')

report_path = os.path.join(BASE_DIR, 'HANDOVER_SCHEMA_DIFF.md')
with open(report_path, 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(out_lines))

print('WROTE', report_path)
