codeunit 6184765 "NPR Vipps Mp Response Handler"
{
    Access = Internal;

    internal procedure AbortRequestBeforeTrxCreated(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        AbortRequestBeforeTrxCreated(EftTransactionRequest, '');
    end;

    internal procedure AbortRequestBeforeTrxCreated(var EftTransactionRequest: Record "NPR EFT Transaction Request"; ErrMessage: Text)
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        LblAborted: Label 'Vipps Mobilepay: Aborted';
    begin
        EftTransactionRequest.Successful := False;
        EftTransactionRequest."External Result Known" := True;
        EftTransactionRequest."Result Amount" := 0.0;
        EftTransactionRequest."Result Description" := 'Aborted';
#pragma warning disable AA0139
        EftTransactionRequest."Client Error" := CopyStr(ErrMessage, 1, 250);
#pragma warning restore AA0139
        EftTransactionRequest."POS Description" := LblAborted;
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    internal procedure HandleCreatedResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    begin
        if (not ParseCreatedResponse(EftTransactionRequest, WebhookContent)) then begin
            ParseErrorHandler(EftTransactionRequest, WebhookContent);
        end;
        EftTransactionRequest.Modify();
    end;

    [TryFunction]
    local procedure ParseCreatedResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        Token: JsonToken;
    begin
        WebhookContent.Get('pspReference', Token);
#pragma warning disable AA0139
        EftTransactionRequest."Reference Number Output" := Token.AsValue().AsText();
#pragma warning restore AA0139
    end;

    internal procedure HandleAuthorizedResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    begin
        if (not ParseAuthorizedResponse(EftTransactionRequest, WebhookContent)) then begin
            ParseErrorHandler(EftTransactionRequest, WebhookContent);
        end;
        EftTransactionRequest.Modify();
    end;

    [TryFunction]
    local procedure ParseAuthorizedResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        Token: JsonToken;
    begin
        WebhookContent.Get('pspReference', Token);
#pragma warning disable AA0139
        EftTransactionRequest."Reference Number Output" := Token.AsValue().AsText();
#pragma warning restore AA0139
    end;

    internal procedure HandleCapturedResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if (not ParseResponse(EftTransactionRequest, WebhookContent)) then begin
            ParseErrorHandler(EftTransactionRequest, WebhookContent);
        end;
        EftTransactionRequest.Modify();
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    internal procedure HandleRefundResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if (not ParseResponse(EftTransactionRequest, WebhookContent)) then begin
            ParseErrorHandler(EftTransactionRequest, WebhookContent);
        end;
        EftTransactionRequest.Modify();
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    internal procedure HandleCancelledResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; CancelContent: JsonObject)
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if (not ParseCancelledResponse(EftTransactionRequest, CancelContent)) then begin
            ParseErrorHandler(EftTransactionRequest, CancelContent);
        end;
        EftTransactionRequest.Modify();
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    [TryFunction]
    local procedure ParseCancelledResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; CancelContent: JsonObject)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Aggregate: JsonToken;
        CancelledAmount: JsonToken;
        Amount: JsonToken;
        DecimalAmount: Decimal;
        DecimalCancelledAmount: Decimal;
        Token: JsonToken;
    begin
        CancelContent.Get('amount', Amount);
        Amount.AsObject().Get('value', Token);
        DecimalAmount := VippsMpUtil.IntegerAmountToDecimalAmount(Token.AsValue().AsInteger());

        CancelContent.Get('aggregate', Aggregate);
        Aggregate.AsObject().Get('cancelledAmount', CancelledAmount);
        CancelledAmount.AsObject().Get('value', Token);
        DecimalCancelledAmount := VippsMpUtil.IntegerAmountToDecimalAmount(Token.AsValue().AsInteger());

        if (DecimalAmount = DecimalCancelledAmount) then begin
            EftTransactionRequest."POS Description" := 'Vipps Mobilepay Cancelled';
            EftTransactionRequest."Result Description" := 'Cancelled';
            EftTransactionRequest."Result Amount" := 0.0;
            EftTransactionRequest."External Result Known" := true;
        end else begin
            Error('Transaction was not cancelled correctly.');
        end;
    end;

    [TryFunction]
    local procedure ParseResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        WhToken: JsonToken;
    begin
