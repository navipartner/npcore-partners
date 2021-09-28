codeunit 6014604 "NPR Text Functions"
{
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

}
