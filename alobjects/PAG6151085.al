page 6151085 "RIS Retail Inventory Sets"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory Sets';
    CardPageID = "RIS Retail Inventory Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "RIS Retail Inventory Set";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
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

                trigger OnAction()
                var
                    RetailInventorySetMgt: Codeunit "RIS Retail Inventory Set Mgt.";
                begin
                    RetailInventorySetMgt.TestProcessInventorySet(Rec);
                end;
            }
        }
    }
}

