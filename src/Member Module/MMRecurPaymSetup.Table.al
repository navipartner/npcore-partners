table 6060093 "NPR MM Recur. Paym. Setup"
{

    Caption = 'Recurring Payment Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
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
        field(20; "Document No. Series"; Code[10])
        {
            Caption = 'Document No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50; "Revenue Account"; Code[20])
        {
            Caption = 'Revenue Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(55; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
        }
        field(100; "Period Alignment"; Option)
        {
            Caption = 'Period Alignment';
            DataClassification = CustomerContent;
            OptionCaption = 'Current Period,Today,Back-to-Back';
            OptionMembers = CURRENT_PERIOD,TODAY,BACK_TO_BACK;
        }
        field(105; "Period Size"; DateFormula)
        {
            Caption = 'Period Size';
            DataClassification = CustomerContent;
        }
        field(200; "Gen. Journal Template Name"; Code[10])
        {
            Caption = 'Gen. Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Gen. Journal Template".Name;
        }
        field(209; "Gen. Journal Batch Name"; Code[10])
        {
            Caption = 'Gen. Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Gen. Journal Template Name"));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

