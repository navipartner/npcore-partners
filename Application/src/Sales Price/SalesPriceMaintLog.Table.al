table 6059858 "NPR Sales Price Maint. Log"
{
    Access = Internal;
    Caption = 'Sales Price Maintenance Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Processed, "Item No.")
        {
        }
    }
}
