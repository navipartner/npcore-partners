page 6184510 "EFT BIN Range SubPage"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.53/MMV /20191204 CASE 349520 Switched type to ListPart

    Caption = 'EFT BIN Ranges';
    PageType = ListPart;
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

