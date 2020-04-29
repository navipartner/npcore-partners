page 6151086 "RIS Retail Inventory Set Card"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory Set Card';
    PageType = Card;
    SourceTable = "RIS Retail Inventory Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
            part(Control6014404;"RIS Retail Inventory Set Sub.")
            {
                SubPageLink = "Set Code"=FIELD(Code);
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

