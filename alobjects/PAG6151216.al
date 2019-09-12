page 6151216 "NpCs Open. Hour Set Card"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Set Card';
    PageType = Card;
    SourceTable = "NpCs Open. Hour Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
            part("Opening Hours";"NpCs Open. Hour Set Subpage")
            {
                Caption = 'Opening Hours';
                SubPageLink = "Set Code"=FIELD(Code);
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

