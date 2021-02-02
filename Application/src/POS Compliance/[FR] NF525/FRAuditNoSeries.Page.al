page 6184851 "NPR FR Audit No. Series"
{
    Caption = 'FR Audit No. Series';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR FR Audit No. Series";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Reprint No. Series"; Rec."Reprint No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reprint No. Series field';
                }
                field("JET No. Series"; Rec."JET No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the JET No. Series field';
                }
                field("Period No. Series"; Rec."Period No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period No. Series field';
                }
                field("Grand Period No. Series"; Rec."Grand Period No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Grand Period No. Series field';
                }
                field("Yearly Period No. Series"; Rec."Yearly Period No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Yearly Period No. Series field';
                }
            }
        }
    }
}