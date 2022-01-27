page 6060159 "NPR Event Attr. Row Templ."
{
    Extensible = False;
    Caption = 'Attribute Row Templates';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Att. Row Templ.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
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
        area(processing)
        {
            action(Values)
            {
                Caption = 'Values';
                Image = BulletList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Event Attr. Row Values";
                RunPageLink = "Template Name" = FIELD(Name);

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

