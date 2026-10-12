codeunit 6060009 "NPR POS Layout Archive Mgt."
{
    Access = Internal;

    procedure CreateArchivedVersion(POSLayout: Record "NPR POS Layout")
    var
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        // Callers hand over rows read without the blob, and TransferFields would archive it empty.
        if POSLayout."Frontend Properties".HasValue() then
            POSLayout.CalcFields("Frontend Properties");
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
    local procedure BackupCurrentVersionOfPOSLayoutBeforeModify(var Rec: Record "NPR POS Layout")
    var
        CurrentPOSLayout: Record "NPR POS Layout";
        LayoutChanged: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        // The version to archive is the row still on disk. xRec is shared with every subscriber after us and is not ours to
        // replace: for a code-driven Modify the platform hands subscribers an xRec that already carries the values being
        // written.
        CurrentPOSLayout.ReadIsolation := IsolationLevel::ReadCommitted;
        if not CurrentPOSLayout.Get(Rec.Code) then
            exit;

        LayoutChanged := Format(CurrentPOSLayout) <> Format(Rec);
        if not LayoutChanged then
            LayoutChanged := CurrentPOSLayout.GetLayout(true) <> Rec.GetLayout(false);
        if not LayoutChanged then
            exit;
        CreateArchivedVersion(CurrentPOSLayout);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Layout", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BackupCurrentVersionOfPOSLayoutBeforeDelete(var Rec: Record "NPR POS Layout")
    begin
        CreateArchivedVersion(Rec);
    end;

    var
        Initialized: Boolean;
}