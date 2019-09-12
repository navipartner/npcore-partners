page 6151391 "CS Whse. Receipt Data"
{
    // NPR5.51/JAKUBV/20190903  CASE 356107 Transport NPR5.51 - 3 September 2019

    Caption = 'CS Whse. Receipt Data';
    Editable = false;
    PageType = List;
    SourceTable = "CS Whse. Receipt Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tag Id";"Tag Id")
                {
                }
                field("Item Group Code";"Item Group Code")
                {
                }
                field("Item Group Description";"Item Group Description")
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
                field("Tag Type";"Tag Type")
                {
                }
                field(Transferred;Transferred)
                {
                }
                field("Transferred By";"Transferred By")
                {
                }
                field("Transferred To Doc";"Transferred To Doc")
                {
                }
            }
        }
    }

    actions
    {
    }
}

