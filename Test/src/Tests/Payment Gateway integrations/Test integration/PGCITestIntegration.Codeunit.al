codeunit 85124 "NPR PG CI Test Integration" implements "NPR IPaymentGateway"
{
    // This codeunit is a singleton to ensure that state is kept across test runs.
    // We cannot test the state of the codeunit instance just by calling it locally
    // since the platform will generate a new instance when it is called from within
    // the module itself.
    SingleInstance = true;

    var
        _DidCapture: Boolean;
        _DidRefund: Boolean;
        _DidCancel: Boolean;
        _DidRunSetupCard: Boolean;
        _ShouldError: Boolean;
        _ShouldCommit: Boolean;
        _LastTransactionId: Text[250];

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        _LastTransactionId := Request."Transaction ID";
        CaptureImpl(Response."Response Success");

        if (_ShouldCommit) then
            Commit();
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        _LastTransactionId := Request."Transaction ID";
        RefundImpl(Response."Response Success");

        if (_ShouldCommit) then
            Commit();
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        _LastTransactionId := Request."Transaction ID";
        CancelImpl(Response."Response Success");

        if (_ShouldCommit) then
            Commit();
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    begin
        _DidRunSetupCard := true;
    end;
    #endregion

    #region Inner implementation
    local procedure CaptureImpl(var Success: Boolean)
    begin
        _DidCapture := true;

        if (_ShouldError) then
            Error('Failure during capture')
        else
            Success := true;
    end;

    local procedure RefundImpl(var Success: Boolean)
    begin
        _DidRefund := true;

        if (_ShouldError) then
            Error('Failure during refund')
        else
            Success := true;
    end;

    local procedure CancelImpl(var Success: Boolean)
    begin
        _DidCancel := true;

        if (_ShouldError) then
            Error('Failure during cancel')
        else
            Success := true;
    end;
    #endregion

    #region Test framework
    internal procedure Reset()
    begin
        Clear(_DidCapture);
        Clear(_DidRefund);
        Clear(_DidCancel);
        Clear(_DidRunSetupCard);
        Clear(_ShouldError);
        Clear(_ShouldCommit);
        Clear(_LastTransactionId);
    end;

    internal procedure GetDidCapture(): Boolean
    begin
        exit(_DidCapture);
    end;

    internal procedure GetDidRefund(): Boolean
    begin
        exit(_DidRefund);
    end;

    internal procedure GetDidCancel(): Boolean
    begin
        exit(_DidCancel);
    end;

    internal procedure GetDidRunSetupCard(): Boolean
    begin
        exit(_DidRunSetupCard);
    end;

    internal procedure GetLastTransactionId(): Text[250]
    begin
        exit(_LastTransactionId);
    end;

    internal procedure SetShouldError()
    begin
        _ShouldError := true;
    end;

    internal procedure SetShouldCommit()
    begin
        _ShouldCommit := true;
    end;
    #endregion
}