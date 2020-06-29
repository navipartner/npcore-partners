table 6151398 "CS Store Users"
{
    // NPR5.51/CLVA  /20190813  CASE 365659 Object created - NP Capture Service
    // NPR5.52/CLVA  /20190916  CASE 368484 Changed field Location to POS Store
    // NPR5.53/CLVA  /20191204  CASE 375919 Added field "Adjust Inventory"

    Caption = 'CS Store Users';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            NotBlank = true;
            TableRelation = "POS Store";
        }
        field(10; Supervisor; Code[10])
        {
            Caption = 'Supervisor';
            TableRelation = "Salesperson/Purchaser" WHERE("Supervisor POS" = FILTER(true));
        }
        field(11; "Adjust Inventory"; Boolean)
        {
            Caption = 'Adjust Inventory';
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

    var
        UserManagement: Codeunit "User Management";
}