#pragma warning disable AA0139
        WebhookContent.Get('msn', WhToken);
        EftTransactionRequest."External Customer ID" := WhToken.AsValue().AsText();

        WebhookContent.Get('reference', WhToken);
        EftTransactionRequest."Reference Number Output" := WhToken.AsValue().AsText();

        WebhookContent.Get('pspReference', WhToken);
        EftTransactionRequest."External Transaction ID" := WhToken.AsValue().AsText();

        WebhookContent.Get('name', WhToken);
        EftTransactionRequest."Result Description" := WhToken.AsValue().AsText();
        EftTransactionRequest."POS Description" := 'Vipps Mobilepay: ' + WhToken.AsValue().AsText();

        WebhookContent.Get('success', WhToken);
        EftTransactionRequest.Successful := WhToken.AsValue().AsBoolean();
        if (EftTransactionRequest.Successful) then begin
            WebhookContent.Get('amount', WhToken);
            WhToken.AsObject().Get('value', WhToken);
            if (EftTransactionRequest."Result Description".ToUpper() = 'REFUNDED') then begin
                EftTransactionRequest."Result Amount" := VippsMpUtil.IntegerAmountToDecimalAmount(WhToken.AsValue().AsInteger()) * -1.0;
                EftTransactionRequest."Amount Output" := EftTransactionRequest."Result Amount";
            end else begin
                EftTransactionRequest."Result Amount" := VippsMpUtil.IntegerAmountToDecimalAmount(WhToken.AsValue().AsInteger());
                EftTransactionRequest."Amount Output" := EftTransactionRequest."Result Amount";
            end;

            WebhookContent.Get('amount', WhToken);
            WhToken.AsObject().Get('currency', WhToken);
            EftTransactionRequest."Currency Code" := WhToken.AsValue().AsText();

        end;
        EftTransactionRequest."External Result Known" := True;
#pragma warning restore AA0139
    end;

    internal procedure HandleLookupResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; LookupContent: JsonObject)
    var
        oldEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        lblNotRecover: Label 'Could not recover the status of the payment, please confirm what happened in the Vipps Mobilepay Portal.';
    begin
        oldEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if (ParseLookupResponse(EftTransactionRequest, oldEFTTransactionRequest, LookupContent)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, EftTransactionRequest, 'Parse lookup success', LookupContent);
            oldEFTTransactionRequest.Recovered := True;
            oldEFTTransactionRequest."Recovered by Entry No." := EftTransactionRequest."Entry No.";
            oldEFTTransactionRequest.Modify();
        end else begin
            Message(lblNotRecover);
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EftTransactionRequest, 'Parse lookup failed', LookupContent);
            oldEFTTransactionRequest.Recoverable := False;
            oldEFTTransactionRequest.Modify();
        end;
        EFTInterface.EftIntegrationResponse(oldEFTTransactionRequest);
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    [TryFunction]
    local procedure ParseLookupResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var OldEftTransactionRequest: Record "NPR EFT Transaction Request"; LookupContent: JsonObject)
    var
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Token: JsonToken;
        Token2: JsonToken;
        Token3: JsonToken;
        Json: JsonObject;
        CapturedAmount: Integer;
        CancelSuccessLabel: Label 'The transaction was cancelled.';
    begin
#pragma warning disable AA0139
        LookupContent.Get('pspReference', Token);
        EftTransactionRequest."External Transaction ID" := Token.AsValue().AsText();
        LookupContent.Get('reference', Token);
        EftTransactionRequest."Reference Number Output" := Token.AsValue().AsText();
        LookupContent.Get('state', Token);
        EftTransactionRequest."Result Description" := Token.AsValue().AsText();
        EftTransactionRequest."POS Description" := 'Vipps Mobilepay: ' + Token.AsValue().AsText();
        EftTransactionRequest.Successful := True;
        case Token.AsValue().AsText() of
            'CREATED':
                begin
                    //we try to cancel, but if it fails just leave it.
                    if (VippsMpePaymentAPI.CancelPayment(EftTransactionRequest, Json)) then begin
                        EftTransactionRequest."External Result Known" := True;
                        EftTransactionRequest."Result Amount" := 0.00;
                        EftTransactionRequest."Result Description" := 'ABORTED';
                        EftTransactionRequest."POS Description" := 'Vipps Mobilepay: ABORTED';
                        OldEftTransactionRequest."Result Description" := 'ABORTED';
                        OldEftTransactionRequest."POS Description" := 'Vipps Mobilepay: ABORTED';
                        Message(CancelSuccessLabel);
                    end else begin
                        EftTransactionRequest."External Result Known" := True;
                        EftTransactionRequest."Result Amount" := 0.00;
                        EftTransactionRequest."Result Description" := 'CREATED';
                        EftTransactionRequest."POS Description" := 'Vipps Mobilepay: CREATED';
                        OldEftTransactionRequest."Result Description" := 'CREATED';
                        OldEftTransactionRequest."POS Description" := 'Vipps Mobilepay: CREATED';
                    end;
                end;
            'ABORTED',
            'EXPIRED',
            'TERMINATED':
                begin
                    EftTransactionRequest."External Result Known" := True;
                    EftTransactionRequest."Result Amount" := 0.00;
                    EftTransactionRequest."POS Description" := 'Vipps Mobilepay: ' + Token.AsValue().AsText();
                    OldEftTransactionRequest."POS Description" := 'Vipps Mobilepay: ' + Token.AsValue().AsText();
                    Message(CancelSuccessLabel);
                end;
            'AUTHORIZED':
                begin
                    LookupContent.Get('aggregate', Token);
                    if (OldEftTransactionRequest."Processing Type" = OldEftTransactionRequest."Processing Type"::PAYMENT) then begin
                        Token.AsObject().Get('capturedAmount', Token2);
                        Token2.AsObject().Get('value', Token3);
                        CapturedAmount := Token3.AsValue().AsInteger();
                        if (VippsMpUtil.IntegerAmountToDecimalAmount(CapturedAmount) = OldEftTransactionRequest."Amount Input") then begin
                            EftTransactionRequest."Amount Output" := VippsMpUtil.IntegerAmountToDecimalAmount(CapturedAmount);
                            EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";
                            EftTransactionRequest."Result Description" := 'Captured';
                            EftTransactionRequest."POS Description" := 'Vipps Mobilepay: Captured';
                            OldEftTransactionRequest."Result Description" := 'Captured';
                            OldEftTransactionRequest."POS Description" := 'Vipps Mobilepay: Captured';
                        end else begin
                            if (VippsMpePaymentAPI.CancelPayment(EftTransactionRequest, Json)) then begin
                                EftTransactionRequest."Result Description" := 'Cancelled';
                                EftTransactionRequest."POS Description" := 'Vipps Mobilepay: Cancelled';
                                OldEftTransactionRequest."Result Description" := 'Cancelled';
                                OldEftTransactionRequest."POS Description" := 'Vipps Mobilepay: Cancelled';
                                Json.Get('aggregate', Token);
                                Token.AsObject().Get('capturedAmount', Token2);
                                Token2.AsObject().Get('value', Token3);
                                CapturedAmount := Token3.AsValue().AsInteger();
                                EftTransactionRequest."Amount Output" := VippsMpUtil.IntegerAmountToDecimalAmount(CapturedAmount);
                                EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";
                                Message(CancelSuccessLabel);
                            end;
                        end;
                    end;
                    if (OldEftTransactionRequest."Processing Type" = OldEftTransactionRequest."Processing Type"::REFUND) then begin
                        Token.AsObject().Get('refundedAmount', Token2);
                        Token2.AsObject().Get('value', Token3);
                        EftTransactionRequest."Amount Output" := VippsMpUtil.IntegerAmountToDecimalAmount(Token3.AsValue().AsInteger()) * -1;
                        EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output"
                    end;
                    EftTransactionRequest."External Result Known" := True;
                end;
        end;
