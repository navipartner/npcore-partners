table 6060093 "NPR MM Recur. Paym. Setup"
{
    Access = Internal;
    Caption = 'Recurring Payment Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM Recurring Payments";
    DrillDownPageId = "NPR MM Recurring Payments";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
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
        field(20; "Document No. Series"; Code[20])
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
        field(110; "Subscr. Auto-Renewal On"; Enum "NPR MM Subscr. Auto-Renewal")
        {
            Caption = 'Subscr. Auto-Renewal On';
            DataClassification = CustomerContent;
        }
        field(115; "First Attempt Offset (Days)"; Integer)
        {
            Caption = 'First Attempt Offset (Days)';
            DataClassification = CustomerContent;
        }
        field(120; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code".Code;
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
        field(6; "Max. Pay. Process Try Count"; Integer)
        {
            Caption = 'Max. Payment Process Try Count';
            DataClassification = CustomerContent;
            InitValue = 5;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
