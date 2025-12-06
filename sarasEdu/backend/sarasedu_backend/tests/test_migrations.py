from django.test import TestCase
from django.core.management import call_command
from django.db import connection


class MigrationsTest(TestCase):
    def test_migrations_apply_and_core_tables_exist(self):
        # Ensure migrations can be applied in a fresh test DB
        call_command('migrate', verbosity=0)
        tables = connection.introspection.table_names()
        # core_user should exist after migrations for the custom user model
        self.assertIn('core_user', tables)
        # spot-check a couple of other important tables
        self.assertIn('core_course', tables)
        self.assertIn('core_assignment', tables)
