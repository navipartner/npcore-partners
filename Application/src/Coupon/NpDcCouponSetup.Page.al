page 6151602 "NPR NpDc Coupon Setup"
{
    Caption = 'Coupon Setup';
    PageType = Card;
    SourceTable = "NPR NpDc Coupon Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Coupon No. Series"; Rec."Coupon No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon No. Series field';
                }
                field("Arch. Coupon No. Series"; Rec."Arch. Coupon No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted Coupon No. Series field';
                }
                field("Reference No. Pattern"; Rec."Reference No. Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. Pattern field';
                }
                field("Print Template Code"; Rec."Print Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Template Code field';
                }
                field("Print on Issue"; Rec."Print on Issue")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print on Issue field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}

