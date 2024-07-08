page 6184640 "NPR TM POS Ticket Profiles"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'POS Ticket Profiles';
    UsageCategory = Administration;
    PageType = List;
    Editable = false;
    SourceTable = "NPR TM POS Ticket Profile";
    CardPageID = "NPR TM POS Ticket Profile";


    layout
    {
        area(content)
        {
            repeater(General)
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
                field("Print Ticket On Sale"; Rec."Print Ticket On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a ticket is going to be printed after the end of the pos sale.';
                }
            }
        }
    }
}