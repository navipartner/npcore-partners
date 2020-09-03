codeunit 6014562 "NPR Report: Terminal Ticket"
{
    // NPR5.20/BR/20160229 CASE 231481 Support for Pepper
    // NPR5.29/BR/20161222 CASE 261666 Certification requirements NETS
    // NPR5.35/BR  /20170803 CASE 285804 Added Receipt No. so that a cut can be made between Merchant and Client tickets
    // NPR5.36/BR/20170320 CASE 268704 Changed Certifcation requirements NETS
    // NPR5.36/MMV /20170711 CASE 283791 Moved "No. Printed" increment away from print.
    //                                   Removed legacy cut logic.
    // NPR5.46/MMV /20181005 CASE 290734 EFT Framework refactored.

    TableNo = "NPR EFT Receipt";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.25, 0.25, 0.5);
        GetRecords(Rec);

        Printer.SetFont('A11');

        PrintLines(CreditCardTransaction);

        Printer.SetFont('Control');
        Printer.AddLine('P');
        Printer.SetFont('A11');
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        CreditCardTransaction: Record "NPR EFT Receipt";
        Register: Record "NPR Register";
        First: Boolean;
        NotFirst: Boolean;
        DontCut: Boolean;
        FirstLineText: Text[100];
        txtCopy: Label '*** COPY ***';
        txtCopyCentred: Label '******************COPY******************';
        ThisReceiptNo: Integer;
        ThisRequestEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";

    procedure PrintLines(var CreditCardTransaction: Record "NPR EFT Receipt")
    begin
        with CreditCardTransaction do begin
            if FindSet then
                repeat
                    CreditCardTransOnAftGetRecord(CreditCardTransaction);
                    PrintLine(CreditCardTransaction);
                until Next = 0;
        end;
    end;

    procedure PrintLine(var CreditCardTransaction: Record "NPR EFT Receipt")
    var
        NewSlip: Boolean;
        CopyCaption: Text;
    begin
        NewSlip := (ThisReceiptNo <> CreditCardTransaction."Receipt No.") or (ThisRequestEntryNo <> CreditCardTransaction."EFT Trans. Request Entry No.");

        if NewSlip then begin
            ThisRequestEntryNo := CreditCardTransaction."EFT Trans. Request Entry No.";
            //-NPR5.46 [290734]
            if ThisRequestEntryNo <> 0 then
                EFTTransactionRequest.Get(ThisRequestEntryNo);
            //+NPR5.46 [290734]
            ThisReceiptNo := CreditCardTransaction."Receipt No.";
            Printer.SetFont('Control');
            Printer.AddLine('P');
        end;

        if Register."Credit Card Solution" = Register."Credit Card Solution"::Pepper then begin
            Printer.SetFont('A11');
            CopyCaption := txtCopyCentred;
        end else begin
            Printer.SetFont('B21');
            CopyCaption := txtCopy;
        end;

        //-NPR5.46 [290734]
        //IF (CreditCardTransaction."No. Printed" > 0) AND (NewSlip OR (First AND NOT NotFirst)) THEN BEGIN
        if ((EFTTransactionRequest."No. of Reprints" > 0) or (CreditCardTransaction."No. Printed" > 0)) and (NewSlip or (First and not NotFirst)) then begin
            //+NPR5.46 [290734]
            Printer.SetBold(true);
            Printer.AddLine(CopyCaption);
            Printer.SetBold(false);
        end;

        Printer.AddLine(CreditCardTransaction.Text)
    end;

    procedure CreditCardTransOnAftGetRecord(var CreditCardTransaction: Record "NPR EFT Receipt")
    begin
        with CreditCardTransaction do begin
            if First then begin
                NotFirst := true;
                exit;
            end;

            First := true;
            FirstLineText := CreditCardTransaction.Text;
            ThisReceiptNo := CreditCardTransaction."Receipt No.";
            ThisRequestEntryNo := CreditCardTransaction."EFT Trans. Request Entry No.";
            //-NPR5.46 [290734]
            if ThisRequestEntryNo <> 0 then
                EFTTransactionRequest.Get(ThisRequestEntryNo);
            //+NPR5.46 [290734]
            if FirstLineText = '' then
                DontCut := true
            else
                DontCut := false;
        end;
    end;

    procedure GetRecords(var Rec: Record "NPR EFT Receipt")
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        CreditCardTransaction.CopyFilters(Rec);
        Register.Get(RetailFormCode.FetchRegisterNumber);
    end;
}

