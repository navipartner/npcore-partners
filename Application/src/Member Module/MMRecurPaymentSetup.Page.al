page 6060077 "NPR MM Recur. Payment Setup"
{
    Extensible = False;
    Caption = 'Recurring Payment Setup';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR MM Recur. Paym. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the recurring payment.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Service Provider Code"; Rec."Payment Service Provider Code")
                {
                    ToolTip = 'Specifies the value of the Payment Service Provider Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PSP Recurring Plan ID"; Rec."PSP Recurring Plan ID")
                {
                    ToolTip = 'Specifies the value of the PSP Recurring Plan ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Period Alignment"; Rec."Period Alignment")
                {
                    ToolTip = 'Specifies the value of the Period Alignment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Period Size"; Rec."Period Size")
                {
                    ToolTip = 'Specifies the value of the Period Size field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscr. Auto-Renewal On"; Rec."Subscr. Auto-Renewal On")
                {
                    ToolTip = 'Specifies when the system should automatically renew subscriptions.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Attempt Offset (Days)"; Rec."First Attempt Offset (Days)")
                {
                    ToolTip = 'Specifies how many days before the auto-renewal date the system will first attempt to automatically renew the subscription. This helps to ensure continuity of service for subscribers.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Max. Process Error Retry Count"; Rec."Max. Pay. Process Try Count")
                {
                    BlankZero = true;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the maximum number of attempts the system will make to process the recurring payment.';
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; Rec."Gen. Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document No. Series"; Rec."Document No. Series")
                {
                    ToolTip = 'Specifies the value of the Document No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code the system uses to post subscription renewal related transactions to General Ledger.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Revenue Account"; Rec."Revenue Account")
                {
                    ToolTip = 'Specifies the value of the Revenue Account field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }
}
