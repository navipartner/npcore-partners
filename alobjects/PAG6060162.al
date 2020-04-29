page 6060162 "Event Attribute Col. Templates"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.38/TJ  /20171221 CASE Fixed ENU caption of the page

    Caption = 'Attribute Column Templates';
    PageType = List;
    SourceTable = "Event Attribute Col. Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
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
                RunObject = Page "Event Attribute Column Values";
                RunPageLink = "Template Name"=FIELD(Name);
            }
        }
    }
}

