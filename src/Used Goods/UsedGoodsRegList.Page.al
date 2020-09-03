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
                }
                field("Purchase Date"; "Purchase Date")
                {
                    ApplicationArea = All;
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Purchased By Customer No."; "Purchased By Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Identification Number"; "Identification Number")
                {
                    ApplicationArea = All;
                }
                field("Subject Sold Date"; "Subject Sold Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No. Created"; "Item No. Created")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field(Serienummer; Serienummer)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

