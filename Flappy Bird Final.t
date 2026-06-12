% Flappy Bird
% 2023 01 05
% Tei & Nihaal

%INPUT
var chars : array char of boolean   % holds state of all keys (for held-key detection)
var ch : string (1)                 % holds a single keypress (for event-style input)

%UI
var flappybird, gameover, instruction, getready, bg, bg2 : int
% n1f = "1" digit sized for the tens column; n1s = "1" digit sized for the units column
% (the digit 1 is narrower than other digits and requires two separate assets)
var n1f, n1s, n2, n3, n4, n5, n6, n7, n8, n9, n0, sx : int

%GROUND
var ground, gx : int := 0
var grx : int := 0    % reserved for a second ground tile; not currently used

%PIPE  (pipe1 is active; pipe2 variables are reserved for a second pipe, not yet implemented)
var pipet, pipeb, px, pty, pby : int
var pipe2t, pipe2b, p2x, p2ty, p2by : int
var xdiff, ydifft, ydiffb : int   % collision delta values reused each frame

%STAT
var start : boolean := false
var background : int := 1   % 1 = day, 2 = night

%BIRD
var bird1, bird2, bird3, flystatus : int := 0
var birdx : int := 190
var birdy : real := 360

%SCORE
var passstatus2 : boolean := false   % reserved for second-pipe scoring; not yet used
var scoreboard : int
var score, recordscore, imagescore : int := 0
var medal1, medal2 : int

%FONT
var font : int

%GRAPHICS  — load all assets into picture handles
font := Font.New ("Arial:20")
flappybird := Pic.FileNew ("assets/flappybird.bmp")
gameover := Pic.FileNew ("assets/game over.bmp")
instruction := Pic.FileNew ("assets/instruction.bmp")
bg := Pic.FileNew ("assets/background.bmp")
bg2 := Pic.FileNew ("assets/backgroundnight.bmp")
ground := Pic.FileNew ("assets/ground.bmp")
pipet := Pic.FileNew ("assets/pipet.bmp")
pipeb := Pic.FileNew ("assets/pipeb.bmp")
bird1 := Pic.FileNew ("assets/bird down.bmp")
bird2 := Pic.FileNew ("assets/bird middle.bmp")
bird3 := Pic.FileNew ("assets/bird up.bmp")
scoreboard := Pic.FileNew ("assets/Scoreboard.bmp")
getready := Pic.FileNew ("assets/get ready.bmp")
n0 := Pic.FileNew ("assets/n0.bmp")
n1f := Pic.FileNew ("assets/n1f.bmp")   % wide "1" for tens column
n1s := Pic.FileNew ("assets/n1s.bmp")   % narrow "1" for units column
n2 := Pic.FileNew ("assets/n2.bmp")
n3 := Pic.FileNew ("assets/n3.bmp")
n4 := Pic.FileNew ("assets/n4.bmp")
n5 := Pic.FileNew ("assets/n5.bmp")
n6 := Pic.FileNew ("assets/n6.bmp")
n7 := Pic.FileNew ("assets/n7.bmp")
n8 := Pic.FileNew ("assets/n8.bmp")
n9 := Pic.FileNew ("assets/n9.bmp")
medal1 := Pic.FileNew ("assets/medal1.bmp")
medal2 := Pic.FileNew ("assets/medal2.bmp")
setscreen ("graphics:430;650")
View.Set ("offscreenonly")   % enable double buffering to prevent flicker

%PROCEDURE

% Draws the title screen and resets pipe/score state to starting values.
proc setup
    Pic.Draw (bg, 0, 0, 3)
    Pic.Draw (ground, 0, 0, 2)
    Pic.Draw (flappybird, 79, 500, 2)
    Pic.Draw (instruction, 126, 250, 2)
    View.Update
    px := 430
    pby := 0
    pty := pby + 580
    score := 0
    sx := 75
end setup

% Displays the title screen and waits for the player to press Space to begin.
proc ready
    setup
    loop
	Pic.Draw (ground, gx, 0, 2)
	delay (25)
	View.Update
	gx := gx - 3
	if gx <= -72 then
	    gx := 0
	end if
	if hasch then
	    getch (ch)
	    if ch = " " then
		start := true
		exit
	    end if
	end if
    end loop
end ready

