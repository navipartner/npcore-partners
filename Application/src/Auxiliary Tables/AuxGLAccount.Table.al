table 6014528 "NPR Aux. G/L Account"
{
    Caption = 'Aux. G/L Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;
        }
        field(6014400; "Retail Payment"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Retail Payment';

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Retail Payment" then begin
                    TestField("No.");
                    GLAccount.Get("No.");
                    GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}
