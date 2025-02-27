#if not BC17
table 6150815 "NPR Spfy Fulfillment Entry"
{
    Access = Internal;
    Caption = 'Shopify Fulfillment Entry';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(3; "BC Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'BC Record ID';
        }
        field(10; "Fulfillment Order ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Fulfillment Order ID';
        }
        field(11; "Fulfillment Order Line ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Fulfillment Order Line ID';
        }
        field(12; "Order Line ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Line ID';
        }
        field(20; "Fulfillable Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Fulfillable Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(21; "Fulfilled Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Fulfilled Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(30; "Gift Card"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Gift Card';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RelationFromBCTables; "Table No.", "BC Record ID") { }
        key(ByFulfillmentOrder; "Fulfillment Order ID", "Fulfillment Order Line ID") { }
    }
}
#endif