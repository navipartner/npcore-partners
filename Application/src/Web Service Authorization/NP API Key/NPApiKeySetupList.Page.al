page 6150970 "NPR NP API Key Setup List"
{
    Extensible = false;
    Caption = 'API Key Authorization Setup';
    PageType = List;
    SourceTable = "NPR NP API Key Setup";
    CardPageId = "NPR NP API Key Setup Card";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique code identifying this NP API Key setup.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a description of this NP API Key setup.';
                }
                field("Key Secret Hint"; Rec."Key Secret Hint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Displays a masked preview of the stored API key for identification purposes. The full key is never displayed again.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this NP API Key setup is enabled and can be used for authorization.';
                }
            }
        }
    }
}
