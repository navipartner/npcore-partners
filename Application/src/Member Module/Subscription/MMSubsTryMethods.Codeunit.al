codeunit 6248294 "NPR MM Subs Try Methods"
{
    Access = Internal;
    trigger OnRun()
    begin
        case _ProcessingOption of
            1:
                CreatePayByLinkSubscriptionRequests();
        end;
    end;

    internal procedure SetSubscriptionRequestEntryNo(SubscriptionRequestEntryNo: Integer)
    begin
        _SubscriptionRequestEntryNo := SubscriptionRequestEntryNo;
    end;

    internal procedure GetSubscriptionRequestEntryNo() SubscriptionRequestEntryNo: Integer
    begin
        SubscriptionRequestEntryNo := _SubscriptionRequestEntryNo;
    end;

    internal procedure SetSubscriptionPaymentRequestEntryNo(SubscriptionPaymentRequestEntryNo: Integer)
    begin
        _SubscriptionPaymentRequestEntryNo := SubscriptionPaymentRequestEntryNo;
    end;

    internal procedure GetSubscriptionPaymentRequestEntryNo() SubscriptionPaymentRequestEntryNo: Integer
    begin
        SubscriptionPaymentRequestEntryNo := _SubscriptionPaymentRequestEntryNo;
    end;

    internal procedure GetPayByLinkSubscriptionRequest(var PayByLinkSubscriptionRequest: Record "NPR MM Subscr. Request")
    begin
        PayByLinkSubscriptionRequest := _PayByLinkSubscriptionRequest;
    end;

    internal procedure GetPayByLinkSubscriptionPaymentRequest(var PayByLinkSubscriptionPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin
        PayByLinkSubscriptionPaymentRequest := _PayByLinkSubscriptionPaymentRequest;
    end;

    internal procedure SetProcessingOption(ProcessingOption: Integer)
    begin
        _ProcessingOption := ProcessingOption;
    end;

    internal procedure GetProcessingOption() ProcessingOption: Integer
    begin
        ProcessingOption := _ProcessingOption;
    end;

    local procedure CreatePayByLinkSubscriptionRequests()
    begin
        CreatePayByLinkSubscriptionRequest(_SubscriptionRequestEntryNo, _SubscriptionPaymentRequestEntryNo, _PayByLinkSubscriptionRequest);
        CreatePayByLinkSubscrPaymentRequest(_PayByLinkSubscriptionRequest."Entry No.", _SubscriptionPaymentRequestEntryNo, _PayByLinkSubscriptionPaymentRequest)
    end;

    local procedure CreatePayByLinkSubscriptionRequest(OriginalSubscriptionRequestEntryNo: Integer; OriginalSubscriptionPaymentRequestEntryNo: Integer; var PayByLinkSubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        Clear(PayByLinkSubscriptionRequest);

        SubscriptionRequest.SetLoadFields("Subscription Entry No.", "Item No.", Description, Amount, "Currency Code", "New Valid From Date", "New Valid Until Date", "Entry No.", "Membership Code");
        SubscriptionRequest.Get(OriginalSubscriptionRequestEntryNo);

        PayByLinkSubscriptionRequest.Init();
        PayByLinkSubscriptionRequest."Subscription Entry No." := SubscriptionRequest."Subscription Entry No.";
        PayByLinkSubscriptionRequest.Type := _PayByLinkSubscriptionRequest.Type::Renew;
        PayByLinkSubscriptionRequest."Item No." := SubscriptionRequest."Item No.";
        PayByLinkSubscriptionRequest.Description := SubscriptionRequest.Description;
        PayByLinkSubscriptionRequest.Amount := SubscriptionRequest.Amount;
        PayByLinkSubscriptionRequest."Currency Code" := SubscriptionRequest."Currency Code";
        PayByLinkSubscriptionRequest."New Valid From Date" := SubscriptionRequest."New Valid From Date";
        PayByLinkSubscriptionRequest."New Valid Until Date" := SubscriptionRequest."New Valid Until Date";
        PayByLinkSubscriptionRequest."Created from Entry No." := OriginalSubscriptionPaymentRequestEntryNo;
        PayByLinkSubscriptionRequest."Membership Code" := SubscriptionRequest."Membership Code";
        PayByLinkSubscriptionRequest.Insert();
    end;

    local procedure CreatePayByLinkSubscrPaymentRequest(SubscriptionRequestEntryNo: Integer; OriginalSubscriptionPaymentRequestEntryNo: Integer; var PayByLinkSubscriptionPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        OriginalSubscriptionPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrRenewRequest: Codeunit "NPR MM Subscr. Renew: Request";
    begin
        Clear(PayByLinkSubscriptionPaymentRequest);

        OriginalSubscriptionPaymentRequest.SetLoadFields(PSP, Amount, "Currency Code", Description, "Payment E-mail", "Payment Phone No.", "External Membership No.");
        OriginalSubscriptionPaymentRequest.Get(OriginalSubscriptionPaymentRequestEntryNo);

        PayByLinkSubscriptionPaymentRequest.Init();
        PayByLinkSubscriptionPaymentRequest."Entry No." := 0;
        PayByLinkSubscriptionPaymentRequest."Batch No." := SubscrRenewRequest.GetBatchNo();
        PayByLinkSubscriptionPaymentRequest."Subscr. Request Entry No." := SubscriptionRequestEntryNo;
        PayByLinkSubscriptionPaymentRequest.Status := PayByLinkSubscriptionPaymentRequest.Status::New;
        PayByLinkSubscriptionPaymentRequest.PSP := OriginalSubscriptionPaymentRequest.PSP;
        PayByLinkSubscriptionPaymentRequest.Amount := OriginalSubscriptionPaymentRequest.Amount;
        PayByLinkSubscriptionPaymentRequest."Currency Code" := OriginalSubscriptionPaymentRequest."Currency Code";
        PayByLinkSubscriptionPaymentRequest.Description := OriginalSubscriptionPaymentRequest.Description;
        PayByLinkSubscriptionPaymentRequest.Type := PayByLinkSubscriptionPaymentRequest.Type::PayByLink;
        PayByLinkSubscriptionPaymentRequest."Set Membership Auto-Renew" := true;
        PayByLinkSubscriptionPaymentRequest."External Membership No." := OriginalSubscriptionPaymentRequest."External Membership No.";
        PayByLinkSubscriptionPaymentRequest."Payment E-mail" := OriginalSubscriptionPaymentRequest."Payment E-mail";
        PayByLinkSubscriptionPaymentRequest."Payment Phone No." := OriginalSubscriptionPaymentRequest."Payment Phone No.";
        PayByLinkSubscriptionPaymentRequest.Insert();
    end;

    var
        _ProcessingOption: Integer;
        _SubscriptionRequestEntryNo: Integer;
        _SubscriptionPaymentRequestEntryNo: Integer;
        _PayByLinkSubscriptionRequest: Record "NPR MM Subscr. Request";
        _PayByLinkSubscriptionPaymentRequest: Record "NPR MM Subscr. Payment Request";
}