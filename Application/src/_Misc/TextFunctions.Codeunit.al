codeunit 6014604 "NPR Text Functions"
{
#IF BC17
    procedure Camelize(InputString: Text): Text
    var
        DotNetRegEx: Codeunit DotNet_Regex;
        TempString: Text;
        Word: Text;
        Words: List of [Text];
        i: Integer;
        TB: TextBuilder;
    begin
        DOtNetRegEx.Regex('[^a-zA-Z0-9 ]');
        TempString := DotNetRegEx.Replace(InputString, ' ');
        DotNetRegEx.Regex('[ ]{2,}'); //more than one space
        TempString := DotNetRegEx.Replace(TempString, ' ').Trim();

        Words := TempString.Split(' ');
        for i := 1 to Words.Count() do begin
            IF Words.Get(i, Word) then
                Case i of
                    1:
                        Word := Word.ToLower();
                    else
                        Word := Format(Word[1]).ToUpper() + Word.Substring(2).ToLower();
                End;
            TB.Append(Word);
        end;

        exit(TB.ToText());
    end;

#ELSE
    procedure Camelize(InputString: Text): Text
    var
        Regex: Codeunit Regex;
        TempString: Text;
        Word: Text;
        Words: List of [Text];
        i: Integer;
        TB: TextBuilder;
    begin
        TempString := Regex.Replace(InputString, '[^a-zA-Z0-9 ]', ' ', 10000);
        TempString := Regex.Replace(TempString, '[ ]{2,}', ' ', 10000).Trim(); //more than one space

        Words := TempString.Split(' ');
        for i := 1 to Words.Count() do begin
            IF Words.Get(i, Word) then
                Case i of
                    1:
                        Word := Word.ToLower();
                    else
                        Word := Format(Word[1]).ToUpper() + Word.Substring(2).ToLower();
                End;
            TB.Append(Word);
        end;

        exit(TB.ToText());
    end;
#ENDIF
    procedure AddressArrayToMultilineString(InputArray: Array[8] of Text) Result: Text
    var
        Counter: Integer;
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        for Counter := 1 to ArrayLen(InputArray) do begin
            If InputArray[Counter] <> '' then begin
                If Result <> '' then
                    Result += CRLF;
                Result += InputArray[Counter];
            end;
        end;
    end;
}
