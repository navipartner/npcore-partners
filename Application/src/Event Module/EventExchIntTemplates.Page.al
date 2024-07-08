page 6151578 "NPR Event Exch. Int. Templates"
{
    Extensible = False;
    Caption = 'Event Exch. Int. Templates';
    CardPageID = "NPR Event Exch.Int.Templ. Card";
    PageType = List;
    SourceTable = "NPR Event Exch. Int. Template";
    UsageCategory = Lists;
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
}

