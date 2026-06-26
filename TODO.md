TODO:

 - Make sure json is sending book strings, not objects
 - Update data methods to as_json
 - Lots of code that maybe isn't needed anymore? In game etc
 - Update api spec /get Game describe block to use context blocks
 - Move Server into lib and manage routing changes
 - Change Server to Controller
 - Ordering to books and hands

DONE:



LOBBY ROADMAP:

  TODO:

  - add actual logic with tdd
    - each player that joins enters a lobby
    - each player can start a game
      - when starting, they can choose the size of the game
    - if a game already exists, and there aren't enough players,
    player can join a game
    - when game is over, players get redirected to lobby

  - build ui
  - build controller logic to connect the ui with the game logic

  DONE:

  - refactor server to controller and move it to lib
    - NOTE: controller must stay in root of the repo for sinatra/rack
