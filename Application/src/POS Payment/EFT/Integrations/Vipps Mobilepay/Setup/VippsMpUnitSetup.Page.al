page 6151349 "NPR Vipps Mp Unit Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Vipps Mp Unit Setup";
    Extensible = False;
    Caption = 'Vipps Mobilepay Unit Configuration';

    layout
    {
        area(Content)
        {
            group("POS Unit")
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the POS Unit you are setting the integration up for.';
#if NOT BC17
                    AboutTitle = 'POS Unit No.';
                    AboutText = 'Specifies the POS Unit you are setting the integration up for.';
#endif
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the name POS Unit you are setting the integration up for.';
#if NOT BC17
                    AboutTitle = 'POS Unit Name';
                    AboutText = 'Specifies the name POS Unit you are setting the integration up for.';
#endif
                }
            }
            group(Vipps)
            {
                field("Merchant Store Id"; Rec."Merchant Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier for your Sales Unit/Store.';
#if NOT BC17
                    AboutTitle = 'Merchant Serial Number (MSN)';
                    AboutText = 'Specifies the unique identifier for your Sales Unit/Store.';
#endif
                }
                field("Merchant Store Name"; Rec."Merchant Store Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the Name of the Store';
#if NOT BC17
                    AboutTitle = 'Store name';
                    AboutText = 'Specifies the Name of the Store';
#endif
                }
                field("Static QR ID"; Rec."Merchant Qr Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which static QR the POS Unit should be using for payments.';
#if NOT BC17
                    AboutTitle = 'Static Qr Id';
                    AboutText = 'Specifies which static QR the POS Unit should be using for payments.';
#endif
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSaaSSetup)
            {
                Caption = 'Create Setup (Admin)';
                Visible = IsSaaS;
                ApplicationArea = NPRRetail;
                ToolTip = 'Creates the Vipps Mobilepay Entra app, with user permissions. Needs Admin.';
                Image = Action;

                trigger OnAction()
                begin
                    SaaSWebhookSetup();
                end;
            }
        }
    }

    var
        IsSaaS: Boolean;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsSaaS := not EnvironmentInformation.IsOnPrem();
    end;

    local procedure SaaSWebhookSetup()
    var
        AADApplication: Record "AAD Application";
    begin
        CreateAzureADVippsMobilepayApplication(AADApplication);
        TryGrantPermission(AADApplication);
    end;


    local procedure TryGrantPermission(var AADApplication: Record "AAD Application")
    var
        OAuth2: Codeunit OAuth2;
        ErrLbl: Label 'An error occoured while granting access: %1';
        ClientIdLbl: Label 'ede1f55c-1a4b-4873-be5c-374f048d695a', Locked = true;
        ConsentUrlLbl: Label 'https://login.microsoftonline.com/common/adminconsent', Locked = true;
        ConsentSuccess: Boolean;
        PermissionError: Text;
    begin
        if (OAuth2.RequestClientCredentialsAdminPermissions(ClientIdLbl, ConsentUrlLbl, '', ConsentSuccess, PermissionError)) then begin
            if (ConsentSuccess) then begin
                AADApplication."Permission Granted" := True;
                AADApplication.Modify();
                exit;
            end;
            Error(ErrLbl, PermissionError);
        end else begin
            Error(ErrLbl, GetLastErrorText());
        end;
    end;

    local procedure CreateAzureADVippsMobilepayApplication(var AADApplication: Record "AAD Application")
    var
        AADApplicationInterface: Codeunit "AAD Application Interface";
        MissingPermissionsErr: Label 'You need to have write permission to both %1 and %2. If you do not have access to manage users and Entra ID Applications, you cannot perform this action', Comment = '%1 = table caption of "AAD Application", %2 = table caption of "Access Control"';
        UserDoestNotExistErr: Label 'The user associated with the Entra ID App (%1) does not exist. System cannot assign permissions. Before the app can be used, make sure to create the user and assign appropriate permissions', Comment = '%1 = Entra ID App Client ID';
        AppInfo: ModuleInfo;
        AccessControl: Record "Access Control";
        User: Record User;
        ClientIdLbl: Label '{ede1f55c-1a4b-4873-be5c-374f048d695a}', Locked = true;
        ClientId: Guid;
    begin
        if not (AADApplication.WritePermission() and AccessControl.WritePermission()) then
            Error(MissingPermissionsErr, AADApplication.TableCaption(), AccessControl.TableCaption());

        NavApp.GetCurrentModuleInfo(AppInfo);
        Evaluate(ClientId, ClientIdLbl);
        AADApplicationInterface.CreateAADApplication(
            ClientId,
            'Vipps Mobilepay Webhook',
            CopyStr(AppInfo.Publisher, 1, 50),
            true
        );
        AADApplication.Get(ClientId);
        AADApplication."App ID" := AppInfo.Id;
        AADApplication."App Name" := CopyStr(AppInfo.Name, 1, MaxStrLen(AADApplication."App Name"));
        AADApplication.Modify();
        Commit();

        if (not User.Get(AADApplication."User ID")) then
            Error(UserDoestNotExistErr, AADApplication."Client Id");

        AddPermissionSet(AADApplication."User ID", 'NPR Vipps Mp Webhook');

        Commit();
    end;

    local procedure AddPermissionSet(UserSecurityId: Guid; PermissionSetId: Code[20])
    var
        AccessControl: Record "Access Control";
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", PermissionSetId);
        if (not AccessControl.IsEmpty()) then
            exit;

        AggregatePermissionSet.SetRange("Role ID", PermissionSetId);
        AggregatePermissionSet.FindFirst();

        AccessControl.Init();
        AccessControl."User Security ID" := UserSecurityId;
        AccessControl."Role ID" := PermissionSetId;
        AccessControl.Scope := AggregatePermissionSet.Scope;
        AccessControl."App ID" := AggregatePermissionSet."App ID";
        AccessControl.Insert(true);
    end;

}