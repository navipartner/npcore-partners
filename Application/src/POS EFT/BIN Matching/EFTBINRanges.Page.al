page 6184514 "NPR EFT BIN Ranges"
{
    // NPR5.53/MMV /20191204 349520 Created object

    Caption = 'EFT BIN Ranges';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR EFT BIN Range";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BIN from"; "BIN from")
                {
                    ApplicationArea = All;
                }
                field("BIN to"; "BIN to")
                {
                    ApplicationArea = All;
                }
                field("BIN Group Code"; "BIN Group Code")
                {
                    ApplicationArea = All;
                }
                field("BIN Group Priority"; "BIN Group Priority")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

