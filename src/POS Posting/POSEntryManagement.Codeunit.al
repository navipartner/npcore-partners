codeunit 6150629 "NPR POS Entry Management"
{
    // NPR5.36/BR  /20170705  CASE 276413 Object Created
    // NPR5.38/BR  /20180122  CASE 302690 Added function ShowSalesDocument
    // NPR5.38/BR  /20180123  CASE 302816 Fixed bug Return Sales Quantity
    // NPR5.39/BR  /20180129  CASE 302696 Bugfix quantity calculation
    // NPR5.39/BR  /20180129  CASE 302803 Fix Total Amount Calculation
    // NPR5.40/MMV /20180228  CASE 300660 Added lookup function
    // NPR5.40/MMV /20180328  CASE 276562 Adjusted totals for debit sale
    // NPR5.48/MMV /20181120  CASE 318028 French audit
    // NPR5.51/MMV /20190624  CASE 356076 Added support for new total fields.
    //                                    Fixed header "Sales Amount" containing amount excl. VAT of only the last sale line.
    //                                    Now called "Direct Item Sales (LCY)" based on what audit roll -> pos entry upgrade does.
    // NPR5.51/ZESO/20190701  CASE 360453 Set Request Page to True
    // NPR5.51/MHA /20190718  CASE 362329 Skip "Exclude from Posting" Sales Lines
    // NPR5.51/ALPO/20190802  CASE 362747 Handle check of allowed number of receipt reprints
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/ALPO/20191218 CASE 382911 'DeObfuscateTicketNo' function moved here from CUs 6150798 and 6150821 to avoid code duplication
    // NPR5.55/SARA/20200608 CASE 401473 Update Discount Amount in POS Entry


    trigger OnRun()
    begin
    end;

    var
        TextInconsistent: Label '%1 is set to %2 on %3 and to %4 on %4. %5 is inconsistent.';
        ReprintNotAllowedErrMsg: Label 'Additional reprints are not allowed for current sale (%1 %2).';

    procedure RecalculatePOSEntry(var POSEntry: Record "NPR POS Entry"; var EntryModified: Boolean)
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        POSPaymentLine: Record "NPR POS Payment Line";
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
        NoOfSalesLines: Integer;
        CalcTotalAmountInclVATInclRounding: Decimal;
        CalcItemReturnsAmount: Decimal;
    begin
        if POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted then
            exit;
        POSTaxCalculation.RefreshPOSTaxLines(POSEntry);

        with POSEntry do begin
            POSSalesLine.SetRange("POS Entry No.", "Entry No.");
            //-NPR5.51 [362329]
            POSSalesLine.SetRange("Exclude from Posting", false);
            //+NPR5.51 [362329]
            //-#362329 [362329]
            POSSalesLine.SetRange("Exclude from Posting", false);
            //+#362329 [362329]
            if POSSalesLine.FindSet then
                repeat
                    //-NPR5.51 [356076]
                    CalcTotalAmountInclVATInclRounding += POSSalesLine."Amount Incl. VAT";

                    if POSSalesLine.Type <> POSSalesLine.Type::Rounding then begin
                        //+NPR5.51 [356076]
                        CalcTotalAmount += POSSalesLine."Amount Excl. VAT";
                        CalcTotalAmountInclVAT += POSSalesLine."Amount Incl. VAT";
                        NoOfSalesLines += 1;

                        //-NPR5.51 [356076]
                        if POSSalesLine.Type = POSSalesLine.Type::Item then begin
                            if POSSalesLine.Quantity > 0 then
                                CalcItemSalesAmount += POSSalesLine."Amount Incl. VAT (LCY)";
                            if POSSalesLine.Quantity < 0 then
                                CalcItemReturnsAmount += POSSalesLine."Amount Incl. VAT (LCY)";
                        end;
                        //+NPR5.51 [356076]

                        if POSSalesLine.Type in [POSSalesLine.Type::Item, POSSalesLine.Type::"G/L Account"] then begin
                            if POSSalesLine.Quantity > 0 then
                                CalcSalesQty += POSSalesLine.Quantity
                            else
                                CalcReturnSalesQty += POSSalesLine.Quantity;
                        end;
                        //-NPR5.55 [401473]
                        CalcDiscountAmount += POSSalesLine."Line Discount Amount Excl. VAT";
                        //+NPR5.55 [401473]
                    end;
                until POSSalesLine.Next = 0;

            POSTaxAmountLine.Reset;
            POSTaxAmountLine.SetRange("POS Entry No.", "Entry No.");
            if POSTaxAmountLine.FindSet then
                repeat
                    CalcTotalVATAmount := CalcTotalVATAmount + POSTaxAmountLine."Tax Amount";
                until POSTaxAmountLine.Next = 0;

            POSPaymentLine.Reset;
            POSPaymentLine.SetRange("POS Entry No.", "Entry No.");
            if POSPaymentLine.FindSet then
                repeat
                    CalcTotalPaymentAmountLCY := CalcTotalPaymentAmountLCY + POSPaymentLine."Amount (LCY)";
                until POSPaymentLine.Next = 0;

            if (CalcItemSalesAmount <> "Item Sales (LCY)") then begin
                Validate("Item Sales (LCY)", CalcItemSalesAmount);
                EntryModified := true;
            end;
            if (CalcDiscountAmount <> "Discount Amount") then begin
                Validate("Discount Amount", CalcDiscountAmount);
                EntryModified := true;
            end;
            if (CalcSalesQty <> "Sales Quantity") then begin
                Validate("Sales Quantity", CalcSalesQty);
                EntryModified := true;
            end;
            if (CalcReturnSalesQty <> "Return Sales Quantity") then begin
                Validate("Return Sales Quantity", CalcReturnSalesQty);
                EntryModified := true;
            end;
            if (CalcTotalAmount <> "Amount Excl. Tax") then begin
                Validate("Amount Excl. Tax", CalcTotalAmount);
                EntryModified := true;
            end;
            if (CalcTotalVATAmount <> "Tax Amount") then begin
                Validate("Tax Amount", CalcTotalVATAmount);
                EntryModified := true;
            end;
            if (CalcTotalAmountInclVAT <> "Amount Incl. Tax") then begin
                Validate("Amount Incl. Tax", CalcTotalAmountInclVAT);
                EntryModified := true;
            end;
            if "Entry Type" <> "Entry Type"::"Credit Sale" then begin
                DifferenceAmount := CalcTotalPaymentAmountLCY - CalcTotalAmountInclVAT;
                if (DifferenceAmount <> "Rounding Amount (LCY)") then begin
                    Validate("Rounding Amount (LCY)", DifferenceAmount);
                    EntryModified := true;
                end;
            end;
            if NoOfSalesLines <> "No. of Sales Lines" then begin
                Validate("No. of Sales Lines", NoOfSalesLines);
                EntryModified := true;
            end;
            //-NPR5.51 [356076]
            if CalcTotalAmountInclVATInclRounding <> "Amount Incl. Tax & Round" then begin
                Validate("Amount Incl. Tax & Round", CalcTotalAmountInclVATInclRounding);
                EntryModified := true;
            end;
            if CalcItemReturnsAmount <> "Item Returns (LCY)" then begin
                Validate("Item Returns (LCY)", CalcItemReturnsAmount);
                EntryModified := true;
            end;
            //+NPR5.51 [356076]
        end;
    end;

    procedure CheckPostingSetup()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if POSPostingSetup.FindSet then
            repeat
                CheckPostingSetupLine(POSPostingSetup);
            until POSPostingSetup.Next = 0;
    end;

    procedure CheckPostingSetupLine(POSPostingSetup: Record "NPR POS Posting Setup")
    begin
        with POSPostingSetup do begin
            if "Account Type" = "Account Type"::"Bank Account" then begin
                TestField("Account No.");
                CheckBankPaymentMethodConsistent("Account No.", "POS Payment Method Code");
            end;

            if "Difference Account Type" = "Difference Account Type"::"Bank Account" then begin
                TestField("Difference Acc. No.");
                TestField("Difference Acc. No. (Neg)");
                CheckBankPaymentMethodConsistent("Difference Acc. No.", "POS Payment Method Code");
                CheckBankPaymentMethodConsistent("Difference Acc. No. (Neg)", "POS Payment Method Code");
            end;
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

    procedure GetPOSUnit(RegisterNo: Code[10]): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
        Register: Record "NPR Register";
    begin
        if POSUnit.Get(RegisterNo) then
            exit(RegisterNo);
        CreatePOSUnit(RegisterNo);
        exit(RegisterNo);
    end;

    local procedure CreatePOSUnit(POSUnitCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPaymentBin: Record "NPR POS Payment Bin";
        Register: Record "NPR Register";
    begin
        POSUnit.Init;
        Register.Get(POSUnitCode);
        POSUnit."No." := Register."Register No.";
        POSUnit.Name := Register.Name;
        //-NPR5.53 [371956]-revoked (Dimensions are controlled now from POS Unit)
        //POSUnit.VALIDATE("Global Dimension 1 Code",Register."Global Dimension 1 Code");
        //POSUnit.VALIDATE("Global Dimension 2 Code",Register."Global Dimension 2 Code");
        //+NPR5.53 [371956]-revoked
        if not POSStore.Get(POSUnitCode) then
            CreatePOSStore(POSUnit, Register);
        if not POSPaymentBin.Get(POSUnitCode) then
            CreateBinCodeFromUnit(POSUnit, POSStore);
        POSUnit.Validate("POS Store Code", POSStore.Code);
        POSUnit.Validate("Default POS Payment Bin", POSPaymentBin."No.");
        POSUnit.Insert(true);
    end;

    local procedure CreatePOSStore(var POSUnit: Record "NPR POS Unit"; Register: Record "NPR Register")
    var
        POSStore: Record "NPR POS Store";
    begin
        POSStore.Init;
        POSStore.Code := POSUnit."No.";
        POSStore.Validate(Name, Register.Name);
        POSStore.Validate("Name 2", Register."Name 2");
        POSStore.Validate(Address, Register.Address);
        POSStore.Validate("Post Code", Register."Post Code");
        POSStore.Validate(City, Register.City);
        POSStore.Validate("Phone No.", Register."Phone No.");
        POSStore.Validate("E-Mail", Register."E-mail");
        POSStore.Validate("Location Code", Register."Location Code");
        POSStore.Validate("VAT Registration No.", Register."VAT No.");
        //-NPR5.53 [371956]-revoked
        //POSStore.VALIDATE("Global Dimension 1 Code",Register."Global Dimension 1 Code");
        //POSStore.VALIDATE("Global Dimension 2 Code",Register."Global Dimension 2 Code");
        //+NPR5.53 [371956]-revoked
        //-NPR5.53 [371956]
        POSStore.Validate("Global Dimension 1 Code", POSUnit."Global Dimension 1 Code");
        POSStore.Validate("Global Dimension 2 Code", POSUnit."Global Dimension 2 Code");
        //+NPR5.53 [371956]
        POSStore.Validate("Gen. Bus. Posting Group", Register."Gen. Business Posting Group");
        POSStore.Validate("VAT Bus. Posting Group", Register."VAT Gen. Business Post.Gr");
        POSStore.Validate("Default POS Posting Setup", POSStore."Default POS Posting Setup"::Customer);
        POSStore.Insert(true);
    end;

    local procedure CreateBinCodeFromUnit(var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin
        POSPaymentBin.Init;
        POSPaymentBin."No." := POSUnit."No.";
        POSPaymentBin."POS Store Code" := POSStore.Code;
        POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
        POSPaymentBin.Description := POSStore.Name;
        POSPaymentBin.Insert(true);
        POSUnittoBinRelation.Init;
        POSUnittoBinRelation."POS Unit No." := POSUnit."No.";
        POSUnittoBinRelation."POS Payment Bin No." := POSPaymentBin."No.";
        POSUnittoBinRelation.Insert(true);
    end;

    procedure ShowSalesDocument(POSEntry: Record "NPR POS Entry"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        //-NPR5.38 [302690]
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
        //+NPR5.38 [302690]
    end;

    procedure FindPOSEntryViaEntryNo(EntryNo: Integer; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //-NPR5.40 [300660]
        //EntryNo = Auto increment primary key

        Clear(POSEntryOut);
        exit(POSEntryOut.Get(EntryNo));
        //+NPR5.40 [300660]
    end;

    procedure FindPOSEntryViaDocumentNo(DocumentNo: Code[20]; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //-NPR5.40 [300660]
        //DocumentNo = Unique, volatile front end no. (=SalePOS."Sales Ticket No.")

        Clear(POSEntryOut);
        POSEntryOut.SetRange("Document No.", DocumentNo);
        exit(POSEntryOut.FindFirst);
        //+NPR5.40 [300660]
    end;

    procedure FindPOSEntryViaFiscalNo(FiscalNo: Code[20]; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //-NPR5.40 [300660]
        //FiscalNo = Back end no. - Can be different from DocumentNo

        Clear(POSEntryOut);
        POSEntryOut.SetRange("Fiscal No.", FiscalNo);
        exit(POSEntryOut.FindFirst);
        //+NPR5.40 [300660]
    end;

    procedure FindPOSEntryViaPOSSaleID(POSSaleID: Integer; var POSEntryOut: Record "NPR POS Entry"): Boolean
    begin
        //-NPR5.40 [300660]
        //POSSaleID = Unique, constant front end no. (=SalePOS."POS Sale ID")

        Clear(POSEntryOut);
        POSEntryOut.SetRange("POS Sale ID", POSSaleID);
        exit(POSEntryOut.FindFirst);
        //+NPR5.40 [300660]
    end;

    procedure PrintEntry(POSEntry: Record "NPR POS Entry"; Large: Boolean)
    var
        RecRef: RecordRef;
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        IsReprint: Boolean;
    begin
        //-NPR5.48 [318028]
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryOutputLog.SetRange("Output Method", POSEntryOutputLog."Output Method"::Print);
        POSEntryOutputLog.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog."Output Type"::SalesReceipt, POSEntryOutputLog."Output Type"::LargeSalesReceipt);
        IsReprint := not POSEntryOutputLog.IsEmpty;

        //-NPR5.51 [362747]
        if IsReprint then begin
            POSEntry.TestField("POS Unit No.");
            POSUnit.Get(POSEntry."POS Unit No.");
            if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                POSAuditProfile.Init;
            if (POSAuditProfile."Allow Printing Receipt Copy" = POSAuditProfile."Allow Printing Receipt Copy"::Never)
               or
               ((POSAuditProfile."Allow Printing Receipt Copy" = POSAuditProfile."Allow Printing Receipt Copy"::"Only Once") and (POSEntryOutputLog.Count > 1))
            then
                Error(ReprintNotAllowedErrMsg, POSEntryOutputLog.FieldCaption("POS Entry No."), POSEntry."Entry No.");
        end;
        //+NPR5.51 [362747]

        OnBeforePrintEntry(POSEntry, IsReprint);

        POSEntry.SetRecFilter;
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
                        //-NPR5.51 [360453]
                        RetailReportSelectionMgt.SetRequestWindow(true);
                        //-NPR5.51 [360453]
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Balancing (POS Entry)")
                    end else
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
                end;
        end;

        OnAfterPrintEntry(POSEntry, IsReprint);
        //+NPR5.48 [318028]
    end;

    procedure DeObfuscateTicketNo(ObfucationMethod: Option "None",MI; var SalesTicketNo: Code[20])
    var
        MyBigInt: BigInteger;
        RPAuxMiscLibrary: Codeunit "NPR RP Aux - Misc. Library";
    begin
        //-NPR5.53 [382911]
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
        //+NPR5.53 [382911]
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePrintEntry(POSEntry: Record "NPR POS Entry"; IsReprint: Boolean)
    begin
        //-NPR5.48 [318028]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPrintEntry(POSEntry: Record "NPR POS Entry"; IsReprint: Boolean)
    begin
        //-NPR5.48 [318028]
    end;
}

