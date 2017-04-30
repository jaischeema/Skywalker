# Skywalker

Simple rock-paper-scissor-spock-lizard game to figure out various parts involved in making a good
turn based game using GameCenter

## Requirements

- [x] Create new matches
- [x] Join existing matches
- [x] Saving turn to GameCenter
- [x] Saving match result to GameCenter
- [x] Decoupling slow moving UI with animations vs fast moving game logic
- [x] Handling state advancement with multiple clients running their own state machines
- [x] Updating current running game with latest data
- [x] Handling auto match players properly
- [ ] Add ability to rematch after the match has ended
- [ ] Pausing game and resuming UI from that event
- [ ] Positioning local player at the primary position on screen (e.g. bottom)
- [ ] Local game against AI without changing any of the game logic
- [ ] Keeping match data local for a quick glance
- [ ] Notifications for turns on inactive matches
- [ ] Handling GameInvite/turn notifications properly
- [ ] Handle players quitting the game

## Game Center Quirks

- GameCenter auto match players have nil identifier
- The person initiating the game always get the first turn
- There has been a case where the match loaded and it had no participants
