table 6014593 "NPR Aux. G/L Entry"
{
    Access = Internal;
    // Fields are populated via transferfield from "G/L Entry", mind the field ids when adding new fields.

    Caption = 'Aux. G/L Entry';
    DataClassification = CustomerContent;
    ObsoleteReason = 'Aux. G/L Entry has been removed due performance issues.';
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';


    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Replication Counter")
        {
        }

    }
}
