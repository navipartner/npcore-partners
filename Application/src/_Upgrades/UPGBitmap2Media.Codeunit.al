codeunit 6014588 "NPR UPG Bitmap 2 Media"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Bitmap 2 Media Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
    end;

    local procedure Upgrade()
    begin
        UpgradeAFArgsSpireBarcode();
        UpgradeMCSFaces();
        UpgradeMagentoPicture();
        UpgradeMMMember();
        UpgradeMMMemberInfoCapture();
        UpgradeMPOSQRCode();
        UpgradeDisplayContentLines();
        UpgradeRetailLogo();
        UpgradeRPTemplateMediaInfo();
        UpgradeNpRvArchVoucher();
        UpgradeNpRvVoucher();
    end;

    local procedure UpgradeAFArgsSpireBarcode()
    var
        Rec: Record "NPR AF Args: Spire Barcode";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Picture.HasValue()) and Rec.Image.HasValue() then begin
                Rec.CalcFields(Image);
                Rec.Image.CreateInStream(InStr);
                Rec.Picture.ImportStream(InStr, Rec.FieldName(Picture));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeMCSFaces()
    var
        Rec: Record "NPR MCS Faces";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Image.HasValue()) and Rec.Picture.HasValue() then begin
                Rec.CalcFields(Picture);
                Rec.Picture.CreateInStream(InStr);
                Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeMagentoPicture()
    var
        Rec: Record "NPR Magento Picture";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Image.HasValue()) and Rec.Picture.HasValue() then begin
                Rec.CalcFields(Picture);
                Rec.Picture.CreateInStream(InStr);
                Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeMMMember()
    var
        Rec: Record "NPR MM Member";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Image.HasValue()) and Rec.Picture.HasValue() then begin
                Rec.CalcFields(Picture);
                Rec.Picture.CreateInStream(InStr);
                Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeMMMemberInfoCapture()
    var
        Rec: Record "NPR MM Member Info Capture";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Image.HasValue()) and Rec.Picture.HasValue() then begin
                Rec.CalcFields(Picture);
                Rec.Picture.CreateInStream(InStr);
                Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
                Rec.Modify();
            end;
        until Rec.Next() = 0;
    end;

    local procedure UpgradeMPOSQRCode()
    var
        Rec: Record "NPR MPOS QR Code";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec."QR Image".HasValue()) and Rec."QR code".HasValue() then begin
                Rec.CalcFields("QR code");
                Rec."QR code".CreateInStream(InStr);
                Rec."QR Image".ImportStream(InStr, Rec.FieldName("QR Image"));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeDisplayContentLines()
    var
        Rec: Record "NPR Display Content Lines";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Picture.HasValue()) and Rec.Image.HasValue() then begin
                Rec.CalcFields(Image);
                Rec.Image.CreateInStream(InStr);
                Rec.Picture.ImportStream(InStr, Rec.FieldName(Picture));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeRetailLogo()
    var
        Rec: Record "NPR Retail Logo";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec."POS Logo".HasValue()) and Rec.Logo.HasValue() then begin
                Rec.CalcFields(Logo);
                Rec.Logo.CreateInStream(InStr);
                Rec."POS Logo".ImportStream(InStr, Rec.FieldName("POS Logo"));
                Rec.Modify();
            end;
        until Rec.Next() = 0
    end;

    local procedure UpgradeRPTemplateMediaInfo()
    var
        Rec: Record "NPR RP Template Media Info";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec.Image.HasValue()) and Rec.Picture.HasValue() then begin
                Rec.CalcFields(Picture);
                Rec.Picture.CreateInStream(InStr);
                Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
                Rec.Modify();
            end;
        until Rec.Next() = 0;
    end;

    local procedure UpgradeNpRvArchVoucher()
    var
        Rec: Record "NPR NpRv Arch. Voucher";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec."Barcode Image".HasValue()) and Rec.Barcode.HasValue() then begin
                Rec.CalcFields(Barcode);
                Rec.Barcode.CreateInStream(InStr);
                Rec."Barcode Image".ImportStream(InStr, Rec.FieldName("Barcode Image"));
                Rec.Modify();
            end;
        until Rec.Next() = 0;
    end;

    local procedure UpgradeNpRvVoucher()
    var
        Rec: Record "NPR NpRv Voucher";
        InStr: InStream;
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet(true);
        repeat
            if (not Rec."Barcode Image".HasValue()) and Rec.Barcode.HasValue() then begin
                Rec.CalcFields(Barcode);
                Rec.Barcode.CreateInStream(InStr);
                Rec."Barcode Image".ImportStream(InStr, Rec.FieldName("Barcode Image"));
                Rec.Modify();
            end;
        until Rec.Next() = 0;
    end;
}