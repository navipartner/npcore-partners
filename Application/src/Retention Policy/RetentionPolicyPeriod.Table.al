#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
table 6060013 "NPR Retention Policy Period"
{
    Caption = 'NPR Retention Policy Period';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Period Type"; Enum "NPR Retention Period Type")
        {
            Caption = 'Period Type';
            DataClassification = CustomerContent;
        }
        field(3; "Retention Period"; DateFormula)
        {
            Caption = 'Retention Period';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Table Id", "Period Type")
        {
            Clustered = true;
        }
    }
}
#endif