page 6184731 "NPR RS EI Defaults Setup Step"
{
    Caption = 'Defaults Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS E-Invoice Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group("Defaults Setup")
            {
                Caption = 'Defaults Setup';
                ShowCaption = false;
                field("Default Unit Of Measure"; Rec."Default Unit Of Measure")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Unit Of Measure field.';
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
        if not RSEInvoiceSetup.Get() then
            exit;
        Rec.TransferFields(RSEInvoiceSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure RSEISetupDataToCreate(): Boolean
    begin
        exit(Rec."Default Unit Of Measure" <> '');
    end;

    internal procedure CreateRSEISetupData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSEInvoiceSetup.Get() then
            RSEInvoiceSetup.Init();

        RSEInvoiceSetup."Default Unit Of Measure" := Rec."Default Unit Of Measure";

        if not RSEInvoiceSetup.Insert() then
            RSEInvoiceSetup.Modify()
    end;

    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
}
