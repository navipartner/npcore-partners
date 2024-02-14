page 6151394 "NPR RS Fisc. Bill Mailing Step"
{
    Caption = 'RS Fiscal Bill Mailing';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS Fiscalisation Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(FiscalBillEMailing)
            {
                Caption = 'Fiscal Bill E-Mailing';
                field("Report Mail Selection"; Rec."Report E-Mail Selection")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Report E-Mail Selection field.';
                }
                field("E-Mail Subject"; Rec."E-Mail Subject")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the E-Mail Subject field.';
                }
            }
        }
    }

    procedure CopyRealToTemp()
    begin
        if not RSFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(RSFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    procedure CreateRSFiscalBillMailingData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSFiscalizationSetup.Get() then
            RSFiscalizationSetup.Init();
        if Rec."E-Mail Subject" <> xRec."E-Mail Subject" then
            RSFiscalizationSetup."E-Mail Subject" := Rec."E-Mail Subject";
        if Rec."Report E-Mail Selection" <> xRec."Report E-Mail Selection" then
            RSFiscalizationSetup."Report E-Mail Selection" := Rec."Report E-Mail Selection";
        if not RSFiscalizationSetup.Insert() then
            RSFiscalizationSetup.Modify();
    end;

    internal procedure RSFiscalBillMailingToModify(): Boolean
    begin
        exit(Rec."E-Mail Subject" <> '');
    end;

    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
}