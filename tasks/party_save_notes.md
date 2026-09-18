# Party location + save notes

This document tracks the Beta integration for save system and party state.

Current state:
- Party data model stub exists in scripts/party_data.gd
- Encounter builder exists in scripts/encounter_builder.gd
- Save handler exists in scripts/beta_save_handler.gd

Next implementation steps:
- Save current location after travel
- Save roster changes after recruit
- Append save/load hooks to OverworldManager and Town UI
- Integrate with BattleManager to load enemy composition and rewards
