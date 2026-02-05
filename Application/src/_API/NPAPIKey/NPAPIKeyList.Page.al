#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185107 "NPR NP API Key List"
{
    Caption = 'NaviPartner API Keys';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR NaviPartner API Key";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    SourceTableView = sorting(Description);
    AdditionalSearchTerms = 'NP API Keys';

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
                field("Key Secret Hint"; Rec."Key Secret Hint")
                {
                }
            }
            part(NPAPIKeyPermissionSubPage; "NPR NP API Key Permission")
            {
                SubPageLink = "NPR NP API Key Id" = field(Id);
                Editable = true;
            }
        }
        area(Factboxes)
        {
            part(EntraApps; "NPR NP API Key Entra App List")
            {
                SubPageLink = "NPR NaviPartner API Key Id" = field(Id);
            }
            systempart(NotesFactBox; Notes)
            {
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
                ToolTip = 'Creates a new NaviPartner API Key with a provided description.';
                AccessByPermission = tabledata "NPR NaviPartner API Key" = I;

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
            action(RotateApiKey)
            {
                Caption = 'Rotate API Key';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = UpdateDescription;
                ToolTip = 'Rotates the selected API Key.';
                Ellipsis = true;
                Enabled = RotateActionEnabled;
                AccessByPermission = tabledata "NPR NaviPartner API Key" = M;

                trigger OnAction()
                var
                    NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                    ConfirmMgt: Codeunit "Confirm Management";
                    ApiKey: Text;
                begin
                    if (not ConfirmMgt.GetResponseOrDefault(RotateApiKeyQst, false)) then
                        exit;

                    ApiKey := NPAPIKeyMgt.RotateApiKey(Rec);
                    Message(APIKeyRotatedMsg, ApiKey);

                    CurrPage.Update(false);
                end;
            }
            action(RegisterNewEntraApp)
            {
                Caption = 'Register new Entra App';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = New;
                ToolTip = 'Registers a new Entra ID application and credentials for the selected NaviPartner API Key. This action must be performed by an administrator!!!';
                Enabled = HasPermissionsDefined and IsApiKeyActive;
                AccessByPermission = tabledata "NPR NaviPartner API Key" = M;

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
                    AccessByPermission = tabledata "NPR NaviPartner API Key" = M;

                    trigger OnAction()
                    var
                        NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                        ConfirmMgt: Codeunit "Confirm Management";
                    begin
                        if (not ConfirmMgt.GetResponseOrDefault(RevokeApiKeyQst, false)) then
                            exit;

                        NPAPIKeyMgt.RevokeApiKey(Rec);

                        CurrPage.Update(false);
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
                    AccessByPermission = tabledata "NPR NaviPartner API Key" = M;

                    trigger OnAction()
                    var
                        NPAPIKeyMgt: Codeunit "NPR NP API Key Mgt.";
                        ConfirmMgt: Codeunit "Confirm Management";
                    begin
                        if (not ConfirmMgt.GetResponseOrDefault(ActivateApiKeyQst, false)) then
                            exit;

                        NPAPIKeyMgt.ActivateApiKey(Rec);

                        CurrPage.Update(false);
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
        RotateApiKeyQst: Label 'Are you sure you want to rotate the existing API key? This will produce a new API Key secret for the existing NaviPartner API Key.';
        APIKeyRotatedMsg: Label 'API Key rotated. New API Key secret: %1', Comment = '%1 = new API Key secret';
        RotateActionEnabled: Boolean;
        HasPermissionsDefined: Boolean;
        IsApiKeyActive: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateRecControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateRecControls();
    end;

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

    local procedure UpdateRecControls()
    var
        NPAPIKeyPermission: Record "NPR NaviPartner API Key Perm.";
    begin
        RotateActionEnabled := false;
        HasPermissionsDefined := false;
        IsApiKeyActive := false;

        if (not IsNullGuid(Rec.Id)) then begin
            RotateActionEnabled := (not (Rec.Status = Rec.Status::Revoked));

            NPAPIKeyPermission.Reset();
            NPAPIKeyPermission.SetRange("NPR NP API Key Id", Rec.Id);
            HasPermissionsDefined := (not NPAPIKeyPermission.IsEmpty());
        end;

        IsApiKeyActive := (Rec.Status in [Rec.Status::Active]);
    end;
}
#endif