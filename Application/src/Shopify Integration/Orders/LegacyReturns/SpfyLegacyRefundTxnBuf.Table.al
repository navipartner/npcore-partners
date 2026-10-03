table 6059954 "NPR Spfy Legacy Refund Txn Buf"
{
    Access = Internal;
    Caption = 'Shopify Legacy Refund Transaction Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Return Id"; Text[30]) { Caption = 'Return Id'; DataClassification = SystemMetadata; }
        field(20; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = SystemMetadata; }
        field(30; Amount; Decimal) { Caption = 'Amount'; DataClassification = SystemMetadata; }
        field(40; "Store Currency Code"; Code[10]) { Caption = 'Store Currency Code'; DataClassification = SystemMetadata; }
        field(50; "Amount (Store Currency)"; Decimal) { Caption = 'Amount (Store Currency)'; DataClassification = SystemMetadata; }
        field(60; Kind; Text[50]) { Caption = 'Kind'; DataClassification = SystemMetadata; }
        field(70; Gateway; Text[50]) { Caption = 'Gateway'; DataClassification = SystemMetadata; }
        field(80; "Transaction Id"; Text[30]) { Caption = 'Transaction Id'; DataClassification = SystemMetadata; }
        field(90; "Gift Card Id"; Text[30]) { Caption = 'Shopify Gift Card Id'; DataClassification = SystemMetadata; }
        field(100; "Processed At"; DateTime) { Caption = 'Processed At'; DataClassification = SystemMetadata; }
        field(110; "Created At"; DateTime) { Caption = 'Created At'; DataClassification = SystemMetadata; }
        field(120; "Credit Card Company"; Text[100]) { Caption = 'Credit Card Company'; DataClassification = SystemMetadata; }
    }
    keys { key(PK; "Return Id", "Line No.") { Clustered = true; } }
}
