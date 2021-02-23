page 6184514 "NPR EFT BIN Ranges"
{
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
                field("BIN from"; Rec."BIN from")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BIN from field';
                }
                field("BIN to"; Rec."BIN to")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BIN to field';
                }
                field("BIN Group Code"; Rec."BIN Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BIN Group Code field';
                }
                field("BIN Group Priority"; Rec."BIN Group Priority")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the BIN Group Priority field';
                }
            }
        }
    }
}

