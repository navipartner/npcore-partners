page 6150890 "NPR MM SubsUserAccountFactbox"
{
    Extensible = False;
    Caption = 'MM SubsUserAccountFactbox';
    PageType = CardPart;
    SourceTable = "NPR MM Member Payment Method";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Visible = ShowUserAccount;

                field(DisplayName; UserAccount.DisplayName)
                {
                    Caption = 'Display Name';
                    ToolTip = 'Specifies the value of the Display Name field.';
                    ApplicationArea = NPRRetail;
                }
                field(EmailAddress; UserAccount.EmailAddress)
                {
                    Caption = 'E-mail Address';
                    ToolTip = 'Specifies the value of the E-mail Address field.';
                    ApplicationArea = NPRRetail;
                }
                field(PhoneNo; UserAccount.PhoneNo)
                {
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the value of the Phone No. field.';
                    ApplicationArea = NPRRetail;
                }
                field(NoOfPaymentMethods; NoOfPaymentMethods)
                {
                    Caption = 'No. of Payment Methods';
                    ToolTip = 'Specifies the number of Payment Methods for the User Account.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        PaymentMethod: Record "NPR MM Member Payment Method";
                        PaymentMethods: Page "NPR MM Member Payment Methods";
                    begin
                        if NoOfPaymentMethods = 0 then
                            exit;
                        PaymentMethod.SetRange("Table No.", Database::"NPR UserAccount");
                        PaymentMethod.SetRange("BC Record ID", Rec."BC Record ID");
                        PaymentMethods.SetTableView(PaymentMethod);
                        PaymentMethods.Run();
                    end;
                }
            }
        }
    }

    var
        UserAccount: Record "NPR UserAccount";
        PreviousUserAccountNo: BigInteger;
        NoOfPaymentMethods: Integer;
        ShowUserAccount: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        PaymentMethod: Record "NPR MM Member Payment Method";
    begin
        if not UserAccount.Get(Rec."BC Record ID") then begin
            ShowUserAccount := false;
            NoOfPaymentMethods := 0;
            PreviousUserAccountNo := 0;
        end else
            if (UserAccount.AccountNo <> PreviousUserAccountNo) then begin
                PaymentMethod.SetRange("Table No.", Database::"NPR UserAccount");
                PaymentMethod.SetRange("BC Record ID", UserAccount.RecordId());
                NoOfPaymentMethods := PaymentMethod.Count;
                ShowUserAccount := true;
                PreviousUserAccountNo := UserAccount.AccountNo;
            end;

    end;
}
