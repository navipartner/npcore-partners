page 6151369 "CS Stock-Takes Data"
{
    // NPR5.50/CLVA/20190515 CASE 350696 Object created - NP Capture Service
    // NPR5.51/CLVA/20190902 CASE 365659 Added captions
    // NPR5.52/CLVA/20190917 CASE 368484 Added field Area

    Caption = 'CS Stock-Takes Data';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Stock-Takes Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Stock-Take Id";"Stock-Take Id")
                {
                }
                field("Worksheet Name";"Worksheet Name")
                {
                }
                field("Tag Id";"Tag Id")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Item Group Code";"Item Group Code")
                {
                }
                field("Item Description";"Item Description")
                {
                }
                field("Variant Description";"Variant Description")
                {
                }
                field("Item Group Description";"Item Group Description")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field(Approved;Approved)
                {
                }
                field("Approved By";"Approved By")
                {
                }
                field("Transferred To Worksheet";"Transferred To Worksheet")
                {
                }
                field("Combined key";"Combined key")
                {
                }
                field("Stock-Take Config Code";"Stock-Take Config Code")
                {
                }
                field("Area";Area)
                {
                }
            }
        }
    }

    actions
    {
    }
}

