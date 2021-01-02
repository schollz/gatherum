## downtown

view downtown over the skyline. build skyscrapers or tear them down to change the sounds coming from the city. record and mix in your own sounds to join the city.

![Image](https://user-images.githubusercontent.com/6550035/103465225-7859a380-4cee-11eb-981d-bc571d9b152d.png)

https://vimeo.com/496475138

all cities are alike and all cities are different. like cities, this script welcomes change. the towers are built from supercollider tweets - you can [easily find more](https://twitter.com/search?q=SinOsc%20(%23supercollider%20OR%20%23sc%20OR%20%23sctweet)&src=typed_query&f=live). find one you like and [add it as a new tower in the city](https://github.com/schollz/infinitedigits/tree/master/1#new-towers). i welcome prs if you'd like to share your tower with this script.

### Requirements

- norns

### Documentation

- K2 changes sample
- K3 toggles recording
- E2 changes modulator
- E3 modulates

i made this script as a "playground" where i can very easily add little supercollider things and interact with them through softcut loops. the three sample loops record in stereo and their length is dependent on the norns internal tempo. they are set to 16 beats, but this can be changed within the script (restart to apply changes).

#### new towers

the engine has a bunch of different free-running supercollider scripts. its easy to add your own. if you want to add one, you can follow these five steps to get your own working:

1. in `Engine_Downtown.sc`, add a `  var <synthX;` at the top after `Engine_Downtown : CroneEngine {`, where `X` is whatever you want.
2. in `Engine_Downtown.sc`, define the `synthX`, using something similar to this:

```
synthX = {
    arg amp=0.0, amplag=0.02;
    var amp_, snd;
    amp_ = Lag.ar(K2A.ar(amp), amplag);

    // define your beautiful sound here
    snd = SinOsc(440); // or anything!

    snd
}.play(target: context.xg);
```

3. in `Engine_Downtown.sc`, create a command definition that can be used from within lua. a simple one that each could have is amplitude to change the levels.

```
this.addCommand("ampX", "f", { arg msg;
    synthX.set(\amp, msg[1]);
});
```

4. in `Engine_Downtown.sc`, add `synthX.free;` at the bottom of the code.
5. in `downtown.lua` add a new modulator that references the command definitions:

```lua
modulators = {  
  {name="my beautiful sound",engine="ampX",min=0,max=0.5}, // <- your new sound here!
  ...
```

6. that's it! there will now be a new tower in the city with your sound.

## license 

mit 