codeunit 6184496 "NPR Pepper Event Sub."
{
    // NPR5.27/BR  /20161025 CASE 255131 Object Created
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback
    // NPR5.46/MM /20180924 CASE 290734 EFT Framework refactored


    // TODO: CTRLUPGRADE - Event subscriber subscribes to a removed event publisher - INVESTIGATE
    /*
    [EventSubscriber(ObjectType::Codeunit, 6014435, 'OnBeforeBalancingEvent', '', true, true)]
    local procedure OnBalanceRegisterRunEndOfDay(var Sender: Codeunit "Retail Form Code";var SalePOS: Record "Sale POS";var Register: Record Register)
    begin
        CheckRunEndOfDay(SalePOS,Register);
    end;
    */

    local procedure CheckRunEndOfDay(var SalePOS: Record "NPR Sale POS"; var Register: Record "NPR Register")
    var
        TerminalCode: Code[10];
        PepperProtocol: Codeunit "NPR Pepper Protocol";
        PepperTerminal: Record "NPR Pepper Terminal";
    begin
        if not SalePOS.TouchScreen then
            exit;
        TerminalCode := PepperProtocol.FindTerminalCode(Register);
        if TerminalCode = '' then
            exit;
        if not PepperTerminal.Get(TerminalCode) then
            exit;
        if not PepperTerminal."Close Automatically" then
            exit;
        if not (PepperTerminal.Status in [PepperTerminal.Status::Open, PepperTerminal.Status::ActiveOffline]) then
            exit;

        RunEndOfDay(SalePOS, Register);
        Commit;
    end;

    local procedure RunEndOfDay(var SalePOS: Record "NPR Sale POS"; var Register: Record "NPR Register")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
        PepperProtocol: Codeunit "NPR Pepper Protocol";
        t004: Label 'Terminal succesfully closed.';
        CCTrans: Record "NPR EFT Receipt";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then;
        LineNo := SaleLinePOS."Line No.";

        LineNo += 10000;
        SaleLinePOS.Init;
        SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
        SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.Validate("Line No.", LineNo);
        SaleLinePOS.Validate(Date, Today);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"Open/Close");
        SaleLinePOS.Validate("No.", '');
        SaleLinePOS.Validate(Quantity, -0);
        SaleLinePOS.Validate("Unit Price", 0);
        SaleLinePOS.Validate("Variant Code", '');
        PepperProtocol.InitializeProtocol;
        //-NPR5.35 [284379]
        //IF NOT PepperProtocol.Init(0,SaleLinePOS,0,0,FALSE) THEN
        if not PepperProtocol.Init(0, 0, SaleLinePOS, 0, 0, false) then
            //+NPR5.35 [284379]
            exit;
        PepperProtocol.SetTransaction(3);
        if PepperProtocol.SendTransaction then begin
            CCTrans.Reset;
            CCTrans.FilterGroup := 2;
            CCTrans.SetCurrentKey("Register No.", "Sales Ticket No.", Type);
            CCTrans.SetRange("Register No.", SaleLinePOS."Register No.");
            CCTrans.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            CCTrans.SetRange(Type, 0);
            //-NPR5.46 [290734]
            //CCTrans.SETRANGE("No. Printed", 0);
            //+NPR5.46 [290734]
            CCTrans.FilterGroup := 0;
            //-NPR5.46 [290734]
            //  IF (NOT Register."Terminal Auto Print") AND (NOT CCTrans.ISEMPTY) THEN
            //    CCTrans.PrintTerminalReceipt(FALSE);
            if CCTrans.FindSet then
                CCTrans.PrintTerminalReceipt();
            //+NPR5.46 [290734]
            Message(t004);
        end;
    end;
}

