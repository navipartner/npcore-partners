page 6185048 "NPR UserAccounts"
{
    Extensible = false;
    Caption = 'User Accounts';
    ApplicationArea = NPRRetail;
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "NPR UserAccount";

    layout
    {
        area(Content)
        {
            repeater(AccountRepeater)
            {
                field(DisplayName; Rec.DisplayName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Display Name field.';
                }
                field(EmailAddress; Rec.EmailAddress)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the E-mail Address field.';
                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PaymentMethods)
            {
                Caption = 'Payment Methods';
                ToolTip = 'Runing this action will open a list of the payment methods on the user account.';
                ApplicationArea = NPRRetail;
                Image = Payment;

#if (BC17 or BC18 or BC19 or BC20)
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction()
                var
                    PaymentMethod: Record "NPR MM Member Payment Method";
                    PaymentMethods: Page "NPR MM Member Payment Methods";
                begin
                    PaymentMethod.SetRange("Table No.", Database::"NPR UserAccount");
                    PaymentMethod.SetRange("BC Record ID", Rec.RecordId());
                    PaymentMethods.SetTableView(PaymentMethod);
                    PaymentMethods.Run();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(Promoted_PaymentMethods; PaymentMethods) { }
        }
#endif
    }
}