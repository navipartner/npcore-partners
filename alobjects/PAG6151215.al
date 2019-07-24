page 6151215 "NpCs Open. Hour Sets"
{
    // #362443/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Sets';
    CardPageID = "NpCs Open. Hour Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpCs Open. Hour Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Opening Hour Calendar")
            {
                Caption = 'Opening Hour Calendar';
                Image = Calendar;
                ShortCutKey = 'Ctrl+F7';

                trigger OnAction()
                var
                    NpCsStoreOpeningHourMgt: Codeunit "NpCs Store Opening Hours Mgt.";
                begin
                    NpCsStoreOpeningHourMgt.ShowOpeningHours(Code);
                end;
            }
        }
    }
}

