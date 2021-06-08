codeunit 6014569 "NPR RegEx"
{
    var
#if BC17
        RegEx: Codeunit DotNet_Regex;
#else
        RegEx: Codeunit Regex;
#endif

    procedure GetSingleMatchValue(Input: Text; Pattern: Text; var Output: Text): Boolean;
    var
#if BC17
        Match: Codeunit DotNet_Match;
#else
        Match: Record Matches temporary;
#endif
    begin
        Clear(RegEx);
#if BC17
        Regex.Regex(Pattern);
        Regex.Match(Input, Match);
        if Match.Success() then begin
            Output := Match.Value();
            exit(true);
        end;
#else
        Regex.Match(Input, Pattern, 1, Match);
        Match.SetRange(Success, true);
        if Match.FindFirst() then begin
            Output := Match.ReadValue();
            exit(true);
        end;
#endif
        exit(false);
    end;

    procedure RegExReplaceAN(Input: Text) Output: Text
    var
#if BC17
        Match: Codeunit DotNet_Match;
        GroupCollection: Codeunit DotNet_GroupCollection;
        DotNetGroup: Codeunit DotNet_Group;
#else
        Matches: Record Matches temporary;
        Groups: Record Groups temporary;
#endif
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Clear(RegEx);
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
#if BC17
        Regex.Regex(Pattern);

        Regex.Match(Input, Match);
        while Match.Success() do begin
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
                    Groups.Reset();
                    Groups.DeleteAll();
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

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; Count: Integer): Text
    begin
        Clear(RegEx);
#if BC17
        RegEx.Regex(Pattern);
        exit(RegEx.Replace(Input, Replacement));
#else
        exit(RegEx.Replace(Input, Pattern, Replacement, Count));
#endif
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text): Text
    begin
        Clear(RegEx);
#if BC17
        RegEx.Regex(Pattern);
        exit(RegEx.Replace(Input, Replacement));
#else
        exit(RegEx.Replace(Input, Pattern, Replacement, 1));
#endif
    end;

    procedure IsMatch(Input: Text; Pattern: Text): Boolean
    begin
        exit(RegEx.IsMatch(Input, Pattern));
    end;

    procedure RegExReplaceSerialNo(Input: Text; AdditionPattern: Text; SerialNo: Text) Output: Text
    var
        Pattern: Text;
    begin
        Clear(RegEx);
        Pattern := '(?<SerialNo>' + AdditionPattern + ')';
#if BC17
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, SerialNo);
#else
        Output := RegEx.Replace(Input, Pattern, SerialNo);
#endif
        exit(Output);
    end;

    procedure RegExReplaceS(Input: Text; SerialNo: Text) Output: Text
    begin
        Output := RegExReplaceSerialNo(Input, '\[S\]', SerialNo);
    end;

    procedure RegExReplaceN(Input: Text) Output: Text
    var
#if BC17
        Match: Codeunit DotNet_Match;
        GroupCollection: Codeunit DotNet_GroupCollection;
        DotNetGroup: Codeunit DotNet_Group;
#else
        RegEx: Codeunit Regex;
        Matches: Record Matches temporary;
        Groups: Record Groups temporary;
