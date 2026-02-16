table 6059889 "NPR MM Memb. Entry Tag Buff"
{
    DataClassification = CustomerContent;
    Caption = 'MM Membership Entry Tag Buffer';
    TableType = Temporary;
    Extensible = False;
    Access = Internal;

    fields
    {
        field(10; "Tag Key"; Code[20])
        {
            Caption = 'Tag Key';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Tag"."Key";
        }

        field(20; "Tag Value"; Code[100])
        {
            Caption = 'Tag Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tag Key", "Tag Value")
        {
            Clustered = true;
        }
    }
}
