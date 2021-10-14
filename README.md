# MarioLearn #

Reinforcement learning algorithm capable of learning to pass levels in platform games like Super Mario World.
This algorithm was developed as a TCC (Course Completion Work) of the Computer Science course at the University of Sorocaba, entitled __"Machine Learning Applied to Decision Problem Solving"__ and its documentation can be found [here]( https://github.com/daniloluca/tcc-doc/blob/master/release/TCC%20-%20Danilo%20de%20Lucas.pdf).

### What is it for? ###

* The algorithm is intended to learn how to play 2d platform games, without any prior knowledge of the environment or the conditions presented to the character.

### What is used in it? ###

#### Conceptually ####
* It uses classification concepts such as entropy and information gain to generate decision trees.
* It uses a machine learning library called [ml-lua](https://github.com/daniloluca/ml-lua) to generate the decision trees. It is a self-authored library used to aid in the development of classification algorithms.
* Heuristics are used for the inference of non-deterministic data and concepts such as backtracking for the recursive iteration of solutions.
* In the end, a neural network capable of learning from successful solutions and modifying or generalizing their results to solve situations never encountered before is programmed as a goal.

#### Technically ####
* Lua programming language was used to develop the script.
* The script is run through __TAS__ (plugin for SNES emulators that support scripting in lua).
* The emulator used was __Snes9x__.
* The rom used was __Super Mario World (USA)__.
* The Machine Learning library used was [ml-lua](https://github.com/daniloluca/ml-lua).
    
### How to configure? ###

* Download the [zip](https://github.com/daniloluca/mariolearn/master.zip) from the repository. The zip containing the emulator is inside the repository zip.
* Unzip both and run the file __snes9x.exe__ present in the emulator directory.
* Select the rom in the emulator that is present in the emulator directory. You can drag and drop the rom into the emulator window.
* With the game running, add the __smw.lua__ file to the plugin, it is located in __\your_path\mariolearn\src__. It can also be dragged into the emulator and a window referring to __TAS__ will appear.
 
### How to use? ###

* If the game is running on the splash screen and some blue, green or red rectangles are appearing on the emulator screen, just press the __F1__ key and the algorithm will be started in the first phase of the game.
* If you prefer, the + key can be pressed several times to speed up the emulation and consequently the training of the algorithm. It can be accelerated up to 400%.

### Useful links ###

#### Articles and References ####
* https://goo.gl/4EGygO
* http://goo.gl/Cj8khW
* https://goo.gl/MLC3DW
* https://goo.gl/wc2ltw
* https://goo.gl/NR07UU
* http://goo.gl/jyp8yK
* http://goo.gl/8UhmeO
* https://goo.gl/3EYa99
* https://goo.gl/MkFu8m
* https://goo.gl/6DS6tV
* https://goo.gl/LcBgHI
* http://goo.gl/CS45lZ
* https://goo.gl/868FiM
* https://goo.gl/Wk8gsD
* https://goo.gl/jNKkCH
* http://goo.gl/TccvC
* http://goo.gl/O9n6f6
* https://goo.gl/Pt188G

#### Tools ####
##### Ram Map Super Mario World #####
* http://www.smwcentral.net/?p=map&type=ram
* http://www.smwcentral.net/?p=nmap&m=smwram

##### Lua TAS Scripting #####
* http://www.fceux.com/web/help/fceux.html?LuaFunctionsList.html

#### Images ####

