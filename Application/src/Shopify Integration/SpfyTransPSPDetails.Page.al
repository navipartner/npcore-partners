#if not BC17
page 6185091 "NPR Spfy Trans. PSP Details"
{
    Extensible = false;
    Caption = 'Shopify Transaction PSP Details';
    PageType = List;
    SourceTable = "NPR Spfy Trans. PSP Details";
    Editable = false;
    UsageCategory = Tasks;
    ApplicationArea = NPRShopify;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the entry no. of the Shopify transaction to be synced.';
                }
                field("Transaction PSP"; Rec."Transaction PSP")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Payment Service Provider name of the transaction.';
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the NP Pay merchant account of Shopify transaction.';
                }
                field("Merchant Reference"; Rec."Merchant Reference")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the merchant reference of the transaction.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the payment method of the transaction.';
                }
                field("Card Summary"; Rec."Card Summary")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the card summary.';
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the card expiry date.';
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the PSP reference of the transaction.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the amount of the transaction.';
                }
                field("Card Added Brand"; Rec."Card Added Brand")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the card added brand.';
                }
                field("Card Function"; Rec."Card Function")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the card function.';
                }
                field("Merchant Order Reference"; Rec."Merchant Order Reference")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the merchant order reference of the transaction.';
                }
            }
        }
    }
}
#endif