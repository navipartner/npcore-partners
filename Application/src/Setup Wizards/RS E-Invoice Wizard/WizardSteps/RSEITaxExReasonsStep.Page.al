page 6184728 "NPR RS EI Tax Ex. Reasons Step"
{
    Caption = 'Tax Exemption Reasons Setup';
    PageType = ListPart;
    SourceTable = "NPR RS EI Tax Exemption Reason";
    UsageCategory = None;
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tax Category"; Rec."Tax Category")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Tax Category field.';
                }
                field("Tax Exemption Reason Code"; Rec."Tax Exemption Reason Code")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Code field.';
                }
                field("Tax Exemption Reason Text"; Rec."Tax Exemption Reason Text")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Text field.';
                }
                field("Configuration Date"; Rec."Configuration Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Configuration Date field.';
                }
            }
        }
    }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    actions
    {
        area(Processing)
        {
            action(GetTaxExemptionList)
            {
                ApplicationArea = NPRRSEInvoice;
                Caption = 'Get Tax Exemption Reason List';
                Image = Administration;
                ToolTip = 'Executing this Action, the Tax Exemption Reason List will be pulled from the E-Invoice API.';
                trigger OnAction()
                var
                    RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                begin
                    RSEICommunicationMgt.GetTaxExemptionReasonList();
                end;
            }
        }
    }
#endif

    internal procedure CopyRealToTemp()
    begin
        if RSEITaxExemptionReason.IsEmpty() then
            exit;
        RSEITaxExemptionReason.FindSet();
        repeat
            Rec.TransferFields(RSEITaxExemptionReason);
            if not Rec.Insert() then
                Rec.Modify();
        until RSEITaxExemptionReason.Next() = 0;
    end;

    internal procedure RSEITaxExemptionReasonSetupMappingDataToCreate(): Boolean
    begin
        exit(Rec.FindFirst());
    end;

    internal procedure CreateRSEITaxExemptionReasonMappingData()
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet();
        repeat
            RSEITaxExemptionReason.TransferFields(Rec);
            if not RSEITaxExemptionReason.Insert() then
                RSEITaxExemptionReason.Modify();
        until Rec.Next() = 0;
    end;

    var
        RSEITaxExemptionReason: Record "NPR RS EI Tax Exemption Reason";
}