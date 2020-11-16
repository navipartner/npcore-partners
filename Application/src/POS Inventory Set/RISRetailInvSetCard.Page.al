page 6151086 "NPR RIS Retail Inv. Set Card"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory Set Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR RIS Retail Inv. Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
            part(Control6014404; "NPR RIS Retail Inv. Set Sub.")
            {
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea = All;
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

