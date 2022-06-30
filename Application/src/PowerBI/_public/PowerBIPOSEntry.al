page 6184617 NPRPowerBIPOSEntry
{
    PageType = List;
    Caption = 'PowerBI POS Entry';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR POS Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = All;
                }
                field("Event No."; Rec."Event No.")
                {
                    ToolTip = 'Specifies the value of the Active Event No. field.';
                    ApplicationArea = All;
                }
            }
        }
    }

}