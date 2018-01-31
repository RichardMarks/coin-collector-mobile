import strutils
import typetraits

proc commandPanel*(): tuple[y: int, x: int] =
  echo "Enter Coordinate To Check(Y,X): "
  while true:
    let yxInput = readLine(stdin)
    echo "you entered: ", yxInput

    if (find(yxInput , "(") != -1 or find(yxInput , ")") != -1):
      echo "please enter only comma separated numbers"
      continue

    # should only have two values, which are numbers
    let sepValues = rsplit(yxInput, ',')

    if len(sepValues) != 2:
      echo "please only enter two values, a letter and a number"
      continue

    let yVal = int(yxInput[0])
    let xVal = parseInt(strip(sepValues[1], true))

    if (yVal < 65 or yVal > 74):
      echo "Y must be between A and J"
      continue
    
    if (xVal < 0 or xVal > 9):
      echo "X must be between 0 and 9"
      continue


    return (yVal - 65, xVal)


let test = commandPanel()

echo "test:", test