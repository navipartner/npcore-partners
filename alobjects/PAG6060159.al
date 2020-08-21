page 6060159 "Event Attribute Row Templates"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

    Caption = 'Attribute Row Templates';
    PageType = List;
    SourceTable = "Event Attribute Row Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
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
        area(processing)
        {
            action(Values)
            {
                Caption = 'Values';
                Image = BulletList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Event Attribute Row Values";
                RunPageLink = "Template Name" = FIELD(Name);
            }
        }
    }
}

