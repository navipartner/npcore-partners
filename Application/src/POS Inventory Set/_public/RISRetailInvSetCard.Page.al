page 6151086 "NPR RIS Retail Inv. Set Card"
{
    UsageCategory = None;
    Caption = 'Retail Inventory Set Card';
    PageType = Card;
    SourceTable = "NPR RIS Retail Inv. Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Type"; Rec."Client Type")
                {
                    ToolTip = 'Specifies the value of the web service client type. NOTE: Switching type will reset API values on entries.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(InventorySetEntries; "NPR RIS Retail Inv. Set Sub.")
            {
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Test Retail Inventory action';
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
