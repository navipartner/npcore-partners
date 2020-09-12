page 6060159 "NPR Event Attr. Row Templ."
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

    Caption = 'Attribute Row Templates';
    PageType = List;
    SourceTable = "NPR Event Att. Row Templ.";

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
                RunObject = Page "NPR Event Attr. Row Values";
                RunPageLink = "Template Name" = FIELD(Name);
                ApplicationArea = All;
            }
        }
    }
}

