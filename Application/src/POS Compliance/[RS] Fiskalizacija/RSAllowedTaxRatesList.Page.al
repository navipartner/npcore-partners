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
                    ToolTip = 'Specifies the date from which the given Tax Rates are valid.';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the time from which the given Tax Rates are valid.';
                }
                field("Group ID"; Rec."Group ID")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Group ID for the given Tax Rates.';
                }
                field("Tax Category Name"; Rec."Tax Category Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Tax Category Name related to the given Tax Rates.';
                }
                field("Tax Category Type"; Rec."Tax Category Type")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Tax Category Type of the related Tax Rates.';
                }
                field("Tax Category Rate"; Rec."Tax Category Rate")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Tax Rate of the related Tax Category.';
                }
                field("Tax Category Rate Label"; Rec."Tax Category Rate Label")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Label of the related Tax Rate Category.';
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
