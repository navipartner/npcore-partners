page 6150762 "NPR Environment Information"
{
    Caption = 'NP Retail Environment Information';
    PageType = Card;
    SourceTable = "NPR Environment Information";
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Environment Type. Some features in NP Retail will be enabled/disabled based on the Environment Type';
                }
                field("Environment Verified"; Rec."Environment Verified")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether a user have verified the Enviroment Type value.';
                }
                field("Environment Company Name"; Rec."Environment Company Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Company Name when the Environment Type was verified.';
                    Editable = false;
                }
                field("Environment Database Name"; Rec."Environment Database Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Database Name when the Environment Type was verified.';
                    Editable = false;
                }
                field("Environment Tenant Name"; Rec."Environment Tenant Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tenant when the Environment Type was verified.';
                    Editable = false;
                }
            }
        }
    }
}
