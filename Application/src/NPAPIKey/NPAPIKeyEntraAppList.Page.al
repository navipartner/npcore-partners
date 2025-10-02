#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185109 "NPR NP API Key Entra App List"
{
    Caption = 'NP API Key Entra Application List';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "AAD Application";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(EntraAppsRepeater)
            {
                field("Client ID"; Rec."Client ID")
                {
                    ToolTip = 'Specifies the Client ID of the Entra ID application.';
                }
                field(State; Rec.State)
                {
                    ToolTip = 'Specifies the state of the Entra ID application.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Entra ID application.';
                }
            }
        }
    }
}
#endif