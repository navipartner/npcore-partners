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
                end;
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
                    NotAllFieldsFilledOutErr: Label 'All required fields must be filled out.';
                begin
                    if (Rec.FromEmailAddress = '') or (Rec.FromName = '') then
                        Error(NotAllFieldsFilledOutErr);

                    _Success := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        _Success: Boolean;
        _NPEmailAccount: Record "NPR NP Email Account";
        _MailManagement: Codeunit "Mail Management";

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
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
}
#endif