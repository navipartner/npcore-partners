#if not BC17
table 6150815 "NPR Spfy Fulfillment Buffer"
{
    Access = Internal;
    Caption = 'Shopify Fulfillment Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        field(31; "Initial Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Initial Amount';
            DecimalPlaces = 0 : 5;
        }
        field(32; Email; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Email';
        }
        field(33; "Updated At"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Updated At';
        }
#endif
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RelationFromBCTables; "Table No.", "BC Record ID") { }
        key(ByFulfillmentOrder; "Fulfillment Order ID", "Fulfillment Order Line ID") { }
        key(OrderLindId; "Order Line ID") { }
    }
}
#endif