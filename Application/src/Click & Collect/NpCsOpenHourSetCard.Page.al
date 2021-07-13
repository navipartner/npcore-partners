page 6151216 "NPR NpCs Open. Hour Set Card"
{
    Caption = 'Collect Store Opening Hour Set Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpCs Open. Hour Set";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            part("Opening Hours"; "NPR NpCs Open.Hour Set S.page")
            {
                Caption = 'Opening Hours';
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Opening Hour Calendar action';
                ApplicationArea = NPRRetail;

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

