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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Payment Service Provider Code"; Rec."Payment Service Provider Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Service Provider Code field';
                }
                field("PSP Recurring Plan ID"; Rec."PSP Recurring Plan ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PSP Recurring Plan ID field';
                }
                field("Period Alignment"; Rec."Period Alignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Alignment field';
                }
                field("Period Size"; Rec."Period Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Size field';
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; Rec."Gen. Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field';
                }
                field("Document No. Series"; Rec."Document No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. Series field';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Revenue Account"; Rec."Revenue Account")
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

