table 6151398 "NPR CS Store Users"
{
   
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
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

           
        }
        field(2; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Store";
        }
        field(10; Supervisor; Code[10])
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser" WHERE("NPR Supervisor POS" = FILTER(true));
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

