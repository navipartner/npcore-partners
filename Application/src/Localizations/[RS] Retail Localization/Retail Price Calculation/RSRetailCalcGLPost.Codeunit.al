codeunit 6151527 "NPR RS Retail Calc. GL Post"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "G/L Register" = rm;

    internal procedure PostCalculationGLEntry(GenJnlLine: Record "Gen. Journal Line"; ValueEntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if GenJnlLine.Amount = 0 then
            exit;

        GLSetup.Get();
        _AddCurrencyCode := GLSetup."Additional Reporting Currency";

        GenJnlCheckLine.RunCheck(GenJnlLine);
        InitAmounts(GenJnlLine);

        PostGLAcc(GenJnlLine, GLEntry);

        RSRLocalizationMgt.InsertGLItemLedgerRelation(_GenJnlPostLine, GLEntry."Entry No.", ValueEntryNo);
    end;

    local procedure PostGLAcc(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get(GenJnlLine."Account No.");
        InitGLEntry(GenJnlLine, GLEntry, GenJnlLine."Account No.", GenJnlLine."Amount (LCY)", GenJnlLine."Source Currency Amount", true, GenJnlLine."System-Created Entry");
        CheckGLAccDirectPosting(GenJnlLine, GLAcc);
        CheckDescriptionForGL(GLAcc, GenJnlLine.Description);
        GLEntry."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
        GLEntry."Bal. Account Type" := GenJnlLine."Bal. Account Type";
        GLEntry."Bal. Account No." := GenJnlLine."Bal. Account No.";
        GLEntry."No. Series" := GenJnlLine."Posting No. Series";
        GLEntry."Journal Templ. Name" := GenJnlLine."Journal Template Name";
        if GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only" then begin
            GLEntry."Additional-Currency Amount" := GenJnlLine.Amount;
            GLEntry.Amount := 0;
        end;
        _GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, false);
        GLEntry.Insert();
    end;

    local procedure InitGLEntry(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GLAccNo: Code[20]; Amount: Decimal; AmountAddCurr: Decimal; UseAmountAddCurr: Boolean; SystemCreatedEntry: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        if GLAccNo <> '' then begin
            GLAcc.Get(GLAccNo);
            GLAcc.TestField(Blocked, false);
            GLAcc.TestField("Account Type", GLAcc."Account Type"::Posting);

            if not IsLineAccount(GLAccNo, GenJnlLine) then
                _GenJnlPostLine.CheckGLAccDimError(GenJnlLine, GLAccNo);
        end;

        GLEntry.Init();
        GLEntry.CopyFromGenJnlLine(GenJnlLine);
        InitNextEntryNo();
        GLEntry."Entry No." := _NextEntryNo;
        GLEntry."Transaction No." := _NextTransactionNo;
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."System-Created Entry" := SystemCreatedEntry;
        GLEntry.Amount := Amount;
        GLEntry."Debit Amount" := GenJnlLine."Debit Amount";
        GLEntry."Credit Amount" := GenJnlLine."Credit Amount";
        GLEntry."Additional-Currency Amount" := GLCalcAddCurrency(Amount, AmountAddCurr, GLEntry."Additional-Currency Amount", UseAmountAddCurr, GenJnlLine);
    end;

    local procedure InitAmounts(var GenJnlLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
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
                GenJnlLine.FieldError(GenJnlLine.Amount, StrSubstNo(NeedsRoundingErr, GenJnlLine.Amount));
            if GenJnlLine."Amount (LCY)" <> Round(GenJnlLine."Amount (LCY)") then
                GenJnlLine.FieldError("Amount (LCY)", StrSubstNo(NeedsRoundingErr, GenJnlLine."Amount (LCY)"));
        end;
    end;

    local procedure InitNextEntryNo()
    var
        GLEntry: Record "G/L Entry";
        LastEntryNo: Integer;
        LastTransactionNo: Integer;
    begin
        GLEntry.LockTable();
        GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
        _NextEntryNo := LastEntryNo + 1;
        _NextTransactionNo := LastTransactionNo + 1;
    end;

    local procedure GLCalcAddCurrency(Amount: Decimal; AddCurrAmount: Decimal; OldAddCurrAmount: Decimal; UseAddCurrAmount: Boolean; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        if (_AddCurrencyCode <> '') and (GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::None) then begin
            if (GenJnlLine."Source Currency Code" = _AddCurrencyCode) and UseAddCurrAmount then
                exit(AddCurrAmount);

            exit(ExchangeAmtLCYToFCY(Amount, GenJnlLine));
        end;
        exit(OldAddCurrAmount);
    end;

    local procedure ExchangeAmtLCYToFCY(Amount: Decimal; GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        AddCurrency: Record Currency;
        NewCurrencyDate: Date;
        UseCurrFactorOnly: Boolean;
    begin
        AddCurrency.Get(_AddCurrencyCode);

        NewCurrencyDate := GenJnlLine."Posting Date";
        if GenJnlLine."Reversing Entry" then
            NewCurrencyDate := NewCurrencyDate - 1;

        if NewCurrencyDate <> _CurrencyDate then begin
            UseCurrFactorOnly := false;
            _CurrencyDate := NewCurrencyDate;
            _CurrencyFactor := _CurrExchRate.ExchangeRate(_CurrencyDate, _AddCurrencyCode);
        end;

        if (GenJnlLine."FA Add.-Currency Factor" <> 0) and (GenJnlLine."FA Add.-Currency Factor" <> _CurrencyFactor) then begin
            UseCurrFactorOnly := true;
            _CurrencyDate := 0D;
            _CurrencyFactor := GenJnlLine."FA Add.-Currency Factor";
        end;

        if UseCurrFactorOnly then
            exit(Round(_CurrExchRate.ExchangeAmtLCYToFCYOnlyFactor(Amount, _CurrencyFactor), AddCurrency."Amount Rounding Precision"));

        exit(Round(_CurrExchRate.ExchangeAmtLCYToFCY(_CurrencyDate, _AddCurrencyCode, Amount, _CurrencyFactor), AddCurrency."Amount Rounding Precision"));
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
                Error(DescriptionMustNotBeBlankErr, GLAccount.FieldCaption("Omit Default Descr. in Jnl."), GLAccount."No.", GLEntry.FieldCaption(Description));
    end;

    local procedure IsLineAccount(GLAccNo: Code[20]; GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        exit(((GLAccNo = GenJnlLine."Account No.") and (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account")) or
             ((GLAccNo = GenJnlLine."Bal. Account No.") and (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account")));
    end;

    var
        _CurrExchRate: Record "Currency Exchange Rate";
        _GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        _AddCurrencyCode: Code[10];
        _CurrencyDate: Date;
        _CurrencyFactor: Decimal;
        _NextEntryNo: Integer;
        _NextTransactionNo: Integer;
}