% Resets all game-state variables to their starting values for a new run.
proc reset
    birdx := 190
    birdy := 360
    flystatus := 0
    passstatus2 := false
    px := 430
    pby := 0
    pty := pby + 580
    score := 0
    start := true
end reset

% Shows the game-over scoreboard and waits for Space to restart.
% Updates the session high score if the current run beats the record.
proc death
    loop
	if score > recordscore then
	    recordscore := score
	end if
	cls
	Pic.Draw (scoreboard, 115, 225, 2)
	if score >= 10 then
	    Font.Draw (intstr (score), 200, 375, font, black)
	elsif score < 10 then
	    Font.Draw (intstr (score), 210, 375, font, black)
	end if
	if recordscore >= 10 then
	    Font.Draw (intstr (recordscore), 200, 270, font, black)
	elsif recordscore < 10 then
	    Font.Draw (intstr (recordscore), 210, 270, font, black)
	end if
	Pic.Draw (getready, 80, 50, 2)
	Pic.Draw (gameover, 79, 500, 2)
	View.Update
	if hasch then
	    getch (ch)
	    if ch = " " then
		reset
		exit
	    end if
	end if
	View.Update
    end loop
end death

% Checks AABB overlap between the bird and the active pipe.
% Sets start := false (triggering death) on any hit.
proc collision
    xdiff := birdx - px
    ydiffb := round (birdy) - pby
    ydifft := round (birdy) - pty
    if xdiff < 78 and xdiff > -51 and ydiffb < 380 and ydiffb > -36 then
	start := false
    end if
    if xdiff < 78 and xdiff > -51 and ydifft < 380 and ydifft > -36 then
	start := false
    end if
end collision

% Increments the score when a pipe passes the bird's x position.
% Also controls the day/night background cycle every 25 points.
proc passstatus
    if px = 190 then
	score := score + 1
    end if
    if score = 25 or score = 75 then
	background := 2
    elsif score = 0 or score = 50 or score = 100then
	background := 1
    end if
end passstatus

% Hidden win-condition sequence triggered at score 100.
% Plays a congratulatory text crawl, then loops an animated medal screen.
proc ending
    cls
    View.Update
    Draw.FillBox (0, 0, maxx, maxy, black)
    View.Update
    delay (1000)
    Font.Draw ("Congratulation", 10, 600, font, white)
    View.Update
    delay (1000)
    Font.Draw ("You Beat The Game!", 10, 550, font, white)
    View.Update
    delay (1000)
    Font.Draw ("But you wasted your time...", 10, 500, font, white)
    View.Update
    delay (2500)
    Font.Draw ("However", 10, 450, font, white)
    Font.Draw ("There's a big prize for you", 10, 400, font, white)
    View.Update
    delay (2500)
    View.Update
    cls
    View.Update
    setscreen ("graphics:750;750")
    Draw.FillBox (0, 0, maxx, maxy, black)
    loop
	Pic.Draw (medal1, 0, 0, 2)
	View.Update
	delay (50)
	Pic.Draw (medal2, 0, 0, 2)
	View.Update
	delay (50)
    end loop
end ending

