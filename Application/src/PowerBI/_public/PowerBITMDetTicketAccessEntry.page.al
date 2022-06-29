page 6184623 NPRPowerBITMDetTicketAccess
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR TM Det. Ticket AccessEntry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Closed By Entry No."; Rec."Closed By Entry No.")
                {
                    ToolTip = 'Specifies the value of the Closed By Entry No. field';
                    ApplicationArea = All;
                }
                field("Created Datetime"; Rec."Created Datetime")
                {
                    ToolTip = 'Specifies the value of the Created Datetime field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field(Open; Rec.Open)
                {
                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = All;
                }
                field("Ticket Access Entry No."; Rec."Ticket Access Entry No.")
                {
                    ToolTip = 'Specifies the value of the Ticket Access Entry No. field';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = All;
                }
            }
        }
    }
}