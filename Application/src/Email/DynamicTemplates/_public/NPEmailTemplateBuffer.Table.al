table 6151280 "NPR NPEmailTemplateBuffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Access = Public;
    Caption = 'NP Email Template';

    fields
    {
        field(1; TemplateId; Code[20])
        {
            Caption = 'Template Id';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; TemplateId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; TemplateId, Description)
        {
        }
    }
}