page 6014507 "Used Goods Reg. List"
{
    // NPR5.29/BHR /20170401  CASE 246761 Add field Purchase date
    // NPR5.29/TS  /20170126  CASE 264644 Added Field Serial No.

    Caption = 'Used Item Registration Card List';
    CardPageID = "Used Goods Reg. Card";
    Editable = false;
    PageType = List;
    SourceTable = "Used Goods Registration";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field("Purchase Date";"Purchase Date")
                {
                }
                field(Subject;Subject)
                {
                }
                field("Unit Cost";"Unit Cost")
                {
                }
                field("Purchased By Customer No.";"Purchased By Customer No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Identification Number";"Identification Number")
                {
                }
                field("Subject Sold Date";"Subject Sold Date")
                {
                    Visible = false;
                }
                field("Item No. Created";"Item No. Created")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field(Serienummer;Serienummer)
                {
                }
            }
        }
    }

    actions
    {
    }
}

