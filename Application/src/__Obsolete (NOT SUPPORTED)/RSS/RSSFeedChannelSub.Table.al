table 6059937 "NPR RSS Feed Channel Sub."
{
    Access = Internal;
    ObsoleteState = Removed;
    ObsoleteReason = 'We dont use RSS Feed any more.';
    Caption = 'RSS Feed Channel Subscription';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Feed Code"; Code[10])
        {
            Caption = 'Feed Code';
            DataClassification = CustomerContent;
        }
        field(10; Url; Text[250])
        {
            Caption = 'Url';
            Description = 'NPR5.22';
            DataClassification = CustomerContent;
        }
        field(20; "Show as New Within"; DateFormula)
        {
            Caption = 'Show as New Within';
            Description = 'NPR5.22';
            DataClassification = CustomerContent;
        }
        field(30; Default; Boolean)
        {
            Caption = 'Default';
            Description = 'NPR5.22';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Feed Code")
        {
        }
    }
}