#endif
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[N\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
#if BC17
        Regex.Regex(Pattern);

        Regex.Match(Input, Match);
        while Match.Success() do begin
            ReplaceString := '';
            RandomQty := 1;
            Match.Groups(GroupCollection);
            GroupCollection.ItemGroupName('RandomQty', DotNetGroup);
            if Evaluate(RandomQty, Format(DotNetGroup.Value())) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(Random(9));
            Input := Regex.Replace(Input, ReplaceString, 1);

            Regex.Match(Input, Match);
        end;
#else
        Regex.Match(Input, Pattern, 1, Matches);
        if Matches.FindSet() then
            repeat
                if Matches.Success then begin
                    Groups.Reset();
                    Groups.DeleteAll();
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

    procedure RegExReplacePS(Input: Text; PosStoreCode: Text) Output: Text
    begin
        Output := RegExReplaceSerialNo(Input, '\[PS\]', PosStoreCode);
    end;

    procedure RegExReplacePU(Input: Text; PosUnitNo: Text) Output: Text
    begin
        Output := RegExReplaceSerialNo(Input, '\[PU\]', PosUnitNo);
    end;

    procedure RegExReplaceL(Input: Text; LineNo: Text) Output: Text
    begin
        Output := RegExReplaceSerialNo(Input, '\[L\]', LineNo);
    end;

    procedure RegExReplaceNL(Input: Text; NaturalLineNo: Text) Output: Text
    begin
        Output := RegExReplaceSerialNo(Input, '\[NL\]', NaturalLineNo);
    end;

    procedure GenerateRandomChar() RandomChar: Char
    var
        RandomInt: Integer;
        AllowedChars: Text;
    begin
        AllowedChars := 'QWERTYUPASDFGHJKZXCVBNM';
        RandomInt := Random(StrLen(AllowedChars));
        RandomChar := CopyStr(AllowedChars, RandomInt, 1) [1];
        exit(RandomChar);
    end;

    procedure FindVariables(var TempVariable: Record "NPR Smart Email Variable" temporary; CodeString: Text)
    var
#if BC17
        Match: Codeunit DotNet_Match;
#else
        Match: Record Matches temporary;
#endif
        i: Integer;
        OffSet: Integer;
    begin
        if CodeString = '' then
            exit;
        Clear(RegEx);
#if BC17
        RegEx.Regex('(\*\|)(.*?)(\|\*)');
        RegEx.Match(CodeString, Match);
        while Match.Success() do begin
            TempVariable.Init();
            TempVariable."Line No." := i;
            TempVariable."Variable Name" := Match.Value();
            TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
            TempVariable."Variable Type" := TempVariable."Variable Type"::Mailchimp;
            TempVariable.Insert();
            i += 1;
            OffSet := i + 1;
            Match.NextMatch(Match);
        end;

        RegEx.Regex('({{)(.*?)(}})');
        RegEx.Match(CodeString, Match);
        i := 0;
        while Match.Success() do begin
            TempVariable.Init();
            TempVariable."Line No." := i + OffSet;
            TempVariable."Variable Name" := Match.Value();
            TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
            TempVariable."Variable Type" := TempVariable."Variable Type"::Handlebars;
            TempVariable.Insert();
            i += 1;
            Match.NextMatch(Match);
        end;
#else
        Regex.Match(CodeString, '(\*\|)(.*?)(\|\*)', 1, Match);
        i := 0;
        if Match.FindSet() then
            repeat
                if Match.Success then begin
                    TempVariable.Init();
                    TempVariable."Line No." := i;
                    TempVariable."Variable Name" := Match.ReadValue();
                    TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
                    TempVariable."Variable Type" := TempVariable."Variable Type"::Mailchimp;
                    TempVariable.Insert();
                    i += 1;
                    OffSet := i + 1;
                end;
            until Match.Next() = 0;

        RegEx.Match(CodeString, '({{)(.*?)(}})', Match);
        i := 0;
        if Match.FindSet() then
            repeat
                if Match.Success then begin
                    TempVariable.Init();
                    TempVariable."Line No." := i + OffSet;
                    TempVariable."Variable Name" := Match.ReadValue();
                    TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
                    TempVariable."Variable Type" := TempVariable."Variable Type"::Handlebars;
                    TempVariable.Insert();
                end;
            until Match.Next() = 0;
#endif
    end;

    procedure MergeDataFields(TextLine: Text; var RecRef: RecordRef; ReportID: Integer; AFReportLinkTag: Text) ResultText: Text
    var
#if BC17
        Match: Codeunit DotNet_Match;
#else
        Match: Record Matches temporary;
#endif
    begin
        Clear(RegEx);
        ResultText := '';
#if BC17
        repeat
            RegEx.Regex('{\d+}');
            RegEx.Match(TextLine, Match);
            if Match.Success() then begin
                ResultText += CopyStr(TextLine, 1, Match.Index());
                ResultText += ConvertToValue(Match.Value(), RecRef);
                TextLine := CopyStr(TextLine, Match.Index() + Match.Length() + 1);
            end;
        until not Match.Success();

        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        repeat
            RegEx.Regex(StrSubstNo(AFReportLinkTag, '.*?'));
            RegEx.Match(TextLine, Match);
            if Match.Success() then begin
                ResultText += CopyStr(TextLine, 1, Match.Index());
                TextLine := CopyStr(TextLine, Match.Index() + Match.Length() + 1);
            end;
        until not Match.Success();
#else
        RegEx.Match(TextLine, '{\d+}', Match);
        if Match.FindSet() then
            repeat
                if Match.Success then begin
                    ResultText += CopyStr(TextLine, 1, Match.Index);
                    ResultText += ConvertToValue(Match.ReadValue(), RecRef);
                    TextLine := CopyStr(TextLine, Match.Index + Match.Length + 1);
                end;
            until Match.Next() = 0;

        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        RegEx.Match(TextLine, StrSubstNo(AFReportLinkTag, '.*?'), Match);
        if Match.FindSet() then
            repeat
                if Match.Success then begin
                    ResultText += CopyStr(TextLine, 1, Match.Index);
                    TextLine := CopyStr(TextLine, Match.Index + Match.Length + 1);
                end;
            until Match.Next() = 0;
#endif
        ResultText += TextLine;
    end;

    local procedure ConvertToValue(FieldNoText: Text; RecRef: RecordRef): Text
    var
        FldRef: FieldRef;
        FieldNumber: Integer;
        OptionString: Text;
        OptionNo: Integer;
        AutoFormat: Codeunit "Auto Format";
    begin
        if not Evaluate(FieldNumber, DelChr(FieldNoText, '<>', '{}')) then
            exit(FieldNoText);
        if not RecRef.FieldExist(FieldNumber) then
            exit(FieldNoText);
        FldRef := RecRef.Field(FieldNumber);
        if FldRef.Class = FieldClass::FlowField then
            FldRef.CalcField();

        if FldRef.Type = FieldType::Option then begin
            OptionString := Format(FldRef.OptionCaption);
            Evaluate(OptionNo, Format(FldRef.Value, 0, 9));
            exit(SelectStr(OptionNo + 1, OptionString));
        end else
            exit(Format(FldRef.Value, 0, AutoFormat.ResolveAutoFormat(Enum::"Auto Format".FromInteger(1), '')));
    end;

    procedure ExtractMagentoPicture(DataUri: Text; PictureName: Text; PictureSize: Integer; PictureType: Integer;
        var TempMagentoPicture: Record "NPR Magento Picture" temporary)
    var
#if BC17
        Match: Codeunit DotNet_Match;
        Groups: Codeunit DotNet_GroupCollection;
        Group1: Codeunit DotNet_Group;
        Group2: Codeunit DotNet_Group;
#else
        Match: Record Matches temporary;
        Groups: Record Groups temporary;
        Group1: Record Groups temporary;
        Group2: Record Groups temporary;
#endif
        Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
    begin
        Clear(RegEx);
#if BC17
        RegEx.Regex('data\:image/(.*?);base64,(.*)');
        RegEx.Match(DataUri, Match);
        if Match.Success() then begin
            Match.Groups(Groups);
            Groups.Item(1, Group1);
            Groups.Item(2, Group2);
            TempMagentoPicture.Init();
            TempMagentoPicture.Type := "NPR Magento Picture Type".FromInteger(PictureType);
            TempMagentoPicture.Name := PictureName;
            TempMagentoPicture."Size (kb)" := Round(PictureSize / 1000, 1);
            TempMagentoPicture."Mime Type" := Group1.Value();
            TempMagentoPicture.Image.ExportStream(OutStr);
            Convert.FromBase64(Group2.Value(), OutStr);
            TempMagentoPicture.Insert();
        end;
#else
        RegEx.Match(DataUri, 'data\:image/(.*?);base64,(.*)', Match);
        if Match.FindSet() then
            repeat
                if Match.Success then begin
                    Groups.Reset();
                    Groups.DeleteAll();


                    RegEx.Groups(Match, Groups);
                    Groups.FindSet();
                    Group1 := Groups;
                    Groups.Next();
                    Group2 := Groups;
                    TempMagentoPicture.Init();
                    TempMagentoPicture.Type := "NPR Magento Picture Type".FromInteger(PictureType);
                    TempMagentoPicture.Name := PictureName;
                    TempMagentoPicture."Size (kb)" := Round(PictureSize / 1000, 1);
                    TempMagentoPicture."Mime Type" := Group1.ReadValue();
                    TempMagentoPicture.Image.ExportStream(OutStr);
                    Convert.FromBase64(Group2.ReadValue(), OutStr);
                    TempMagentoPicture.Insert();
                end;
            until Match.Next() = 0;
#endif
    end;
}