page 6151062 "NPR Distribution Setup"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Setup';
    PageType = List;
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
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Required Delivery Date"; "Required Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Replenishment Grace Period"; "Replenishment Grace Period")
                {
                    ApplicationArea = All;
                }
                field("Create SKU Per Location"; "Create SKU Per Location")
                {
                    ApplicationArea = All;
                }
                field("Default SKU Repl. Setup"; "Default SKU Repl. Setup")
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
            action("Create SKUs")
            {
                Caption = 'Create SKUs';
                Image = SKU;
                Promoted = true;
                ApplicationArea=All;
            }
            action("Create Demands")
            {
                Caption = 'Create Demands';
                Image = CreateLinesFromJob;
                Promoted = true;
                ApplicationArea=All;

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
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Item Hiearachy"),
                              "Distribution Group" = FIELD("Distribution Group");
                ApplicationArea=All;
            }
        }
    }

    var
        TextCreated: Label 'Records Created!';
}

