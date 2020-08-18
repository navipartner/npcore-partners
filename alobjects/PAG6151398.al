page 6151398 "CS RFID Header List"
{
    // NPR5.55/CLVA  /20200506  CASE 379709 Object created - NP Capture Service

    Caption = 'CS Rfid Header List';
    DelayedInsert = false;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Rfid Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Document Item Quantity";"Document Item Quantity")
                {
                }
                field("Shipping Closed";"Shipping Closed")
                {
                }
                field("Shipping Closed By";"Shipping Closed By")
                {
                }
                field("Receiving Closed";"Receiving Closed")
                {
                }
                field("Receiving Closed By";"Receiving Closed By")
                {
                }
                field("From Company";"From Company")
                {
                }
                field("To Company";"To Company")
                {
                }
                field("Document Matched";"Document Matched")
                {
                }
            }
        }
    }

    actions
    {
    }
}

