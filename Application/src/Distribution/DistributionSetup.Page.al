page 6151062 "NPR Distribution Setup"
{
    Extensible = False;
    Caption = 'Distribution Setup';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Distribution Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; Rec."Distribution Group")
                {

                    ToolTip = 'Specifies the value of the Distribution Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Hiearachy"; Rec."Item Hiearachy")
                {

                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Type"; Rec."Distribution Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Distribution Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Required Delivery Date"; Rec."Required Delivery Date")
                {

                    ToolTip = 'Specifies the value of the Required Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Replenishment Grace Period"; Rec."Replenishment Grace Period")
                {

                    ToolTip = 'Specifies the value of the Replenishment Grace Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Create SKU Per Location"; Rec."Create SKU Per Location")
                {

                    ToolTip = 'Specifies the value of the Create SKU Per Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Default SKU Repl. Setup"; Rec."Default SKU Repl. Setup")
                {

                    ToolTip = 'Specifies the value of the Default SKU Repl. Setup field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create SKUs")
            {
                Caption = 'Create SKUs';
                Image = SKU;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Create SKUs action';
                ApplicationArea = NPRRetail;
            }
            action("Create Demands")
            {
                Caption = 'Create Demands';
                Image = CreateLinesFromJob;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Create Demands action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ReplenishmentMgmt: Codeunit "NPR Retail Replenish. Mgt.";
                begin
                    ReplenishmentMgmt.CreateDemandLines(Rec."Item Hiearachy", Rec."Distribution Group");
                    Message(TextCreated);
                end;
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Item Hiearachy"),
                              "Distribution Group" = FIELD("Distribution Group");

                ToolTip = 'Executes the Demand Lines action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        TextCreated: Label 'Records Created!';
}
