codeunit 6150629 "NPR POS Entry Management"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        NotInitialized: Label 'Codeunit 6150629 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        POSEntry := Rec;
        case FunctionToRun of
            FunctionToRun::PrintEntry:
                PrintEntry(POSEntry, LargePrint);
            else
                Error(NotInitialized);
        end;
        Rec := POSEntry;
    end;

    var
        FunctionToRun: Option " ",PrintEntry;
        LargePrint: Boolean;
        TextInconsistent: Label '%1 is set to %2 on %3 and to %4 on %4. %5 is inconsistent.';
        ReprintNotAllowedErrMsg: Label 'Additional reprints are not allowed for current sale (%1 %2).';

    procedure SetFunctionToRun(FunctionToRunIn: Option " ",PrintEntry)
    begin
        FunctionToRun := FunctionToRunIn;
    end;

    procedure SetLargePrint(Set: Boolean)
    begin
        LargePrint := Set;
    end;

    procedure RecalculatePOSEntry(var POSEntry: Record "NPR POS Entry"; var EntryModified: Boolean)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
        CalcItemSalesAmount: Decimal;
        CalcDiscountAmount: Decimal;
        CalcSalesQty: Decimal;
        CalcReturnSalesQty: Decimal;
        CalcTotalAmount: Decimal;
        CalcTotalVATAmount: Decimal;
        CalcTotalAmountInclVAT: Decimal;
        CalcTotalPaymentAmountLCY: Decimal;
        DifferenceAmount: Decimal;
        CalcTotalAmountInclVATInclRounding: Decimal;
        CalcItemReturnsAmount: Decimal;
        NoOfSalesLines: Integer;
    begin
        if POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted then
            exit;
        POSTaxCalculation.RefreshPOSTaxLines(POSEntry);

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange("Exclude from Posting", false);
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet() then
            repeat
                CalcTotalAmountInclVATInclRounding += POSSalesLine."Amount Incl. VAT";

                if POSSalesLine.Type <> POSSalesLine.Type::Rounding then begin
                    CalcTotalAmount += POSSalesLine."Amount Excl. VAT";
                    CalcTotalAmountInclVAT += POSSalesLine."Amount Incl. VAT";
                    NoOfSalesLines += 1;

                    if POSSalesLine.Type = POSSalesLine.Type::Item then begin
                        if POSSalesLine.Quantity > 0 then
                            CalcItemSalesAmount += POSSalesLine."Amount Incl. VAT (LCY)";
                        if POSSalesLine.Quantity < 0 then
                            CalcItemReturnsAmount += POSSalesLine."Amount Incl. VAT (LCY)";
                    end;

                    if POSSalesLine.Type in [POSSalesLine.Type::Item, POSSalesLine.Type::"G/L Account"] then begin
                        if POSSalesLine.Quantity > 0 then
                            CalcSalesQty += POSSalesLine.Quantity
                        else
                            CalcReturnSalesQty += POSSalesLine.Quantity;
                    end;
                    CalcDiscountAmount += POSSalesLine."Line Discount Amount Excl. VAT";
                end;
            until POSSalesLine.Next() = 0;

        POSTaxAmountLine.Reset();
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSTaxAmountLine.FindSet then
            repeat
                CalcTotalVATAmount := CalcTotalVATAmount + POSTaxAmountLine."Tax Amount";
            until POSTaxAmountLine.Next() = 0;

        POSPaymentLine.Reset();
        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSPaymentLine.FindSet then
            repeat
                CalcTotalPaymentAmountLCY := CalcTotalPaymentAmountLCY + POSPaymentLine."Amount (LCY)";
            until POSPaymentLine.Next() = 0;

        if (CalcItemSalesAmount <> POSEntry."Item Sales (LCY)") then begin
            POSEntry.Validate("Item Sales (LCY)", CalcItemSalesAmount);
            EntryModified := true;
        end;
        if (CalcDiscountAmount <> POSEntry."Discount Amount") then begin
            POSEntry.Validate("Discount Amount", CalcDiscountAmount);
            EntryModified := true;
        end;
        if (CalcSalesQty <> POSEntry."Sales Quantity") then begin
            POSEntry.Validate("Sales Quantity", CalcSalesQty);
            EntryModified := true;
        end;
        if (CalcReturnSalesQty <> POSEntry."Return Sales Quantity") then begin
            POSEntry.Validate("Return Sales Quantity", CalcReturnSalesQty);
            EntryModified := true;
        end;
        if (CalcTotalAmount <> POSEntry."Amount Excl. Tax") then begin
            POSEntry.Validate("Amount Excl. Tax", CalcTotalAmount);
            EntryModified := true;
        end;
        if (CalcTotalVATAmount <> POSEntry."Tax Amount") then begin
            POSEntry.Validate("Tax Amount", CalcTotalVATAmount);
            EntryModified := true;
        end;
        if (CalcTotalAmountInclVAT <> POSEntry."Amount Incl. Tax") then begin
            POSEntry.Validate("Amount Incl. Tax", CalcTotalAmountInclVAT);
            EntryModified := true;
        end;
        if POSEntry."Entry Type" <> POSEntry."Entry Type"::"Credit Sale" then begin
            DifferenceAmount := CalcTotalPaymentAmountLCY - CalcTotalAmountInclVAT;
            if (DifferenceAmount <> POSEntry."Rounding Amount (LCY)") then begin
                POSEntry.Validate("Rounding Amount (LCY)", DifferenceAmount);
                EntryModified := true;
            end;
        end;
        if NoOfSalesLines <> POSEntry."No. of Sales Lines" then begin
            POSEntry.Validate("No. of Sales Lines", NoOfSalesLines);
            EntryModified := true;
        end;
        if CalcTotalAmountInclVATInclRounding <> POSEntry."Amount Incl. Tax & Round" then begin
            POSEntry.Validate("Amount Incl. Tax & Round", CalcTotalAmountInclVATInclRounding);
            EntryModified := true;
        end;
        if CalcItemReturnsAmount <> POSEntry."Item Returns (LCY)" then begin
            POSEntry.Validate("Item Returns (LCY)", CalcItemReturnsAmount);
            EntryModified := true;
        end;
    end;

    procedure CheckPostingSetup()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if POSPostingSetup.FindSet() then
            repeat
                CheckPostingSetupLine(POSPostingSetup);
            until POSPostingSetup.Next() = 0;
    end;

    procedure CheckPostingSetupLine(POSPostingSetup: Record "NPR POS Posting Setup")
    begin
        if POSPostingSetup."Account Type" = POSPostingSetup."Account Type"::"Bank Account" then begin
            POSPostingSetup.TestField("Account No.");
            CheckBankPaymentMethodConsistent(POSPostingSetup."Account No.", POSPostingSetup."POS Payment Method Code");
        end;

        if POSPostingSetup."Difference Account Type" = POSPostingSetup."Difference Account Type"::"Bank Account" then begin
            POSPostingSetup.TestField("Difference Acc. No.");
            POSPostingSetup.TestField("Difference Acc. No. (Neg)");
            CheckBankPaymentMethodConsistent(POSPostingSetup."Difference Acc. No.", POSPostingSetup."POS Payment Method Code");
            CheckBankPaymentMethodConsistent(POSPostingSetup."Difference Acc. No. (Neg)", POSPostingSetup."POS Payment Method Code");
        end;
    end;

    local procedure CheckBankPaymentMethodConsistent(BankAccountCode: Code[20]; POSPaymentMethodCode: Code[10])
    var
        BankAccount: Record "Bank Account";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if (POSPaymentMethodCode = '') or (BankAccountCode = '') then
            exit;
        BankAccount.Get(BankAccountCode);
        POSPaymentMethod.Get(POSPaymentMethodCode);
        if (BankAccount."Currency Code" <> POSPaymentMethod."Currency Code") then
            Error(TextInconsistent, BankAccount.FieldCaption("Currency Code"), BankAccount."Currency Code", BankAccount.TableCaption, POSPaymentMethod."Currency Code", POSPaymentMethod.TableCaption, POSPostingSetup.TableCaption);
    end;
    procedure ShowSalesDocument(POSEntry: Record "NPR POS Entry"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        POSEntry.TestField("Sales Document No.");
        if SalesHeader.Get(POSEntry."Sales Document Type", POSEntry."Sales Document No.") then begin
            PAGE.Run(SalesHeader.GetCardpageID, SalesHeader);
            exit(true);
        end;
        case POSEntry."Sales Document Type" of
            POSEntry."Sales Document Type"::"Credit Memo":
                begin
                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", POSEntry."Sales Document No.");
                    if SalesCrMemoHeader.FindFirst then begin
                        PAGE.Run(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                        exit(true);
                    end;
                end;
            POSEntry."Sales Document Type"::Invoice:
                begin
                    SalesInvoiceHeader.SetRange("Pre-Assigned No.", POSEntry."Sales Document No.");
                    if SalesInvoiceHeader.FindFirst then begin
                        PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                        exit(true);
                    end;
                end;
            POSEntry."Sales Document Type"::Order:
                begin
                    SalesInvoiceHeader.SetRange("Order No.", POSEntry."Sales Document No.");
                    if SalesInvoiceHeader.FindFirst then begin
                        PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                        exit(true);
                    end;
                end;
            POSEntry."Sales Document Type"::Quote:
                begin
                    SalesHeader.SetRange("Quote No.", POSEntry."Sales Document No.");
                    if SalesHeader.FindFirst then begin
                        PAGE.Run(SalesHeader.GetCardpageID, SalesHeader);
                        exit(true);
                    end else begin
                        SalesInvoiceHeader.SetRange("Quote No.", POSEntry."Sales Document No.");
                        if SalesInvoiceHeader.FindFirst then begin
                            PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                            exit(true);
                        end;
                    end;
                end;
        end;
        exit(false);
    end;

    procedure FindPOSEntryViaEntryNo(EntryNo: Integer; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //EntryNo = Auto increment primary key
        Clear(POSEntryOut);
        exit(POSEntryOut.Get(EntryNo));
    end;

    procedure FindPOSEntryViaDocumentNo(DocumentNo: Code[20]; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //DocumentNo = Unique, volatile front end no. (=SalePOS."Sales Ticket No.")
        Clear(POSEntryOut);
        POSEntryOut.SetRange("Document No.", DocumentNo);
        exit(POSEntryOut.FindFirst());
    end;

    procedure FindPOSEntryViaFiscalNo(FiscalNo: Code[20]; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //FiscalNo = Back end no. - Can be different from DocumentNo
        Clear(POSEntryOut);
        POSEntryOut.SetRange("Fiscal No.", FiscalNo);
        exit(POSEntryOut.FindFirst());
    end;

    procedure FindPOSEntryViaPOSSaleID(POSSaleID: Integer; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //POSSaleID = Unique, constant front end no. (=SalePOS."POS Sale ID")
        Clear(POSEntryOut);
        POSEntryOut.SetRange("POS Sale ID", POSSaleID);
        exit(POSEntryOut.FindFirst());
    end;

    procedure PrintEntry(POSEntry: Record "NPR POS Entry"; Large: Boolean)
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        IsReprint: Boolean;
    begin
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryOutputLog.SetRange("Output Method", POSEntryOutputLog."Output Method"::Print);
        POSEntryOutputLog.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog."Output Type"::SalesReceipt, POSEntryOutputLog."Output Type"::LargeSalesReceipt);
        IsReprint := not POSEntryOutputLog.IsEmpty();

        if IsReprint then begin
            POSEntry.TestField("POS Unit No.");
            POSUnit.Get(POSEntry."POS Unit No.");
            if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                POSAuditProfile.Init();
            if (POSAuditProfile."Allow Printing Receipt Copy" = POSAuditProfile."Allow Printing Receipt Copy"::Never)
               or
               ((POSAuditProfile."Allow Printing Receipt Copy" = POSAuditProfile."Allow Printing Receipt Copy"::"Only Once") and (POSEntryOutputLog.Count > 1))
            then
                Error(ReprintNotAllowedErrMsg, POSEntryOutputLog.FieldCaption("POS Entry No."), POSEntry."Entry No.");
        end;

        OnBeforePrintEntry(POSEntry, IsReprint);

        POSEntry.SetRecFilter();
        RecRef.GetTable(POSEntry);
        RetailReportSelectionMgt.SetRegisterNo(POSEntry."POS Unit No.");
        case POSEntry."Entry Type" of
            POSEntry."Entry Type"::"Direct Sale":
                if Large then
                    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)")
                else
                    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");

            POSEntry."Entry Type"::"Credit Sale":
                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");

            POSEntry."Entry Type"::Balancing:
                begin
                    POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
                    POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
                    POSWorkshiftCheckpoint.FindFirst();
                    RecRef.GetTable(POSWorkshiftCheckpoint);
                    if Large then begin
                        RetailReportSelectionMgt.SetRequestWindow(true);
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Balancing (POS Entry)")
                    end else
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
                end;
        end;

        OnAfterPrintEntry(POSEntry, IsReprint);
    end;

    procedure DeObfuscateTicketNo(ObfucationMethod: Option "None",MI; var SalesTicketNo: Code[20])
    var
        RPAuxMiscLibrary: Codeunit "NPR RP Aux - Misc. Library";
        MyBigInt: BigInteger;
    begin
        case ObfucationMethod of
            ObfucationMethod::MI:  //Multiplicative Inverse
                begin
                    if StrLen(SalesTicketNo) > 2 then
                        if CopyStr(SalesTicketNo, 1, 2) = 'MI' then
                            SalesTicketNo := CopyStr(SalesTicketNo, 3);

                    if Evaluate(MyBigInt, SalesTicketNo) then
                        SalesTicketNo := Format(RPAuxMiscLibrary.MultiplicativeInverseDecode(MyBigInt), 0, 9);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePrintEntry(POSEntry: Record "NPR POS Entry"; IsReprint: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPrintEntry(POSEntry: Record "NPR POS Entry"; IsReprint: Boolean)
    begin
    end;
}