# tunician
A mediocre tool for decoding the runic language from the game Tunic

### Phonemes 

Huge credit goes to [u/oposdeo](https://www.reddit.com/user/oposdeo) who did all the work of actually decoding the runic code. See their post [here](https://www.reddit.com/r/TunicGame/comments/tgc056/tunic_language_reference_sheet_big_spoiler/).

## How To Use

After downloading the latest release, or building the latest version from source, simply run it and a UI will appear:



The controls are as follows:

```
<-/->       Move cursor left and right; moving right at the end of a phrase adds more runes to the phrase
Backspace   Clear current rune & remove it from the phrase
Click       on the lines in the central rune to toggle them on/off; toggling the diacritic at the bottom will swap phoneme order
```

## Notes & Limitations
 - Empty runes are treated as half-width spaces
 - There is no punctuation support
 - The phrase will cut off if it is too long
