table 6014535 "NPR MobilePayV10 Store"
{
    DataClassification = CustomerContent;
    LookupPageId = "NPR MobilePayV10 Stores";

    fields
    {
        field(1; "Store ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Store ID';
        }
        field(10; "Store Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Name';
        }
        field(20; "Store Street"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Street';
        }
        field(30; "Store City"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Store City';
        }
        field(110; "Brand Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Brand Name';
            Editable = false;
        }
        field(120; "Merchant Brand Id"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Brand Id';
            Editable = false;
        }
        field(130; "Merchant Location Id"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Location Id';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Store ID")
        {
            Clustered = true;
        }
    }
}