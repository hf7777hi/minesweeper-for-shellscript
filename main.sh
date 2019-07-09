#!/bin/bash -eu
trap "echo error." ERR
trap "echo game over." EXIT

LINE=9
COLUMN=$LINE
RATE=20
BOMNUM=$(($LINE * $COLUMN / $RATE))
PANEL_NUM=$(($LINE * $COLUMN - $BOMNUM))

init(){
  bom_list=()
  for i in $(seq 1 $BOMNUM ); do
    bom_list+=($(($RANDOM % $(($LINE * $COLUMN)) + 1)))
  done
  field=(\*)
  for i in $(seq 1 $(($LINE * $COLUMN)) ); do
    field+=(\*)
  done
}
view(){
  echo -ne c\\l\\t
  for j in $(seq 1 $COLUMN); do echo -en $j\\t; done; echo -en \\n\\n
  for i in $(seq 1 $LINE); do
    echo -ne $i\\t
    for j in $(seq 1 $COLUMN); do
      echo -en ${field[ $(( $(( $i - 1 )) * $LINE + $j )) ]}\\t
    done
    echo -en \\n\\n
  done
}
open(){
  while read -p "c\\l:" column line; do
    if [ ${column:-999} -le $COLUMN ] && [ ${line:-999} -le $LINE ]; then
      break
    fi
    echo "1～${LINE} で行列を入力してください. ex) 1 2"
  done
}
judge(){
  open_panel=$(( $(( $column - 1 )) * $LINE + $line ))
  if [ "${field[$open_panel]}" = "*" ]; then
    open_count=$(($open_count + 1))
  fi
  for i in $(seq 1 $BOMNUM); do
    if [ $open_panel -eq ${bom_list[ $((i-1)) ]} ]; then
      isGame=false
      field[ $open_panel ]="@"
      return
    fi
  done
  local count=0
  for i in $(seq $(( $column - 1 )) $(( $column + 1 )) ); do
    for j in $(seq $(( $line - 1 )) $(( $line + 1 )) ); do
      for k in $(seq 1 $BOMNUM); do
        if [ $(( $(( $i - 1 )) * $LINE + j )) -eq ${bom_list[ $(( k - 1 )) ]} ]; then
          count=$(($count + 1))
          echo $(( $(( $i - 1 )) * $LINE + j ))
          echo ${bom_list[ $((k-1)) ]}
          break
        fi
      done
    done
  done
  field[ $open_panel ]="${count}"
}
gameover(){
  for i in $(seq 1 $BOMNUM); do
    field[ ${bom_list[ $((i-1)) ]} ]="@"
  done
  view
}
win(){
  echo win!!!!!!
}

isGame=true
open_count=0
init
if ${1:-false}; then gameover; fi;
while $isGame; do
  view
  open
  /usr/bin/clear
  judge
  [[ $open_count -eq $PANEL_NUM ]] && { isGame=false; win; }
  echo -e c\\l:$column $line
done
gameover