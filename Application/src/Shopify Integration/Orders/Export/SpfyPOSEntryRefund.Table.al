table 6060027 "NPR Spfy POS Entry Refund"
{
    Access = Internal;
    Caption = 'Shopify POS Entry Refund';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Store Code"; Code[20]) { Caption = 'Shopify Store Code'; DataClassification = CustomerContent; TableRelation = "NPR Spfy Store".Code; }
        field(2; "POS Entry No."; Integer) { Caption = 'POS Entry No.'; DataClassification = CustomerContent; TableRelation = "NPR POS Entry"."Entry No."; }
        field(3; "Shopify Order ID"; Text[30]) { Caption = 'Shopify Order ID'; DataClassification = CustomerContent; }
        field(10; "Shopify Refund ID"; Text[30]) { Caption = 'Shopify Refund ID'; DataClassification = CustomerContent; }
        field(20; "Refunded Amount"; Decimal) { Caption = 'Refunded Amount'; DataClassification = CustomerContent; }
        field(21; "Currency Code"; Code[10]) { Caption = 'Currency Code'; DataClassification = CustomerContent; }
        field(30; "Created At"; DateTime) { Caption = 'Created At'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Shopify Store Code", "POS Entry No.", "Shopify Order ID") { Clustered = true; }
        key(ByPOSEntry; "POS Entry No.") { }
    }

    procedure Find(ShopifyStoreCode: Code[20]; POSEntryNo: Integer; ShopifyOrderID: Text[30]): Boolean
    begin
        exit(Rec.Get(ShopifyStoreCode, POSEntryNo, ShopifyOrderID));
    end;

    procedure Store(ShopifyStoreCode: Code[20]; POSEntryNo: Integer; ShopifyOrderID: Text[30]; ShopifyRefundID: Text[30]; RefundedAmount: Decimal; CurrencyCode: Code[10])
    begin
        Rec.Init();
        Rec."Shopify Store Code" := ShopifyStoreCode;
        Rec."POS Entry No." := POSEntryNo;
        Rec."Shopify Order ID" := ShopifyOrderID;
        Rec."Shopify Refund ID" := ShopifyRefundID;
        Rec."Refunded Amount" := RefundedAmount;
        Rec."Currency Code" := CurrencyCode;
        Rec."Created At" := CurrentDateTime();
        Rec.Insert();
    end;
}
