page 6060154 "NPR Event Standard Dialog"
{
    Extensible = False;
    Caption = 'Event Standard Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            field(MessageText; MessageText)
            {

                Caption = 'Message';
                Visible = ShowMessage;
                ToolTip = 'Specifies the value of the Message field';
                ApplicationArea = NPRRetail;
            }
            field(Password; Password)
            {

                Caption = 'Password';
                ExtendedDatatype = Masked;
                Visible = ShowPassword;
                ToolTip = 'Specifies the value of the Password field';
                ApplicationArea = NPRRetail;
            }
            field(ConfirmPassword; ConfirmPassword)
            {

                Caption = 'Confirm Password';
                ExtendedDatatype = Masked;
                Visible = ShowPassword;
                ToolTip = 'Specifies the value of the Confirm Password field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if ShowPassword then
            if Password <> ConfirmPassword then
                Error(PasswordsMatchErr);
    end;

    var
        MessageText: Text[30];
        ShowMessage: Boolean;
        Password: Text;
        ConfirmPassword: Text;
        ShowPassword: Boolean;
        PasswordsMatchErr: Label 'Passwords do not match.';

    procedure UseForMessage()
    begin
        ShowMessage := true;
    end;

    procedure UseForPassword()
    begin
        ShowPassword := true;
    end;

    procedure GetMessage(): Text
    begin
        exit(MessageText);
    end;

    procedure GetPassword(): Text
    begin
        exit(ConfirmPassword);
    end;
}

