codeunit 6185031 "NPR MM Subscr.Pmt.: Undefined" implements "NPR MM Subscr.Payment IHandler"
{
    Access = Internal;
    procedure ProcessPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    begin
        ThrowNoHandlerError();
    end;

    procedure RunSetupCard(SubscriptionPaymentGateway: Code[10])
    begin
        ThrowNoHandlerError();
    end;

    procedure DeleteSetupCard(SubscriptionPaymentGateway: Code[10])
    begin
        ThrowNoHandlerError();
    end;

    procedure GetPaymentPostingAccount(var AccountType: Enum "Gen. Journal Account Type"; var AccountNo: Code[20])
    begin
        AccountType := AccountType::"G/L Account";
        AccountNo := '';
        ThrowNoHandlerError();
    end;

    local procedure ThrowNoHandlerError()
    var
        NoHandlerErr: Label 'No handler registered in the system for the specified subscription payment service provider.';
    begin
        Error(NoHandlerErr);
    end;
}