commentString := "#"
prefixString := "~pre "
suffixString := "~suf "

currentWord := ""
translationMap := Map() ; will be a string -> string[] map

; will be string -> string[] map, where the value first index is the translation string and the second index is the percent chance to occur as a string
prefixDefaultMap := Map()
suffixDefaultMap := Map()

; load file
fileText := FileRead(A_ScriptDir "\eng_to_orkz.txt")

; parse file
for line in StrSplit(fileText, "`n", "`r")
{
    if (line == "") ; empty line
		continue
	if (SubStr(line, 1, StrLen(commentString)) == commentString) ; commented out line
		continue

	; suffix rule case
	if (SubStr(line, 1, StrLen(suffixString)) == suffixString)
	{
		; parts[1] == input, parts[2] == output, parts[3] == percent chance
		parts := StrSplit(LTrim(line, suffixString), ",")
		parts[1] := Trim(parts[1], " `t`r`n`"")
		parts[2] := Trim(parts[2], " `t`r`n`"")
		parts[3] := Trim(parts[3], " `t`r`n`"")

		suffixDefaultMap[parts[1]] := [parts[2], parts[3]]
		;MsgBox parts[1] " " parts[2] " " parts[3]
		continue
	}

	; prefix rule case
	if (SubStr(line, 1, StrLen(prefixString)) == prefixString)
	{
		; parts[1] == input, parts[2] == output, parts[3] == percent chance
		parts := StrSplit(LTrim(line, prefixString), ",")
		parts[1] := Trim(parts[1], " `t`r`n`"")
		parts[2] := Trim(parts[2], " `t`r`n`"")
		parts[3] := Trim(parts[3], " `t`r`n`"")

		prefixDefaultMap[parts[1]] := [parts[2], parts[3]]
		;MsgBox parts[1] " " parts[2] " " parts[3]
		continue
	}

	; one-to-one translation case
	parts := StrSplit(line, ",")
	if (parts.Length == 2)
	{
		leftSide := Trim(parts[1], " `t`r`n`"")
		rightSide := Trim(parts[2], " `t`r`n`"")

		keys := StrSplit(leftSide, "/")
		values := StrSplit(rightSide, "/")

		for (key in keys)
		{
			newValues := values
			; handle duplicate keys
			if (translationMap.Has(key))
			{
				;MsgBox "duplicate key caught"
				for (v in translationMap[key])
				{
					; handle duplicate values
					for (nV in newValues)
					{
						if (nV != v)
							newValues.Push(v)
						;else
							;MsgBox "duplicate value caught"
					}
				}
			}
			translationMap[key] := newValues
		}
	}
}

; key presses
for (key in ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"])
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
	cLen := StrLen(currentWord)
	newWord := currentWord
	currentWordOneLess := SubStr(currentWord, 1, cLen-1)
	lastCharCurrentWord := SubStr(currentWord, cLen, cLen)

	if (translationMap.Has(currentWord))
		newWord := translationMap[currentWord][Random(1, translationMap[currentWord].Length)]
	else if (lastCharCurrentWord == "s" && translationMap.Has(currentWordOneLess))
		newWord := translationMap[currentWordOneLess][Random(1, translationMap[currentWordOneLess].Length)] lastCharCurrentWord
	else
	{
		for (key in suffixDefaultMap)
		{
			nLen := StrLen(newWord)
			kLen := StrLen(key)
			if (nLen > kLen && StrCompare(SubStr(newWord, nLen - kLen + 1, nLen), key) == 0) ; suffix check
			{
				if (Random(1, 100) <= Floor(suffixDefaultMap[key][2])) ; percent chance
				{
					newWord := SubStr(newWord, 1, nLen - kLen) suffixDefaultMap[key][1] ; assign new suffix
				}
			}
		}
		for (key in prefixDefaultMap)
		{
			kLen := StrLen(key)
			if (nLen > kLen && StrCompare(SubStr(newWord, 1, kLen), key) == 0) ; prefix check
			{
				if (Random(1, 100) <= Floor(prefixDefaultMap[key][2])) ; percent chance
				{
					newWord := prefixDefaultMap[key][1] SubStr(newWord, kLen+1, nLen)  ; assign new prefix
				}
			}
		}
	}

	; StrLen(currentWord)
    Send("{Backspace "  1 "}") ; delete old word + space
    SendText(newWord " ") ; send new word + space

    currentWord := "" ; reset word
	; SendText("~") ; debug
}
