page 6151344 "NPR CRO Setup No. Series"
{
    Extensible = False;
    Caption = 'CRO Fiscal Bill No. Series Setup';
    PageType = CardPart;
    SourceTable = "NPR CRO Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(NoSeries)
            {
                Caption = 'No. Series Setup';
                ShowCaption = false;

                field("Bill No. Series"; Rec."Bill No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. Series for fiscal bill printing.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    internal procedure CopyRealToTemp()
    begin
        if not CROFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(CROFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CRONoSeriesToModify(): Boolean
    begin
        exit(Rec."Bill No. Series" <> '');
    end;

    internal procedure CreateNoSeriesSetupData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not CROFiscalizationSetup.FindFirst() then
            CROFiscalizationSetup.Init();
        CROFiscalizationSetup."Bill No. Series" := Rec."Bill No. Series";
        if not CROFiscalizationSetup.Insert() then
            CROFiscalizationSetup.Modify();
    end;

    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
}
