page 6184514 "EFT BIN Ranges"
{
    // NPR5.53/MMV /20191204 349520 Created object

    Caption = 'EFT BIN Ranges';
    PageType = List;
    SourceTable = "EFT BIN Range";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BIN from";"BIN from")
                {
                }
                field("BIN to";"BIN to")
                {
                }
                field("BIN Group Code";"BIN Group Code")
                {
                }
                field("BIN Group Priority";"BIN Group Priority")
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

