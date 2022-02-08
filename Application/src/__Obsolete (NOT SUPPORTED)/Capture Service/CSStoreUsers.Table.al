table 6151398 "NPR CS Store Users"
{
    Access = Internal;

    Caption = 'CS Store Users';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Supervisor; Code[10])
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
        }
        field(11; "Adjust Inventory"; Boolean)
        {
            Caption = 'Adjust Inventory';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User ID", "POS Store")
        {
        }
    }

    fieldgroups
    {
    }


}

