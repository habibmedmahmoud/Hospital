# Generated by Django 3.1 on 2022-05-28 23:03

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('api', '0008_auto_20220527_0226'),
    ]

    operations = [
        migrations.AddField(
            model_name='analyse',
            name='analyste',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='analyste_anl', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='analyse',
            name='nomLaboratoire',
            field=models.TextField(null=True),
        ),
        migrations.AddField(
            model_name='analyse',
            name='type',
            field=models.PositiveSmallIntegerField(blank=True, choices=[(1, 'Hemato'), (2, 'Bioch'), (3, 'Microb'), (4, 'Anatomo')], null=True),
        ),
    ]
