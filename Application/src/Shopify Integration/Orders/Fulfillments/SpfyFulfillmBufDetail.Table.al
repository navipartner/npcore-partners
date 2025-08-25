#if not BC17
table 6150996 "NPR Spfy Fulfillm. Buf. Detail"
{
    Access = Internal;
    Caption = 'Shopify Fulfillment Buffer Detail';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Parent Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Parent Entry No.';
            TableRelation = "NPR Spfy Fulfillment Buffer"."Entry No.";
        }
        field(10; "Gift Card ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Gift Card ID';
        }
        field(11; "Gift Card Reference No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Gift Card Reference No.';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RelationFromParent; "Parent Entry No.") { }
    }
}
#endif