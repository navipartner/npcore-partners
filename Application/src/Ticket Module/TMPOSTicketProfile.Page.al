page 6184639 "NPR TM POS Ticket Profile"
{
    Extensible = false;
    Caption = 'POS Ticket Profile';
    PageType = Card;
    SourceTable = "NPR TM POS Ticket Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
            group(Print)
            {
                field("Print Ticket On Sale"; Rec."Print Ticket On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a ticket is going to be printed after the end of the pos sale.';
                }
            }
        }
    }
}