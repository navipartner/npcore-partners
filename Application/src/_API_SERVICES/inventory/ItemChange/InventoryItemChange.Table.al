table 6248744 "NPR Inventory Item Change"
{
    Access = Internal;
    Caption = 'Inventory Item Change';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(2; "Change Count"; BigInteger)
        {
            Caption = 'Change Count';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
        key(RowVersion; SystemRowVersion)
        {
        }
    }
}
