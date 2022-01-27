page 6184851 "NPR FR Audit No. Series"
{
    Extensible = False;
    Caption = 'FR Audit No. Series';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR FR Audit No. Series";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reprint No. Series"; Rec."Reprint No. Series")
                {

                    ToolTip = 'Specifies the value of the Reprint No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("JET No. Series"; Rec."JET No. Series")
                {

                    ToolTip = 'Specifies the value of the JET No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Period No. Series"; Rec."Period No. Series")
                {

                    ToolTip = 'Specifies the value of the Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Grand Period No. Series"; Rec."Grand Period No. Series")
                {

                    ToolTip = 'Specifies the value of the Grand Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Yearly Period No. Series"; Rec."Yearly Period No. Series")
                {

                    ToolTip = 'Specifies the value of the Yearly Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
