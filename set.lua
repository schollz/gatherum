norns.script.load("code/gatherum/live.lua")

tapestop()
tapestart()
tapebreak()

clock.run(function() clock.sleep(1.5);tapestop();clock.sleep(2.5);tapestart() end)
clock.run(function() clock.sleep(1.5);tapebreak() clock.sleep(1.5);tapebreak() end)

for _, v in ipairs({"crow","bou","hh","bou","usb","op1"}) do stop(v) end


params:set("clock_tempo",165)

play("kick",er(1),1)
play("kick",er_add(er(1),rot(er(1),3)),2)
play("kicklfo",er("kick.patch.distAmt=lfo(10,1,80)",12))
play("hh",er_sub(er(8),er(4)),1)
play("clap",rot(er(2),4),1)

play("bou","G/B:3",1)
play("bou","Bm:3",3)
play("bou","F#m/A:3",5)
play("bou","Amaj:3",7)
play("bou","Amaj:3",8)

e.sload(1,wav("la"));
play("la",er("e.spos(1,0)",1),1)
expand("la",8)
e.samp(1,0.5)
e.samp(1,0.0)


stop("usb")
play("usb","b2",1)
play("usb","d2",2)

stop("op1")
play("op1",arp("f#5 c#5 e5 .",8,1),1)

play("usb","b2 d3 b2 a2 f#3 g4 g4 a4",1)
play("usb","d3 e3 f#4 a4 g4 f#4 b1 a1",2)
play("usb","b2 . . . b2 . . .  e3 . d3 . f#3 . g3 .",1)
play("usb",". . d3 .  e3  d3  . f#1  . . g1 . . ",2)

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.07) }";crow.output[2]()
play("crow",arp("d5 b4 g5",16),1)

crow.output[2].action="{ to(10,2),to(0,6) }";crow.output[2]()
crow.output[3].action="lfo(3.1415,10)";crow.output[3]()
stop("crow")
expand("crow",8)
play("crow","d3",1)
play("crow","f#3",3)
play("crow","a3",5)
play("crow","e4",7)
play("crow","e4",8)

e.bload(wav("165_1"))
e.bload(wav("165_2"))
e.bload(wav("165_3"))
e.bload(wav("165_4"))
e.bamp(0.8)
e.bamp(0)

nature(1.0)

-- closer

params:set("clock_tempo",120)


play("bou","Abm/Eb:3",1)
play("bou","E:3",2)
play("bou","Gb/Db:3",3)
play("bou","Ebm:3",4)

play("bou","Abm/Eb:3",5)
play("bou","E:3",6)
play("bou","Gb:3",7)
play("bou","Db/F:3",8)

expand("closer",64)
e.sload(1,wav("closer"))
e.samp(1,1.0);
play("closer",er("engine.s_mov(1,3/28)",1),1)
stop("closer"); play("closer",er("e.s_mov(1,26/28)",1),4)

play("op1",arp("bb4 . bb3 eb4 ab4 db4"),1)

play("usb","ab1",1)
play("usb","b2",2)
play("usb","gb1",3)
play("usb","eb1",4)


stop("crow")
crow.output[2].action="{ to(10,2),to(0,6) }";crow.output[2]()
crow.output[3].action="lfo(3,10)";crow.output[3]()
play("crow","ab3",1)
play("crow","gb4",3)
play("crow","bb4",4)

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.07) }";crow.output[2]()
play("crow",arp("ab4 bb3 eb3 ab3 bb4",16),1)
play("crow",arp("ab4 ab5 bb3",16),1)

stop("usb")
play("usb",arp("ab1 ab1 ab1 eb2 eb2 . . . "),1)
play("usb",arp("b2 e1 b2 ."),2)
play("usb",arp("gb1 gb3 db"),3)
play("usb",arp("eb1 eb2 bb3 eb1 . "),4)
play("usb","ab1 ab ab . ab  . eb ab ab1 ab ab . ab  . eb ab",1)
play("usb","b2  e1 e1 . b2  . g# b b2  e1 e1 . b2  . g# b",2)
play("usb","gb1 gb db . gb3 . b  db gb1 gb db . gb3 . b  db",3)
play("usb","eb1 eb bb . bb .  ab bb eb1 eb bb . bb .  ab bb",4)

e.bload(wav("120_1")) -- 1-5
e.bamp(0.8)
play("bbr",er("if math.random()<0.2 then e.brev(1) end",5))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bbreak(v,v+math.random()/40+0.01) end",4),1)


