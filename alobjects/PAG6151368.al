page 6151368 "CS RFID Lines Subpage"
{
    // NPR5.55/CLVA  /20200506  CASE 379709 Object created - NP Capture Service

    Caption = 'RFID Tags';
    Editable = false;
    PageType = List;
    SourceTable = "CS Rfid Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tag Id";"Tag Id")
                {
                }
                field(Match;Match)
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Item Description";"Item Description")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Variant Description";"Variant Description")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Item Group Code";"Item Group Code")
                {
                }
                field("Item Group Description";"Item Group Description")
                {
                }
                field("Transferred to Whse. Receipt";"Transferred to Whse. Receipt")
                {
                }
                field("Tag Shipped";"Tag Shipped")
                {
                }
                field("Tag Received";"Tag Received")
                {
                }
            }
        }
    }

    actions
    {
    }
}

