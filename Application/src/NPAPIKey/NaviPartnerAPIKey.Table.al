#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151254 "NPR NaviPartner API Key"
{
    Caption = 'NaviPartner API Key';
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            NotBlank = true;
            ToolTip = 'Specifies unique identifier of the API Key.';
            Editable = false;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            ToolTip = 'Specifies name/description of the API Key.';
            Editable = false;
        }
        field(3; Status; Enum "NPR NP API Key Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies status of the API Key.';
            Editable = false;
        }
        field(4; "Key Secret Hint"; Text[30])
        {
            Caption = 'Key Secret Hint';
            ToolTip = 'Displays a partial preview of the API key for identification purposes. The full key is not stored and cannot be retrieved.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Description; Description)
        {
        }
    }
}
#endif