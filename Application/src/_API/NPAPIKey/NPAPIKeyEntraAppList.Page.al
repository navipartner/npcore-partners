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
                ToolTip = 'Deletes the selected Entra ID application from NaviPartner Auth Provider and Business Central. This action cannot be undone. Useful when the Entra App is deleted or corrupted in Azure and not synced with NaviPartner Auth Provider.';
                Image = Delete;
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
            action(DeleteInAzure)
            {
                Caption = 'Delete in Azure';
                ToolTip = 'Deletes the Entra ID application in Azure, removes it from NaviPartner Auth Provider and Business Central. This action is only available when the linked NaviPartner API Key is deleted. This action cannot be undone.';
                Image = DeleteXML;
                Enabled = IsApiKeyDeleted;
                Ellipsis = true;

                trigger OnAction()
                var
                    NPAPIKey: Record "NPR NaviPartner API Key";
                    AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                    NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    ConfirmMgt: Codeunit "Confirm Management";
                    ClientId: Guid;
                begin
                    Rec.TestField("Client Id");
                    ClientId := Rec."Client Id";

                    if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(DeleteInAzureQst, ClientId), false)) then
                        exit;

                    NPAPIKey.Get(Rec."NPR NaviPartner API Key Id");
                    NPAPIKeyMgt.RemoveEntraApp(NPAPIKey, Rec);
                    AADApplicationMgt.DeleteAzureADApplication(ClientId);

                    CurrPage.Update(false);
                    Message(DeletedInAzureMsg, ClientId);
                end;
            }
        }
    }

    var
        EntraAppNotFoundErr: Label 'Entra ID application with Client ID %1 not found.', Comment = '%1 - Client ID';
        DeleteQst: Label 'Do you want to delete the Entra ID application with Client ID %1? This will delete the application from the NaviPartner Auth Provider and Business Central.', Comment = '%1 - Client ID';
        DeleteInAzureQst: Label 'Do you want to delete the Entra ID application with Client ID %1 in Azure, NaviPartner Auth Provider and Business Central? This action cannot be undone.', Comment = '%1 - Client ID';
        DeletedInAzureMsg: Label 'Entra ID application with Client ID %1 has been deleted in Azure, NaviPartner Auth Provider and Business Central.', Comment = '%1 - Client ID';
        IsApiKeyDeleted: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateRecControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateRecControls();
    end;

    local procedure UpdateRecControls()
    var
        NPAPIKey: Record "NPR NaviPartner API Key";
    begin
        IsApiKeyDeleted := false;

        if (not IsNullGuid(Rec."NPR NaviPartner API Key Id")) then
            if (NPAPIKey.Get(Rec."NPR NaviPartner API Key Id")) then
                IsApiKeyDeleted := (NPAPIKey.Status = NPAPIKey.Status::Deleted);
    end;
}
#endif