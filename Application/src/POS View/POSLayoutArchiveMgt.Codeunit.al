codeunit 6060009 "NPR POS Layout Archive Mgt."
{
    Access = Internal;

    procedure CreateArchivedVersion(POSLayout: Record "NPR POS Layout")
    var
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        InitializeArchivedVersion(POSLayoutArchive, POSLayout);
        FinishArchivedVersion(POSLayoutArchive, POSLayout);
    end;

    local procedure InitializeArchivedVersion(var POSLayoutArchive: Record "NPR POS Layout Archive"; POSLayout: Record "NPR POS Layout")
    begin
        Clear(POSLayoutArchive);
        POSLayoutArchive.TransferFields(POSLayout);
        Initialized := true;
    end;

    local procedure FinishArchivedVersion(var POSLayoutArchive: Record "NPR POS Layout Archive"; POSLayout: Record "NPR POS Layout")
    var
        RecordLinkManagement: Codeunit "Record Link Management";
        NotInitializedErr: Label 'You must initialize archived POS layout version first.';
    begin
        if not Initialized then
            Error(NotInitializedErr);

        POSLayoutArchive."Version No." := GetNextVersionNo(POSLayoutArchive.Code);
        POSLayoutArchive.Insert(true);
        RecordLinkManagement.CopyLinks(POSLayout, POSLayoutArchive);

        Initialized := false;
    end;

    local procedure GetNextVersionNo(POSLayoutCode: Code[20]): Integer
    var
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        POSLayoutArchive.LockTable();
        POSLayoutArchive.SetRange(Code, POSLayoutCode);
        if POSLayoutArchive.FindLast() then
            exit(POSLayoutArchive."Version No." + 1);
        exit(1);
    end;

    procedure RestoreArchivedVersion(POSLayoutArchive: Record "NPR POS Layout Archive")
    var
        POSLayout: Record "NPR POS Layout";
        ConfirmManagement: Codeunit "Confirm Management";
        Confirmed: Boolean;
        ConfirmRestoreLbl: Label 'Are you sure you want to restore archived version %1 of POS layout %2?', Comment = '%1 - version number, %2 - layout code';
        DoneLbl: Label 'Archived version %1 of POS layout %2 has been successfully restored.', Comment = '%1 - version number, %2 - layout code';
    begin
        Confirmed := not POSLayout.Get(POSLayoutArchive.Code);
        if not Confirmed then
            Confirmed := ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmRestoreLbl, POSLayoutArchive."Version No.", POSLayoutArchive.Code), true);
        if not Confirmed then
            exit;
        RestoreArchivedVersionSilent(POSLayoutArchive);
        Message(DoneLbl, POSLayoutArchive."Version No.", POSLayoutArchive.Code);
    end;

    procedure RestoreArchivedVersionSilent(POSLayoutArchive: Record "NPR POS Layout Archive")
    var
        POSLayout: Record "NPR POS Layout";
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        if POSLayoutArchive."Frontend Properties".HasValue() then
            POSLayoutArchive.CalcFields("Frontend Properties");
        POSLayout.Code := POSLayoutArchive.Code;
        if not POSLayout.find() then
            POSLayout.Insert();
        POSLayout.Init();
        POSLayout.TransferFields(POSLayoutArchive);
        POSLayout.Modify(true);

        RecordLink.SetFilter(Company, '%1|%2', '', CompanyName());
        RecordLink.SetCurrentKey("Record ID");
        RecordLink.SetRange("Record ID", POSLayout.RecordId());
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll();
        RecordLinkManagement.CopyLinks(POSLayoutArchive, POSLayout);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Layout", 'OnBeforeModifyEvent', '', false, false)]
    local procedure BackupCurrentVersionOfPOSLayoutBeforeModify(var Rec: Record "NPR POS Layout"; var xRec: Record "NPR POS Layout")
    var
        LayoutChanged: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        if not xRec.Find() then
            exit;

        LayoutChanged := Format(xRec) <> Format(Rec);
        if not LayoutChanged then
            LayoutChanged := xRec.GetLayot(true) <> Rec.GetLayot(false);
        if not LayoutChanged then
            exit;
        CreateArchivedVersion(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Layout", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BackupCurrentVersionOfPOSLayoutBeforeDelete(var Rec: Record "NPR POS Layout")
    begin
        CreateArchivedVersion(Rec);
    end;

    var
        Initialized: Boolean;
}