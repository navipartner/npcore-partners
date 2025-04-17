#if not BC17
table 6151157 "NPR Spfy Sales Channel"
{
    Access = Internal;
    Caption = 'Shopify Sales Channel';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            Editable = false;
        }
        field(2; ID; Text[30])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; Handle; Text[100])
        {
            Caption = 'Handle';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Use for Publication"; Boolean)
        {
            Caption = 'Use for Publication';
            DataClassification = CustomerContent;
        }
        field(40; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Shopify Store Code", ID)
        {
            Clustered = true;
        }
    }
}
#endif