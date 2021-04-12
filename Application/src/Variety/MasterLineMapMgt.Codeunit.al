codeunit 6014472 "NPR Master Line Map Mgt."
{
    procedure FilterRecRefOnMasterId(var RR: RecordRef; var SrcRR: RecordRef; WithoutMaster: Boolean)
    var
        MasterLineMap: Record "NPR Master Line Map";
        FR: FieldRef;
    begin
        if RR.Number() <> SrcRR.Number() then
            exit;

        if RR.IsTemporary() or SrcRR.IsTemporary() then
            exit;

        FR := SrcRR.Field(SrcRR.SystemIdNo());

        MasterLineMap.Reset();
        MasterLineMap.SetCurrentKey("Master Id", Ordinal);
        MasterLineMap.SetRange("Table Id", RR.Number());
        MasterLineMap.SetRange("Master Id", FR.Value);
        if WithoutMaster then
            MasterLineMap.SetRange("Is Master", false);
        if MasterLineMap.FindSet() then
            repeat
                if RR.GetBySystemId(MasterLineMap."Table Record Id") then
                    RR.Mark(true);
            until MasterLineMap.Next() = 0;

        RR.MarkedOnly(true);
    end;

    procedure CreateMap(TableId: Integer; TableRecordId: Guid; MasterId: Guid)
    var
        MasterLineMap: Record "NPR Master Line Map";
    begin
        MasterLineMap.Init();
        MasterLineMap."Table Id" := TableId;
        MasterLineMap."Table Record Id" := TableRecordId;
        MasterLineMap."Master Id" := MasterId;
        MasterLineMap."Is Master" := (TableRecordId = MasterId);
        MasterLineMap.Ordinal := NextOrdinal(TableId, MasterId);
        MasterLineMap.Insert();
    end;

    procedure IsMaster(TableId: Integer; TableRecordId: Guid): Boolean
    var
        MasterLineMap: Record "NPR Master Line Map";
    begin
        if not MasterLineMap.Get(TableId, TableRecordId) then
            exit(false);

        exit(MasterLineMap."Is Master");
    end;

    procedure TransferOwnershipToNextInLine(TableId: Integer; TableRecordId: Guid)
    var
        OldMasterLineMap: Record "NPR Master Line Map";
        MasterLineMap: Record "NPR Master Line Map";
    begin
        if not OldMasterLineMap.Get(TableId, TableRecordId) then
            exit;

        if not OldMasterLineMap."Is Master" then
            exit;

        OldMasterLineMap.Delete();

        MasterLineMap.Reset();
        MasterLineMap.SetCurrentKey("Master Id", Ordinal);
        MasterLineMap.SetRange("Table Id", TableId);
        MasterLineMap.SetRange("Master Id", OldMasterLineMap."Master Id");
        MasterLineMap.SetRange("Is Master", false);
        if MasterLineMap.IsEmpty() then
            exit;

        MasterLineMap.FindFirst();
        MasterLineMap."Is Master" := true;
        MasterLineMap.Modify();
    end;

    procedure GetLastInLineSystemId(TableId: Integer; MasterId: Guid): Guid
    var
        MasterLineMap: Record "NPR Master Line Map";
        LastInLine: Guid;
    begin
        Clear(LastInLine);

        MasterLineMap.Reset();
        MasterLineMap.SetCurrentKey("Master Id", Ordinal);
        MasterLineMap.SetRange("Table Id", TableId);
        MasterLineMap.SetRange("Master Id", MasterId);
        if MasterLineMap.FindLast() then
            LastInLine := MasterLineMap."Table Record Id";

        exit(LastInLine);
    end;

    local procedure NextOrdinal(TableId: Integer; MasterId: Guid): Integer
    var
        MasterLineMap: Record "NPR Master Line Map";
        Ord: Integer;
    begin
        Ord := 0;

        MasterLineMap.Reset();
        MasterLineMap.SetCurrentKey("Master Id", Ordinal);
        MasterLineMap.SetRange("Table Id", TableId);
        MasterLineMap.SetRange("Master Id", MasterId);
        if MasterLineMap.FindLast() then
            Ord := MasterLineMap.Ordinal;

        exit(Ord + 1);
    end;
}