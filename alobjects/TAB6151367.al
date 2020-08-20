table 6151367 "CS Counting Supervisor"
{
    // NPR5.53/CLVA  /20191203  CASE 375919 Object created - NP Capture Service

    Caption = 'CS Counting Supervisor';
    DataClassification = CustomerContent;

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
        field(10; "Full Name"; Text[80])
        {
            CalcFormula = Lookup (User."Full Name" WHERE("User Name" = FIELD("User ID")));
            Caption = 'Full Name';
            Editable = false;
            FieldClass = FlowField;
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

