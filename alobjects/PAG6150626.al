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
                field("Code";Code)
                {
                }
                field("Sale Fiscal No. Series";"Sale Fiscal No. Series")
                {
                }
                field("Credit Sale Fiscal No. Series";"Credit Sale Fiscal No. Series")
                {
                }
                field("Balancing Fiscal No. Series";"Balancing Fiscal No. Series")
                {
                }
                field("Fill Sale Fiscal No. On";"Fill Sale Fiscal No. On")
                {
                }
                field("Audit Log Enabled";"Audit Log Enabled")
                {
                }
                field("Audit Handler";"Audit Handler")
                {
                }
                field("Allow Zero Amount Sales";"Allow Zero Amount Sales")
                {
                }
                field("Print Receipt On Sale Cancel";"Print Receipt On Sale Cancel")
                {
                }
                field("Allow Printing Receipt Copy";"Allow Printing Receipt Copy")
                {
                }
                field("Do Not Print Receipt on Sale";"Do Not Print Receipt on Sale")
                {
                }
                field("Sales Ticket No. Series";"Sales Ticket No. Series")
                {
                }
            }
        }
    }

    actions
    {
    }
}

