table 6014549 "NPR Stripe POS User"
{
    Access = Internal;
    Caption = 'POS User';
    LookupPageId = "NPR Stripe POS Users";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}