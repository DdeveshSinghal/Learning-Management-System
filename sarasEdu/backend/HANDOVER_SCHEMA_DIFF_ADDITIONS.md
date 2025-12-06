Findings & Suggested Migration Actions

- Most of the "missing in db" items reported are false-positives caused by how Django represents foreign keys: a model field named `user = models.ForeignKey(...)` corresponds to a database column named `user_id`. The diff script reports `user` (model) vs `user_id` (db) as a mismatch. Those do not require changes if the column with `_id` exists (which it does in this DB).

- Many of the "type mismatches" are semantic differences between MySQL column types and Django's `db_type()` return value (for example `decimal(10,2)` vs `numeric(10, 2)`, or `tinyint(1)` vs `bool`). These are generally safe and can be left as-is unless you require strict type normalization.

Recommended conservative actions:
- No immediate schema changes are required for the majority of tables — foreign keys are present as `<field>_id` columns and will work with Django's ORM. Proceed with normal development and create migrations only when you intentionally change a model.
- If you want the DB types to exactly match Django's generated types (for example for portability or strict DDL auditing), generate explicit `AlterField` migrations after running `makemigrations` locally in a dev environment and verify on a non-production copy of the database.

Example migration snippets

1) Add a missing simple field (example):

```python
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='course',
            name='new_field',
            field=models.CharField(max_length=100, null=True, blank=True),
        ),
    ]
```

2) Alter a field type (example):

```python
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='course',
            name='price',
            field=models.DecimalField(max_digits=10, decimal_places=2),
        ),
    ]
```

3) If you must rename a column (rare):

```python
from django.db import migrations

class Migration(migrations.Migration):
    dependencies = [('core', '0001_initial')]

    operations = [
        migrations.RenameField(
            model_name='mymodel',
            old_name='old_field',
            new_name='new_field',
        ),
    ]
```

If you'd like, I can automatically generate a set of `AddField`/`AlterField` migrations for the true differences (non-FK missing columns or type mismatches you want fixed). Say "generate migrations for diffs" and I'll create them in `core/migrations/` as drafts for your review.
