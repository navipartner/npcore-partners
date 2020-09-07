page 6151583 "NPR Event Attributes"
{
    // NPR5.33/TJ  /20170628 277972 New object created

    Caption = 'Event Attributes';
    PageType = List;
    SourceTable = "NPR Event Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Name"; "Template Name")
                {
                    ApplicationArea = All;
                }
                field(Promote; Promote)
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
            action("Attributes Matrix")
            {
                Caption = 'Attributes Matrix';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetJob("Job No.");
                    EventAttributeMatrix.SetAttrTemplate("Template Name");
                    EventAttributeMatrix.Run;
                end;
            }
        }
    }
}

