page 6184803 "NPR Entra App Registration"
{
    PageType = Card;
    Caption = 'Microsoft Entra Application Registration Wizard';
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Extensible = False;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(EntraAppDisplayName; EntraAppDisplayName)
                {
                    Caption = 'Application Name';
                    ToolTip = 'Specifies the display name of the Entra Application.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if EntraAppDisplayName <> '' then
                            EntraAppSecretDisplayName := EntraAppDisplayName + ' - ' + Format(Today, 0, 9);
                    end;
                }
            }
            part(PermissionSetsSubpage; "NPR Entra App Permissions")
            {
                ApplicationArea = NPRRetail;
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateApplication)
            {
                Caption = 'Create Microsoft Entra Application';
                ToolTip = 'Creates a new Microsoft Entra Application with the specified display name, secret, and permission sets.';
                ApplicationArea = NPRRetail;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Ellipsis = true;

                trigger OnAction()
                var
                    PermSets: List of [Code[20]];
                begin
                    if (not ((EntraAppDisplayName <> '') and (EntraAppSecretDisplayName <> '') and HasPermissionSets())) then begin
                        Error(FillMissingDataErr);
                    end;

                    TempPermissionSet.Reset();
                    if TempPermissionSet.FindSet() then
                        repeat
                            PermSets.Add(TempPermissionSet."Permission Set ID");
                        until TempPermissionSet.Next() = 0;

                    CreateEntraApplicationAndSecret(EntraAppDisplayName, EntraAppSecretDisplayName, PermSets);
                    Message(EntraAppCreatedMsg);
                    ClearFields();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TempPermissionSet.Reset();
        TempPermissionSet.DeleteAll();
        CurrPage.PermissionSetsSubpage.Page.SetTableView(TempPermissionSet);
    end;

    local procedure HasPermissionSets(): Boolean
    begin
        TempPermissionSet.Reset();
        exit(not TempPermissionSet.IsEmpty);
    end;

    local procedure ClearFields()
    begin
        Clear(EntraAppDisplayName);
        Clear(EntraAppSecretDisplayName);
        TempPermissionSet.DeleteAll();
        CurrPage.Update(false);
    end;

    local procedure CreateEntraApplicationAndSecret(AppDisplayName: Text[50]; SecretDisplayName: Text; PermissionSets: List of [Code[20]])
    var
        EntraApplication: Record "AAD Application";
        AadApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        EntraAppExists: Boolean;
        CreateAppConfirmMessage: Text;
    begin
        EntraApplication.Reset();
        EntraApplication.SetRange(Description, AppDisplayName);
        EntraAppExists := not EntraApplication.IsEmpty();

        if (EntraAppExists) then begin
            CreateAppConfirmMessage := StrSubstNo(RegistrationSameNameExistsQst, AppDisplayName);
        end else begin
            CreateAppConfirmMessage := StrSubstNo(CreateEntraAppQst, AppDisplayName);
        end;

        if (not ConfirmManagement.GetResponseOrDefault(CreateAppConfirmMessage, false)) then begin
            Error('');
        end;

        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayName, SecretDisplayName, PermissionSets);
    end;

    var
        EntraAppDisplayName: Text[50];
        EntraAppSecretDisplayName: Text;
        TempPermissionSet: Record "NPR Entra App Permission" temporary;
        CreateEntraAppQst: Label 'Do you want to register the Microsoft Entra Application %1?', Comment = '%1 = Application Name';
        RegistrationSameNameExistsQst: Label 'Microsoft Entra Application %1 already exists.\Do you want to create another one with the same name?', Comment = '%1 = Application Name';
        EntraAppCreatedMsg: Label 'Microsoft Entra Application created successfully.', Comment = 'Do not translate Microsoft Entra Application';
        FillMissingDataErr: Label 'You have to fill-in all required data ("Application Display Name", "Secret Display Name" and some permissions) in order to create Microsoft Entra Application.', Comment = 'Do not translate Microsoft Entra Application';

}