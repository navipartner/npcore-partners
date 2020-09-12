page 6060162 "NPR Event Attr. Col. Templates"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.38/TJ  /20171221 CASE Fixed ENU caption of the page

    Caption = 'Attribute Column Templates';
    PageType = List;
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
                RunObject = Page "NPR Event Attr. Column Values";
                RunPageLink = "Template Name" = FIELD(Name);
                ApplicationArea = All;
            }
        }
    }
}

