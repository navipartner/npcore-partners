page 6184514 "NPR EFT BIN Ranges"
{
    // NPR5.53/MMV /20191204 349520 Created object

    Caption = 'EFT BIN Ranges';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the BIN from field';
                }
                field("BIN to"; "BIN to")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BIN to field';
                }
                field("BIN Group Code"; "BIN Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BIN Group Code field';
                }
                field("BIN Group Priority"; "BIN Group Priority")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the BIN Group Priority field';
                }
            }
        }
    }

    actions
    {
    }
}

