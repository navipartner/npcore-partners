table 6059873 "NPR Print and Admit Buffer"
{
    Caption = 'Print and Admit';
    DataClassification = CustomerContent;
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = TICKET,MEMBER_CARD,ATTRACTION_WALLET;
            OptionCaption = 'Ticket,Member Card,Attraction Wallet';
            DataClassification = CustomerContent;
        }
        field(2; "System Id"; Guid)
        {
            Caption = 'System Id';
            DataClassification = CustomerContent;
        }
        field(10; "Visual Id"; Text[250])
        {
            Caption = 'Visual Id';
            DataClassification = CustomerContent;
        }
        field(20; Admit; Boolean)
        {
            Caption = 'Admit';
            DataClassification = CustomerContent;
        }
        field(21; Print; Boolean)
        {
            Caption = 'Print';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Type", "System Id")
        {
            Clustered = true;
        }
    }
}
