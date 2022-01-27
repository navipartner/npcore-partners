page 6060077 "NPR MM Recur. Payment Setup"
{
    Extensible = False;

    Caption = 'Recurring Payment Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR MM Recur. Paym. Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Service Provider Code"; Rec."Payment Service Provider Code")
                {

                    ToolTip = 'Specifies the value of the Payment Service Provider Code field';
                    ApplicationArea = NPRRetail;
                }
                field("PSP Recurring Plan ID"; Rec."PSP Recurring Plan ID")
                {

                    ToolTip = 'Specifies the value of the PSP Recurring Plan ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Alignment"; Rec."Period Alignment")
                {

                    ToolTip = 'Specifies the value of the Period Alignment field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Size"; Rec."Period Size")
                {

                    ToolTip = 'Specifies the value of the Period Size field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; Rec."Gen. Journal Template Name")
                {

                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No. Series"; Rec."Document No. Series")
                {

                    ToolTip = 'Specifies the value of the Document No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {

                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Revenue Account"; Rec."Revenue Account")
                {

                    ToolTip = 'Specifies the value of the Revenue Account field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

