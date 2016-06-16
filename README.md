# Mario IA #

Algoritmo de Inteligência Artificial para "resolver / passar" fases de jogos de plataforma, como Super Mario World.

### Para que serve? ###

* O algoritmo tem a finalidade de "aprender a jogar" jogos de plataforma 2d, sem nenhum conhecimento prévio do mesmo.

### O que é utilizado nele? ###

#### Conceitualmente ####
* Nele são utilizadas tecnicas de programação genética e redes neurais (programação neuro-evolutiva).
* Também é utilizado um algoritmo de Machine Learning para armazenar o conhecimento e melhorar a performace.
* Conceitos de BackTracking também são utilizados.

#### Tecnicamente ####
* Foi utilizada a linguagem de programação Lua para desenvolver o script.
* O script é rodado por meio do TAS (plugin para emuladores de SNES que da suporte a scripting em lua).
* O emulador utilizado foi o __Snes9x__.
* A rom utilizada foi a __Super Mario World (USA)__.
    
### Como configurar? ###

* Baixe o repositorio.
* Abra o diretorio __\your_path\mario-ia\emulator\snes9x-1.51-rerecording-v7-win32__.
* Execute o arquivo __snes9x.exe__
* Selecione a rom no emulador, a rom se contra em __\your_path\mario-ia\emulator__.
* Com o jogo rodando, adicione arquivo __script.lua__ ao plugin, ele se encontra em __\your_path\mario-ia\algorithm__.
 
### Como utilizar? ###

* Existem __3__ states pré-configurados.
* Você pode utilizar as teclas __F1__, __F2__ e __F3__ para navegar entre as fases salvas.


### Links Uteis ###

#### Artigos ####
* http://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf

#### Ferramentas ####
##### Ram Map Super Mario World #####
* http://www.smwcentral.net/?p=map&type=ram
* http://www.smwcentral.net/?p=nmap&m=smwram

##### Lua TAS Scripting #####
* http://www.fceux.com/web/help/fceux.html?LuaFunctionsList.html

#### Imagens ####
![alt tag](http://www.webquest.hawaii.edu/kahihi/mathdictionary/images/quadrant.png)
