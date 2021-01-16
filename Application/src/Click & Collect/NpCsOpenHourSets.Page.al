page 6151215 "NPR NpCs Open. Hour Sets"
{
    Caption = 'Collect Store Opening Hour Sets';
    CardPageID = "NPR NpCs Open. Hour Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Open. Hour Set";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Opening Hour Calendar action';

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

