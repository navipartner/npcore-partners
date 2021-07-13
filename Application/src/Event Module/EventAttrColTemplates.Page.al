page 6060162 "NPR Event Attr. Col. Templates"
{
    Caption = 'Attribute Column Templates';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Attr. Col. Template";
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
                RunObject = Page "NPR Event Attr. Column Values";
                RunPageLink = "Template Name" = FIELD(Name);

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

