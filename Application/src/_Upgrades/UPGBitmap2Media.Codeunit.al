codeunit 6014588 "NPR UPG Bitmap 2 Media"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR UPG Bitmap 2 Media Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Bitmap 2 Media', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeAFArgsSpireBarcode();
        UpgradeMCSFaces();
        UpgradeMagentoPicture();
        UpgradeMMMember();
        UpgradeMPOSQRCode();
        UpgradeDisplayContentLines();
        UpgradeRetailLogo();
        UpgradeRPTemplateMediaInfo();
        UpgradeNpRvArchVoucher();
        UpgradeNpRvVoucher();
    end;

    procedure LogError(Msg: Text)
    var
        EventIdTok: Label 'NPR000_UPGERROR', Locked = true;
        ActiveSession: Record "Active Session";
        LogDict: Dictionary of [Text, Text];
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

    procedure UpgradeAFArgsSpireBarcode()
    var
        MigrationRec: Record "NPR AF Args: Spire Barcode";
        MigrationRec2: Record "NPR AF Args: Spire Barcode";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR AF Args: Spire Barcode", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Image.HasValue() then begin
                        MigrationRec2.CalcFields(Image);
                        MigrationRec2.Image.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Picture.ImportStream(InStr, MigrationRec2.FieldName(Picture)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeMCSFaces()
    var
        MigrationRec: Record "NPR MCS Faces";
        MigrationRec2: Record "NPR MCS Faces";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR MCS Faces", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Picture.HasValue() then begin
                        MigrationRec2.CalcFields(Picture);
                        MigrationRec2.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeMagentoPicture()
    var
        MigrationRec: Record "NPR Magento Picture";
        MigrationRec2: Record "NPR Magento Picture";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR Magento Picture", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Picture.HasValue() then begin
                        MigrationRec2.CalcFields(Picture);
                        MigrationRec2.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeMMMember()
    var
        MigrationRec: Record "NPR MM Member";
        MigrationRec2: Record "NPR MM Member";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR MM Member", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Picture.HasValue() then begin
                        MigrationRec2.CalcFields(Picture);
                        MigrationRec2.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeMPOSQRCode()
    var
        MigrationRec: Record "NPR MPOS QR Code";
        MigrationRec2: Record "NPR MPOS QR Code";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR MPOS QR Code", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2."QR code".HasValue() then begin
                        MigrationRec2.CalcFields("QR code");
                        MigrationRec2."QR code".CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2."QR Image".ImportStream(InStr, MigrationRec2.FieldName("QR Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeDisplayContentLines()
    var
        MigrationRec: Record "NPR Display Content Lines";
        MigrationRec2: Record "NPR Display Content Lines";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR Display Content Lines", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Image.HasValue() then begin
                        MigrationRec2.CalcFields(Image);
                        MigrationRec2.Image.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Picture.ImportStream(InStr, MigrationRec2.FieldName(Picture)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeRetailLogo()
    var
        MigrationRec: Record "NPR Retail Logo";
        MigrationRec2: Record "NPR Retail Logo";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR Retail Logo", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Logo.HasValue() then begin
                        MigrationRec2.CalcFields(Logo);
                        MigrationRec2.Logo.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2."POS Logo".ImportStream(InStr, MigrationRec2.FieldName("POS Logo")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeRPTemplateMediaInfo()
    var
        MigrationRec: Record "NPR RP Template Media Info";
        MigrationRec2: Record "NPR RP Template Media Info";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR RP Template Media Info", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Picture.HasValue() then begin
                        MigrationRec2.CalcFields(Picture);
                        MigrationRec2.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2.Image.ImportStream(InStr, MigrationRec2.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeNpRvArchVoucher()
    var
        MigrationRec: Record "NPR NpRv Arch. Voucher";
        MigrationRec2: Record "NPR NpRv Arch. Voucher";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR NpRv Arch. Voucher", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Barcode.HasValue() then begin
                        MigrationRec2.CalcFields(Barcode);
                        MigrationRec2.Barcode.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2."Barcode Image".ImportStream(InStr, MigrationRec2.FieldName("Barcode Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;

    procedure UpgradeNpRvVoucher()
    var
        MigrationRec: Record "NPR NpRv Voucher";
        MigrationRec2: Record "NPR NpRv Voucher";
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, SystemModifiedAt);
        if MigrationRec.FindSet() then
            repeat
                if not BlobToMediaMigration.Get(Database::"NPR NpRv Voucher", MigrationRec.SystemId) then
                    Clear(BlobToMediaMigration);

                if BlobToMediaMigration.SystemModifiedAt < MigrationRec.SystemModifiedAt then begin
                    MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                    if MigrationRec2.Barcode.HasValue() then begin
                        MigrationRec2.CalcFields(Barcode);
                        MigrationRec2.Barcode.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec2."Barcode Image".ImportStream(InStr, MigrationRec2.FieldName("Barcode Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec2.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end else
                            LogError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));

                        Clear(InStr);
                    end;
                end;
            until MigrationRec.Next() = 0;
    end;
}