## downtown

sounds around town.

![Image](https://user-images.githubusercontent.com/6550035/103465225-7859a380-4cee-11eb-981d-bc571d9b152d.png)

view downtown over the skyline. build skyscrapers or tear them down to change the sounds coming from the city. record and mix in your own sounds to join the city.

cities are all alike and all different. like cities, this script welcomes changes. the engine is simply a collection supercollider tweets - you can [easily find more](https://twitter.com/search?q=SinOsc%20(%23supercollider%20OR%20%23sc%20OR%20%23sctweet)&src=typed_query&f=live). once you remove/add an engine, you can change the [modulators in the main script]().

### Requirements

- norns

### Documentation

- K2 changes sample
- K3 toggles recording
- E2 changes modulator
- E3 modulates

i made this script as a "playground" where i can very easily add little supercollider things and interact with them through softcut loops. the three sample loops record in stereo and their length is dependent on the norns internal tempo. they are set to 16 beats, but this can be changed within the script (restart to apply changes).

the engine has a bunch of different free-running supercollider scripts. its easy to add your own. if you want to add one, you can follow these steps:

1. in `Engine_ID1.sc`, add a `	var <synthX;` at the top after `Engine_ID1 : CroneEngine {`, where `X` is whatever you want.
2. in `Engine_ID1.sc`, define the `synthX`, using something similar to this:

```
synthX = {
	arg amp=0.0, amplag=0.02;
	var amp_, snd;
	amp_ = Lag.ar(K2A.ar(amp), amplag);

	snd = // define your beautiful sound here

	snd
}.play(target: context.xg);
```

3. in `Engine_ID1.sc`, create a definition that can be used from within lua. a simple one that each could have is amplitude, to change the levels, but add whatever you want:

```
this.addCommand("ampX", "f", { arg msg;
	synthX.set(\amp, msg[1]);
});
```

4. in `Engine_ID1.sc`, add `synthX.free;` at the bottom of the code.
5. in `downtown.lua` add a new modulator:

```lua
modulators = {  
  {name="my beautiful sound",engine="ampX",min=0,max=0.5}, // <- your new sound here!
  ...
```

6. that's it! there will now be a new tower in the city with your sound.

## license 

mit 