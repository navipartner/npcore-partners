page 6150632 "POS Audit Profiles"
{
    // NPR5.48/MMV /20181026 CASE 318028 Created object
    // NPR5.50/MMV /20190503 CASE 353807 Added "Allow Zero Amount Sales".
    // NPR5.51/MMV /20190617 CASE 356076 Added field 80
    // NPR5.51/ALPO/20190802 CASE 362747 Added field 90 "Allow Printing Receipt Copy"
    // NPR5.52/ALPO/20191004 CASE 370427 Added field 100 "Do Not Print Receipt on Sale": option to skip receipt printing on sale
    // NPR5.53/ALPO/20191022 CASE 373743 Added field 110 "Sales Ticket No. Series": moved from "Cash Register" (Table 6014401)

    Caption = 'POS Audit Profiles';
    PageType = List;
    SourceTable = "POS Audit Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Sales Ticket No. Series";"Sales Ticket No. Series")
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
                field("Do Not Print Receipt on Sale";"Do Not Print Receipt on Sale")
                {
                }
                field("Allow Printing Receipt Copy";"Allow Printing Receipt Copy")
                {
                }
            }
        }
    }

    actions
    {
    }
}

