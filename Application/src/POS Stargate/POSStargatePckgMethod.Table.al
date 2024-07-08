table 6150714 "NPR POS Stargate Pckg. Method"
{
    Access = Internal;
    Caption = 'POS Stargate Package Method';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR31.0';
    ObsoleteReason = 'Stargate is replaced by hardware connector';

    fields
    {
        field(1; "Method Name"; Text[250])
        {
            Caption = 'Method Name';
            DataClassification = CustomerContent;
        }
        field(2; "Package Name"; Text[80])
        {
            Caption = 'Package Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Method Name")
        {
        }
        key(Key2; "Package Name")
        {
        }
    }

    fieldgroups
    {
    }
}