table 6184507 "NPR EFT Shopper Recognition"
{
    Access = Internal;
    // NPR5.49/MMV /20190401 CASE 345188 Created object

    Caption = 'EFT Shopper Recognition';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Integration Type"; Text[50])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(2; "Shopper Reference"; Text[50])
        {
            Caption = 'Shopper Reference';
            DataClassification = CustomerContent;
        }
        field(3; "Contract ID"; Text[50])
        {
            Caption = 'Contract ID';
            DataClassification = CustomerContent;
        }
        field(4; "Contract Type"; Text[50])
        {
            Caption = 'Contract Type';
            DataClassification = CustomerContent;
        }
        field(10; "Entity Type"; Option)
        {
            Caption = 'Entity Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Contact,Membership,User Account';
            OptionMembers = Customer,Contact,Membership,UserAccount;
        }
        field(11; "Entity Key"; Code[20])
        {
            Caption = 'Entity Key';
            DataClassification = CustomerContent;
            TableRelation = IF ("Entity Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Entity Type" = CONST(Contact)) Contact."No."
            else
            if ("Entity Type" = CONST(Membership)) "NPR MM Membership"
            else
            if ("Entity Type" = CONST(UserAccount)) "NPR UserAccount".AccountNo;
        }
    }

    keys
    {
        key(Key1; "Integration Type", "Shopper Reference")
        {
        }
        key(Key2; "Entity Type", "Entity Key")
        {
        }
    }

    fieldgroups
    {
    }
}

