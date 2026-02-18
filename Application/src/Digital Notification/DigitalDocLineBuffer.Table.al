#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6248185 "NPR Digital Doc. Line Buffer"
{
    Access = Internal;
    Caption = 'Digital Document Line Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = SystemMetadata;
            TableRelation = "NPR Digital Doc. Header Buffer";
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(20; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(35; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }
        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(60; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = SystemMetadata;
            AutoFormatType = 2;
        }
        field(70; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
        field(80; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
        field(90; "Line Discount Amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
        field(100; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "External Order No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
#endif