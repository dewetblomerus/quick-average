Application.ensure_all_started(:mimic)
Mimic.copy(QuickAverage.Presence)
ExUnit.start()
