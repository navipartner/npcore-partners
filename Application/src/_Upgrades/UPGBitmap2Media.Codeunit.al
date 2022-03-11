codeunit 6014588 "NPR UPG Bitmap 2 Media"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        DataLogMgt: Codeunit "NPR Data Log Management";
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Bitmap 2 Media', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Bitmap 2 Media")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Bitmap 2 Media"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeAFArgsSpireBarcode();
        UpgradeMCSFaces();
        UpgradeMagentoPicture();
        UpgradeMPOSQRCode();
        UpgradeDisplayContentLines();
        UpgradeRetailLogo();
        UpgradeRPTemplateMediaInfo();
        UpgradeNpRvArchVoucher();
        UpgradeNpRvVoucher();
        UpgradeResponsibilityCenter();
    end;

    local procedure UpgradeAFArgsSpireBarcode()
    var
        MigrationRec: Record "NPR AF Args: Spire Barcode";
        MigrationRec2: Record "NPR AF Args: Spire Barcode";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Image);
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeMCSFaces()
    var
        MigrationRec: Record "NPR MCS Faces";
        MigrationRec2: Record "NPR MCS Faces";
        InStr: InStream;
        WithError: Boolean;
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
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeMagentoPicture()
    var
        MigrationRec: Record "NPR Magento Picture";
        MigrationRec2: Record "NPR Magento Picture";
        InStr: InStream;
        WithError: Boolean;
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
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeMPOSQRCode()
    var
        MigrationRec: Record "NPR MPOS QR Code";
        MigrationRec2: Record "NPR MPOS QR Code";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, "QR code");
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeDisplayContentLines()
    var
        MigrationRec: Record "NPR Display Content Lines";
        MigrationRec2: Record "NPR Display Content Lines";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Image);
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeRetailLogo()
    var
        MigrationRec: Record "NPR Retail Logo";
        MigrationRec2: Record "NPR Retail Logo";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Logo);
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeRPTemplateMediaInfo()
    var
        MigrationRec: Record "NPR RP Template Media Info";
        MigrationRec2: Record "NPR RP Template Media Info";
        InStr: InStream;
        WithError: Boolean;
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
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeNpRvArchVoucher()
    var
        MigrationRec: Record "NPR NpRv Arch. Voucher";
        MigrationRec2: Record "NPR NpRv Arch. Voucher";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Barcode);
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeNpRvVoucher()
    var
        MigrationRec: Record "NPR NpRv Voucher";
        MigrationRec2: Record "NPR NpRv Voucher";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, Barcode);
        if MigrationRec.FindSet() then
            repeat
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
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeResponsibilityCenter()
    var
        MigrationRec: Record "Responsibility Center";
        MigrationRec2: Record "Responsibility Center";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, "NPR Picture");
        if MigrationRec.FindSet() then
            repeat
                MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                if MigrationRec2."NPR Picture".HasValue() then begin
                    MigrationRec2.CalcFields("NPR Picture");
                    MigrationRec2."NPR Picture".CreateInStream(InStr);
                    WithError := IsNullGuid(MigrationRec2."NPR Image".ImportStream(InStr, MigrationRec2.FieldName("NPR Image")));
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                    Clear(InStr);
                end;
            until MigrationRec.Next() = 0;
    end;
}
