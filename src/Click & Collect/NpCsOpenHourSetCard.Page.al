page 6151216 "NPR NpCs Open. Hour Set Card"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Set Card';
    PageType = Card;
    SourceTable = "NPR NpCs Open. Hour Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
            part("Opening Hours"; "NPR NpCs Open.Hour Set S.page")
            {
                Caption = 'Opening Hours';
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea=All;
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    NpCsStoreOpeningHourMgt: Codeunit "NPR NpCs Store Open.Hours Mgt.";
                begin
                    NpCsStoreOpeningHourMgt.ShowOpeningHours(Code);
                end;
            }
        }
    }
}

