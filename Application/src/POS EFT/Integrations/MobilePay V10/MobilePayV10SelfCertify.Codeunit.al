codeunit 6014508 "NPR MobilePayV10 SelfCertify"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Read more about self-certification here: https://developer.mobilepay.dk/products/point-of-sale/certification
    /// </summary>
    [Test]
    [HandlerFunctions('DefaultMessageHandler')]
    internal procedure PosOnboardOffboard()
    var
        MobilePayV10SelfCert: Codeunit "NPR MobilePayV10 SelfCertify";
        EftSetup: Record "NPR EFT Setup";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
    begin
        BindSubscription(MobilePayV10SelfCert);

        CreateEftSetup(EftSetup);
        CreateMobilePayV10UnitSetup(EftSetup, MobilePayV10UnitSetup);

        CreatePos(EftSetup);
        WaitBetweenSteps();

        DeletePos(EftSetup, MobilePayV10UnitSetup);
        WaitBetweenSteps();

        MobilePayV10UnitSetup.Find();
        MobilePayV10UnitSetup.Delete();
        EftSetup.Delete();
        CreateEftSetup(EftSetup);
        CreateMobilePayV10UnitSetup(EftSetup, MobilePayV10UnitSetup);

        WaitBetweenSteps();

        Commit();

        CreatePos(EftSetup);
        WaitBetweenSteps();

        UnBindSubscription(MobilePayV10SelfCert);   // Not needed but for sanity reasons.

        WaitBetweenCertificationAreas();
        Commit();
    end;

    [Test]
    //[HandlerFunctions('DefaultMessageHandler')]
    internal procedure CompletePayment()
    var
        MobilePayV10SelfCert: Codeunit "NPR MobilePayV10 SelfCertify";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        EftSetup: Record "NPR EFT Setup";
        eftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        BindSubscription(MobilePayV10SelfCert);

        CreateEftSetup(EftSetup);
        CreateMobilePayV10UnitSetup(EftSetup, MobilePayV10UnitSetup);

        // Case 1: Complete a payment
        InitPayment(EftSetup, eftTrxRequest);
        Commit();

        //Sleep(1000);
        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        //Sleep(5000);
        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        //Sleep(10000);

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        WaitBetweenSteps();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        CapturePayment(EftSetup, eftTrxRequest);
        Commit();

        WaitBetweenSteps();

        // Case 2: Handle payment cancelled by user
        InitPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        WaitBetweenSteps();

        // Case 3: Cancel payment
        InitPayment(EftSetup, eftTrxRequest);
        Commit();

        CancelPayment(EftSetup, eftTrxRequest);
        Commit();

        WaitBetweenSteps();

        // Case 4: Clean up an active payment when trying to initiate a new one
        StartNewPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        //MobilePayV10UnitSetup.Delete();
        //EftSetup.Delete();

        UnBindSubscription(MobilePayV10SelfCert);   // Not needed but for sanity reasons.

        WaitBetweenCertificationAreas();
    end;

    [Test]
    internal procedure CompleteRefunds()
    var
        MobilePayV10SelfCert: Codeunit "NPR MobilePayV10 SelfCertify";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        EftSetup: Record "NPR EFT Setup";
        eftTrxRequest: Record "NPR EFT Transaction Request";
        refundEftTrxRequest: Record "NPR EFT Transaction Request";
        lookupEftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        BindSubscription(MobilePayV10SelfCert);

        CreateEftSetup(EftSetup);
        CreateMobilePayV10UnitSetup(EftSetup, MobilePayV10UnitSetup);

        // Case 1: Complete a refund

        // Init and capture any payment
        InitAndCapturePayment(EftSetup, eftTrxRequest);

        // Start with refund
        InitRefund(EftSetup, refundEftTrxRequest, eftTrxRequest);
        Commit();

        QueryRefund(EftSetup, refundEftTrxRequest);
        Commit();

        QueryRefund(EftSetup, refundEftTrxRequest);
        Commit();

        QueryRefund(EftSetup, refundEftTrxRequest);
        Commit();

        QueryRefund(EftSetup, refundEftTrxRequest);
        Commit();

        CaptureRefund(EftSetup, refundEftTrxRequest);
        Commit();

        WaitBetweenSteps();

        // Case 2: Cancel a refund
        // => Init and capture payment
        InitAndCapturePayment(EftSetup, eftTrxRequest);
        // Initiate full refund
        InitRefund(EftSetup, refundEftTrxRequest, eftTrxRequest, false);
        Commit();
        // Cancel refund
        CreateLookupRequest(EftSetup, lookupEftTrxRequest, refundEftTrxRequest);
        Commit();
        SendTrxRequest(lookupEftTrxRequest);
        Commit();

        UnBindSubscription(MobilePayV10SelfCert);   // Not needed but for sanity reasons.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MobilePayV10 Protocol", 'OnBeforeGetBaseURL', '', false, false)]
    local procedure OnBeforeGetBaseURLEventHandler(var url: Text; var handled: Boolean)
    begin
        handled := true;
        url := GetSelfCertApiUrl();
    end;

    [MessageHandler]
    procedure DefaultMessageHandler(Message: Text[1024])
    begin
        Sleep(1);   // TODO: Write the handler code.
    end;

    local procedure CreatePos(var EftSetup: Record "NPR EFT Setup")
    var
        mobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        mobilePayV10Integration.CreatePOS(EftSetup);
    end;

    local procedure DeletePos(var EftSetup: Record "NPR EFT Setup"; var MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup")
    var
        mobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        mobilePayV10Integration.DeletePOS(EftSetup, MobilePayV10UnitSetup);
    end;

    local procedure CreateEftSetup(var EftSetup: Record "NPR EFT Setup")
    begin
        if EftSetup.GET(GetSelfCertPosPaymentType(), GetSelfCertMerchangPosId()) then
            exit;

        EftSetup.Init();
        EftSetup.Validate("Payment Type POS", GetSelfCertPosPaymentType());
        EftSetup.Validate("POS Unit No.", GetSelfCertMerchangPosId());
        EftSetup.Validate("EFT Integration Type", GetSelfCertEftIntegrationType());
        EftSetup.Insert();
    end;

    local procedure CreateMobilePayV10UnitSetup(var EftSetup: Record "NPR EFT Setup"; var MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup")
    begin
        if MobilePayV10UnitSetup.Get(EftSetup."POS Unit No.") then
            exit;

        MobilePayV10UnitSetup.Init();
        MobilePayV10UnitSetup.Validate("POS Unit No.", EftSetup."POS Unit No.");
        MobilePayV10UnitSetup.Validate("Merchant POS ID", GetSelfCertMerchangPosId());
        MobilePayV10UnitSetup.Insert(true);

        MobilePayV10UnitSetup.Validate("Store ID", GetSelfCertStoreId());
        MobilePayV10UnitSetup.Validate("Only QR", true);
        MobilePayV10UnitSetup.Modify();
    end;

    local procedure InitPayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        InitPayment(EftSetup, EftTrxRequest, true);
    end;

    local procedure InitPayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request"; ThrowError: Boolean): Boolean
    var
        mobilePayStartPaymentRequest: Codeunit "NPR MobilePayV10 Start Payment";
        success: Boolean;
    begin
        CreatePaymentRequest(EftSetup, eftTrxRequest);
        Commit();
        success := mobilePayStartPaymentRequest.Run(eftTrxRequest);
        Commit();

        if (ThrowError AND (not success)) then begin
            Error(GetLastErrorText());
        end;

        exit(success);
    end;

    local procedure InitRefund(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request";
        var OrigEftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        InitRefund(EftSetup, EftTrxRequest, OrigEftTrxRequest, true);
    end;

    local procedure InitRefund(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request";
        var OrigEftTrxRequest: Record "NPR EFT Transaction Request"; ThrowError: Boolean): Boolean
    var
        mobilePayStartRefundRequest: Codeunit "NPR MobilePayV10 Start Refund";
        success: Boolean;
    begin
        CreateRefundRequest(EftSetup, eftTrxRequest, OrigEftTrxRequest);
        Commit();
        success := mobilePayStartRefundRequest.Run(eftTrxRequest);
        Commit();
        EftTrxRequest.Find();

        if (ThrowError AND (not success)) then begin
            Error(GetLastErrorText());
        end;

        exit(success);
    end;

    local procedure StartNewPayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        CreatePaymentRequest(EftSetup, eftTrxRequest);
        Commit();
        SendTrxRequest(EftTrxRequest);
        Commit();
        EftTrxRequest.Find();
    end;

    local procedure QueryPayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.PollTrxStatus(EftTrxRequest, EftSetup);
    end;

    local procedure QueryRefund(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.PollTrxStatus(EftTrxRequest, EftSetup);
    end;

    local procedure CapturePayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.CaptureTrx(EftTrxRequest, EftSetup);
    end;

    local procedure CaptureRefund(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.CaptureTrx(EftTrxRequest, EftSetup);
    end;

    local procedure CancelPayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.RequestAbort(EftTrxRequest, EftSetup);
    end;

    local procedure SendTrxRequest(var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayV10Protocol.SetRunningOutOfPosSession(true);
        mobilePayV10Protocol.SendTrxRequest(EftTrxRequest);
    end;

    local procedure InitAndCapturePayment(var EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        // Init and capture any payment
        InitPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        QueryPayment(EftSetup, eftTrxRequest);
        Commit();

        CapturePayment(EftSetup, eftTrxRequest);
        Commit();
    end;

    local procedure CreatePaymentRequest(EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        EftTrxRequest.Init();
        EftTrxRequest."Entry No." := 0;
        EftTrxRequest.Insert();
        eftTrxRequest."Register No." := EftSetup."POS Unit No.";
        EftTrxRequest."Original POS Payment Type Code" := EftSetup."Payment Type POS";
        EftTrxRequest."Reference Number Input" := Format(EftTrxRequest."Entry No.");
        EftTrxRequest."Amount Input" := 100;
        EftTrxRequest."Currency Code" := 'DKK';
        EftTrxRequest."Sales Ticket No." := StrSubstNo('MPayCert-%1', Format(EftTrxRequest."Entry No."));
        EftTrxRequest."Processing Type" := EftTrxRequest."Processing Type"::PAYMENT;
        EftTrxRequest.Modify();
    end;

    local procedure CreateRefundRequest(EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request"; var OrigEftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        EftTrxRequest.Init();
        EftTrxRequest."Entry No." := 0;
        EftTrxRequest.Insert();
        eftTrxRequest."Register No." := EftSetup."POS Unit No.";
        EftTrxRequest."Original POS Payment Type Code" := EftSetup."Payment Type POS";
        EftTrxRequest."Reference Number Input" := Format(EftTrxRequest."Entry No.");
        EftTrxRequest."Amount Input" := OrigEftTrxRequest."Amount Input";
        EftTrxRequest."Currency Code" := OrigEftTrxRequest."Currency Code";
        EftTrxRequest."Sales Ticket No." := OrigEftTrxRequest."Sales Ticket No.";
        EftTrxRequest."Processing Type" := EftTrxRequest."Processing Type"::REFUND;
        EftTrxRequest."Processed Entry No." := OrigEftTrxRequest."Entry No.";
        EftTrxRequest.Modify();
    end;

    local procedure CreateLookupRequest(EftSetup: Record "NPR EFT Setup"; var EftTrxRequest: Record "NPR EFT Transaction Request"; var OrigEftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        EftTrxRequest.Init();
        EftTrxRequest."Entry No." := 0;
        EftTrxRequest.Insert();
        eftTrxRequest."Register No." := EftSetup."POS Unit No.";
        EftTrxRequest."Original POS Payment Type Code" := EftSetup."Payment Type POS";
        EftTrxRequest."Reference Number Input" := Format(EftTrxRequest."Entry No.");
        EftTrxRequest."Sales Ticket No." := OrigEftTrxRequest."Sales Ticket No.";
        EftTrxRequest."Processing Type" := EftTrxRequest."Processing Type"::LOOK_UP;
        EftTrxRequest."Processed Entry No." := OrigEftTrxRequest."Entry No.";
        EftTrxRequest.Modify();
    end;
    #region CONSTANTS AND CONFIGURATIONS
    local procedure GetSelfCertApiUrl(): Text
    begin
        exit('https://api.sandbox.mobilepay.dk/pos-self-certification-api');
    end;

    local procedure GetSelfCertStoreId(): Text
    begin
        exit('9d0a9c45-1793-4e82-9410-b0ee6779ab60');
    end;

    local procedure GetSelfCertMerchangPosId(): Code[10]
    begin
        exit('5');  // TODO: Change this!
    end;

    local procedure GetSelfCertEftIntegrationType(): Code[20]
    begin
        exit('MOBILEPAY_V10');  // TODO: Change this!
    end;

    local procedure GetSelfCertPosPaymentType(): Code[10]
    begin
        exit('T');  // TODO: Change this!
    end;

    local procedure WaitBetweenSteps()
    begin
        Sleep(2000);
    end;

    local procedure WaitBetweenCertificationAreas()
    begin
        Sleep(15000);
    end;
    #endregion
}