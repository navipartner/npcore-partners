table 6059856 "NPR M2 Record Change Log"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Type of Change"; Option)
        {
            Caption = 'Type of Change';
            DataClassification = SystemMetadata;
            OptionMembers = " ",ItemEnabled,ItemDisabled,ResendStockData;
            OptionCaption = ' ,Item Enabled,Item Disabled,Resend Stock Data';
        }
        field(3; "Entity Identifier"; Text[250])
        {
            Caption = 'Entity Identifier';
            DataClassification = CustomerContent;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("Primary Key"; "Entry No.")
        {
            Clustered = true;
        }
#if not (BC17 or BC18 or BC19 or BC20)
        key("Index 1"; "Type of Change", SystemRowVersion)
        {
        }
#endif
    }
}