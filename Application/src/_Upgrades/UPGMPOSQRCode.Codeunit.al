codeunit 6059830 "NPR UPG MPOS QR Code"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        NPRUPGBitmap2Media: Codeunit "NPR UPG Bitmap 2 Media";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG MPOS QR Code', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS QR Code")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        //Move from Blob to Media before deletion
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Bitmap 2 Media")) then
            NPRUPGBitmap2Media.UpgradeMPOSQRCode();

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS QR Code"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeMPOSQRCode();
    end;

    local procedure UpgradeMPOSQRCode()
    var
        CheckNewMPOSQRCode: Record "NPR MPOS QR Codes";
        NewMPOSQRCode: Record "NPR MPOS QR Codes";
        OldMPOSQRCode: Record "NPR MPOS QR Code";
        TenantMedia: Record "Tenant Media";
        InStr: InStream;
    begin
        if not OldMPOSQRCode.FindSet() then
            exit;
        repeat
            CheckNewMPOSQRCode.Reset();
            CheckNewMPOSQRCode.SetRange(Company, OldMPOSQRCode.Company);
            CheckNewMPOSQRCode.SetRange("User ID", OldMPOSQRCode."User ID");
            if CheckNewMPOSQRCode.IsEmpty() then begin
                NewMPOSQRCode.Init();
                NewMPOSQRCode.TransferFields(OldMPOSQRCode);
                if TenantMedia.Get(OldMPOSQRCode."QR Image".MediaId) then begin
                    TenantMedia.CalcFields(Content);
                    TenantMedia.Content.CreateInStream(InStr);
                    NewMPOSQRCode."QR Image".ImportStream(InStr, NewMPOSQRCode.FieldName("QR Image"));
                end;
                NewMPOSQRCode.Insert();
            end;
        until OldMPOSQRCode.Next() = 0;

        OldMPOSQRCode.DeleteAll();
    end;

}
