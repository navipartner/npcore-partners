page 6151216 "NPR NpCs Open. Hour Set Card"
{
    Caption = 'Collect Store Opening Hour Set Card';
    PageType = Card;
    UsageCategory = Administration;
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
                ApplicationArea = All;
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
                ApplicationArea = All;

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

