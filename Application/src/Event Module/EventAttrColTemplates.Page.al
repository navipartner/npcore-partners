page 6060162 "NPR Event Attr. Col. Templates"
{
    Caption = 'Attribute Column Templates';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Attr. Col. Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Values action';
            }
        }
    }
}

