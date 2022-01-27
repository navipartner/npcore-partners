page 6151602 "NPR NpDc Coupon Setup"
{
    Extensible = False;
    Caption = 'Coupon Setup';
    PageType = Card;
    SourceTable = "NPR NpDc Coupon Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Coupon No. Series"; Rec."Coupon No. Series")
                {

                    ToolTip = 'Specifies the value of the Coupon No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Arch. Coupon No. Series"; Rec."Arch. Coupon No. Series")
                {

                    ToolTip = 'Specifies the value of the Posted Coupon No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No. Pattern"; Rec."Reference No. Pattern")
                {

                    ToolTip = 'Specifies the value of the Reference No. Pattern field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template Code"; Rec."Print Template Code")
                {

                    ToolTip = 'Specifies the value of the Print Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Print on Issue"; Rec."Print on Issue")
                {

                    ToolTip = 'Specifies the value of the Print on Issue field';
                    ApplicationArea = NPRRetail;
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

