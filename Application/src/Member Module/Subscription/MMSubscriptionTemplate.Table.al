table 6150917 "NPR MM Subscription Template"
{
    Access = Internal;
    Caption = 'Membership Subscription Template';
    DataClassification = CustomerContent;
    //DrillDownPageId = ;
    //LookupPageId = ;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Renewal Approach"; Option)
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            InitValue = Strict;
            OptionMembers = Optimistic,Strict;
            OptionCaption = 'Optimistic,Strict';
        }
        field(20; "Renewal Grace Period"; DateFormula)
        {
            Caption = 'Renewal Grace Period';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}