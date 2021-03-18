page 6151578 "NPR Event Exch. Int. Templates"
{
    Caption = 'Event Exch. Int. Templates';
    CardPageID = "NPR Event Exch.Int.Templ. Card";
    PageType = List;
    SourceTable = "NPR Event Exch. Int. Template";
    UsageCategory = Lists;
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
}

