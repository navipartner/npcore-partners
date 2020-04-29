page 6151209 "NpCs Store Card POS Relations"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store POS Relations';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpCs Store POS Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

