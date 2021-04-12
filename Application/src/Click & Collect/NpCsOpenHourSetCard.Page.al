page 6151216 "NPR NpCs Open. Hour Set Card"
{
    Caption = 'Collect Store Opening Hour Set Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Open. Hour Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                ToolTip = 'Executes the Opening Hour Calendar action';

                trigger OnAction()
                var
                    NpCsStoreOpeningHourMgt: Codeunit "NPR NpCs Store Open.Hours Mgt.";
                begin
                    NpCsStoreOpeningHourMgt.ShowOpeningHours(Rec.Code);
                end;
            }
        }
    }
}

