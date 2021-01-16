page 6060154 "NPR Event Standard Dialog"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.38/TJ  /20171019    CASE 285194 Renamed function GetParameter to GetMessage
    //                                      Renamed page from Event Message Standard Dialog to Event Standard Dialog
    //                                      Added extra variables/functions for password input

    Caption = 'Event Standard Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(MessageText; MessageText)
            {
                ApplicationArea = All;
                Caption = 'Message';
                Visible = ShowMessage;
                ToolTip = 'Specifies the value of the Message field';
            }
            field(Password; Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                ExtendedDatatype = Masked;
                Visible = ShowPassword;
                ToolTip = 'Specifies the value of the Password field';
            }
            field(ConfirmPassword; ConfirmPassword)
            {
                ApplicationArea = All;
                Caption = 'Confirm Password';
                ExtendedDatatype = Masked;
                Visible = ShowPassword;
                ToolTip = 'Specifies the value of the Confirm Password field';
            }
        }
    }

    actions
    {
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

