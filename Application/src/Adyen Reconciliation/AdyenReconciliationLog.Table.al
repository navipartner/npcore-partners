table 6150800 "NPR Adyen Reconciliation Log"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(10; "Webhook Request ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Webhook Request ID';
            TableRelation = "NPR AF Rec. Webhook Request".ID;
        }
        field(20; Type; Enum "NPR Adyen Rec. Log Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(30; Success; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Success';
        }
        field(40; Description; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(50; "Creation Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Date';
        }
    }
    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }
}
