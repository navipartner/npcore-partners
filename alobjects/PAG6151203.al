page 6151203 "NpCs Document Mapping"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpCs Document Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("From Store Code";"From Store Code")
                {
                }
                field("From No.";"From No.")
                {
                }
                field("From Description";"From Description")
                {
                }
                field("From Description 2";"From Description 2")
                {
                }
                field("To No.";"To No.")
                {
                }
                field("To Description";"To Description")
                {
                }
                field("To Description 2";"To Description 2")
                {
                }
            }
        }
    }

    actions
    {
    }
}

