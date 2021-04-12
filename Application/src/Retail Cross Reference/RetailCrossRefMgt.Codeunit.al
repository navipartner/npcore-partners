codeunit 6151180 "NPR Retail Cross Ref. Mgt."
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

    [IntegrationEvent(false, false)]
    procedure DiscoverRetailCrossReferenceSetup(var RetailCrossReferenceSetup: Record "NPR Retail Cross Ref. Setup")
    begin
    end;

    procedure InitRetailReference(RetailID: Guid; ReferenceNo: Text; TableID: Integer; RecordValue: Text)
    var
        RetailCrossReference: Record "NPR Retail Cross Reference";
    begin
        if RetailCrossReference.Get(RetailID) then
            exit;
        if ReferenceNo = '' then
            exit;

        RetailCrossReference.Init();
        RetailCrossReference."Retail ID" := RetailID;
        RetailCrossReference."Table ID" := TableID;
        RetailCrossReference."Record Value" := RecordValue;
        RetailCrossReference."Reference No." := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(RetailCrossReference."Reference No.")));
        RetailCrossReference.Insert(true);
    end;

    procedure UpdateTableReference(RetailID: Guid; TableID: Integer; RecordValue: Text)
    var
        RetailCrossReference: Record "NPR Retail Cross Reference";
        PrevRec: Text;
    begin
        if IsNullGuid(RetailID) then
            exit;
        if not RetailCrossReference.Get(RetailID) then
            exit;

        PrevRec := Format(RetailCrossReference);

        RetailCrossReference."Table ID" := TableID;
        RetailCrossReference."Record Value" := CopyStr(RecordValue, 1, MaxStrLen(RetailCrossReference."Record Value"));

        if PrevRec <> Format(RetailCrossReference) then
            RetailCrossReference.Modify(true);
    end;

    procedure RemoveRetailReference(RetailID: Guid; TableID: Integer)
    var
        RetailCrossReference: Record "NPR Retail Cross Reference";
    begin
        if IsNullGuid(RetailID) then
            exit;

        if not RetailCrossReference.Get(RetailID) then
            exit;

        if RetailCrossReference."Table ID" = TableID then
            RetailCrossReference.Delete(true);
    end;

    procedure GetRetailID(TableID: Integer; ReferenceNo: Text) RetailID: Guid
    var
        RetailCrossReference: Record "NPR Retail Cross Reference";
    begin
        if ReferenceNo = '' then
            exit;

        if StrLen(ReferenceNo) > MaxStrLen(RetailCrossReference."Reference No.") then
            exit;

        RetailCrossReference.SetCurrentKey("Reference No.", "Table ID");
        RetailCrossReference.SetRange("Reference No.", ReferenceNo);
        RetailCrossReference.SetRange("Table ID", TableID);
        if not RetailCrossReference.FindFirst() then
            exit;

        RetailID := RetailCrossReference."Retail ID";
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
        while Match.Success do begin
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
        while Match.Success do begin
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

