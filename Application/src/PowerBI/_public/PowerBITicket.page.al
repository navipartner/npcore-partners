page 6184621 NPRPowerBITicket
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR TM Ticket";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = All;
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                    ApplicationArea = All;
                }
            }
        }
    }
}