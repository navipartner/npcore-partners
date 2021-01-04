page 6151085 "NPR RIS Retail Inv. Sets"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory Sets';
    CardPageID = "NPR RIS Retail Inv. Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR RIS Retail Inv. Set";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Retail Inventory action';

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

