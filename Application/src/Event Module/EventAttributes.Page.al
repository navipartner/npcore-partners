page 6151583 "NPR Event Attributes"
{
    Caption = 'Event Attributes';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Attribute";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Name"; Rec."Template Name")
                {

                    ToolTip = 'Specifies the value of the Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Promote; Rec.Promote)
                {

                    ToolTip = 'Specifies the value of the Promote field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Attributes Matrix action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetJob(Rec."Job No.");
                    EventAttributeMatrix.SetAttrTemplate(Rec."Template Name");
                    EventAttributeMatrix.Run();
                end;
            }
        }
    }
}

