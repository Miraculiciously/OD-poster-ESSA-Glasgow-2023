;; Axelrod's Model for Cultural Evolution is an agent-based model described by
;; Robert Axelrod in his paper:
;; Axelrod, R. 1997. “The dissemination of culture - A model with local convergence and global polarization.”
;;        Journal of Conflict Resolution 41:203-226.
;;
;; 'Axelrod_Cultural_Dissemination.nlogo' implements this model with one extension: agents can move.
;;
;; Copyright (C) 2013 Arezky H. Rodríguez (arezky@gmail.com)
;;

;; -------------------------------------------------- ;;
;;;;;;;;;;;;;;;;;
;;; VARIABLES ;;;
;;;;;;;;;;;;;;;;;

globals [
  number_of_agents                ;; number of all agents in the society
  Cult_max                        ;; number related with the maximun cultural value of an agent (q-1 q-1 q-1 ... q-1)
  number_of_cultures              ;; number of cultures in the society
  number_of_possible_interactions ;; number of possible interactions at each tick that could be according to cultural overlap between agents
  number_of_real_interactions     ;; number of real interactions at each tick that occurs according to cultural overlap between agents
  time                            ;; time
  component-size                  ;; number of turtles explored so far in the current component
  giant-component-size            ;; number of turtles in the giant component
  number_of_cultural_regions      ;; number of cultural regions simply connected
  seed                            ;; seed for reproduceability
]

turtles-own [
  culture                         ;; culture of an agent
  explored?                       ;; if the agent is already explored (or not) when determining number of cultural regions
]

patches-own [ ]

