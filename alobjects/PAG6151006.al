page 6151006 "POS Entry Related Sales Doc."
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object

    Caption = 'POS Entry Related Sales Documents';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "POS Entry Sales Doc. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Document Type";"Sales Document Type")
                {
                }
                field("Sales Document No";"Sales Document No")
                {
                }
            }
        }
    }

    actions
    {
    }
}

