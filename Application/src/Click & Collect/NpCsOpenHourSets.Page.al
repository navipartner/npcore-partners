page 6151215 "NPR NpCs Open. Hour Sets"
{
    Caption = 'Collect Store Opening Hour Sets';
    CardPageID = "NPR NpCs Open. Hour Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Open. Hour Set";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
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

