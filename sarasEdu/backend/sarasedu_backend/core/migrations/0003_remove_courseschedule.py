# Generated migration to remove CourseSchedule model

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0002_alter_fields'),
    ]

    operations = [
        migrations.DeleteModel(
            name='CourseSchedule',
        ),
    ]
