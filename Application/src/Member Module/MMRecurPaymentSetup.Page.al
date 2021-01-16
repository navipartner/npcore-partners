page 6060077 "NPR MM Recur. Payment Setup"
{

    Caption = 'Recurring Payment Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Payment Service Provider Code"; "Payment Service Provider Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Service Provider Code field';
                }
                field("PSP Recurring Plan ID"; "PSP Recurring Plan ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PSP Recurring Plan ID field';
                }
                field("Period Alignment"; "Period Alignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Alignment field';
                }
                field("Period Size"; "Period Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Size field';
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; "Gen. Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field';
                }
                field("Document No. Series"; "Document No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. Series field';
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Revenue Account"; "Revenue Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Revenue Account field';
                }
            }
        }
    }

    actions
    {
    }
}

