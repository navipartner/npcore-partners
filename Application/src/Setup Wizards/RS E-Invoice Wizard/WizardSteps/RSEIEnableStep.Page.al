page 6184730 "NPR RS EI Enable Step"
{
    Caption = 'Enable RS E-Invoicing';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS E-Invoice Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable RS E-Invoicing';
                ShowCaption = false;
                field("Enable RS E-Invoice"; Rec."Enable RS E-Invoice")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS E-Invoice field.';
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
        exit(Rec."Enable RS E-Invoice");
    end;

    internal procedure CreateRSEISetupData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSEInvoiceSetup.Get() then
            RSEInvoiceSetup.Init();
        RSEInvoiceSetup."Enable RS E-Invoice" := Rec."Enable RS E-Invoice";
        if not RSEInvoiceSetup.Insert() then
            RSEInvoiceSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable RS E-Invoice" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
}