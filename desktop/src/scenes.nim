import scene_management

from title_scene_slc import titleSlc
from credits_scene_slc import creditsSlc
from gameover_scene_slc import gameoverSlc
from start_scene_slc import startSlc
from play_scene_slc import playSlc

let titleScene* = newScene("title", titleSlc)
let creditsScene* = newScene("credits", creditsSlc)
let gameoverScene* = newScene("gameover", gameoverSlc)
let startScene* = newScene("start", startSlc)
let playScene* = newScene("play", playSlc)
