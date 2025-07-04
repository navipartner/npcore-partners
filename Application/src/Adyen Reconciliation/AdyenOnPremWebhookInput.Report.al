report 6014562 "NPR Adyen OnPrem Webhook Input"
{
    Caption = 'NP Pay OnPrem Webhook Input';
    UsageCategory = None;
    ProcessingOnly = true;
#if not BC17
    Extensible = False;
#endif

    requestpage
    {
        layout
        {
            area(content)
            {
                group("Webhook OnPrem Parameters")
                {
                    field(UserName; _UserName)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'User Name';
                        ToolTip = 'Specifies the user name for webhook authentication.';
                        ShowMandatory = true;
                    }
                    field(Password; _Password)
                    {
                        ApplicationArea = NPRRetail;
                        ExtendedDatatype = Masked;
                        Caption = 'Password';
                        ToolTip = 'Specifies the password for webhook authentication.';
                        ShowMandatory = true;
                    }
                    field(BCBaseURL; _BCBaseURL)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'BC Base URL';
                        ToolTip = 'Specifies the base URL of the Business Central instance.';
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            if _BCBaseURL <> '' then
                                _BCBaseURL := CopyStr(_BCBaseURL.TrimEnd('/'), 1, MaxStrLen(_BCBaseURL));
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            _BCBaseURL := CopyStr(GetUrl(ClientType::Web), 1, MaxStrLen(_BCBaseURL));
            _UserName := CopyStr(UserId(), 1, MaxStrLen(_UserName));
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            EnterUserNameLbl: Label 'Please enter a User Name.';
            EnterPasswordLbl: Label 'Please enter a Password.';
            EnterBaseURLLbl: Label 'Please enter a Business Central Base URL.';
        begin
            if CloseAction = Action::OK then begin
                if _UserName = '' then begin
                    Message(EnterUserNameLbl);
                    exit(false);
                end;

                if _Password = '' then begin
                    Message(EnterPasswordLbl);
                    exit(false);
                end;

                if _BCBaseURL = '' then begin
                    Message(EnterBaseURLLbl);
                    exit(false);
                end;
            end;
            exit(true);
        end;
    }

    var
        _UserName: Text[100];
        _Password: Text[100];
        _BCBaseURL: Text[2048];

    procedure GetUserName(): Text[100]
    begin
        exit(_UserName);
    end;

    procedure GetPassword(): Text[100]
    begin
        exit(_Password);
    end;

    procedure GetBCBaseURL(): Text[2048]
    begin
        exit(_BCBaseURL);
    end;
}
