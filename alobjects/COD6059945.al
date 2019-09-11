codeunit 6059945 "CashKeeper API"
{
    // NPR5.29\CLVA\20161108 CASE 244944 Object Created
    // NPR5.40/NPKNAV/20180330  CASE 291921 Transport NPR5.40 - 30 March 2018


    trigger OnRun()
    begin
    end;

    var
        Txt001: Label 'CashKeeper error: %1 - %2';
        Txt002: Label 'Payment was cancelled';
        NoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";

    procedure CallCaptureStart(var SaleLinePOS: Record "Sale Line POS")
    var
        CashKeeperTransaction: Record "CashKeeper Transaction";
        CashKeeperProxy: Codeunit "CashKeeper Proxy";
        ProxyDialog: Page "Proxy Dialog";
    begin
        CashKeeperTransaction.Init;
        CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
        CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        CashKeeperTransaction."Sales Line No." := SaleLinePOS."Line No.";
        CashKeeperTransaction.Amount := SaleLinePOS."Amount Including VAT";
        CashKeeperTransaction."Order ID" := StrSubstNo('%1-%2-%3',CashKeeperTransaction."Register No.",
                                                                 CashKeeperTransaction."Sales Ticket No.",
                                                                 CashKeeperTransaction."Sales Line No.");
        CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
        CashKeeperTransaction.Action := CashKeeperTransaction.Action::Capture;
        CashKeeperTransaction.Insert;
        Commit;

        CashKeeperProxy.InitializeProtocol();
        CashKeeperProxy.SetState(CashKeeperTransaction);
        ProxyDialog.RunProtocolModal(CODEUNIT::"CashKeeper Proxy");
        //DEBUG: MESSAGE(FORMAT(CashKeeperProxy.GetStatus));
        if CashKeeperProxy.GetStatus = 1 then begin
          SaleLinePOS."EFT Approved" := true;
          SaleLinePOS.Description := SaleLinePOS.Description + ' ' + Format(CashKeeperTransaction."Transaction No.");
        end else begin
          SaleLinePOS."EFT Approved" := false;
          SaleLinePOS."Amount Including VAT" := 0;
        end;
        SaleLinePOS.Modify;
        CashKeeperProxy.GetState(CashKeeperTransaction);
        CashKeeperTransaction.Modify;
        Commit;

        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Error) then
          Error(Txt001, CashKeeperTransaction."CK Error Code", CashKeeperTransaction."CK Error Description");

        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Cancelled) then
          Error(Txt002);
    end;

    procedure CallPayOutStart(var SaleLinePOS: Record "Sale Line POS")
    var
        CashKeeperTransaction: Record "CashKeeper Transaction";
        CashKeeperProxy: Codeunit "CashKeeper Proxy";
        ProxyDialog: Page "Proxy Dialog";
    begin
        CashKeeperTransaction.Init;
        CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
        CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        CashKeeperTransaction."Sales Line No." := SaleLinePOS."Line No.";
        SaleLinePOS.CalcSums("Amount Including VAT");
        if SaleLinePOS."Amount Including VAT" < 0 then
          CashKeeperTransaction.Amount := SaleLinePOS."Amount Including VAT" * -1
        else
          CashKeeperTransaction.Amount := SaleLinePOS."Amount Including VAT";

        CashKeeperTransaction."Order ID" := StrSubstNo('%1-%2-%3',CashKeeperTransaction."Register No.",
                                                                 CashKeeperTransaction."Sales Ticket No.",
                                                                 CashKeeperTransaction."Sales Line No.");
        CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
        CashKeeperTransaction.Action := CashKeeperTransaction.Action::Pay;
        CashKeeperTransaction.Insert;
        Commit;

        CashKeeperProxy.InitializeProtocol();
        CashKeeperProxy.SetState(CashKeeperTransaction);
        ProxyDialog.RunProtocolModal(CODEUNIT::"CashKeeper Proxy");
        CashKeeperProxy.GetState(CashKeeperTransaction);
        CashKeeperTransaction.Modify;
        Commit;

        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Error) then
          Error(Txt001, CashKeeperTransaction."CK Error Code", CashKeeperTransaction."CK Error Description");

        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Cancelled) then
          Error(Txt002);
    end;
}

