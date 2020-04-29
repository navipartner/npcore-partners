page 6151387 "CS Stock-Takes Data List"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.51/CLVA/20190902  CASE 365659 Added captions

    Caption = 'CS Stock-Takes Data List';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Stock-Takes Data";
    SourceTableView = SORTING(Created);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
            }
        }
    }

    actions
    {
    }
}

