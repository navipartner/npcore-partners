table 6014528 "NPR Aux. G/L Account"
{
    Access = Internal;
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
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }

        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        key(Key3; "Retail Payment")
        {

        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key4; SystemRowVersion)
        {

        }
#ENDIF
    }
}
