page 6059906 "NPR RS Allowed Tax Rates List"
{
    Caption = 'RS Allowed Tax Rates List';
    ContextSensitiveHelpPage = 'docs/fiscalization/serbia/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR RS Allowed Tax Rates";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Valid From Date field.';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Valid From Time field.';
                }
                field("Group ID"; Rec."Group ID")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Group ID field.';
                }
                field("Tax Category Name"; Rec."Tax Category Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Tax Category Name field.';
                }
                field("Tax Category Type"; Rec."Tax Category Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Tax Category Type field.';
                }
                field("Tax Category Rate"; Rec."Tax Category Rate")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Tax Category Rate field.';
                }
                field("Tax Category Rate Label"; Rec."Tax Category Rate Label")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Tax Category Rate Label field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PullAllowedTaxRates)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'Get Allowed Tax Rates';
                Image = Administration;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this Action, the allowed Tax Rates will be pulled from the Tax Authority.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
                end;
            }
            action(VATPostingSetup)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'VAT Posting Setup';
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "VAT Posting Setup";
                ToolTip = 'Open VAT Posting Setup page';
            }
        }
    }
}
