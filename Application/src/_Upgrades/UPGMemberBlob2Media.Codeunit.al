codeunit 6014678 "NPR UPG Member Blob 2 Media"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Member Blob 2 Media', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Member Blob 2 Media")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Member Blob 2 Media"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        //Blob to Media on Member table
        UpgradeMemberPictureBlobToImageMedia();
        //Blob to Media on Member Info Capture table
        UpgradeMemberInfoCapturePictureBlobToImageMedia();
    end;

    procedure LogError(Msg: Text)
    var
        ActiveSession: Record "Active Session";
        LogDict: Dictionary of [Text, Text];
        EventIdTok: Label 'NPR000_UPGERROR', Locked = true;
    begin
        Clear(LogDict);

        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName);

        Session.LogMessage(EventIdTok, Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;

    procedure UpgradeMemberPictureBlobToImageMedia()
    var
        MigrationRec2: Record "NPR MM Member";
        MigrationRec: Record "NPR MM Member";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Picture);
        if MigrationRec.FindSet() then
            repeat
                MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                if MigrationRec2.Picture.HasValue() then begin
                    MigrationRec2.CalcFields(Picture);
                    MigrationRec2.Picture.CreateInStream(InStr);
                    WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                    Clear(InStr);
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeMemberInfoCapturePictureBlobToImageMedia()
    var
        MigrationRec2: Record "NPR MM Member Info Capture";
        MigrationRec: Record "NPR MM Member Info Capture";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Picture);
        if MigrationRec.FindSet() then
            repeat
                MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                if MigrationRec2.Picture.HasValue() then begin
                    MigrationRec2.CalcFields(Picture);
                    MigrationRec2.Picture.CreateInStream(InStr);
                    WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                    Clear(InStr);
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                end;
            until MigrationRec.Next() = 0;
    end;
}