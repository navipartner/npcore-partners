page 6151215 "NPR NpCs Open. Hour Sets"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Sets';
    CardPageID = "NPR NpCs Open. Hour Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Open. Hour Set";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
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

