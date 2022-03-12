GAME_DIR="/tmp/actungdebash"
PLAYERS_DIR="$GAME_DIR/players"

colors=("🟩" "🟥" "🟦" "⬛" "🟪" "🟧")
used_colors=0

input() {
  # INPUT LOOP
  while true 
  do
    input=`nc -l 1337`
    IFS=' '
    read -a input_parts <<< "$input"
    direction=${input_parts[1]}
    name=${input_parts[0]}
    if [ "$direction" = "w"  ] || [ "$direction" == "a"  ] || [ "$direction" == "s"  ] || [ "$direction" == "d"  ] || [ "$direction" == "r" ]
    then
      color=`cat $PLAYERS_DIR/$name/color 2> /dev/null`
      if [ "$color" = "" ]
      then
        lobby=`cat $GAME_DIR/lobby 2> /dev/null`
        if [ "$lobby" = "0" ]
        then
          # don't process if user doesnt exist and not in lobby
          continue
        fi
        mkdir -p "$PLAYERS_DIR/$name"
        echo -n ${colors[$used_colors]} > $PLAYERS_DIR/$name/color
        used_colors=`expr $used_colors + 1`
      fi
      echo -n "$direction" > "$PLAYERS_DIR/$name/input"
    fi
  done
}

game() {
  echo "0" > $GAME_DIR/lobby
  # GAME LOOP
  while true 
  do
    # MOVE PLAYERS
    i=0
    string=`printf "\033c"`
    playerstring=""
    for player in `ls $PLAYERS_DIR`;
      do
        input=`cat $PLAYERS_DIR/$player/input 2> /dev/null`
        color=`cat $PLAYERS_DIR/$player/color 2> /dev/null`
        x=`cat $PLAYERS_DIR/$player/x 2> /dev/null || echo -n "5"`
        y=`cat $PLAYERS_DIR/$player/y 2> /dev/null || echo -n "5"`
        if [ "$input" = "w" ]
        then
          y=`expr $y - 1`
        fi
        if [ "$input" = "a" ]
        then
          x=`expr $x - 1`
        fi
        if [ "$input" = "s" ] || [ "$input" = "r" ]
        then
          y=`expr $y + 1`
        fi
        if [ "$input" = "d" ]
        then
          x=`expr $x + 1`
        fi
        # check if square is already colored
        field=`cat $GAME_DIR/$x/$y`
        if [ "$field" !=  "⬜" ]
        then
          # kill thme player!
          rm -r $PLAYERS_DIR/$player
          continue
        else
          # paint squares where snake is now
          echo -n $color > $GAME_DIR/$x/$y
          # save new state
          echo -n $x > $PLAYERS_DIR/$player/x
          echo -n $y > $PLAYERS_DIR/$player/y
        fi
        playerstring="$playerstring$color $player\n"
        i=`expr $i + 1`
      done

    # PRINT MAP
    for y in {0..20}; 
    do
      for x in {0..20}; 
      do
        string="$string`cat $GAME_DIR/$x/$y`"
      done
        string="$string\n$"
    done
    printf "$string\n$playerstring\n"

    if [ "$i" = "1" ]
    then
      break
    fi
  done
}

create_field() {
  echo "Setting up!"
  for x in {0..20};
  do 
    mkdir -p "$GAME_DIR/$x"
    for y in {0..20}
      do 
       echo -n "⬜" > $GAME_DIR/$x/$y
      done
  done
  i=1
  for player in `ls $PLAYERS_DIR`;
  do
    result=`expr $i \* 2 + 5`
    echo -n $result > "$PLAYERS_DIR/$player/x"
    echo -n $result > "$PLAYERS_DIR/$player/y"
    i=`expr $i + 1`
  done
}

lobby() {
  all_ready=0
  echo "1" > $GAME_DIR/lobby
  while [ !all_ready ]
  do
    clear
    echo -e "Waiting for players to ready up.\n\nRun Carl's bash script and press 'r' to ready up. \n\n"
    i=0
    ready=0
    for player in `ls $PLAYERS_DIR`;
    do
      input=`cat $PLAYERS_DIR/$player/input 2> /dev/null`
      color=`cat $PLAYERS_DIR/$player/color 2> /dev/null`
      if [ "$input" == "r" ]
      then
        echo -e "  ✅ READY                 $color $player"
        ready=`expr $ready + 1`
      else
        echo -e "  ⌛ not ready yet         $color $player"
      fi
      i=`expr $i + 1`
    done
    sleep 1
    if [ $i -gt 1 ] && [ "$i" == "$ready" ]
    then 
      break
    fi
  done
}

win() {
  for player in `ls $PLAYERS_DIR`;
  do
    echo "Congratulations $player!. You have won the game!"
    echo "🏁🏁🏁🏁🏁  $player  🏁🏁🏁🏁🏁"
    sleep 5
  done
}


while true
do
  rm -r $PLAYERS_DIR
  mkdir -p $PLAYERS_DIR
  used_colors=0
  input &
  lobby
  create_field
  game
  win
  kill $!
done
