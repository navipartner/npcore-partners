page 6184709 "NPR Pay By Link Setup Card"
{
    UsageCategory = None;
    Caption = 'Pay By Link Setup';
    PageType = Card;
    SourceTable = "NPR Pay By Link Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    AdditionalSearchTerms = 'pay by link setup';
    ObsoleteState = Pending;
    ObsoleteTag = '2024-09-13';
    ObsoleteReason = 'Page marked for removal. Reason: All the fields from page are transfered to "NPR Adyen Setup" page in ''Pay By Link'' section.';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Payment Gateaway Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = NPRRetail;
                    LookupPageID = "NPR Magento Payment Gateways";
                }
                field("Enable Pay by Link"; Rec."Enable Pay by Link")
                {
                    ToolTip = 'Specifies if the Pay by Link is enabled';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Template"; Rec."E-Mail Template")
                {
                    Caption = 'E-Mail Template';
                    ToolTip = 'Specifies the value of the E-Mail Template';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Template"; Rec."SMS Template")
                {
                    Caption = 'SMS Template';
                    ToolTip = 'Specifies the value of the SMS Template';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {
                    Caption = 'Account Type';
                    ToolTip = 'Specifies the value of the Account Type';
                    ApplicationArea = NPRRetail;
                }
                field("Account No."; Rec."Account No.")
                {
                    Caption = 'Account No.';
                    ToolTip = 'Specifies the value of the Account No.';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Automatic Posting"; Rec."Enable Automatic Posting")
                {
                    Caption = 'Enable Automatic Posting';
                    ToolTip = 'Specifies if Automating Posting and Capturing is enabled for Posted Documents.';
                    ApplicationArea = NPRRetail;
                }
                field("Pay by Link Exp. Duration"; Rec."Pay by Link Exp. Duration")
                {
                    Caption = 'Pay by Link Expiration';
                    ToolTip = 'Specifies the value of the Pay by Link Expiration';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Retry Count"; Rec."Posting Retry Count")
                {
                    Caption = 'Posting Retry Count';
                    ToolTip = 'Specifies the number of times the system will attempt to post the lines if the initial posting fails.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}