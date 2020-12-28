table 6151367 "NPR CS Counting Supervisor"
{
    
    Caption = 'CS Counting Supervisor';
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

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
       
        field(11; Pin; Code[6])
        {
            Caption = 'Pin';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            Numeric = true;
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        UserManagement: Codeunit "User Management";
}

