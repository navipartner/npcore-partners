page 6151085 "NPR RIS Retail Inv. Sets"
{
    Caption = 'Retail Inventory Sets';
    ContextSensitiveHelpPage = 'docs/retail/replication/how-to/inventory_sets/';
    CardPageID = "NPR RIS Retail Inv. Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR RIS Retail Inv. Set";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the retail inventory set';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the retail inventory set';
                    ApplicationArea = NPRRetail;
                }
                field("Client Type"; Rec."Client Type")
                {
                    ToolTip = 'Specifies the web service client type of the retail inventory set';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Test Retail Inventory")
            {
                Caption = 'Test Retail Inventory';
                Image = Intercompany;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Perform a test for the retail inventory. If clicked, a page which contains the retail items is displayed.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
                begin
                    RetailInventorySetMgt.TestProcessInventorySet(Rec);
                end;
            }
        }
    }
}
