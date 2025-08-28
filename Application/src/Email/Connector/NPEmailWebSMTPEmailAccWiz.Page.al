#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184947 "NPR NPEmailWebSMTPEmailAccWiz"
{
    Caption = 'Setup NP Email Account';
    Extensible = false;
    SourceTable = "NPR NPEmailWebSMTPEmailAccount";
    SourceTableTemporary = true;
    PageType = NavigatePage;
    Permissions = tabledata "NPR NPEmailWebSMTPEmailAccount" = rimd;
    UsageCategory = None;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(AccountPage)
            {
                Visible = _AccountStepVisible;
                ShowCaption = false;

                field("From Name"; Rec.FromName)
                {
                    ToolTip = 'Specifies the From Name used on the account.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field("From E-mail Address"; Rec.FromEmailAddress)
                {
                    ToolTip = 'Specifies the From E-mail Address used on the account.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        Rec.FromEmailAddress := Rec.FromEmailAddress.ToLower();
                        _MailManagement.CheckValidEmailAddress(Rec.FromEmailAddress);
                        UpdateHasSenderIdentity();
                    end;
                }
            }
            group(CreateSenderIdentity)
            {
                Visible = _SenderIdentityStepVisible;
                ShowCaption = false;

                field(_Nickname; _Nickname)
                {
                    Caption = 'Nickname';
                    ToolTip = 'Specifies the Nickname of the created sender identity.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field(_ReplyToEmail; _ReplyToEmail)
                {
                    Caption = 'Reply-to E-mail Address';
                    ToolTip = 'Specifies the Reply-to E-mail Address of the created sender identity.';
                    ApplicationArea = NPRNPEmail;
                    ExtendedDatatype = EMail;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        _ReplyToEmail := _ReplyToEmail.ToLower();
                        _MailManagement.CheckValidEmailAddress(_ReplyToEmail);
                    end;
                }
                field(_Address; _Address)
                {
                    Caption = 'Address';
                    ToolTip = 'Specifies the Address of the created sender identity.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field(_City; _City)
                {
                    Caption = 'City';
                    ToolTip = 'Specifies the City of the created sender identity.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field(_Country; _Country)
                {
                    Caption = 'Country';
                    ToolTip = 'Specifies the Country of the created sender identity.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;
                    NotBlank = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Cancel)
            {
                ApplicationArea = NPRNPEmail;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action("Next")
            {
                ApplicationArea = NPRNPEmail;
                Caption = 'Next';
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Next';

                trigger OnAction()
                var
                    SenderIdentity: Record "NPR SendGrid Sender Identity";
                    Client: Codeunit "NPR SendGrid Client";
                    NotAllFieldsFilledOutErr: Label 'All required fields must be filled out.';
                begin
                    if (_AccountStepVisible) and (not _HasSenderIdentity) then begin
                        _AccountStepVisible := false;
                        _SenderIdentityStepVisible := true;
                        exit;
                    end;

                    if (_SenderIdentityStepVisible) then begin
                        if (
                            (_Nickname = '') or
                            (_ReplyToEmail = '') or
                            (_Address = '') or
                            (_City = '') or
                            (_Country = '')
                        ) then
                            Error(NotAllFieldsFilledOutErr);

                        SenderIdentity.Nickname := _Nickname;
                        SenderIdentity.FromName := Rec.FromName;
                        SenderIdentity.FromEmailAddress := Rec.FromEmailAddress;
                        SenderIdentity.ReplyToEmailAddress := _ReplyToEmail;
                        SenderIdentity.Address := _Address;
                        SenderIdentity.City := _City;
                        SenderIdentity.Country := _Country;

                        Client.CreateSenderIdentity(_NPEmailAccount.AccountId, SenderIdentity);
                        Commit();
                    end;

                    _Success := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        _Success: Boolean;
        _HasSenderIdentity: Boolean;
        _AccountStepVisible, _SenderIdentityStepVisible : Boolean;
        _Nickname: Text[250];
        _ReplyToEmail: Text[250];
        _Address: Text[100];
        _City: Text[100];
        _Country: Text[100];
        _NPEmailAccount: Record "NPR NP Email Account";
        _MailManagement: Codeunit "Mail Management";

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();

        _AccountStepVisible := true;
    end;

    internal procedure SetNPEmailAccount(NPEmailAccount: Record "NPR NP Email Account")
    begin
        _NPEmailAccount := NPEmailAccount;
    end;

    internal procedure GetEmailAccount(var EmailAccount: Record "NPR NPEmailWebSMTPEmailAccount"): Boolean
    begin
        if (_Success) then
            Rec.AccountId := CreateGuid();
        EmailAccount := Rec;
        exit(_Success);
    end;

    local procedure UpdateHasSenderIdentity()
    var
        SenderIdentity: Record "NPR SendGrid Sender Identity";
    begin
        SenderIdentity.ReadIsolation := IsolationLevel::ReadCommitted;
        SenderIdentity.SetRange(FromEmailAddress, Rec.FromEmailAddress);
        SenderIdentity.SetRange(Verified, true);
        _HasSenderIdentity := (not SenderIdentity.IsEmpty());
    end;
}
#endif