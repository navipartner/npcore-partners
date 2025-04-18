table 6059816 "NPR Client Diagnostic v2"
{
    Caption = 'Client Diagnostic';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = CustomerContent;
        }
        field(2; "User Name"; Code[50])
        {
            Caption = 'User Name';
            CalcFormula = Lookup(User."User Name" WHERE("User Security ID" = FIELD("User Security ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Full Name"; Text[80])
        {
            Caption = 'Full Name';
            CalcFormula = Lookup(User."Full Name" WHERE("User Security ID" = FIELD("User Security ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "User Login Type"; Enum "NPR User Login Type")
        {
            Caption = 'User Login Type';
            DataClassification = CustomerContent;
        }
        field(10; "Expiry Date"; DateTime)
        {
            Caption = 'Expiry Date';
            DataClassification = CustomerContent;
        }
        field(15; "Expiry Date Last Updated"; DateTime)
        {
            Caption = 'Expiry Date Last Updated';
            DataClassification = CustomerContent;
        }
        field(20; "Expiry Date Last Checked"; DateTime)
        {
            Caption = 'Expiry Date Last Checked';
            DataClassification = CustomerContent;
        }
        field(30; "Expiration Message"; Text[250])
        {
            Caption = 'Expiration Message';
            DataClassification = CustomerContent;
        }
        field(35; "Expirat. Message Last Updated"; DateTime)
        {
            Caption = 'Expiration Message Last Updated';
            DataClassification = CustomerContent;
        }
        field(40; "Expirat. Message Last Checked"; DateTime)
        {
            Caption = 'Expiration Message Last Checked';
            DataClassification = CustomerContent;
        }
        field(45; "Locked Message"; Text[30])
        {
            Caption = 'Locked Message';
            DataClassification = CustomerContent;
        }
        field(50; "Locked Message Last Updated"; DateTime)
        {
            Caption = 'Locked Message Last Updated';
            DataClassification = CustomerContent;
        }
        field(55; "Locked Message Last Checked"; DateTime)
        {
            Caption = 'Locked Message Last Checked';
            DataClassification = CustomerContent;
        }
        field(60; "Client Diagnostic Last Sent"; DateTime)
        {
            Caption = 'Client Diagnostic Last Sent';
            DataClassification = CustomerContent;
        }
        field(70; "Delegated User"; Boolean)
        {
            Caption = 'Delegated User';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "User Security ID", "User Login Type")
        {
            Clustered = true;
        }
    }
}