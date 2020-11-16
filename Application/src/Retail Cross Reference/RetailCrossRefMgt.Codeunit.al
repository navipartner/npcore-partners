codeunit 6151180 "NPR Retail Cross Ref. Mgt."
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales


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

    local procedure "--- Init"()
    begin
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

        RetailCrossReference.Init;
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

    local procedure "--- Cleanup"()
    begin
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

    local procedure "--- Find"()
    begin
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
        if not RetailCrossReference.FindFirst then
            exit;

        exit(RetailCrossReference."Retail ID");
    end;

    local procedure "--- Generate Reference No"()
    begin
    end;

    procedure RegExReplace(Input: Text; PosStoreCode: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PS\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosStoreCode);
        exit(Output);
    end;

    procedure RegExReplacePS(Input: Text; PosStoreCode: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PS\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosStoreCode);
        exit(Output);
    end;

    procedure RegExReplacePU(Input: Text; PosUnitNo: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[PU\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, PosUnitNo);
        exit(Output);
    end;

    procedure RegExReplaceS(Input: Text; SerialNo: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, SerialNo);
        exit(Output);
    end;

    procedure RegExReplaceAN(Input: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx := RegEx.Regex(Pattern);

        Match := RegEx.Match(Input);
        while Match.Success do begin
            ReplaceString := '';
            RandomQty := 1;
            if Evaluate(RandomQty, Format(Match.Groups.Item('RandomQty'))) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(GenerateRandomChar());
            Input := RegEx.Replace(Input, ReplaceString, 1);

            Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    procedure RegExReplaceN(Input: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[N\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx := RegEx.Regex(Pattern);

        Match := RegEx.Match(Input);
        while Match.Success do begin
            ReplaceString := '';
            RandomQty := 1;
            if Evaluate(RandomQty, Format(Match.Groups.Item('RandomQty'))) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(Random(9));
            Input := RegEx.Replace(Input, ReplaceString, 1);

            Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    procedure RegExReplaceL(Input: Text; LineNo: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[L\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, LineNo);
        exit(Output);
    end;

    procedure RegExReplaceNL(Input: Text; NaturalLineNo: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[NL\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, NaturalLineNo);
        exit(Output);
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
        exit(RandomChar);
    end;
}

