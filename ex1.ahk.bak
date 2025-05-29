currentWord := ""
translationMap := Map() ; will be a string -> string[] map

; load file
fileText := FileRead(A_ScriptDir "\eng_to_orkz.txt")

; parse file
for line in StrSplit(fileText, "`n", "`r")
{
    if line == "" ; empty line
		continue
	if SubStr(line, 1, 1) == ";" ; commented out line
		continue

	parts := StrSplit(line, ",")
	if parts.Length == 2
	{
		leftSide := Trim(parts[1], " `t`r`n`"")
		rightSide := Trim(parts[2], " `t`r`n`"")

		keys := StrSplit(leftSide, " / ")
		values := StrSplit(rightSide, " / ")

		for key in keys
		{
			translationMap[key] := values
		}
	}
}

; key presses
for key in ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
{
    HotIfWinActive()
    Hotkey("*" key, appendChar.Bind(key)) ; append char and output what the user typed
}

Hotkey("*~Backspace", handleBackspace)
Hotkey("*~Space", handleSpace)

appendChar(char, *)
{
    global currentWord
    currentWord .= char
}

handleBackspace(*)
{
    global currentWord
    currentWord := SubStr(currentWord, 1, StrLen(currentWord) - 1)
}

handleSpace(*)
{
    global currentWord, translationMap

	; handle output word
	newWord := currentWord
	if translationMap.Has(currentWord)
		newWord := translationMap[currentWord][Random(1, translationMap[currentWord].Length)]

	; StrLen(currentWord)
    Send("{Backspace "  1 "}") ; delete old word + space
    SendText(newWord " ") ; send new word + space

    currentWord := "" ; reset word
	; SendText("~") ; debug
}
