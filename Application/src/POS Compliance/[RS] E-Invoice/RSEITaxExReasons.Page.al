page 6184585 "NPR RS EI Tax Ex. Reasons"
{
    Caption = 'RS E-Invoice Tax Exemption Reasons';
    UsageCategory = None;
    PageType = List;
    SourceTable = "NPR RS EI Tax Exemption Reason";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tax Category"; Rec."Tax Category")
                {
                    ToolTip = 'Specifies the value of the Tax Category field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Tax Exemption Reason Code"; Rec."Tax Exemption Reason Code")
                {
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Code field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Tax Exemption Reason Text"; Rec."Tax Exemption Reason Text")
                {
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Text field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Configuration Date"; Rec."Configuration Date")
                {
                    ToolTip = 'Specifies the value of the Configuration Date field.';
                    ApplicationArea = NPRRSEInvoice;
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
                Caption = 'Get Tax Exemption Reason List';
                Image = Administration;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this Action, the Tax Exemption Reason List will be pulled from the E-Invoice API.';
                ApplicationArea = NPRRSEInvoice;

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
}