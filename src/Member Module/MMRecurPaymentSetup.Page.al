page 6060077 "NPR MM Recur. Payment Setup"
{

    Caption = 'Recurring Payment Setup';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR MM Recur. Paym. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Payment Service Provider Code"; "Payment Service Provider Code")
                {
                    ApplicationArea = All;
                }
                field("PSP Recurring Plan ID"; "PSP Recurring Plan ID")
                {
                    ApplicationArea = All;
                }
                field("Period Alignment"; "Period Alignment")
                {
                    ApplicationArea = All;
                }
                field("Period Size"; "Period Size")
                {
                    ApplicationArea = All;
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; "Gen. Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Document No. Series"; "Document No. Series")
                {
                    ApplicationArea = All;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                }
                field("Revenue Account"; "Revenue Account")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

