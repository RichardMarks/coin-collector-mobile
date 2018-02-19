import scene_management

from title_scene_slc import titleSlc
from credits_scene_slc import creditsSlc
from gameover_scene_slc import gameoverSlc
from play_scene_slc import playSlc
from debugroom_scene_slc import debugroomSlc

let titleScene* = newScene("title", titleSlc)
let creditsScene* = newScene("credits", creditsSlc)
let gameoverScene* = newScene("gameover", gameoverSlc)
let playScene* = newScene("play", playSlc)
let debugroomScene* = newScene("debugroom", debugroomSlc)
