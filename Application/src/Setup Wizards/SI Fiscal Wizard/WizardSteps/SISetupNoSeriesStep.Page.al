page 6151570 "NPR SI Setup No. Series Step"
{
    Extensible = False;
    Caption = 'SI Fiscal Bill No. Series Setup';
    PageType = CardPart;
    SourceTable = "NPR SI Fiscalization Setup";
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

                field("Receipt No. Series"; Rec."Receipt No. Series")
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
        if not SIFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(SIFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure SINoSeriesToModify(): Boolean
    begin
        exit(Rec."Receipt No. Series" <> '');
    end;

    internal procedure CreateNoSeriesSetupData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not SIFiscalizationSetup.FindFirst() then
            SIFiscalizationSetup.Init();
        SIFiscalizationSetup."Receipt No. Series" := Rec."Receipt No. Series";
        if not SIFiscalizationSetup.Insert() then
            SIFiscalizationSetup.Modify();
    end;

    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
}