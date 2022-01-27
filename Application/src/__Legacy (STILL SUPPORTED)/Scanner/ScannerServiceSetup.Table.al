table 6059996 "NPR Scanner Service Setup"
{
    Access = Internal;
    Caption = 'Scanner Service Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(11; "Log Request"; Boolean)
        {
            Caption = 'Log Request';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(12; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }

    fieldgroups
    {
    }
}

