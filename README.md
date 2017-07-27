# MarioLearn #

Algoritmo de aprendizado por reforço capaz de aprender a passar fases de jogos de plataforma, como Super Mario World.
Este algoritmo foi desenvolvido como TCC (Trabalho de Conclusão de Curso) do curso de Ciência da Computação da Universidade de Sorocaba, de titulo __"Aprendizado de Máquina Aplicado à Resolução de Problemas de Decisão"__ e sua documentação pode ser encontrada [aqui](https://github.com/daniloluca/tcc-doc/blob/master/release/TCC%20-%20Danilo%20de%20Lucas.pdf).

### Para que serve? ###

* O algoritmo tem a finalidade de aprender a jogar jogos de plataforma 2d, sem nenhum conhecimento prévio do ambiente ou das condições apresentadas ao personagem.

### O que é utilizado nele? ###

#### Conceitualmente ####
* Nele são utilizados conceitos de classificação, tais como entropia e ganho de informação para a geração de árvores de decisão.
* Ele utiliza uma biblioteca de machine learning chamada [ml-lua](https://github.com/daniloluca/ml-lua) para gerar as árvores de decisão. Trata-se de uma bibliote de autoria própria utilizada para o auxilio no desenvolvimento de algoritmos de classificação.
* São utilizadas heurísticas para a inferencia de dados de natureza não determinística e conceitos como backtracking para a iteração recursiva das soluções.
* Ao final, é meta programada uma rede neural capaz de aprender com soluções bem sucedidas e modificar ou generalizar seus resultados para solucionar situações nunca antes encontradas.

#### Tecnicamente ####
* Foi utilizada a linguagem de programação Lua para desenvolver o script.
* O script é rodado por meio do __TAS__ (plugin para emuladores de SNES que da suporte a scripting em lua).
* O emulador utilizado foi o __Snes9x__.
* A rom utilizada foi a __Super Mario World (USA)__.
* A biblioteca de Machine Learning utilizada foi a [ml-lua](https://github.com/daniloluca/ml-lua).
    
### Como configurar? ###

* Baixe o [zip]() do repositório e o [emulador]().
* Descompacte ambos e execute o arquivo __snes9x.exe__ presente no diretorio do emulador.
* Selecione a rom no emulador que está presente no diretório do mesmo. Você pode arrastar e soltar a rom na janela do emulador.
* Com o jogo rodando, adicione arquivo __smw.lua__ ao plugin, ele se encontra em __\your_path\mariolearn\src__. Também pode ser arrastado para dentro do emulador e uma janela referente ao __TAS__ irá surgir.
 
### Como utilizar? ###

* Existem __3__ states pré-configurados.
* Você pode utilizar as teclas __F1__, __F2__ e __F3__ para navegar entre as fases salvas.


### Links Uteis ###

#### Artigos e Referências ####
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

#### Ferramentas ####
##### Ram Map Super Mario World #####
* http://www.smwcentral.net/?p=map&type=ram
* http://www.smwcentral.net/?p=nmap&m=smwram

##### Lua TAS Scripting #####
* http://www.fceux.com/web/help/fceux.html?LuaFunctionsList.html

#### Imagens ####

