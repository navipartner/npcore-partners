codeunit 6014620 "NPR POS Cross Reference Mgt."
{
    trigger OnRun()
    begin
        TestReferenceRegEx();
    end;

    local procedure TestReferenceRegEx()
    var
        Pattern: Text;
        ReferenceNo: Text;
        Starttime: DateTime;
        Duration: Duration;
    begin
        Starttime := CurrentDateTime;

        Pattern := '[PS]||[PU]||[S]||[N*4]||[AN*4]||[PS]||[PU]||[S]||[N*4]||[AN*4]';
        ReferenceNo := RegExReplacePS(Pattern, 'StoreCode');
        ReferenceNo := RegExReplacePU(ReferenceNo, 'PosUnit');
        ReferenceNo := RegExReplaceS(ReferenceNo, 'SalesTicket');
        ReferenceNo := RegExReplaceN(ReferenceNo);
        ReferenceNo := RegExReplaceAN(ReferenceNo);

        Duration := CurrentDateTime - Starttime;
        Message('Duration: %1\Pattern: %2\Reference: %3', Duration, Pattern, ReferenceNo);
    end;

    procedure InitReference(SysID: Guid; ReferenceNo: Text; TableName: Text[250]; RecordValue: Text)
    var
        Rec: Record "NPR POS Cross Reference";
    begin
        if ReferenceNo = '' then
            exit;
        if Rec.GetBySystemId(SysID) then
            exit;

        Rec.Init();
        Rec.SystemId := SysID;
        Rec."Table Name" := TableName;
        Rec."Record Value" := RecordValue;
        Rec."Reference No." := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(Rec."Reference No.")));
        Rec.Insert(true, true);
    end;

    procedure UpdateReference(SysID: Guid; TableName: Text[250]; RecordValue: Text)
    var
        Rec: Record "NPR POS Cross Reference";
        PrevRec: Text;
    begin
        if IsNullGuid(SysID) then
            exit;
        if not Rec.GetBySystemId(SysID) then
            exit;

        PrevRec := Format(Rec);

        Rec."Table Name" := TableName;
        Rec."Record Value" := CopyStr(RecordValue, 1, MaxStrLen(Rec."Record Value"));

        if PrevRec <> Format(Rec) then
            Rec.Modify(true);
    end;

    procedure RemoveReference(SysID: Guid; TableName: Text[250])
    var
        Rec: Record "NPR POS Cross Reference";
    begin
        if IsNullGuid(SysID) then
            exit;
        if not Rec.GetBySystemId(SysID) then
            exit;

        if Rec."Table Name" = TableName then
            Rec.Delete(true);
    end;

    procedure GetSysID(TableName: Text[250]; ReferenceNo: Text) SysID: Guid
    var
        Rec: Record "NPR POS Cross Reference";
    begin
        if ReferenceNo = '' then
            exit;

        if StrLen(ReferenceNo) > MaxStrLen(Rec."Reference No.") then
            exit;

        Rec.SetCurrentKey("Reference No.", "Table Name");
        Rec.SetRange("Reference No.", ReferenceNo);
        Rec.SetRange("Table Name", TableName);
        if not Rec.FindFirst() then
            exit;

        SysID := Rec.SystemId;
    end;

    #region Generate Reference No
    procedure RegExReplace(Input: Text; PosStoreCode: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PS\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosStoreCode);
    end;

    procedure RegExReplacePS(Input: Text; PosStoreCode: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PS\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosStoreCode);
    end;

    procedure RegExReplacePU(Input: Text; PosUnitNo: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PU\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosUnitNo);
    end;

    procedure RegExReplaceS(Input: Text; SerialNo: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, SerialNo);
    end;

    procedure RegExReplaceAN(Input: Text) Output: Text
    var
        Match: Codeunit DotNet_Match;
        RegEx: Codeunit DotNet_Regex;
        GroupCollection: Codeunit DotNet_GroupCollection;
        DotNetGroup: Codeunit DotNet_Group;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx.Regex(Pattern);
        RegEx.Match(Input, Match);
        while Match.Success() do begin
            ReplaceString := '';
            RandomQty := 1;
            Match.Groups(GroupCollection);
            GroupCollection.ItemGroupName('RandomQty', DotNetGroup);
            if Evaluate(RandomQty, Format(DotNetGroup.Value())) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(GenerateRandomChar());
            Input := RegEx.Replace(Input, ReplaceString, 1);

            RegEx.Match(Input, Match);
        end;

        Output := Input;
    end;

    procedure RegExReplaceN(Input: Text) Output: Text
    var
        Match: Codeunit DotNet_Match;
        RegEx: Codeunit DotNet_Regex;
        GroupCollection: Codeunit DotNet_GroupCollection;
        DotNetGroup: Codeunit DotNet_Group;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[N\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx.Regex(Pattern);
        RegEx.Match(Input, Match);
        while Match.Success() do begin
            ReplaceString := '';
            RandomQty := 1;
            Match.Groups(GroupCollection);
            GroupCollection.ItemGroupName('RandomQty', DotNetGroup);
            if Evaluate(RandomQty, Format(DotNetGroup.Value())) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(Random(9));
            Input := RegEx.Replace(Input, ReplaceString, 1);

            RegEx.Match(Input, Match);
        end;

        Output := Input;
    end;

    procedure RegExReplaceL(Input: Text; LineNo: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[L\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, LineNo);
    end;

    procedure RegExReplaceNL(Input: Text; NaturalLineNo: Text) Output: Text
    var
        RegEx: Codeunit DotNet_Regex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[NL\])';
        RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, NaturalLineNo);
    end;

    local procedure GenerateRandomChar() RandomChar: Char
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
    end;

    #endregion
}

