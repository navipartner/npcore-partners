codeunit 6014569 "NPR RegEx"
{
    procedure RegExReplaceAN(Input: Text) Output: Text
    var
#if BC17
        Match: Codeunit DotNet_Match;
        Regex: Codeunit DotNet_Regex;
        GroupCollection: Codeunit DotNet_GroupCollection;
        DotNetGroup: Codeunit DotNet_Group;
#else
        Regex: Codeunit Regex;
        Matches: Record Matches;
        Groups: Record Groups;
#endif
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
#if BC17
        Regex.Regex(Pattern);

        Regex.Match(Input, Match);
        while Match.Success do begin
            ReplaceString := '';
            RandomQty := 1;
            Match.Groups(GroupCollection);
            GroupCollection.ItemGroupName('RandomQty', DotNetGroup);
            if Evaluate(RandomQty, Format(DotNetGroup.Value())) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(GenerateRandomChar());
            Input := Regex.Replace(Input, ReplaceString, 1);

            Regex.Match(Input, Match);
        end;
#else
        Regex.Match(Input, Pattern, 1, Matches);
        if Matches.FindSet() then
            repeat
                if Matches.Success then begin
                    Regex.Groups(Matches, Groups);
                    Groups.SetRange(Groups.Name, 'RandomQty');
                    if Groups.FindFirst() then begin
                        if Evaluate(RandomQty, Groups.ReadValue()) then begin
                            for i := 1 to RandomQty do
                                ReplaceString += Format(GenerateRandomChar());
                            Input := Regex.Replace(Input, Pattern, ReplaceString, 1);
                        end;
                    end;
                end;
            until Matches.Next() = 0;
#endif
        Output := Input;
    end;

    procedure RegExReplaceS(Input: Text; SerialNo: Text) Output: Text
    var
#if BC17
        RegEx: DotNet NPRNetRegex;
#else
        RegEx: Codeunit Regex;
#endif
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
#if BC17
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, SerialNo);
#else
        Output := RegEx.Replace(Input, Pattern, SerialNo);
#endif
        exit(Output);
    end;

    procedure GenerateRandomChar() RandomChar: Char
    var
        RandomInt: Integer;
        RandomText: Text[1];
    begin
        RandomInt := Random(9999);

        if Random(35) < 10 then begin
            RandomText := Format(RandomInt mod 10);
            RandomChar := RandomText[1];
            exit(RandomChar);
        end;

        RandomChar := (RandomInt mod 25) + 65;
        RandomText := UpperCase(Format(RandomChar));
        RandomChar := RandomText[1];
        exit(RandomChar);
    end;
}