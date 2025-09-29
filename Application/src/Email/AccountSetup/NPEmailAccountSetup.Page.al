#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184950 "NPR NP Email Account Setup"
{
    Extensible = false;
    Caption = 'NP Email Account Setup';
    Editable = false;
    ApplicationArea = NPRNPEmail;
    UsageCategory = Administration;
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(Info)
            {
                ShowCaption = false;
                InstructionalText = 'On this page you can see the status and eventually create an NP Email Account';
            }
            group(Status)
            {
                Caption = 'Status';

                field(_AccountSetupStatus; _AccountSetupStatus)
                {
                    ApplicationArea = NPRNPEmail;
                    ShowCaption = false;
                    StyleExpr = _AccountStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNPEmailAccount)
            {
                Caption = 'Create NP Email Account';
                ToolTip = 'Running this action will launch Create NP Email Account Wizard';
                ApplicationArea = NPRNPEmail;
                Image = AddContacts;
                Enabled = (not _HasAccount);

                trigger OnAction()
                var
                    SendGridClient: Codeunit "NPR SendGrid Client";
                    NPEmailAccount: Record "NPR NP Email Account";
                    ExistingAccountFound: Boolean;
                    CreateAccountWizard: Page "NPR CreateNPEmailAccWiz";
                    ErrInfo: ErrorInfo;
                    ErrDimensions: Dictionary of [Text, Text];
                    FailedToCheckErr: Label 'Failed to check for an existing account.';
                begin
                    if (not SendGridClient.TryGetAccountFromD1Database(SendGridClient.GetEnvironmentIdentifier(), NPEmailAccount, ExistingAccountFound)) then begin
                        ErrInfo.Message := FailedToCheckErr;
                        ErrInfo.DetailedMessage := GetLastErrorText();
                        ErrDimensions.Add('callstack', GetLastErrorCallStack());
                        ErrInfo.CustomDimensions := ErrDimensions;
                        Error(ErrInfo);
                    end;

                    if (ExistingAccountFound) then begin
                        NPEmailAccount.Insert();
                        UpdateHasAccount();
                        exit;
                    end;

                    CreateAccountWizard.RunModal();
                    UpdateHasAccount();
                end;
            }
            action(DeleteNPEmailAccountSetup)
            {
                Caption = 'Delete NP Email Account Setup';
                ApplicationArea = NPRNPEmail;
                Image = RemoveContacts;
                Enabled = (_HasAccount);
                ToolTip = 'Warning: This action will permanently delete the NP Email Account Setup. This is IRREVERSIBLE and all information will be lost.';

                trigger OnAction()
                var
                    NPEmailAccount: Record "NPR NP Email Account";
                    ConfirmManagement: Codeunit "Confirm Management";
                    DeleteEmailAccountsLbl: Label 'Are you sure you want to delete the NP Email Account Setup? This is IRREVERSIBLE and the information will be lost.';
                begin
                    if ConfirmManagement.GetResponseOrDefault(DeleteEmailAccountsLbl, false) then begin
                        NPEmailAccount.DeleteAll(true);
                        UpdateHasAccount();
                    end;
                end;
            }
        }
        area(Navigation)
        {
            action(Domains)
            {
                Caption = 'Domains';
                ToolTip = 'Running this action will open a page with the associated domains.';
                ApplicationArea = NPRNPEmail;
                Image = EntriesList;
                Enabled = (_HasAccount);

                trigger OnAction()
                var
                    NPEmailDomains: Page "NPR NP Email Domains";
                begin
                    NPEmailDomains.Initialize(_AccountId);
                    NPEmailDomains.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Promoted_CreateNPEmailAccount; CreateNPEmailAccount) { }
            actionref(Promoted_Domains; Domains) { }
        }
    }

    var
        _HasAccount: Boolean;
        _AccountId: Integer;
        _AccountSetupStatus: Text;
        _AccountExistsLbl: Label 'Account setup completed!';
        _AccountMissingLbl: Label 'Account setup missing!';
        _AccountStyle: Text;

    trigger OnOpenPage()
    begin
        UpdateHasAccount();
    end;

    local procedure UpdateHasAccount()
    var
        NPEmailAccount: Record "NPR NP Email Account";
    begin
        _HasAccount := NPEmailAccount.FindFirst();
        _AccountId := NPEmailAccount.AccountId;

        if (_HasAccount) then begin
            _AccountSetupStatus := _AccountExistsLbl;
            _AccountStyle := 'Favorable';
        end else begin
            _AccountSetupStatus := _AccountMissingLbl;
            _AccountStyle := 'Unfavorable';
        end;
    end;
}
#endif