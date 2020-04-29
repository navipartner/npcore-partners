page 6151583 "Event Attributes"
{
    // NPR5.33/TJ  /20170628 277972 New object created

    Caption = 'Event Attributes';
    PageType = List;
    SourceTable = "Event Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Name";"Template Name")
                {
                }
                field(Promote;Promote)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Attributes Matrix")
            {
                Caption = 'Attributes Matrix';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetJob("Job No.");
                    EventAttributeMatrix.SetAttrTemplate("Template Name");
                    EventAttributeMatrix.Run;
                end;
            }
        }
    }
}

