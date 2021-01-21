page 6151062 "NPR Distribution Setup"
{
    Caption = 'Distribution Setup';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Distribution Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Group field';
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Distribution Type field';
                }
                field("Required Delivery Date"; "Required Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required Delivery Date field';
                }
                field("Replenishment Grace Period"; "Replenishment Grace Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replenishment Grace Period field';
                }
                field("Create SKU Per Location"; "Create SKU Per Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create SKU Per Location field';
                }
                field("Default SKU Repl. Setup"; "Default SKU Repl. Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default SKU Repl. Setup field';
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
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create SKUs action';
            }
            action("Create Demands")
            {
                Caption = 'Create Demands';
                Image = CreateLinesFromJob;
                Promoted = true;
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Demands action';

                trigger OnAction()
                var
                    ReplenishmentMgmt: Codeunit "NPR Retail Replenish. Mgt.";
                begin
                    ReplenishmentMgmt.CreateDemandLines("Item Hiearachy", "Distribution Group");
                    Message(TextCreated);
                end;
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = Line;
                Promoted = true;
				PromotedOnly = true;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Item Hiearachy"),
                              "Distribution Group" = FIELD("Distribution Group");
                ApplicationArea = All;
                ToolTip = 'Executes the Demand Lines action';
            }
        }
    }

    var
        TextCreated: Label 'Records Created!';
}
