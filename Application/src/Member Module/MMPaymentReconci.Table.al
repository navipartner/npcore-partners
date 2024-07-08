table 6060094 "NPR MM Payment Reconci."
{
    Access = Internal;

    Caption = 'Payment Reconciliation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Payment Service Provider Code"; Code[20])
        {
            Caption = 'Payment Service Provider Code';
            DataClassification = CustomerContent;
        }
        field(15; "PSP Recurring Plan ID"; Text[30])
        {
            Caption = 'PSP Recurring Plan ID';
            DataClassification = CustomerContent;
        }
        field(30; "Payment Reference"; Text[50])
        {
            Caption = 'Payment Reference';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

