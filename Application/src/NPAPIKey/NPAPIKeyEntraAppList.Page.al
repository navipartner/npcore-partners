#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185109 "NPR NP API Key Entra App List"
{
    Caption = 'NaviPartner API Key Entra Application List';
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

                    trigger OnDrillDown()
                    var
                        EntraIdApp: Record "AAD Application";
                    begin
                        Rec.TestField("Client Id");
                        if (not EntraIdApp.Get(Rec."Client Id")) then
                            Error(EntraAppNotFoundErr, Rec."Client Id");
                        Page.Run(Page::"AAD Application Card", EntraIdApp);
                    end;
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

    var
        EntraAppNotFoundErr: Label 'Entra ID application with Client ID %1 not found.', Comment = '%1 - Client ID';
}
#endif