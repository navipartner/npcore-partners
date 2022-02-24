page 6184510 "NPR EFT BIN Range SubPage"
{
    Extensible = False;
    Caption = 'EFT BIN Ranges';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR EFT BIN Range";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BIN from"; Rec."BIN from")
                {

                    ToolTip = 'Specifies the value of the BIN from field';
                    ApplicationArea = NPRRetail;
                }
                field("BIN to"; Rec."BIN to")
                {

                    ToolTip = 'Specifies the value of the BIN to field';
                    ApplicationArea = NPRRetail;
                }
                field("BIN Group Code"; Rec."BIN Group Code")
                {

                    ToolTip = 'Specifies the value of the BIN Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field("BIN Group Priority"; Rec."BIN Group Priority")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the BIN Group Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

