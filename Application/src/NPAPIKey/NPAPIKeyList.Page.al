#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185107 "NPR NP API Key List"
{
    Caption = 'NP API Key List';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR NP API Key";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    SourceTableView = sorting(Description);

    layout
    {
        area(Content)
        {
            repeater(ApiKeysRepeater)
            {
                field(Id; Rec.Id)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Status; Rec.Status)
                {
                }
            }
            part(NPAPIKeyPermission; "NPR NP API Key Permission")
            {
                SubPageLink = "NPR NP API Key Id" = field(Id);
                Editable = true;
            }
        }
        area(Factboxes)
        {
            part(EntraApps; "NPR NP API Key Entra App List")
            {
                SubPageLink = "NPR NP API Key Id" = field(Id);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNewApiKey)
            {
                Caption = 'Create new API Key';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = New;
                ToolTip = 'Creates a new NP API Key with a provided description.';

                trigger OnAction()
                var
                    NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    Description: Text[30];
                    ApiKey: Text;
                begin
                    Description := GetDescriptionViaDialog();
                    if (Description.Trim() = '') then
                        Error(ProvideApiKeyDescriptionErr);

                    ApiKey := NPAPIKeyMgt.CreateNewApiKey(Description);

                    Message(NewAPIKeyCreatedMsg, ApiKey);
                end;
            }
            action(RegisterNewEntraApp)
            {
                Caption = 'Register new Entra App';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = New;
                ToolTip = 'Registers a new Entra ID application and credentials for the selected NP API Key. This action must be performed by an administrator!!!';

                trigger OnAction()
                var
                    NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                begin
                    NPAPIKeyMgt.RegisterEntraAppAndCredentials(Rec);
                    Message(NewEntraAppRegisteredMsg);
                end;
            }
            group(ChangeStatus)
            {
                Caption = 'Change Status';
                Image = ChangeStatus;

                action(RevokeApiKey)
                {
                    Caption = 'Revoke API Key';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = DeleteQtyToHandle;
                    ToolTip = 'Revokes the selected API Key.';
                    Enabled = Rec.Status = Rec.Status::Active;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    begin
                        if (not Confirm(RevokeApiKeyQst)) then
                            exit;
                        NPAPIKeyMgt.RevokeApiKey(Rec);
                    end;
                }
                action(ActivateApiKey)
                {
                    Caption = 'Activate API Key';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = ImportCodes;
                    ToolTip = 'Activates the selected API Key.';
                    Enabled = Rec.Status = Rec.Status::Revoked;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    begin
                        if (not Confirm(ActivateApiKeyQst)) then
                            exit;
                        NPAPIKeyMgt.ActivateApiKey(Rec);
                    end;
                }
            }
        }
    }

    var
        NewAPIKeyCreatedMsg: Label 'New API Key created: %1', Comment = '%1 = API Key';
        NewEntraAppRegisteredMsg: Label 'New Entra App registered.';
        ProvideApiKeyDescriptionMsg: Label 'Provide a description for the new API key.';
        ProvideApiKeyDescriptionErr: Label 'You must provide a valid description for the new API key.';
        DescriptionTooLongErr: Label 'The description is too long. Maximum length is %1 characters.', Comment = '%1 = maximum length';
        RevokeApiKeyQst: Label 'Are you sure you want to revoke the API key?';
        ActivateApiKeyQst: Label 'Are you sure you want to activate the API key?';

    local procedure GetDescriptionViaDialog() RetVal: Text[30]
    var
        InputDialog: Page "NPR Input Dialog";
        SelectedDescription: Text;
    begin
        Clear(InputDialog);

        InputDialog.SetInput(1, '', ProvideApiKeyDescriptionMsg);
        InputDialog.LookupMode(true);
        if (InputDialog.RunModal() <> Action::LookupOK) then
            Error('');

        InputDialog.InputText(1, SelectedDescription);

        if (SelectedDescription = '') then
            Error(ProvideApiKeyDescriptionErr);

        if ((StrLen(SelectedDescription) > (MaxStrLen(RetVal)))) then
            Error(DescriptionTooLongErr, MaxStrLen(RetVal));

        RetVal := CopyStr(SelectedDescription, 1, MaxStrLen(RetVal));

        exit(RetVal);
    end;
}
#endif