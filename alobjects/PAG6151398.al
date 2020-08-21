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
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Document Item Quantity"; "Document Item Quantity")
                {
                    ApplicationArea = All;
                }
                field("Shipping Closed"; "Shipping Closed")
                {
                    ApplicationArea = All;
                }
                field("Shipping Closed By"; "Shipping Closed By")
                {
                    ApplicationArea = All;
                }
                field("Receiving Closed"; "Receiving Closed")
                {
                    ApplicationArea = All;
                }
                field("Receiving Closed By"; "Receiving Closed By")
                {
                    ApplicationArea = All;
                }
                field("From Company"; "From Company")
                {
                    ApplicationArea = All;
                }
                field("To Company"; "To Company")
                {
                    ApplicationArea = All;
                }
                field("Document Matched"; "Document Matched")
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

