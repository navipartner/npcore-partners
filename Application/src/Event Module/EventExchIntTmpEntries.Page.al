page 6151579 "NPR Event Exch.Int.Tmp.Entries"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object

    Caption = 'Event Exch. Int. Temp. Entries';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Exch.Int.Temp.Entry";

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
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
            }
        }
    }

    actions
    {
    }
}