#pragma warning restore AA0139
    end;

    internal procedure HandleUnsuccessfulTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; LookupContent: JsonObject)
    var
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if (not ParseUnsuccessfulTransaction(EftTransactionRequest, LookupContent)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EftTransactionRequest, 'Parse lookup failed json', LookupContent);
            EftTransactionRequest."Client Error" := CopyStr(GetLastErrorText(), 1, 250);
        end;
        EftTransactionRequest.Modify();
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    [TryFunction]
    local procedure ParseUnsuccessfulTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; LookupContent: JsonObject)
    var
        Token: JsonToken;
    begin
        EFTTransactionRequest."External Result Known" := True;
        EFTTransactionRequest."Result Amount" := 0.0;
#pragma warning disable AA0139
        LookupContent.Get('name', Token);
        EFTTransactionRequest."Result Description" := Token.AsValue().AsText();
        EFTTransactionRequest."POS Description" := 'Vipps Mobilepay: ' + Token.AsValue().AsText();
#pragma warning restore AA0139
    end;

    local procedure ParseErrorHandler(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; WebhookContent: JsonObject)
    var
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        LblErr: Label 'Parse error';
        LblErrMsg: Label 'An error occurred when reading the data. If the problem persist, please contact your vendor.';
    begin
        VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EftTransactionRequest, 'Error Parse Created Response', WebhookContent);
        EftTransactionRequest."Result Description" := 'Parse Error';
        EftTransactionRequest."POS Description" := LblErr;
        EftTransactionRequest."Client Error" := CopyStr(GetLastErrorText(), 1, 250);
        Message(LblErrMsg);
    end;

    [TryFunction]
    internal procedure HttpErrorResponseMessage(WebhookErrorContent: JsonObject; var Msg: Text)
    var
        Token: JsonToken;
        Token2: JsonToken;
        JsonArr: JsonArray;
        Title: Text;
        Detail: Text;
        Code: Integer;
    begin
        if (WebhookErrorContent.Contains('title')) then begin
            WebhookErrorContent.Get('title', Token);
            Title := Token.AsValue().AsText();
        end;
        if (WebhookErrorContent.Contains('detail')) then begin
            WebhookErrorContent.Get('detail', Token);
            Detail := Token.AsValue().AsText();
        end;
        if (WebhookErrorContent.Contains('extraDetails')) then begin
            WebhookErrorContent.Get('extraDetails', Token);
            JsonArr := Token.AsArray();
            foreach Token in JsonArr do begin
                Token.AsObject().Get('name', Token2);
                Detail += Token2.AsValue().AsText() + ': ';
                Token.AsObject().Get('reason', Token2);
                Detail += Token2.AsValue().AsText() + '.';
            end;
        end;
        if (WebhookErrorContent.Contains('status')) then begin
            WebhookErrorContent.Get('status', Token);
            Code := Token.AsValue().AsInteger();
        end;
        if ((Title = '') and (Detail = '')) then begin
            WebhookErrorContent.WriteTo(Msg);
        end else begin
            Msg := StrSubstNo('%1 (%2): %3', Title, Code, Detail);
        end;
    end;

}