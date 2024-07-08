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

    actions
    {
    }
}

