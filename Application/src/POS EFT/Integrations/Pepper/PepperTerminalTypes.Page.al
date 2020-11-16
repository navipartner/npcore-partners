page 6184495 "NPR Pepper Terminal Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Terminal Types';
    CardPageID = "NPR Pepper Terminal Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field(Deprecated; Deprecated)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

