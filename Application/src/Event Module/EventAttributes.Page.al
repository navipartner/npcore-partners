page 6151583 "NPR Event Attributes"
{
    Caption = 'Event Attributes';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Template Name field';
                }
                field(Promote; Promote)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promote field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Attributes Matrix action';

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

