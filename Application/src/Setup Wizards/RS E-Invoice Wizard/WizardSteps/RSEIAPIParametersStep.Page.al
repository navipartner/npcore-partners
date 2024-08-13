page 6184732 "NPR RS EI API Parameters Step"
{
    Caption = 'Setup API Parameters';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS E-Invoice Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group("API Parameters")
            {
                Caption = 'API Parameters';
                ShowCaption = false;
                field("API URL"; Rec."API URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the API URL field.';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the API Key field.';
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
        exit((Rec."API URL" <> '') and (Rec."API Key" <> ''));
    end;

    internal procedure CreateRSEISetupData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSEInvoiceSetup.Get() then
            RSEInvoiceSetup.Init();
        RSEInvoiceSetup."API URL" := Rec."API URL";
        RSEInvoiceSetup."API Key" := Rec."API Key";

        if not RSEInvoiceSetup.Insert() then
            RSEInvoiceSetup.Modify()
    end;

    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
}
