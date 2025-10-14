#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151235 "NPR NP API Key"
{
    Access = Internal;
    Caption = 'NaviPartner API Key';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-13';
    ObsoleteReason = 'Replaced by new table "NPR NaviPartner API Key" created with `DataPerCompany = false`.';

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            NotBlank = true;
            ToolTip = 'Specifies unique identifier of the API Key.';
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            ToolTip = 'Specifies name/description of the API Key.';
        }
        field(3; Status; Enum "NPR NP API Key Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies status of the API Key.';
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