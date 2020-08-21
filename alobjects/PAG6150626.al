page 6150626 "POS Audit Profile"
{
    // NPR5.54/BHR /20200228 CASE 393305 Created Card Page

    Caption = 'POS Audit Profile';
    PageType = Card;
    SourceTable = "POS Audit Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Sale Fiscal No. Series"; "Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                }
                field("Credit Sale Fiscal No. Series"; "Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                }
                field("Balancing Fiscal No. Series"; "Balancing Fiscal No. Series")
                {
                    ApplicationArea = All;
                }
                field("Fill Sale Fiscal No. On"; "Fill Sale Fiscal No. On")
                {
                    ApplicationArea = All;
                }
                field("Audit Log Enabled"; "Audit Log Enabled")
                {
                    ApplicationArea = All;
                }
                field("Audit Handler"; "Audit Handler")
                {
                    ApplicationArea = All;
                }
                field("Allow Zero Amount Sales"; "Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                }
                field("Print Receipt On Sale Cancel"; "Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                }
                field("Allow Printing Receipt Copy"; "Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                }
                field("Do Not Print Receipt on Sale"; "Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No. Series"; "Sales Ticket No. Series")
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

