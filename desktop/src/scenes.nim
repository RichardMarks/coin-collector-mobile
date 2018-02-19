import scene_management

from title_scene_slc import titleSlc
from credits_scene_slc import creditsSlc
from gameover_scene_slc import gameoverSlc
from play_scene_slc import playSlc
from highscore_scene_slc import highscoreSlc
from view_highscores_scene_slc import viewhighscoresSlc

let titleScene* = newScene("title", titleSlc)
let creditsScene* = newScene("credits", creditsSlc)
let gameoverScene* = newScene("gameover", gameoverSlc)
let playScene* = newScene("play", playSlc)
let highscoreScene* = newScene("highscore", highscoreSlc)
let viewhighscoresScene* = newScene("viewhighscores", viewhighscoresSlc)
