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
        TempMatch: Record Matches temporary;
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
        Regex.Match(Input, Pattern, 1, TempMatch);
        TempMatch.SetRange(Success, true);
        if TempMatch.FindFirst() then begin
            Output := TempMatch.ReadValue();
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
        TempMatches: Record Matches temporary;
        TempGroups: Record Groups temporary;
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
        Regex.Match(Input, Pattern, 1, TempMatches);
        if TempMatches.FindSet() then
            repeat
                if TempMatches.Success then begin
                    TempGroups.Reset();
                    TempGroups.DeleteAll();
                    Regex.Groups(TempMatches, TempGroups);
                    TempGroups.SetRange(TempGroups.Name, 'RandomQty');
                    if TempGroups.FindFirst() then begin
                        if Evaluate(RandomQty, TempGroups.ReadValue()) then begin
                            for i := 1 to RandomQty do
                                ReplaceString += Format(GenerateRandomChar());
                            Input := Regex.Replace(Input, Pattern, ReplaceString, 1);
                        end;
                    end;
                end;
            until TempMatches.Next() = 0;
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
        TempMatches: Record Matches temporary;
        TempGroups: Record Groups temporary;
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
        Regex.Match(Input, Pattern, 1, TempMatches);
        if TempMatches.FindSet() then
            repeat
                if TempMatches.Success then begin
                    TempGroups.Reset();
                    TempGroups.DeleteAll();
                    Regex.Groups(TempMatches, TempGroups);
                    TempGroups.SetRange(TempGroups.Name, 'RandomQty');
                    if TempGroups.FindFirst() then begin
                        if Evaluate(RandomQty, TempGroups.ReadValue()) then begin
                            for i := 1 to RandomQty do
                                ReplaceString += Format(GenerateRandomChar());
                            Input := Regex.Replace(Input, Pattern, ReplaceString, 1);
                        end;
                    end;
                end;
            until TempMatches.Next() = 0;
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
        TempMatch: Record Matches temporary;
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
        Regex.Match(CodeString, '(\*\|)(.*?)(\|\*)', 1, TempMatch);
        i := 0;
        if TempMatch.FindSet() then
            repeat
                if TempMatch.Success then begin
                    TempVariable.Init();
                    TempVariable."Line No." := i;
                    TempVariable."Variable Name" := TempMatch.ReadValue();
                    TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
                    TempVariable."Variable Type" := TempVariable."Variable Type"::Mailchimp;
                    TempVariable.Insert();
                    i += 1;
                    OffSet := i + 1;
                end;
            until TempMatch.Next() = 0;

        RegEx.Match(CodeString, '({{)(.*?)(}})', TempMatch);
        i := 0;
        if TempMatch.FindSet() then
            repeat
                if TempMatch.Success then begin
                    TempVariable.Init();
                    TempVariable."Line No." := i + OffSet;
                    TempVariable."Variable Name" := TempMatch.ReadValue();
                    TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
                    TempVariable."Variable Type" := TempVariable."Variable Type"::Handlebars;
                    TempVariable.Insert();
                end;
            until TempMatch.Next() = 0;
#endif
    end;

    procedure MergeDataFields(TextLine: Text; var RecRef: RecordRef; ReportID: Integer; AFReportLinkTag: Text) ResultText: Text
    var
#if BC17
        Match: Codeunit DotNet_Match;
#else
        TempMatch: Record Matches temporary;
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
        RegEx.Match(TextLine, '{\d+}', TempMatch);
        if TempMatch.FindSet() then
            repeat
                if TempMatch.Success then begin
                    ResultText += CopyStr(TextLine, 1, TempMatch.Index);
                    ResultText += ConvertToValue(TempMatch.ReadValue(), RecRef);
                    TextLine := CopyStr(TextLine, TempMatch.Index + TempMatch.Length + 1);
                end;
            until TempMatch.Next() = 0;

        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        RegEx.Match(TextLine, StrSubstNo(AFReportLinkTag, '.*?'), TempMatch);
        if TempMatch.FindSet() then
            repeat
                if TempMatch.Success then begin
                    ResultText += CopyStr(TextLine, 1, TempMatch.Index);
                    TextLine := CopyStr(TextLine, TempMatch.Index + TempMatch.Length + 1);
                end;
            until TempMatch.Next() = 0;
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
        TempMatch: Record Matches temporary;
        TempGroups: Record Groups temporary;
        TempGroup1: Record Groups temporary;
        TempGroup2: Record Groups temporary;
#endif
        Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
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
            TempBlob.CreateOutStream(OutStr);
            Convert.FromBase64(Group2.Value(), OutStr);
            TempBlob.CreateInStream(InStr);
            // TempMagentoPicture.Image.ImportStream(InStr, TempMagentoPicture.FieldName(Image));
            TempMagentoPicture.Picture.CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
            TempMagentoPicture.Insert();
        end;
#else
        RegEx.Match(DataUri, 'data\:image/(.*?);base64,(.*)', TempMatch);
        if TempMatch.FindSet() then
            repeat
                if TempMatch.Success then begin
                    TempGroups.Reset();
                    TempGroups.DeleteAll();
                    RegEx.Groups(TempMatch, TempGroups);
                    TempGroups.FindSet();
                    TempGroup1 := TempGroups;
                    TempGroups.Next();
                    TempGroup2 := TempGroups;
                    TempMagentoPicture.Init();
                    TempMagentoPicture.Type := "NPR Magento Picture Type".FromInteger(PictureType);
                    TempMagentoPicture.Name := PictureName;
                    TempMagentoPicture."Size (kb)" := Round(PictureSize / 1000, 1);
                    TempMagentoPicture."Mime Type" := TempGroup1.ReadValue();
                    TempBlob.CreateOutStream(OutStr);
                    Convert.FromBase64(TempGroup2.ReadValue(), OutStr);
                    TempBlob.CreateInStream(InStr);
                    // TempMagentoPicture.Image.ImportStream(InStr, TempMagentoPicture.FieldName(Image));
                    TempMagentoPicture.Picture.CreateOutStream(OutStr);
                    CopyStream(OutStr, InStr);
                    TempMagentoPicture.Insert();
                end;
            until TempMatch.Next() = 0;
#endif
    end;
}