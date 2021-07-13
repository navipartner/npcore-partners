page 6151579 "NPR Event Exch.Int.Tmp.Entries"
{
    Caption = 'Event Exch. Int. Temp. Entries';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Exch.Int.Temp.Entry";
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
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

