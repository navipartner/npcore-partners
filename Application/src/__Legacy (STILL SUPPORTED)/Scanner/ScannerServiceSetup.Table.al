table 6059996 "NPR Scanner Service Setup"
{
    Caption = 'Scanner Service Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(11; "Log Request"; Boolean)
        {
            Caption = 'Log Request';
            DataClassification = CustomerContent;
        }
        field(12; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

