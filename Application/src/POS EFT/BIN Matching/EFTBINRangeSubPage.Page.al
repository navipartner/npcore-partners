page 6184510 "NPR EFT BIN Range SubPage"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.53/MMV /20191204 CASE 349520 Switched type to ListPart

    Caption = 'EFT BIN Ranges';
    PageType = ListPart;
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

