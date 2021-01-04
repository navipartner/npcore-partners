page 6014507 "NPR Used Goods Reg. List"
{
    // NPR5.29/BHR /20170401  CASE 246761 Add field Purchase date
    // NPR5.29/TS  /20170126  CASE 264644 Added Field Serial No.

    Caption = 'Used Item Registration Card List';
    CardPageID = "NPR Used Goods Reg. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Used Goods Registration";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Purchase Date"; "Purchase Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Date field';
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Purchased By Customer No."; "Purchased By Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Customer No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Identification Number"; "Identification Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Legitimation No. field';
                }
                field("Subject Sold Date"; "Subject Sold Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Subject Sold Date field';
                }
                field("Item No. Created"; "Item No. Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generated Item No. field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Serienummer; Serienummer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
            }
        }
    }

    actions
    {
    }
}

