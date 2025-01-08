table 6150985 "NPR SG NumberWhiteListLine"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(2; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = TICKET,MEMBER_CARD,WALLET,DOC_LX_CITY_CARD;
            OptionCaption = 'Ticket,Member Card,Wallet,City Card';
        }

        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(15; RuleType; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Rule';
            OptionMembers = ALLOW,REJECT;
            OptionCaption = 'Allow,Reject';
        }

        field(20; Prefix; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Prefix';
        }

        field(30; NumberLength; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Length';
        }
    }

    keys
    {
        key(Key1; Code, Type, Prefix)
        {
            Clustered = true;
        }

    }
}