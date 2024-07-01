codeunit 6151029 "NPR RS Purhc. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Purchase Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnAfterPostInvoice', '', false, false)]
    local procedure AddGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchaseHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        RetailValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if PurchInvHeader."No." = '' then
            exit;

        FillRetailPurchaseLines(PurchaseHeader);

        if TempPurchLine.FindSet() then begin
            FilterPriceListHeader(PurchaseHeader);

            repeat
                FindPriceListLine();
                InsertRetailValueEntries(RetailValueEntry, PurchInvHeader);

                if RetailValueEntry."Entry No." <> 0 then begin
                    CreateAdditionalGLEntries(GenJnlPostLine, RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                    CreateAdditionalGLEntries(GenJnlPostLine, RetailValueEntry, RSRetailCalculationType::VAT);
                    CreateAdditionalGLEntries(GenJnlPostLine, RetailValueEntry, RSRetailCalculationType::Margin);

                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::VAT));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::"Margin with VAT"));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::Margin));
                end
            until TempPurchLine.Next() = 0;

            TempPurchLine.DeleteAll();
        end;

        FilterItemChargeLines(PurchaseHeader);
        if TempPurchLine.IsEmpty() then
            exit;

        TempPurchLine.FindSet();
        repeat
            FilterRetailItemChargeAssignment();
            if TempItemChargeAssignment.FindSet() then
                repeat
                    CreateAdditionalGLEntries(GenJnlPostLine, RetailValueEntry, RSRetailCalculationType::"Item Charge Margin With VAT");
                    CreateAdditionalGLEntries(GenJnlPostLine, RetailValueEntry, RSRetailCalculationType::"Item Charge Margin");
                until TempItemChargeAssignment.Next() = 0;
        until TempPurchLine.Next() = 0;
    end;
    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenLineFromLastGLEntry(GenJournalLine, RSRetailCalculationType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSRetailCalculationType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        case TempPurchLine.Type of
            "Purchase Line Type"::Item:
                CalculatePurchLineItemTypeAmounts(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);
            "Purchase Line Type"::"Charge (Item)":
                CalculatePurchLineItemChTypeAmounts(GenJournalLine, RSRetailCalculationType);
        end;

        SetGlobalDimensionCodes(GenJournalLine, CalculationValueEntry);

        GenJnlCheckLine.RunCheck(GenJournalLine);
        InitAmounts(GenJournalLine);
        if GenJournalLine."Bill-to/Pay-to No." = '' then
            case true of
                GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Account No.";
                GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer, GenJournalLine."Bal. Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Bal. Account No.";
            end;

        if (TempPurchLine.Type in ["Purchase Line Type"::"Charge (Item)"]) and (RSRetailCalculationType in [RSRetailCalculationType::"Item Charge Margin With VAT"]) then begin
            GenJournalLine."Debit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Credit Amount" := 0;
        end;

        PostGLAcc(GenJnlPostLine, GenJournalLine, GLEntry);

        RSRLocalizationMgt.ModifyGLRegForRetailCalculationEntries(GLRegister, GLEntry);
    end;

    local procedure InitAmounts(var GenJnlLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
    begin
        if GenJnlLine."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
            GenJnlLine.Amount := Round(GenJnlLine.Amount, Currency."Amount Rounding Precision");
            GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
            GenJnlLine."VAT Amount (LCY)" := GenJnlLine."VAT Amount";
            GenJnlLine."VAT Base Amount (LCY)" := GenJnlLine."VAT Base Amount";
        end else begin
            Currency.Get(GenJnlLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            if not GenJnlLine."System-Created Entry" then begin
                GenJnlLine."Source Currency Code" := GenJnlLine."Currency Code";
                GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
                GenJnlLine."Source Curr. VAT Base Amount" := GenJnlLine."VAT Base Amount";
                GenJnlLine."Source Curr. VAT Amount" := GenJnlLine."VAT Amount";
            end;
        end;
        if GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::None then begin
            if GenJnlLine.Amount <> Round(GenJnlLine.Amount, Currency."Amount Rounding Precision") then
                GenJnlLine.FieldError(
                  GenJnlLine.Amount,
                  StrSubstNo(NeedsRoundingErr, GenJnlLine.Amount));
            if GenJnlLine."Amount (LCY)" <> Round(GenJnlLine."Amount (LCY)") then
                GenJnlLine.FieldError(
                  "Amount (LCY)",
                  StrSubstNo(NeedsRoundingErr, GenJnlLine."Amount (LCY)"));
        end;
    end;

    local procedure InitGenLineFromLastGLEntry(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        if not GLEntry.FindLast() then
            exit;
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Posting Date" := GLEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Item Charge Margin With VAT":
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin, RSRetailCalculationType::"Item Charge Margin":
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
        end;
        GenJournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
        GenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
        GenJournalLine."Document Date" := GLEntry."Posting Date";
        GenJournalLine."Due Date" := GLEntry."Posting Date";
    end;

    local procedure SetGlobalDimensionCodes(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry")
    begin
        GenJournalLine."Shortcut Dimension 1 Code" := CalculationValueEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := CalculationValueEntry."Global Dimension 2 Code";
    end;

    local procedure PostGLAcc(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get(GenJnlLine."Account No.");
        InitGLEntry(GenJnlPostLine, GenJnlLine, GLEntry,
         GenJnlLine."Account No.", GenJnlLine."Amount (LCY)",
          GenJnlLine."Source Currency Amount", true, GenJnlLine."System-Created Entry");
        CheckGLAccDirectPosting(GenJnlLine, GLAcc);
        CheckDescriptionForGL(GLAcc, GenJnlLine.Description);
        GLEntry."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
        GLEntry."Bal. Account Type" := GenJnlLine."Bal. Account Type";
        GLEntry."Bal. Account No." := GenJnlLine."Bal. Account No.";
        GLEntry."No. Series" := GenJnlLine."Posting No. Series";
        GLEntry."Journal Templ. Name" := GenJnlLine."Journal Template Name";
        if GenJnlLine."Additional-Currency Posting" =
           GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only"
        then begin
            GLEntry."Additional-Currency Amount" := GenJnlLine.Amount;
            GLEntry.Amount := 0;
        end;
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
    end;

    local procedure InitGLEntry(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GLAccNo: Code[20]; Amount: Decimal; AmountAddCurr: Decimal; UseAmountAddCurr: Boolean; SystemCreatedEntry: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        if GLAccNo <> '' then begin
            GLAcc.Get(GLAccNo);
            GLAcc.TestField(Blocked, false);
            GLAcc.TestField("Account Type", GLAcc."Account Type"::Posting);

            if (not CheckForGLAccountType(GLAccNo, GenJnlLine)) then
                GenJnlPostLine.CheckGLAccDimError(GenJnlLine, GLAccNo);
        end;

        GLEntry.Init();
        GLEntry.CopyFromGenJnlLine(GenJnlLine);
        InitNextEntryNo();
        GLEntry."Entry No." := NextEntryNo;
        GLEntry."Transaction No." := NextTransactionNo;
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."System-Created Entry" := SystemCreatedEntry;
        GLEntry.Amount := Amount;
        GLEntry."Debit Amount" := GenJnlLine."Debit Amount";
        GLEntry."Credit Amount" := GenJnlLine."Credit Amount";
        GLEntry."Additional-Currency Amount" :=
          GLCalcAddCurrency(Amount, AmountAddCurr, GLEntry."Additional-Currency Amount", UseAmountAddCurr, GenJnlLine);
    end;
    #endregion

    #region Additional Item Ledger and Value Entry Posting

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        StdValueEntry: Record "Value Entry";
    begin
        StdValueEntry.SetRange("Location Code", TempPurchLine."Location Code");
        StdValueEntry.SetRange("Document No.", PurchInvHeader."No.");
        StdValueEntry.SetRange("Item No.", TempPurchLine."No.");
        StdValueEntry.SetRange("Document Line No.", TempPurchLine."Line No.");
        if not StdValueEntry.FindFirst() then
            exit;

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(StdValueEntry);
        InsertRetailValueEntry(RetailValueEntry, StdValueEntry);
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry")
    var
        CalculationValueEntryDescLbl: Label 'Calculation';
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);
        RetailValueEntry."Cost Amount (Actual)" := PriceListLine."Unit Price" * TempPurchLine.Quantity - StdValueEntry."Cost Amount (Actual)";
        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        RetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - StdValueEntry."Cost per Unit";
        RetailValueEntry.Description := CalculationValueEntryDescLbl;

        if (RetailValueEntry."Cost Amount (Actual)" = 0) then
            exit;

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    #endregion

    #region Retail Price Calculation

    local procedure CalculatePurchLineItemTypeAmounts(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Amount (Actual)");
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculationValueEntry."Cost Amount (Actual)", GenJournalLine) - CalculateRSGLVATAmount());
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Credit Amount", CalculateRSGLVATAmount());
        end;
    end;

    local procedure CalculatePurchLineItemChTypeAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Item Charge Margin With VAT":
                begin
                    GenJournalLine.Validate("Debit Amount", -Abs(TempItemChargeAssignment."Amount to Assign"));
                    GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
                end;
            RSRetailCalculationType::"Item Charge Margin":
                begin
                    GenJournalLine.Validate("Credit Amount", -Abs(TempItemChargeAssignment."Amount to Assign"));
                    GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
                end;
        end;
    end;

    local procedure GetRSAccountNoFromSetup(RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        LocalizationSetup.Get();
        case RSRetailCalculationType of
            RSRetailCalculationType::VAT:
                begin
                    LocalizationSetup.TestField("RS Calc. VAT GL Account");
                    exit(LocalizationSetup."RS Calc. VAT GL Account");
                end;
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Item Charge Margin With VAT":
                exit(GetInventoryAccountFromInvPostingSetup(TempPurchLine."Location Code"));
            RSRetailCalculationType::Margin, RSRetailCalculationType::"Item Charge Margin":
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempPurchLine.Quantity) * RSRLocalizationMgt.CalculateVATBreakDown(TempPurchLine."VAT Bus. Posting Group", TempPurchLine."VAT Prod. Posting Group"));
    end;

    #endregion

    #region Helper Procedures

    local procedure InitNextEntryNo()
    var
        GLEntry: Record "G/L Entry";
        LastEntryNo: Integer;
        LastTransactionNo: Integer;
    begin
        GLEntry.LockTable();
        GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
        NextEntryNo := LastEntryNo + 1;
        NextTransactionNo := LastTransactionNo + 1;
    end;

    local procedure GLCalcAddCurrency(Amount: Decimal; AddCurrAmount: Decimal; OldAddCurrAmount: Decimal; UseAddCurrAmount: Boolean; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        if (AddCurrencyCode <> '') and
           (GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::None)
        then begin
            if (GenJnlLine."Source Currency Code" = AddCurrencyCode) and UseAddCurrAmount then
                exit(AddCurrAmount);

            exit(ExchangeAmtLCYToFCY2(Amount));
        end;
        exit(OldAddCurrAmount);
    end;

    local procedure ExchangeAmtLCYToFCY2(Amount: Decimal): Decimal
    begin
        exit(Round(CurrExchRate.ExchangeAmtLCYToFCYOnlyFactor(Amount, CurrencyFactor), AddCurrency."Amount Rounding Precision"));
    end;

    local procedure PostJob(GenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    var
        JobPostLine: Codeunit "Job Post-Line";
    begin
        if not JobLine then
            exit;
        JobLine := false;
        JobPostLine.PostGenJnlLine(GenJnlLine, GLEntry);
    end;

    local procedure CheckGLAccDirectPosting(GenJnlLine: Record "Gen. Journal Line"; GLAcc: Record "G/L Account")
    begin
        if not GenJnlLine."System-Created Entry" then
            if GenJnlLine."Posting Date" = NormalDate(GenJnlLine."Posting Date") then
                GLAcc.TestField("Direct Posting", true);
    end;

    local procedure CheckDescriptionForGL(GLAccount: Record "G/L Account"; Description: Text[100])
    var
        GLEntry: Record "G/L Entry";
        DescriptionMustNotBeBlankErr: Label 'When %1 is selected for %2, %3 must have a value.', Comment = '%1: Field Omit Default Descr. in Jnl., %2 G/L Account No, %3 Description';
    begin
        if GLAccount."Omit Default Descr. in Jnl." then
            if DelChr(Description, '=', ' ') = '' then
                Error(
                    DescriptionMustNotBeBlankErr,
                    GLAccount.FieldCaption("Omit Default Descr. in Jnl."),
                    GLAccount."No.",
                    GLEntry.FieldCaption(Description));
    end;

    local procedure CheckForGLAccountType(GLAccNo: Code[20]; GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        if ((GLAccNo = GenJnlLine."Account No.") and
                 (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account")) or
                ((GLAccNo = GenJnlLine."Bal. Account No.") and
                 (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account")) then
            exit(true);
    end;

    local procedure FillRetailPurchaseLines(PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange(Type, "Purchase Line Type"::Item);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.IsEmpty() then
            exit;
        PurchaseLine.FindSet();
        repeat
            if Location.Get(PurchaseLine."Location Code") then
                if Location."NPR Retail Location" then begin
                    TempPurchLine.Init();
                    TempPurchLine.Copy(PurchaseLine);
                    TempPurchLine.Insert();
                end;
        until PurchaseLine.Next() = 0;
    end;

    local procedure FilterItemChargeLines(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange(Type, "Purchase Line Type"::"Charge (Item)");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.IsEmpty() then
            exit;
        PurchaseLine.FindSet();
        repeat
            TempPurchLine.Init();
            TempPurchLine.Copy(PurchaseLine);
            TempPurchLine.Insert();
        until PurchaseLine.Next() = 0;
    end;

    local procedure FilterRetailItemChargeAssignment()
    var
        ItemChargeAssignment: Record "Item Charge Assignment (Purch)";
        AssignedPurchLine: Record "Purchase Line";
        AssignedPurcRcptLine: Record "Purch. Rcpt. Line";
        Location: Record Location;
    begin
        ItemChargeAssignment.SetRange("Document No.", TempPurchLine."Document No.");
        ItemChargeAssignment.SetRange("Document Line No.", TempPurchLine."Line No.");
        ItemChargeAssignment.SetRange("Item Charge No.", TempPurchLine."No.");
        if ItemChargeAssignment.IsEmpty() then
            exit;

        ItemChargeAssignment.FindSet();
        repeat
            case ItemChargeAssignment."Applies-to Doc. Type" of
                "Purchase Applies-to Document Type"::Order:
                    begin
                        AssignedPurchLine.Get(ItemChargeAssignment."Applies-to Doc. Type", ItemChargeAssignment."Applies-to Doc. No.", ItemChargeAssignment."Line No.");
                        if Location.Get(AssignedPurchLine."Location Code") then
                            if Location."NPR Retail Location" then begin
                                TempItemChargeAssignment.Init();
                                TempItemChargeAssignment.Copy(ItemChargeAssignment);
                                TempItemChargeAssignment.Insert();
                            end;
                    end;
                "Purchase Applies-to Document Type"::Receipt:
                    begin
                        AssignedPurcRcptLine.Get(ItemChargeAssignment."Applies-to Doc. No.", ItemChargeAssignment."Line No.");
                        if Location.Get(AssignedPurcRcptLine."Location Code") then
                            if Location."NPR Retail Location" then begin
                                TempItemChargeAssignment.Init();
                                TempItemChargeAssignment.Copy(ItemChargeAssignment);
                                TempItemChargeAssignment.Insert();
                            end;
                    end;
            end;
        until ItemChargeAssignment.Next() = 0;
    end;

    local procedure FilterPriceListHeader(PurchaseHeader: Record "Purchase Header")
    var
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);
        PriceListHeader.SetRange("Assign-to No.", PurchaseHeader."Sell-to Customer No.");

        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, PurchaseHeader."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, PurchaseHeader."Posting Date"));
    end;

    local procedure FindPriceListLine()
    var
        PriceListNotFoundErr: Label 'Price for the Location %2 has not been found.', Comment = '%1 - Location Code';
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
    begin
        PriceListHeader.SetRange("NPR Location Code", TempPurchLine."Location Code");
        if not PriceListHeader.FindFirst() then
            PriceListHeader.SetRange("Assign-to No.", '');
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, TempPurchLine."Location Code");

        PriceListLine.SetLoadFields("Unit Price", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", TempPurchLine."No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, TempPurchLine."No.", PriceListHeader.Code, TempPurchLine."Location Code");
    end;

    local procedure GetInventoryAccountFromInvPostingSetup(LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        AssignedPurchLine: Record "Purchase Line";
        AssignedPurchRcptLine: Record "Purch. Rcpt. Line";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        case TempPurchLine.Type of
            "Purchase Line Type"::Item:
                begin
                    Item.Get(TempPurchLine."No.");

                    if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
                        Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                                InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
                end;
            "Purchase Line Type"::"Charge (Item)":
                begin
                    Item.Get(TempItemChargeAssignment."Item No.");
                    case TempItemChargeAssignment."Applies-to Doc. Type" of
                        "Purchase Applies-to Document Type"::Order:
                            begin
                                AssignedPurchLine.Get(TempItemChargeAssignment."Applies-to Doc. Type", TempItemChargeAssignment."Applies-to Doc. No.", TempItemChargeAssignment."Line No.");
                                if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
                                    Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                                            InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
                            end;
                        "Purchase Applies-to Document Type"::Receipt:
                            begin
                                AssignedPurchRcptLine.Get(TempItemChargeAssignment."Applies-to Doc. No.", TempItemChargeAssignment."Line No.");
                                if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
                                    Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                                            InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
                            end;
                    end;
                end;
        end;
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        TempPurchLine: Record "Purchase Line" temporary;
        TempItemChargeAssignment: Record "Item Charge Assignment (Purch)" temporary;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}