codeunit 6014620 "NPR POS Cross Reference Mgt."
{
    Access = Internal;
    var
        NpRegEx: Codeunit "NPR RegEx";

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
        ReferenceNo := NpRegEx.RegExReplacePS(Pattern, 'StoreCode');
        ReferenceNo := NpRegEx.RegExReplacePU(ReferenceNo, 'PosUnit');
        ReferenceNo := NpRegEx.RegExReplaceS(ReferenceNo, 'SalesTicket');
        ReferenceNo := NpRegEx.RegExReplaceN(ReferenceNo);
        ReferenceNo := NpRegEx.RegExReplaceAN(ReferenceNo);

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
        Rec."Record Value" := CopyStr(RecordValue, 1, MaxStrLen(Rec."Record Value"));
        Rec."Reference No." := CopyStr(UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(Rec."Reference No."))), 1, MaxStrLen(Rec."Reference No."));
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
}

