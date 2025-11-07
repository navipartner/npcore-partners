table 6150990 "NPR NPDesignerTemplates"
{
    Access = Public;
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'Design Templates';

    fields
    {
        field(1; ExternalId; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(10; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; ExternalId)
        {
            Clustered = true;
        }

        key(Key2; Description)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Description) { }
    }
}
