table 6014556 "NPR Attribute Key"
{
    // 
    // NPRx.xx/TSA/22-04-15 CASE209946 - Entity and Shortcut Attributes
    // NPR4.19/BR/20160309 CASE182391 Added support for documents and for Worksheets added Fields MDR Code 2 PK and MDR Line 2 PK

    Caption = 'Attribute Key';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attribute Set ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
        }
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(11; "MDR Code PK"; Code[20])
        {
            Caption = 'MDR Code PK';
            DataClassification = CustomerContent;
        }
        field(12; "MDR Line PK"; Integer)
        {
            Caption = 'MDR Line PK';
            DataClassification = CustomerContent;
        }
        field(13; "MDR Option PK"; Integer)
        {
            Caption = 'MDR Option PK';
            DataClassification = CustomerContent;
        }
        field(20; "MDR Code 2 PK"; Code[20])
        {
            Caption = 'MDR Code 2 PK';
            Description = 'CASE182391';
            DataClassification = CustomerContent;
        }
        field(21; "MDR Line 2 PK"; Integer)
        {
            Caption = 'MDR Line 2 PK';
            Description = 'CASE182391';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID")
        {
        }
        key(Key2; "Table ID", "MDR Code PK", "MDR Line PK", "MDR Option PK")
        {
        }
    }

    fieldgroups
    {
    }
}

