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

    actions
    {
        area(processing)
        {
            action("Delete")
            {
                Caption = 'Delete';
                ToolTip = 'Deletes the selected Entra ID application. This action cannot be undone.';
                Image = Delete;
                Enabled = true;
                Ellipsis = true;

                trigger OnAction()
                var
                    NPAPIKey: Record "NPR NaviPartner API Key";
                    NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    ConfirmMgt: Codeunit "Confirm Management";
                begin
                    if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(DeleteQst, Rec."Client Id"), true)) then
                        Error('');

                    NPAPIKey.Get(Rec."NPR NaviPartner API Key Id");
                    NPAPIKeyMgt.RemoveEntraApp(NPAPIKey, Rec);

                    CurrPage.Update(false);
                end;
            }
        }
    }


    var
        EntraAppNotFoundErr: Label 'Entra ID application with Client ID %1 not found.', Comment = '%1 - Client ID';
        DeleteQst: Label 'Do you want to delete the Entra ID application with Client ID %1?', Comment = '%1 - Client ID';
}
#endif