;; -------------------------------------------------- ;;
;;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; General setup settings
to setup
  clear-all
  clear-all-plots

  set seed random 100000 ; This sets a random seed between 0 and 99999
  random-seed seed       ; This line uses the seed for the model's random operations

  resize-world 0 (world-size-x - 1) 0 (world-size-y - 1) ;; defining the size of the society (number of patches
  set number_of_agents (world-size-x * world-size-y)     ;; one agent per patch
  set-patch-size 360 / world-size-y                      ;; setting patch size for good looking
  ask patches [set pcolor 34]                            ;; setting color of patches
  set giant-component-size 0                             ;; initializing the number of agent in the bigger cultural domain
  set number_of_cultural_regions 0                       ;; initializing the number of the cultural domains

  setup-turtles                                          ;; creating the agents, locating them and setting their cultural values randomly

  reset-ticks
  set time 0
end


;; Turtles settings
to setup-turtles
  set-default-shape turtles "default"
  create-turtles number_of_agents [
    set size 0.8
    set color white
    while [any? other turtles-here] [ move-to one-of patches ] ;; setting agent location. Only one agent at each patch
  ]

  setup-culture-max                                       ;; asigning a value to the culture with maximum traits value
  setup-agent-culture                                     ;; setting agents culture
  count-cultures                                          ;; counting the amount of different cultures at time = 0
  do-plots                                                ;; plotting for visualization
end


;; setting agents culture
;to setup-agent-culture
;  ask turtles [
;    set culture []
;    repeat f [
;      set culture lput random q culture                   ;; setting a random trait to each feature of the agent culture
;    ]
;    setup-agent-culture-color                             ;; setting a color for an agent according to its culture
;  ]
;end

;;;;;;;;;;;;;; Beginning of my additions

to setup-agent-culture
  ifelse q = 4 [ ;; only activate this block if q is 4
    let total-weight (amount-culture-0 + amount-culture-1 + amount-culture-2 + amount-culture-3 + amount-culture-4)

    ifelse total-weight = 0
    [ ;; if the sum of all culture amounts is 0
      ask turtles [
        set culture []
        repeat f [
          set culture lput random q culture
        ]
        setup-agent-culture-color
      ]
    ]
    [ ;; else: weighted culture setup
      let prob0 amount-culture-0 / total-weight
      let prob1 amount-culture-1 / total-weight
      let prob2 amount-culture-2 / total-weight
      let prob3 amount-culture-3 / total-weight
      let prob4 amount-culture-4 / total-weight

      let probabilities (list prob0 prob1 prob2 prob3 prob4)

      ask turtles [
        set culture []
        repeat f [
          set culture lput weighted-random probabilities culture
        ]
        setup-agent-culture-color
      ]
    ]
  ]
  [ ;; if q is not 4, use the original random culture setup
    ask turtles [
      set culture []
      repeat f [
        set culture lput random q culture
      ]
      setup-agent-culture-color
    ]
  ]
end


;; Helper function to get a weighted random culture
to-report weighted-random [prob-list]
  let random-val random-float 1.0
  let cumulative 0
  let index 0

  foreach prob-list [prob ->
    set cumulative cumulative + prob
    if random-val <= cumulative [
      report index
      stop
    ]
    set index index + 1
  ]
end



;;;;;;;;;;;;;; End of my additions


;; asigning a value to the culture with maximum traits values
;; it is done mapping the traits value to a number in base q
to setup-culture-max
  let i 1
  let suma 0
  repeat F [
    set suma suma + q ^ (F - i)
    set i i + 1
  ]
  set Cult_max ((q - 1) * suma)
end

;; -------------------------------------------------- ;;
;;;;;;;;;;;;;;;;;;;;;;
;;; MAIN PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;

;to go
;  clear-links
;  let repeating? true
;  while [repeating?] [
;    set number_of_possible_interactions 0                            ;; setting initial values
;    set number_of_real_interactions 0
;    ask turtles [                                                    ;; asking agents to move and interact localy
;      if random-float 1.0 < veloc [ random-move ]                    ;;   moving (in case veloc > 0)
;      cultural-interaction                                           ;; all agents interact in asyncronous-random updating
;    ]
;    if number_of_possible_interactions = 0 [set repeating? false]    ;; stopping when there are no possible interactions
;    set time time + 1                                                ;;   it happens when each agent has full or null overlap with
;                                                                     ;;   each of its neighbors.
;                                                                     ;;   neighbors are all agents in radius 'radius'
;    count-cultures                                                   ;; counting the amount of different cultures
;    do-plots                                                         ;;   and plotting for visualization
;    tick
;  ]
;
;  count-turtles-on-bigger-region                                     ;; when running stops, count number of agents in the bigger domain
;                                                                     ;;   and the amount of domains
;
;  if saving? [                                                         ;; to save if saving? true
;    let file_out_name  (word "F" F "L" world-size-x "r" radius ".dat") ;;   it is saved a file with values of
;    file-open file_out_name                                            ;;   q, number of agents in the bigger cultural domain (normalized), number of cultural domains (normalized)
;    file-print (word q " " (giant-component-size / number_of_agents) " " (number_of_cultural_regions / number_of_agents))
;    file-close
;  ]
;  stop
;end


;;;;;;;;;;;;;; Beginning of my additions

to go
  clear-links
  let repeating? true
  save-culture-to-file ; save initial state once
  while [repeating?] [
    set number_of_possible_interactions 0                            ;; setting initial values
    set number_of_real_interactions 0
    ask turtles [                                                    ;; asking agents to move and interact localy
      if random-float 1.0 < veloc [ random-move ]                    ;;   moving (in case veloc > 0)
      cultural-interaction                                           ;; all agents interact in asyncronous-random updating
    ]
    if number_of_possible_interactions = 0 [set repeating? false]    ;; stopping when there are no possible interactions
    set time time + 1                                                ;;   it happens when each agent has full or null overlap with
                                                                     ;;   each of its neighbors.
                                                                     ;;   neighbors are all agents in radius 'radius'
    count-cultures                                                   ;; counting the amount of different cultures
    do-plots                                                         ;;   and plotting for visualization
    tick
    if saving [ save-culture-to-file ]
  ]
  count-turtles-on-bigger-region
end

to save-culture-to-file
  let filename (word "culture_data_" seed "_" ticks ".txt")
  file-open filename
  ask turtles [
    file-print culture
  ]
  file-close
end





;;;;;;;;;;;;;; End of my additions

;; calculating number cultures on the whole society
to count-cultures
  let list_of_cultures []
  ask turtles [
    ; setting agent culture in base q
    let i 1
    let suma 0
    repeat F [
      set suma suma + item (i - 1) culture * q ^ (F - i) ;10 ^ (F - i)
      set i i + 1
    ]
    set list_of_cultures fput suma list_of_cultures                    ;; including each culture (its corresponding number) in a list
  ]
  set list_of_cultures remove-duplicates list_of_cultures              ;; removing repeted cultures
  set number_of_cultures length list_of_cultures                       ;; the amount of different cultures is the length of the list
end

;; counting the number of agent in the biggest culture
to count-turtles-on-bigger-region
  ; first it is linked all agents of the same culture (each agent looks for a neighbour which is in its neighborhood (agent inside in radius)
  ask turtles [
    creates-links-with-same-cultural-neighbours-in-neighborhood-of-radio-radius
  ]
  find-all-components                                                  ;; exploring each connected network finding and counting agents of the same culture
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Network Exploration ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; to find all the connected components in the network, their sizes and starting turtles
to find-all-components
  ask turtles [ set explored? false]
  ;; keep exploring till all turtles get explored
  loop
  [
    ;; pick a node taht has not yet been explored
    let starting_turtle one-of turtles with [ not explored? ]
    if starting_turtle = nobody [ stop ]
    ;; reset the number of turtles found to 0. This variable is updated each time we explore an unexplored node
    set component-size 0
    ;; find all turtles reachable from this node
    ask starting_turtle [
      explore
      ;; after each explore procedure finishes it is explored one cultural region, so increment the counter (  number_of_cultural_regions )
      set number_of_cultural_regions number_of_cultural_regions + 1
    ]
    ;; the explore procedure updates the component-size variable, so check, have we found a new giant component?
    if component-size > giant-component-size [
      set giant-component-size component-size
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TURTLES' PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Finds all turtle reachable from this node (it is a recursive procedure)
to explore ;; turtle procedure
  if explored? [ stop ]
  set explored? true
  set component-size component-size + 1
  ask link-neighbors [ explore ]
end

;; agents look for a neighbor to interact
to cultural-interaction
  ;counting any turtle for interacting at distance less than radius
  let number_of_possible_neighbors count other turtles in-radius radius
  ;if there are neighbors for interacting, setting agent neighbors
  if number_of_possible_neighbors > 0 [
    let neighbor_turtle one-of other turtles in-radius radius
    ;interacting the cultures
    let target_turtle self
    culturally_interacting target_turtle neighbor_turtle
  ]
end

;; an agent creates a link with all it neighbors with the same culture
to creates-links-with-same-cultural-neighbours-in-neighborhood-of-radio-radius
  let neighborhood other turtles in-radius radius
  ask neighborhood [
    if overlap_between self myself = F [ create-link-with myself ]                ;; overlap_between is a reporter
  ]
end

;; setting interaction between target agent and neighbor selected
to culturally_interacting [target_turtle neighbor_turtle]
  let overlap overlap_between target_turtle neighbor_turtle
  if (0 < overlap and overlap < F ) [
    set number_of_possible_interactions number_of_possible_interactions + 1       ;; if interaction is possible increment the counter
    let prob_interaction (overlap / F)                                            ;; setting the probability of interaction
    if random-float 1.0 < prob_interaction [
      set number_of_real_interactions number_of_real_interactions + 1
      ;choosing a feature position randomly where the two cultures are different
      let trait random F                                                          ;; generates a number between 0 and (F - 1)
      let trait_selected? false
      while [not trait_selected?] [
        ifelse (item trait [culture] of target_turtle = item trait [culture] of neighbor_turtle)
        [
          set trait ((trait + 1) mod F)                                           ;; looking for other feature
        ]
        [
          set trait_selected? true                                                ;; found a feature with different cultural traits
        ]
      ]
      let new_cultural_value (item trait [culture] of neighbor_turtle)
      set culture replace-item trait culture new_cultural_value                   ;; replacing/copying the neighbor trait
      setup-agent-culture-color                                                   ;; updating the agent color according to its new culture
    ]
  ]
end

;; random move according to 'steplength' and 'angle' for rotating
to random-move
  let var (random angle + 1)                                           ;; selecting and angle to rotate
  set heading (heading +  var - ((angle + 1) / 2))                     ;; mapping for left and right
  ifelse can-move? steplength                                          ;; in case of no periodic boundary conditions, if agent at the border
  [                                                                    ;;     rotate with any angle for new direction
    forward steplength
  ]
  [
    set heading random 360
    forward steplength
  ]
end

;; setting the color according to the culture
to setup-agent-culture-color
  ;setting agent culture in base q
  let i 1
  let suma 0
  repeat F [
    set suma suma + item (i - 1) culture * q ^ (F - i)  ;10 ^ (F - i)
    set i i + 1
  ]
  let Cult_base_q suma

  ;setting the corresponding color to the turtle according to the culture_base_q value. a range of blue is selected
  set color (9.9 * Cult_base_q / Cult_max) + 100
end

;;;;;;;;;;;;;;
;;; GRAPHS ;;;
;;;;;;;;;;;;;;

to do-plots
  ;setting the plot of Cultures
  set-current-plot "Cultures"
  set-current-plot-pen "Cultures"
  plotxy time (number_of_cultures / q ^ F)

  ;setting the plot of interactions
  set-current-plot "Interactions"
  set-current-plot-pen "Possible"
  plotxy time (number_of_possible_interactions / number_of_agents)
  set-current-plot-pen "Real"
  plotxy time (number_of_real_interactions / number_of_agents)
end


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; REPORT PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; reporting overlap between two agents
to-report overlap_between [target_turtle neighbor_turtle]
  let suma 0
  (foreach [culture] of target_turtle [culture] of neighbor_turtle
    [ [?1 ?2] -> if ?1 = ?2 [ set suma suma + 1]  ]
    )
  report suma
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PATCHES' PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; there are no patches procedures
@#$#@#$#@
GRAPHICS-WINDOW
162
10
590
379
-1
-1
12.0
1
15
1
1
1
0
1
1
1
0
34
0
29
1
1
1
ticks
30.0

BUTTON
4
10
59
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
4
46
77
106
world-size-x
35.0
1
0
Number

BUTTON
4
192
67
225
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
3
228
95
261
veloc
veloc
0
1
0.5
0.1
1
NIL
HORIZONTAL

INPUTBOX
4
110
54
170
F
10.0
1
0
Number

INPUTBOX
57
110
107
170
q
4.0
1
0
Number

INPUTBOX
108
110
158
170
radius
1.5
1
0
Number

SLIDER
20
262
140
295
steplength
steplength
0.1
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
19
297
111
330
angle
angle
0
359
61.0
1
1
NIL
HORIZONTAL

PLOT
536
10
788
208
Cultures
time
No. Cultures/q^F
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Cultures" 1.0 0 -16777216 true "" ""

PLOT
537
209
803
415
Interactions
time
No. of Interactions
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Possible" 1.0 0 -2674135 true "" ""
"Real" 1.0 0 -13791810 true "" ""

MONITOR
730
101
898
146
Normalized No. of Cultures
number_of_cultures / q ^ F
17
1
11

MONITOR
732
266
861
311
Possible Interactions
number_of_possible_interactions
17
1
11

INPUTBOX
79
46
156
106
world-size-y
30.0
1
0
Number

MONITOR
730
54
817
99
No. Cultures
number_of_cultures
17
1
11

MONITOR
164
418
305
463
Giant Component Size
giant-component-size
17
1
11

MONITOR
536
418
700
463
Number of cultural regions
number_of_cultural_regions
17
1
11

MONITOR
308
418
517
463
Normalized Giant Component Size
giant-component-size / number_of_agents
17
1
11

MONITOR
702
419
912
464
Normalized No. of Cultural Regions
number_of_cultural_regions / number_of_agents
17
1
11

TEXTBOX
52
420
174
450
reporting at the end ->
12
0.0
1

PLOT
392
530
724
680
culture development
ticks
mean culture
0.0
10.0
0.0
4.0
true
true
"" ""
PENS
"culture 0" 1.0 0 -16777216 true "" "plot mean [item 0 culture] of turtles"
"culture 1" 1.0 0 -2674135 true "" "plot mean [item 1 culture] of turtles"
"culture 2" 1.0 0 -13345367 true "" "plot mean [item 2 culture] of turtles"
"culture 3" 1.0 0 -1184463 true "" "plot mean [item 3 culture] of turtles"
"culture 4" 1.0 0 -13840069 true "" "plot mean [item 4 culture] of turtles"

INPUTBOX
23
547
178
607
amount-culture-1
100.0
1
0
Number

INPUTBOX
23
607
178
667
amount-culture-2
50.0
1
0
Number

INPUTBOX
23
488
178
548
amount-culture-0
100.0
1
0
Number

INPUTBOX
23
667
178
727
amount-culture-3
50.0
1
0
Number

INPUTBOX
23
727
178
787
amount-culture-4
10.0
1
0
Number

MONITOR
214
554
330
599
example agent
[culture] of turtle 0
17
1
11

SWITCH
70
193
160
226
saving
saving
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This is Axelrod’s model of cultural dissemination. See Reference at the end. It is an agent-model designed to investigate the dissemination of culture among interacting agents on a society.

Axelrod model consists in a population of agents, each one occupying a single node of a square network of size L. The culture of an agent is described by a vector of F integer variables called 'features'. Each feature can assume q different values between 0 and q-1. In the original Axelrod model the interaction topology is regular bounded (non-toroidal). Each agent can interact only with its four neighbors (von Neumann neighborhood).

Dynamics are based on two main mechanisms: (1) agents tend to chose culturally similar neighbors as interaction partners (homophily) and (2) during interaction agents influence each other in a way that they become more similar. 

The interplay of these mechanisms either leads to cultural homogeneity (all agents are perfectly similar) or the development of culturally distinct regions (multicultural society). The model allows studying to which degree the likelihood of these two outcomes depends on the size of the population, the number of features the agents hold, the number of traits (values) each feature can adopt and the neighborhood size (interaction range). 

## HOW IT WORKS

Each agent is located at each patch of the grid with the default shape. Agents hold a number of features F. Each feature is a nominal variable that can adopt a certain number of values (called traits) from 0 to q - 1. Initially, agents adopt randomly chosen traits. At each time step (tick) agents update its cultural value in an asyncronous-random updating. That is that the computer makes a list where all agents are included in a random order and the list is followed until all agents are choosen. Each agent them become a focal agent and then, one of the focal agent’s neighbors is selected at random. Neighbor agents are those who are in distance less than the value of the parameter 'radius'. If radius = 1, then it is von Neumann neighborhood. The cultural overlap between these two agents is computed. The cultural overlap is equal to the percentage of similar features. With probability similar to the overlap, the two agents interact. Otherwise, the program continues with the next agent until the list is exhausted and it follows the next time step (next tick). An interaction consists of selecting at random one of the features on which the two agents differ and changing the focal agent’s feature to the interaction partner’s trait. Note that if the overlap is zero, interaction is not possible and the respective agents refuse to influence each other.

## HOW TO USE IT

First, you should choose the population size selecting the size of the grid society on x and y directions and write these values on 'world-size-x' and 'world-size-y'. Also you should choose value for F (number of features), q (how many traitseach feature cand adopt) and radius (size of the neighborhood). Here, 1 means that each agent has 4 neighbors, 2 corresponds to 12 neighbors, and so on.

Each agent adopts a color which represents its culture. If two agents adopt the same color, they have the same culture.

Click on Go and the simulation starts. You can follow the changes of the agents culture according to his color. Furthermore, there is a graph reporting the number of different cultures on the society and the number of possible and real interactions. A possible interaction is that which agents share more than zero and left than all its features. A real interaction is when focal agent actualy change the value of one of its features.

Simulation stops when the number of possible interactions reaches zero. That means that each agent share all of none of its traits value with all its neighbors.

At the end it is calculated and reported the number of cultural regions in the population and the number of agents in the biggest one (also normalized). A region is a set of agents that are similar on all features. You can choose to save these values with 'saving? on'.

We included an extensions of Axelrod’s model: agents can move.
Then, you should also decide if the agents can move or not. In original Axelrod model the agents do not move. If moving, select the velocity of agent movement with 'veloc', select the length of the step with 'steplength' and the angle of rotating with 'angle'. If moving, at each tick agents decide to move taking 'veloc' as a probability. In case of actual movement, agents select at random an angle were the upper half values add this angle value to the current one the agent has and the lower half subtracts this angle to the current one. Then, ones direction is selected, agent moves a distance 'steplength'.

## THINGS TO NOTICE

Here we have setted toroidal boundaries, but the simulation can properly function as well in the original non-toroidal one. In our case, the four von Neumann neighbors are at distance 'radius' one. The model permits to change the value of 'radius' to explore the implications of other neighborhood sizes. It is also implemented the possiblity for agents to move. 

At the end, in the absorving final state, when calculating for the number of regions, the model makes different visible networks which include all neighbors agents with the same culture. Then, when counting the number of cultural domains it is considered that two domains are different if they are not connected, even if agents in both domains share same culture.

Note also that two agents could have similar (but with zero overlap) cultural values and then, its corresponding colors could be so similar that it could induce to think that the cultural values are the same. Just check to see that it is not.

## THINGS TO TRY

Vary the population size, the number of features, the number of traits, the range of interactions and also the movement of the agents. The program stops when the first absorving state is found (the number of possible interactions are zero on one time step), even if the agents are moving. Try toroidal and not toroidal borders activating ‘World wraps horizontally’ and ‘World wraps vertically’ in the Settings menu.

## EXTENDING THE MODEL

Many many extensions of this model have been proposed (see e.g. references below). One of the most interesting is certainly the inclusion of 'social influence' instead of dyadic interaction (see e.g. references below). It has been shown that this makes the persistence of different cultural region very strongh.

## RELATED MODELS

There are a lot of related models. You can follow the References here after or in the literature.

## CREDITS AND REFERENCES

This model has been developed by Robert Axelrod. 
It was implemented by Arezky H. Rodríguez (arezky@gmail.com).

This is the paper where Axelrod presented the model:

Axelrod, R. 1997. “The dissemination of culture - A model with local convergence and global polarization.” Journal of Conflict Resolution 41:203-226.

Extensions can be found at:

Flache, A., and M. Macy. 2008. “Local Convergence and Global Diversity: From Interpersonal to Social Influence.” arXiv:0808.2710 [physics.soc-ph].

Flache, A., and M. Macy. 2006. “What sustains cultural diversity and what undermines it? Axelrod and beyond.” arXiv:physics/0604201v1 [physics.soc-ph].

Flache, A., and M. Macy. 2007. “Local Convergence and Global Diversity: The Robustness of Cultural Homophily.” arXiv:physics/0701333v1 [physics.soc-ph].

Klemm, K., V. M. Eguiluz, R. Toral, and M. S. Miguel. 2003. “Global culture: A noise-induced transition in finite systems.” Phys. Rev. E 67, 045101.

Klemm, K., V. M. Eguiluz, R. Toral, and M. San Miguel. 2003. “Nonequilibrium transitions in complex networks: A model of social interaction.” Phys. Rev. E 67, 026120.

Copyright 2013 by Arezky H. Rodríguez (arezky@gmail.com). All rights reserved.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="1" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="veloc">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="angle">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="steplength">
      <value value="0.1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="q" first="5" step="1" last="15"/>
    <enumeratedValueSet variable="world-size-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size-y">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
