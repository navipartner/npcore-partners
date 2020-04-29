page 6151062 "Distribution Setup"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Setup';
    PageType = List;
    SourceTable = "Distribution Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group";"Distribution Group")
                {
                }
                field("Item Hiearachy";"Item Hiearachy")
                {
                }
                field("Distribution Type";"Distribution Type")
                {
                    Visible = false;
                }
                field("Required Delivery Date";"Required Delivery Date")
                {
                }
                field("Replenishment Grace Period";"Replenishment Grace Period")
                {
                }
                field("Create SKU Per Location";"Create SKU Per Location")
                {
                }
                field("Default SKU Repl. Setup";"Default SKU Repl. Setup")
                {
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
            }
            action("Create Demands")
            {
                Caption = 'Create Demands';
                Image = CreateLinesFromJob;
                Promoted = true;

                trigger OnAction()
                var
                    ReplenishmentMgmt: Codeunit "Retail Replenishment Mgmt";
                begin
                    ReplenishmentMgmt.CreateDemandLines("Item Hiearachy","Distribution Group");
                    Message(TextCreated);
                end;
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = Line;
                Promoted = true;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy"=FIELD("Item Hiearachy"),
                              "Distribution Group"=FIELD("Distribution Group");
            }
        }
    }

    var
        TextCreated: Label 'Records Created!';
}

