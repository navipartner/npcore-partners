#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151036 "NPR NpGp Export Control"
{
    Access = Internal;

    Caption = 'NpGp Export Control';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sales Setup Code"; Code[10])
        {
            Caption = 'POS Sales Setup Code';
        }
        field(10; "Last Entry No. Exported"; Integer)
        {
            Caption = 'Last Entry No. Exported';
        }
        field(11; "Last Exported Date"; DateTime)
        {
            Caption = 'Last Exported Date';
        }
    }
    keys
    {
        key(PK; "POS Sales Setup Code")
        {
            Clustered = true;
        }
    }
}
#endif