% Composites one complete frame: background, pipes, ground, animated bird, and score digits.
% Score digits are drawn as individual BMP sprites rather than font characters.
% imagescore = 1000 is a sentinel used when score = 1 (to avoid conflicting with the tens-digit
% branch, which would otherwise draw n1f at x=10 for a two-digit score starting with 1).
proc draw
    if background = 1 then
	Pic.Draw (bg, 0, 0, 3)
    elsif background = 2 then
	Pic.Draw (bg2, 0, 0, 3)
    end if
    Pic.Draw (pipeb, px, pby, 2)
    Pic.Draw (pipet, px, pty, 2)
    Pic.Draw (ground, gx, 0, 2)
    if flystatus = 1 then
	Pic.Draw (bird1, birdx, round (birdy), 2)
	flystatus := 2
    elsif flystatus = 2 then
	Pic.Draw (bird2, birdx, round (birdy), 2)
	flystatus := 3
    elsif flystatus = 3 then
	Pic.Draw (bird3, birdx, round (birdy), 2)
	flystatus := 1
    end if
    if score >= 0 and score < 10 then
	if score = 1 then
	    imagescore := 1000   % sentinel: draw n1s (units "1") not n1f (tens "1")
	else
	    imagescore := score
	    sx := 10
	end if
    elsif score >= 10 and score < 20 then
	imagescore := score - 10
	Pic.Draw (n1f, 10, 565, 2)
	sx := 70
    elsif score >= 20 and score < 30 then
	imagescore := score - 20
	Pic.Draw (n2, 10, 565, 2)
	sx := 70
    elsif score >= 30 and score < 40 then
	imagescore := score - 30
	Pic.Draw (n3, 10, 565, 2)
	sx := 70
    elsif score >= 40 and score < 50 then
	imagescore := score - 40
	Pic.Draw (n4, 10, 565, 2)
	sx := 70
    elsif score >= 50 and score < 60 then
	imagescore := score - 50
	Pic.Draw (n5, 10, 565, 2)
	sx := 70
    elsif score >= 60 and score < 70 then
	imagescore := score - 60
	Pic.Draw (n6, 10, 565, 2)
	sx := 70
    elsif score >= 70 and score < 80 then
	imagescore := score - 70
	Pic.Draw (n7, 10, 565, 2)
	sx := 70
    elsif score >= 80 and score < 90 then
	imagescore := score - 80
	Pic.Draw (n8, 10, 565, 2)
	sx := 70
    elsif score >= 90 and score < 100 then
	imagescore := score - 90
	Pic.Draw (n9, 10, 565, 2)
	sx := 70
    elsif score = 100 then
	ending
    end if
    if imagescore = 0 then
	Pic.Draw (n0, sx, 565, 2)
    elsif imagescore = 1 then
	Pic.Draw (n1s, sx, 565, 2)
    elsif imagescore = 2 then
	Pic.Draw (n2, sx, 565, 2)
    elsif imagescore = 3 then
	Pic.Draw (n3, sx, 565, 2)
    elsif imagescore = 4 then
	Pic.Draw (n4, sx, 565, 2)
    elsif imagescore = 5 then
	Pic.Draw (n5, sx, 565, 2)
    elsif imagescore = 6 then
	Pic.Draw (n6, sx, 565, 2)
    elsif imagescore = 7 then
	Pic.Draw (n7, sx, 565, 2)
    elsif imagescore = 8 then
	Pic.Draw (n8, sx, 565, 2)
    elsif imagescore = 9 then
	Pic.Draw (n9, sx, 565, 2)
    elsif imagescore = 1000 then
	Pic.Draw (n1f, sx, 565, 2)
    end if
    View.Update
end draw

% Scrolls the ground and the active pipe leftward each tick.
% When the pipe exits the left edge, it is repositioned off the right edge
% with a new randomized gap height.
proc move
    gx := gx - 3
    if gx <= -72 then
	gx := 0
    end if
    px := px - 3
    if px <= -100 then
	px := 430
	randint (pby, -215, 25)
	pty := pby + 580
    end if
    passstatus
    draw
end move

% Executes the bird's jump arc using sine interpolation over 0°–180°.
% Accumulating sind(angle) across that range produces a smooth rise-then-fall
% that feels more natural than a fixed-velocity model.
% Collision is checked at the start, during each step, and again at the end.
proc jump
    collision
    flystatus := 3
    for angle : 0 .. 180 by 5
	birdy := birdy + 5 * sind (angle)
	if background = 1 then
	    Pic.Draw (bg, 0, 0, 3)
	elsif background = 2 then
	    Pic.Draw (bg2, 0, 0, 3)
	end if
	cls
	if background = 1 then
	    Pic.Draw (bg, 0, 0, 3)
	elsif background = 2 then
	    Pic.Draw (bg2, 0, 0, 3)
	end if
	move
	collision
	if birdy >= 600 then
	    birdy := 600
	end if
    end for
    collision
end jump

% Polls the keyboard each frame; triggers a jump when Space is held down.
proc jumpstatus
    Input.KeyDown (chars)
    if chars (' ') then
	jump
    end if
end jumpstatus

% Kills the bird if it falls below the ground line; clamps the top of the screen.
proc boundary
    if birdy <= 125 then
	death
    end if
    if birdy >= 600 then
	birdy := 600
    end if
end boundary

%------------------------------------------------

%GAME
ready
setup
loop
    reset
    if start = true then
	cls
	draw
	loop
	    jumpstatus
	    collision
	    boundary
	    birdy := birdy - 5
	    draw
	    delay (5)
	    cls
	    move
	    collision
	    boundary
	    exit when start = false
	end loop
    end if
    death
    if start = false then
	exit
    end if
end loop


