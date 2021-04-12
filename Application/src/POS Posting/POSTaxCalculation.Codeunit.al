codeunit 6150633 "NPR POS Tax Calculation"
{
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        POSEntry: Record "NPR POS Entry";
        GlobalTempPOSTaxAmountLine: Record "NPR POS Entry Tax Line" temporary;
        TempPOSTaxAmountLine2: Record "NPR POS Entry Tax Line" temporary;
        GlobalPOSSalesLine: Record "NPR POS Entry Sales Line";
        POSSalesLine2: Record "NPR POS Entry Sales Line";
        Currency: Record Currency;
        Text000: Label '%1 in %2 %3 must be filled in with unique values when %4 is %5.';
        Text1020000: Label 'Tax country/region %1 is being used.  You must use %2.';
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        ExchangeFactor: Decimal;
        TaxCountry: Option US,CA;
        TotalTaxAmountRounding: Decimal;
        TaxAreaRead: Boolean;
        Posted: Boolean;
        Text1020002: Label 'A %1 record could not be found within the following parameters:/%2: %3, %4: %5, %6: %7.';
        LastCalculationOrder: Integer;
        TaxOnTaxCalculated: Boolean;
        CalculationOrderViolation: Boolean;

    procedure RefreshPOSTaxLines(var POSEntryIn: Record "NPR POS Entry")
    var
        PersistentPOSTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        OnBeforeRefreshTaxPOSEntry(POSEntryIn);
        if POSEntryIn."Post Entry Status" >= POSEntryIn."Post Entry Status"::Posted then
            exit;

        ValidateTaxFields(POSEntryIn);

        GlobalTempPOSTaxAmountLine.DeleteAll();
        PersistentPOSTaxAmountLine.SetRange("POS Entry No.", POSEntryIn."Entry No.");
        PersistentPOSTaxAmountLine.DeleteAll();

        CalculateSalesTaxLinesPOSEntry(POSEntryIn);
        PersistSalesTaxAmountLines(POSEntryIn);

        if not HasSalesTaxLines(POSEntryIn."Entry No.") then begin
            CalcVATAmountLines(POSEntryIn, TempVATAmountLine);
            TestVATOnLines(POSEntryIn, TempVATAmountLine);
            PersistVATAmountLines(POSEntryIn, TempVATAmountLine);
        end;

        if not POSPostEntries.CheckPOSTaxAmountLines(POSEntryIn, false) then
            Message(GetLastErrorText);

        OnAfterRefreshTaxPOSEntry(POSEntryIn);
    end;

    procedure CalculateSalesTaxLinesPOSEntry(POSEntryIn: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry := POSEntryIn;
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;
        if POSEntry."Prices Including VAT" then
            exit;
        SetUpCurrency(POSEntry."Currency Code");
        if POSEntry."Currency Code" <> '' then
            POSEntry.TestField("Currency Factor");
        if POSEntry."Currency Factor" = 0 then
            ExchangeFactor := 1
        else
            ExchangeFactor := POSEntry."Currency Factor";

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1', POSSalesLine.Type::Rounding);
        POSSalesLine.SetRange("VAT Calculation Type", POSSalesLine."VAT Calculation Type"::"Sales Tax");
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet() then
            repeat
                AddPOSSalesLine(POSSalesLine);
            until POSSalesLine.Next() = 0;
        EndSalesTaxCalculation(POSEntry."Posting Date");
    end;

    procedure AddPOSSalesLine(POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        RecRef: RecordRef;
    begin
        if POSSalesLine."Exclude from Posting" then
            exit;
        if not GetSalesTaxCountry(POSSalesLine."Tax Area Code") then
            exit;

        POSSalesLine.TestField("Tax Group Code");

        GlobalTempPOSTaxAmountLine.Reset();
        case TaxCountry of
            TaxCountry::US:  // Area Code
                begin
                    GlobalTempPOSTaxAmountLine.SetRange("Tax Area Code for Key", POSSalesLine."Tax Area Code");
                    GlobalTempPOSTaxAmountLine."Tax Area Code for Key" := POSSalesLine."Tax Area Code";
                end;
            TaxCountry::CA:  // Jurisdictions
                begin
                    GlobalTempPOSTaxAmountLine.SetRange("Tax Area Code for Key", '');
                    GlobalTempPOSTaxAmountLine."Tax Area Code for Key" := '';
                end;
        end;
        GlobalTempPOSTaxAmountLine.SetRange("Tax Group Code", POSSalesLine."Tax Group Code");
        TaxAreaLine.SetCurrentKey("Tax Area", "Calculation Order");
        TaxAreaLine.SetRange("Tax Area", POSSalesLine."Tax Area Code");
        TaxAreaLine.FindSet();
        repeat
            GlobalTempPOSTaxAmountLine.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
            GlobalTempPOSTaxAmountLine.SetRange(Positive, POSSalesLine."Amount Excl. VAT" > 0);

            GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
            if not GlobalTempPOSTaxAmountLine.FindFirst() then begin
                GlobalTempPOSTaxAmountLine.Init();
                GlobalTempPOSTaxAmountLine."Tax Calculation Type" := GlobalTempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax";
                GlobalTempPOSTaxAmountLine."Tax Group Code" := POSSalesLine."Tax Group Code";
                GlobalTempPOSTaxAmountLine."Tax Area Code" := POSSalesLine."Tax Area Code";
                GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
                TaxJurisdiction.Get(GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code");
                if TaxCountry = TaxCountry::US then begin
                    RecRef.GetTable(TaxArea);
                    GlobalTempPOSTaxAmountLine."Round Tax" := RecRef.Field(10011).Value; //TaxArea."Round Tax" in NA localization
                    GlobalTempPOSTaxAmountLine."Is Report-to Jurisdiction" := (GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
                    GlobalTempPOSTaxAmountLine."Print Order" := 0;
                    GlobalTempPOSTaxAmountLine."Print Description" := TaxArea.Description;
                end;
                if TaxCountry = TaxCountry::CA then begin
                    RecRef.GetTable(TaxJurisdiction);
                    GlobalTempPOSTaxAmountLine."Print Order" := RecRef.Field(10020).Value; //TaxJurisdiction."Print Order" in NA localization
                    GlobalTempPOSTaxAmountLine."Print Description" := RecRef.Field(10030).Value; //TaxJurisdiction."Print Description" in NA localization
                end;
                SetTaxBaseAmount(
                  GlobalTempPOSTaxAmountLine, POSSalesLine."Amount Excl. VAT", ExchangeFactor, false);
                GlobalTempPOSTaxAmountLine."Line Amount" := POSSalesLine."Amount Excl. VAT" / ExchangeFactor;
                GlobalTempPOSTaxAmountLine."Tax Liable" := POSSalesLine."Tax Liable";
                GlobalTempPOSTaxAmountLine.Quantity := POSSalesLine."Quantity (Base)";
                GlobalTempPOSTaxAmountLine."Invoice Discount Amount" := 0;
                GlobalTempPOSTaxAmountLine."Calculation Order" := TaxAreaLine."Calculation Order";

                GlobalTempPOSTaxAmountLine.Positive := POSSalesLine."Amount Excl. VAT" > 0;

                GlobalTempPOSTaxAmountLine.Insert();
            end else begin
                GlobalTempPOSTaxAmountLine."Line Amount" := GlobalTempPOSTaxAmountLine."Line Amount" + (POSSalesLine."Amount Excl. VAT" / ExchangeFactor);
                if POSSalesLine."Tax Liable" then
                    GlobalTempPOSTaxAmountLine."Tax Liable" := POSSalesLine."Tax Liable";
                SetTaxBaseAmount(
                  GlobalTempPOSTaxAmountLine, POSSalesLine."Amount Excl. VAT", ExchangeFactor, true);
                GlobalTempPOSTaxAmountLine."Tax Amount" := 0;
                GlobalTempPOSTaxAmountLine.Quantity := GlobalTempPOSTaxAmountLine.Quantity + POSSalesLine."Quantity (Base)";
                GlobalTempPOSTaxAmountLine."Invoice Discount Amount" := GlobalTempPOSTaxAmountLine."Invoice Discount Amount" + 0;
                GlobalTempPOSTaxAmountLine.Modify();
            end;
        until TaxAreaLine.Next() = 0;
    end;

    local procedure ValidateTaxFields(var POSEntryIn: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        POSSalesLine.SetRange("POS Entry No.", POSEntryIn."Entry No.");
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet() then
            repeat
                if POSSalesLine.Type = POSSalesLine.Type::Voucher then begin
                    VATPostingSetup.Get(POSSalesLine."VAT Bus. Posting Group", POSSalesLine."VAT Prod. Posting Group");
                end;
                if (POSSalesLine."VAT Calculation Type" = POSSalesLine."VAT Calculation Type"::"Full VAT") and (POSSalesLine."VAT Prod. Posting Group" <> '') then begin
                    VATPostingSetup.Get(POSSalesLine."VAT Bus. Posting Group", POSSalesLine."VAT Prod. Posting Group");
                    POSSalesLine.TestField(Type, POSSalesLine.Type::"G/L Account");
                    VATPostingSetup.TestField("Sales VAT Account");
                    POSSalesLine.TestField("No.", VATPostingSetup."Sales VAT Account");
                end;
            until POSSalesLine.Next() = 0;
    end;

    local procedure PersistSalesTaxAmountLines(var POSEntryIn: Record "NPR POS Entry")
    var
        PersistentPOSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        if GlobalTempPOSTaxAmountLine.FindSet() then
            repeat
                PersistentPOSTaxAmountLine.Init();
                PersistentPOSTaxAmountLine := GlobalTempPOSTaxAmountLine;
                PersistentPOSTaxAmountLine."POS Entry No." := POSEntryIn."Entry No.";
                PersistentPOSTaxAmountLine.Insert();
            until GlobalTempPOSTaxAmountLine.Next() = 0;
    end;

    local procedure PersistVATAmountLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        PersistentPOSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        if VATAmountLine.FindSet() then
            repeat
                PersistentPOSTaxAmountLine.Init();
                PersistentPOSTaxAmountLine."VAT Identifier" := VATAmountLine."VAT Identifier";
                PersistentPOSTaxAmountLine."Tax Calculation Type" := VATAmountLine."VAT Calculation Type";
                PersistentPOSTaxAmountLine."Tax Group Code" := VATAmountLine."Tax Group Code";
                PersistentPOSTaxAmountLine."Use Tax" := VATAmountLine."Use Tax";
                PersistentPOSTaxAmountLine.Positive := VATAmountLine.Positive;
                PersistentPOSTaxAmountLine."Tax %" := VATAmountLine."VAT %";
                PersistentPOSTaxAmountLine."Tax Base Amount" := VATAmountLine."VAT Base";
                PersistentPOSTaxAmountLine."Tax Amount" := VATAmountLine."VAT Amount";
                PersistentPOSTaxAmountLine."Amount Including Tax" := VATAmountLine."Amount Including VAT";
                PersistentPOSTaxAmountLine."Line Amount" := VATAmountLine."Line Amount";
                PersistentPOSTaxAmountLine."Inv. Disc. Base Amount" := VATAmountLine."Inv. Disc. Base Amount";
                PersistentPOSTaxAmountLine."Invoice Discount Amount" := VATAmountLine."Invoice Discount Amount";
                PersistentPOSTaxAmountLine.Quantity := VATAmountLine.Quantity;
                PersistentPOSTaxAmountLine.Modified := VATAmountLine.Modified;
                PersistentPOSTaxAmountLine."Calculated Tax Amount" := VATAmountLine."Calculated VAT Amount";
                PersistentPOSTaxAmountLine."Tax Difference" := VATAmountLine."VAT Difference";
                PersistentPOSTaxAmountLine."POS Entry No." := POSEntryIn."Entry No.";
                PersistentPOSTaxAmountLine.Insert();
            until VATAmountLine.Next() = 0;
    end;

    procedure UpdateVATOnLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
    begin
        POSEntry := POSEntryIn;
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;
        SetUpCurrency(POSEntry."Currency Code");
        if POSEntry."Currency Code" <> '' then
            POSEntry.TestField("Currency Factor");
        if POSEntry."Currency Factor" = 0 then
            ExchangeFactor := 1
        else
            ExchangeFactor := POSEntry."Currency Factor";

        TempVATAmountLineRemainder.DeleteAll();

        GlobalPOSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        GlobalPOSSalesLine.SetRange("Exclude from Posting", false);
        GlobalPOSSalesLine.LockTable();
        if GlobalPOSSalesLine.FindSet() then
            repeat
                if (((GlobalPOSSalesLine."Unit Price" <> 0) and (GlobalPOSSalesLine.Quantity <> 0)) or (GlobalPOSSalesLine."Amount Excl. VAT" <> 0)) then begin

                    VATAmountLine.Get(GlobalPOSSalesLine."VAT Identifier", GlobalPOSSalesLine."VAT Calculation Type", GlobalPOSSalesLine."Tax Group Code", false, GlobalPOSSalesLine."Amount Excl. VAT" >= 0);
                    if VATAmountLine.Modified then begin
                        if not TempVATAmountLineRemainder.Get(
                             GlobalPOSSalesLine."VAT Identifier", GlobalPOSSalesLine."VAT Calculation Type", GlobalPOSSalesLine."Tax Group Code", false, GlobalPOSSalesLine."Amount Excl. VAT" >= 0)
                        then begin
                            TempVATAmountLineRemainder := VATAmountLine;
                            TempVATAmountLineRemainder.Init();
                            TempVATAmountLineRemainder.Insert();
                        end;

                        if GlobalPOSSalesLine."VAT Calculation Type" = GlobalPOSSalesLine."VAT Calculation Type"::"Full VAT" then begin
                            VATAmount := GlobalPOSSalesLine."Amount Excl. VAT";
                            NewAmount := 0;
                            NewVATBaseAmount := 0;
                        end else begin
                            NewAmount := GlobalPOSSalesLine."Amount Excl. VAT";
                            NewVATBaseAmount :=
                              Round(
                                NewAmount,
                                Currency."Amount Rounding Precision");
                            if VATAmountLine."VAT Base" = 0 then
                                VATAmount := 0
                            else
                                VATAmount :=
                                  TempVATAmountLineRemainder."VAT Amount" +
                                  VATAmountLine."VAT Amount" * NewAmount / VATAmountLine."VAT Base";
                        end;
                        NewAmountIncludingVAT := NewAmount + Round(VATAmount, Currency."Amount Rounding Precision");

                        GlobalPOSSalesLine."Amount Excl. VAT" := NewAmount;
                        GlobalPOSSalesLine."Amount Incl. VAT" := Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                        GlobalPOSSalesLine."VAT Base Amount" := NewVATBaseAmount;

                        GlobalPOSSalesLine.UpdateLCYAmounts;

                        GlobalPOSSalesLine.Modify();

                        TempVATAmountLineRemainder."Amount Including VAT" :=
                          NewAmountIncludingVAT - Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                        TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                        TempVATAmountLineRemainder."VAT Difference" := VATDifference - GlobalPOSSalesLine."VAT Difference";
                        TempVATAmountLineRemainder.Modify();
                    end;
                end;
            until GlobalPOSSalesLine.Next() = 0;
    end;

    procedure TestVATOnLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
        InvDiscAmount: Decimal;
        LineAmountToInvoice: Decimal;
        LineAmountToInvoiceDiscounted: Decimal;
        DeferralAmount: Decimal;
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry := POSEntryIn;
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;

        if (not VATAmountLine.FindFirst()) then
            exit;

        repeat
            POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSSalesLine.SetRange("VAT Identifier", VATAmountLine."VAT Identifier");
            POSSalesLine.SetRange("Tax Group Code", VATAmountLine."Tax Group Code");
            POSSalesLine.SetFilter(Type, '<>%1', POSSalesLine.Type::Rounding);
            if VATAmountLine.Positive then
                POSSalesLine.SetFilter("Amount Excl. VAT", '>=%1', 0)
            else
                POSSalesLine.SetFilter("Amount Excl. VAT", '<%1', 0);
            POSSalesLine.SetRange("Exclude from Posting", false);
            POSSalesLine.CalcSums("Line Amount", "Amount Excl. VAT", "Amount Incl. VAT");

            VATAmountLine.TestField("VAT Base", POSSalesLine."Amount Excl. VAT");
            VATAmountLine.TestField("Amount Including VAT", POSSalesLine."Amount Incl. VAT");
            VATAmountLine.TestField("VAT Amount", POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT");
        until VATAmountLine.Next() = 0;
    end;

    procedure CalcVATAmountLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        PrevVatAmountLine: Record "VAT Amount Line";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalVATAmount: Decimal;
    begin
        POSEntry := POSEntryIn;
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;
        SetUpCurrency(POSEntry."Currency Code");
        if POSEntry."Currency Code" <> '' then
            POSEntry.TestField("Currency Factor");
        if POSEntry."Currency Factor" = 0 then
            ExchangeFactor := 1
        else
            ExchangeFactor := POSEntry."Currency Factor";

        VATAmountLine.DeleteAll();

        GlobalPOSSalesLine.SetRange("POS Entry No.", POSEntryIn."Entry No.");
        GlobalPOSSalesLine.SetFilter(Type, '<>%1', GlobalPOSSalesLine.Type::Rounding);
        GlobalPOSSalesLine.SetRange("Exclude from Posting", false);
        if GlobalPOSSalesLine.FindSet() then
            repeat
                if ((GlobalPOSSalesLine."Unit Price" <> 0) and (GlobalPOSSalesLine.Quantity <> 0)) or (GlobalPOSSalesLine."Amount Excl. VAT" <> 0) then begin
                    if (GlobalPOSSalesLine."VAT Calculation Type" in
                       [GlobalPOSSalesLine."VAT Calculation Type"::"Reverse Charge VAT", GlobalPOSSalesLine."VAT Calculation Type"::"Sales Tax"])
                    then
                        GlobalPOSSalesLine."VAT %" := 0;
                    if not VATAmountLine.Get(
                         GlobalPOSSalesLine."VAT Identifier", GlobalPOSSalesLine."VAT Calculation Type", GlobalPOSSalesLine."Tax Group Code", false, GlobalPOSSalesLine."Line Amount" >= 0)
                    then begin
                        VATAmountLine.Init();
                        VATAmountLine."VAT Identifier" := GlobalPOSSalesLine."VAT Identifier";
                        VATAmountLine."VAT Calculation Type" := GlobalPOSSalesLine."VAT Calculation Type";
                        VATAmountLine."Tax Group Code" := GlobalPOSSalesLine."Tax Group Code";
                        VATAmountLine."VAT %" := GlobalPOSSalesLine."VAT %";
                        VATAmountLine.Modified := true;
                        VATAmountLine.Positive := GlobalPOSSalesLine."Line Amount" >= 0;
                        VATAmountLine.Insert();
                    end;
                    VATAmountLine.Quantity := VATAmountLine.Quantity + GlobalPOSSalesLine."Quantity (Base)";
                    VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + GlobalPOSSalesLine."Line Amount";
                    VATAmountLine.Modify();
                    TotalVATAmount := TotalVATAmount + GlobalPOSSalesLine."Amount Incl. VAT" - GlobalPOSSalesLine."Amount Excl. VAT";
                end;
            until GlobalPOSSalesLine.Next() = 0;

        if VATAmountLine.FindSet() then
            repeat
                if (PrevVatAmountLine."VAT Identifier" <> VATAmountLine."VAT Identifier") or
                   (PrevVatAmountLine."VAT Calculation Type" <> VATAmountLine."VAT Calculation Type") or
                   (PrevVatAmountLine."Tax Group Code" <> VATAmountLine."Tax Group Code") or
                   (PrevVatAmountLine."Use Tax" <> VATAmountLine."Use Tax")
                then
                    PrevVatAmountLine.Init();
                if POSEntry."Prices Including VAT" then begin
                    case VATAmountLine."VAT Calculation Type" of
                        VATAmountLine."VAT Calculation Type"::"Normal VAT",
                        VATAmountLine."VAT Calculation Type"::"Reverse Charge VAT":
                            begin
                                VATAmountLine."VAT Base" :=
                                  Round(
                                    (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount") / (1 + VATAmountLine."VAT %" / 100),
                                    Currency."Amount Rounding Precision") - VATAmountLine."VAT Difference";
                                VATAmountLine."VAT Amount" :=
                                  VATAmountLine."VAT Difference" +
                                  Round(
                                    PrevVatAmountLine."VAT Amount" +
                                    (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount" - VATAmountLine."VAT Base" - VATAmountLine."VAT Difference"),
                                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                VATAmountLine."Amount Including VAT" := VATAmountLine."VAT Base" + VATAmountLine."VAT Amount";
                                if VATAmountLine.Positive then
                                    PrevVatAmountLine.Init
                                else begin
                                    PrevVatAmountLine := VATAmountLine;
                                    PrevVatAmountLine."VAT Amount" :=
                                      (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount" - VATAmountLine."VAT Base" - VATAmountLine."VAT Difference");
                                    PrevVatAmountLine."VAT Amount" :=
                                      PrevVatAmountLine."VAT Amount" -
                                      Round(PrevVatAmountLine."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                end;
                            end;
                        VATAmountLine."VAT Calculation Type"::"Full VAT":
                            begin
                                VATAmountLine."VAT Base" := 0;
                                VATAmountLine."VAT Amount" := VATAmountLine."VAT Difference" + VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount";
                                VATAmountLine."Amount Including VAT" := VATAmountLine."VAT Amount";
                            end;
                        VATAmountLine."VAT Calculation Type"::"Sales Tax":
                            begin
                                VATAmountLine."Amount Including VAT" := VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount";
                                VATAmountLine."VAT Base" :=
                                  Round(
                                    SalesTaxCalculate.ReverseCalculateTax(
                                      POSEntry."Tax Area Code", VATAmountLine."Tax Group Code", GlobalPOSSalesLine."Tax Liable",
                                      POSEntry."Posting Date", VATAmountLine."Amount Including VAT", VATAmountLine.Quantity, POSEntry."Currency Factor"),
                                    Currency."Amount Rounding Precision");
                                VATAmountLine."VAT Amount" := VATAmountLine."VAT Difference" + VATAmountLine."Amount Including VAT" - VATAmountLine."VAT Base";
                                if VATAmountLine."VAT Base" = 0 then
                                    VATAmountLine."VAT %" := 0
                                else
                                    VATAmountLine."VAT %" := Round(100 * VATAmountLine."VAT Amount" / VATAmountLine."VAT Base", 0.00001);
                            end;
                    end;
                end else
                    case VATAmountLine."VAT Calculation Type" of
                        VATAmountLine."VAT Calculation Type"::"Normal VAT",
                        VATAmountLine."VAT Calculation Type"::"Reverse Charge VAT":
                            begin
                                VATAmountLine."VAT Base" := VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount";
                                VATAmountLine."VAT Amount" :=
                                  VATAmountLine."VAT Difference" +
                                  Round(
                                    PrevVatAmountLine."VAT Amount" +
                                    VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100,
                                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                VATAmountLine."Amount Including VAT" := VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount" + VATAmountLine."VAT Amount";
                                if VATAmountLine.Positive then
                                    PrevVatAmountLine.Init
                                else
                                    if not VATAmountLine."Includes Prepayment" then begin
                                        PrevVatAmountLine := VATAmountLine;
                                        PrevVatAmountLine."VAT Amount" :=
                                          VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100;
                                        PrevVatAmountLine."VAT Amount" :=
                                          PrevVatAmountLine."VAT Amount" -
                                          Round(PrevVatAmountLine."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    end;
                            end;
                        VATAmountLine."VAT Calculation Type"::"Full VAT":
                            begin
                                VATAmountLine."VAT Base" := 0;
                                VATAmountLine."VAT Amount" := VATAmountLine."VAT Difference" + VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount";
                                VATAmountLine."Amount Including VAT" := VATAmountLine."VAT Amount";
                            end;
                        VATAmountLine."VAT Calculation Type"::"Sales Tax":
                            begin
                                VATAmountLine."VAT Base" := VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount";
                                VATAmountLine."VAT Amount" :=
                                  SalesTaxCalculate.CalculateTax(
                                    POSEntry."Tax Area Code", VATAmountLine."Tax Group Code", GlobalPOSSalesLine."Tax Liable",
                                    POSEntry."Posting Date", VATAmountLine."VAT Base", VATAmountLine.Quantity, POSEntry."Currency Factor");
                                if VATAmountLine."VAT Base" = 0 then
                                    VATAmountLine."VAT %" := 0
                                else
                                    VATAmountLine."VAT %" := Round(100 * VATAmountLine."VAT Amount" / VATAmountLine."VAT Base", 0.00001);
                                VATAmountLine."VAT Amount" :=
                                  VATAmountLine."VAT Difference" +
                                  Round(VATAmountLine."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                VATAmountLine."Amount Including VAT" := VATAmountLine."VAT Base" + VATAmountLine."VAT Amount";
                            end;
                    end;

                VATAmountLine."Calculated VAT Amount" := VATAmountLine."VAT Amount" - VATAmountLine."VAT Difference";
                VATAmountLine.Modify();
            until VATAmountLine.Next() = 0;
    end;

    local procedure HasSalesTaxLines(POSEntryNo: Integer): Boolean
    var
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntryNo);
        POSTaxAmountLine.SetRange("Tax Calculation Type", POSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
        exit(not POSTaxAmountLine.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRefreshTaxPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRefreshTaxPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    local procedure "-- Active POS Line Calculation"()
    begin
    end;

    procedure CalculateSalesTaxSaleLinePOS(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        TaxArea: Record "Tax Area";
    begin
        if SalePOS."Tax Area Code" = '' then
            exit;
        if SalePOS."Prices Including VAT" then
            exit;
        TaxArea.Get(SalePOS."Tax Area Code");
        SetUpCurrency('');
        ExchangeFactor := 1;

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("VAT Calculation Type", SaleLinePOS."VAT Calculation Type"::"Sales Tax");
        SaleLinePOS.SetFilter("Sale Type", '%1|%2|%3', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Deposit, SaleLinePOS."Sale Type"::"Out payment");
        if SaleLinePOS.FindSet() then
            repeat
                if (not ((SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment") and (SaleLinePOS.Type <> SaleLinePOS.Type::"G/L Entry"))) then
                    AddSaleLinePOS(SaleLinePOS);
            until SaleLinePOS.Next() = 0
        else
            exit;

        EndSalesTaxCalculation(SalePOS.Date);
        DistTaxOverSaleLinePOS(SaleLinePOS);
    end;

    local procedure AddSaleLinePOS(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        RecRef: RecordRef;
    begin
        if POSCreateEntry.ExcludeFromPosting(SaleLinePOS) then
            exit;
        if not GetSalesTaxCountry(SaleLinePOS."Tax Area Code") then
            exit;

        SaleLinePOS.TestField("Tax Group Code");

        GlobalTempPOSTaxAmountLine.Reset();
        case TaxCountry of
            TaxCountry::US:  // Area Code
                begin
                    GlobalTempPOSTaxAmountLine.SetRange("Tax Area Code for Key", SaleLinePOS."Tax Area Code");
                    GlobalTempPOSTaxAmountLine."Tax Area Code for Key" := SaleLinePOS."Tax Area Code";
                end;
            TaxCountry::CA:  // Jurisdictions
                begin
                    GlobalTempPOSTaxAmountLine.SetRange("Tax Area Code for Key", '');
                    GlobalTempPOSTaxAmountLine."Tax Area Code for Key" := '';
                end;
        end;
        GlobalTempPOSTaxAmountLine.SetRange("Tax Group Code", SaleLinePOS."Tax Group Code");
        TaxAreaLine.SetCurrentKey("Tax Area", "Calculation Order");
        TaxAreaLine.SetRange("Tax Area", SaleLinePOS."Tax Area Code");
        TaxAreaLine.FindSet();
        repeat
            GlobalTempPOSTaxAmountLine.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
            GlobalTempPOSTaxAmountLine.SetRange(Positive, SaleLinePOS.Amount > 0);

            GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
            if not GlobalTempPOSTaxAmountLine.FindFirst() then begin
                GlobalTempPOSTaxAmountLine.Init();
                GlobalTempPOSTaxAmountLine."Tax Calculation Type" := GlobalTempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax";
                GlobalTempPOSTaxAmountLine."Tax Group Code" := SaleLinePOS."Tax Group Code";
                GlobalTempPOSTaxAmountLine."Tax Area Code" := SaleLinePOS."Tax Area Code";
                GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
                TaxJurisdiction.Get(GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code");
                if TaxCountry = TaxCountry::US then begin
                    RecRef.GetTable(TaxArea);
                    GlobalTempPOSTaxAmountLine."Round Tax" := RecRef.Field(10011).Value; //TaxArea."Round Tax" in NA localization
                    GlobalTempPOSTaxAmountLine."Is Report-to Jurisdiction" := (GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
                    GlobalTempPOSTaxAmountLine."Print Order" := 0;
                    GlobalTempPOSTaxAmountLine."Print Description" := TaxArea.Description;
                end;
                if TaxCountry = TaxCountry::CA then begin
                    RecRef.GetTable(TaxJurisdiction);
                    GlobalTempPOSTaxAmountLine."Print Order" := RecRef.Field(10020).Value; //TaxJurisdiction."Print Order" in NA localization
                    GlobalTempPOSTaxAmountLine."Print Description" := RecRef.Field(10030).Value; //TaxJurisdiction."Print Description" in NA localization
                end;
                SetTaxBaseAmount(
                  GlobalTempPOSTaxAmountLine, SaleLinePOS.Amount, ExchangeFactor, false);
                GlobalTempPOSTaxAmountLine."Line Amount" := SaleLinePOS.Amount / ExchangeFactor;
                GlobalTempPOSTaxAmountLine."Tax Liable" := SaleLinePOS."Tax Liable";
                GlobalTempPOSTaxAmountLine.Quantity := SaleLinePOS."Quantity (Base)";
                GlobalTempPOSTaxAmountLine."Invoice Discount Amount" := 0;
                GlobalTempPOSTaxAmountLine."Calculation Order" := TaxAreaLine."Calculation Order";

                GlobalTempPOSTaxAmountLine.Positive := SaleLinePOS.Amount > 0;

                GlobalTempPOSTaxAmountLine.Insert();
            end else begin
                GlobalTempPOSTaxAmountLine."Line Amount" := GlobalTempPOSTaxAmountLine."Line Amount" + (SaleLinePOS.Amount / ExchangeFactor);
                if SaleLinePOS."Tax Liable" then
                    GlobalTempPOSTaxAmountLine."Tax Liable" := SaleLinePOS."Tax Liable";
                SetTaxBaseAmount(
                  GlobalTempPOSTaxAmountLine, SaleLinePOS.Amount, ExchangeFactor, true);
                GlobalTempPOSTaxAmountLine."Tax Amount" := 0;
                GlobalTempPOSTaxAmountLine.Quantity := GlobalTempPOSTaxAmountLine.Quantity + SaleLinePOS."Quantity (Base)";
                GlobalTempPOSTaxAmountLine."Invoice Discount Amount" := GlobalTempPOSTaxAmountLine."Invoice Discount Amount" + 0;
                GlobalTempPOSTaxAmountLine.Modify();
            end;
        until TaxAreaLine.Next() = 0;
    end;

    local procedure DistTaxOverSaleLinePOS(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        tmpSaleLinePOS: Record "NPR POS Sale Line" temporary;
        Amount: Decimal;
        TaxAmount: Decimal;
        ReturnTaxAmount: Decimal;
    begin
        TotalTaxAmountRounding := 0;
        SetUpCurrency(POSEntry."Currency Code");
        if POSEntry."Currency Factor" = 0 then
            ExchangeFactor := 1
        else
            ExchangeFactor := POSEntry."Currency Factor";
        SaleLinePOS.SetSkipCalcDiscount(true);
        GlobalTempPOSTaxAmountLine.Reset();
        if GlobalTempPOSTaxAmountLine.FindSet() then
            repeat
                if (GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code" <> TempPOSTaxAmountLine2."Tax Jurisdiction Code") and (TaxCountry = TaxCountry::CA) then begin
                    TempPOSTaxAmountLine2."Tax Jurisdiction Code" := GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code";
                    TotalTaxAmountRounding := 0;
                end;
                if TaxCountry = TaxCountry::US then
                    SaleLinePOS.SetRange("Tax Area Code", GlobalTempPOSTaxAmountLine."Tax Area Code");
                SaleLinePOS.SetRange("Tax Group Code", GlobalTempPOSTaxAmountLine."Tax Group Code");
                SaleLinePOS.FindSet(true);
                repeat
                    if ((TaxCountry = TaxCountry::US) or
                        ((TaxCountry = TaxCountry::CA) and TaxAreaLine.Get(SaleLinePOS."Tax Area Code", GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code"))) and
                       CheckTaxAmtLinePos(SaleLinePOS.Amount,
                         GlobalTempPOSTaxAmountLine.Positive)
                    then begin
                        if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax" then begin
                            Amount := (SaleLinePOS.Amount);
                            if GlobalTempPOSTaxAmountLine."Tax Difference" <> 0 then
                                TaxAmount := Amount * GlobalTempPOSTaxAmountLine."Tax Amount" / GlobalTempPOSTaxAmountLine."Tax Base Amount"
                            else
                                TaxAmount := Amount * GlobalTempPOSTaxAmountLine."Tax %" / 100;
                        end else begin
                            if (SaleLinePOS."Quantity (Base)" = 0) or (GlobalTempPOSTaxAmountLine.Quantity = 0) then
                                TaxAmount := 0
                            else
                                TaxAmount := GlobalTempPOSTaxAmountLine."Tax Amount" * ExchangeFactor * SaleLinePOS."Quantity (Base)" / GlobalTempPOSTaxAmountLine.Quantity;
                        end;
                        if TaxAmount = 0 then
                            ReturnTaxAmount := 0
                        else begin
                            ReturnTaxAmount := Round(TaxAmount + TotalTaxAmountRounding, Currency."Amount Rounding Precision");
                            TotalTaxAmountRounding := TaxAmount + TotalTaxAmountRounding - ReturnTaxAmount;
                        end;
                        if tmpSaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Line No.") then begin
                            tmpSaleLinePOS."Amount Including VAT" := tmpSaleLinePOS."Amount Including VAT" + ReturnTaxAmount;
                            tmpSaleLinePOS.Modify();
                        end else begin
                            tmpSaleLinePOS.Copy(SaleLinePOS);
                            tmpSaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount + ReturnTaxAmount;
                            tmpSaleLinePOS.Insert();
                        end;
                        if SaleLinePOS."Tax Liable" then
                            SaleLinePOS."Amount Including VAT" := tmpSaleLinePOS."Amount Including VAT"
                        else
                            SaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount;
                        if SaleLinePOS.Amount <> 0 then
                            SaleLinePOS."VAT %" :=
                              Round(100 * (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount) / SaleLinePOS.Amount, 0.00001)
                        else
                            SaleLinePOS."VAT %" := 0;
                        SaleLinePOS.Modify();
                    end;
                until SaleLinePOS.Next() = 0;
            until GlobalTempPOSTaxAmountLine.Next() = 0;
        SaleLinePOS.SetRange("Tax Area Code");
        SaleLinePOS.SetRange("Tax Group Code");
        if SaleLinePOS.FindSet(true) then
            repeat
                SaleLinePOS."Amount Including VAT" := Round(SaleLinePOS."Amount Including VAT", Currency."Amount Rounding Precision");
                SaleLinePOS.Amount :=
                  Round(SaleLinePOS.Amount, Currency."Amount Rounding Precision");
                SaleLinePOS."VAT Base Amount" := SaleLinePOS.Amount;
                if ((SaleLinePOS."Tax Area Code" = '') and (GlobalTempPOSTaxAmountLine."Tax Area Code" <> '')) or (SaleLinePOS."Tax Group Code" = '') then
                    SaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount;
                SaleLinePOS.Modify();
            until SaleLinePOS.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; var Handled: Boolean)
    begin
    end;

    local procedure SetUpCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    procedure GetSalesTaxCountry(TaxAreaCode: Code[20]): Boolean
    var
        RecRef: RecordRef;
        NewTaxCountry: Option US,CA;
    begin
        if TaxAreaCode = '' then
            exit(false);
        if TaxAreaRead then begin
            if TaxAreaCode = TaxArea.Code then
                exit(true);
            if TaxArea.Get(TaxAreaCode) then begin
                RecRef.GetTable(TaxArea);
                NewTaxCountry := RecRef.Field(10010).Value; //TaxArea."Country/Region" in NA localization.
                if TaxCountry <> NewTaxCountry then
                    Error(Text1020000, NewTaxCountry, TaxCountry)
                else
                    exit(true);
            end;
        end else
            if TaxArea.Get(TaxAreaCode) then begin
                TaxAreaRead := true;
                RecRef.GetTable(TaxArea);
                TaxCountry := RecRef.Field(10010).Value; //TaxArea."Country/Region" in NA localization.
                exit(true);
            end;

        exit(false);
    end;

    procedure EndSalesTaxCalculation(Date: Date)
    var
        POSTaxAmountLine2: Record "NPR POS Entry Tax Line" temporary;
        TaxDetail: Record "Tax Detail";
        AddedTaxAmount: Decimal;
        TotalTaxAmount: Decimal;
        MaxAmount: Decimal;
        TaxBaseAmt: Decimal;
        TaxDetailFound: Boolean;
        LastTaxAreaCode: Code[20];
        LastTaxGroupCode: Code[20];
        RoundTax: Option "To Nearest",Up,Down;
    begin
        GlobalTempPOSTaxAmountLine.Reset();
        GlobalTempPOSTaxAmountLine.SetRange("Tax Type", GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax");
        if GlobalTempPOSTaxAmountLine.FindSet() then
            repeat
                TaxDetailFound := false;
                TaxDetail.Reset();
                TaxDetail.SetRange("Tax Jurisdiction Code", GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code");
                if GlobalTempPOSTaxAmountLine."Tax Group Code" = '' then
                    TaxDetail.SetFilter("Tax Group Code", '%1', GlobalTempPOSTaxAmountLine."Tax Group Code")
                else
                    TaxDetail.SetFilter("Tax Group Code", '%1|%2', '', GlobalTempPOSTaxAmountLine."Tax Group Code");
                if Date = 0D then
                    TaxDetail.SetFilter("Effective Date", '<=%1', WorkDate())
                else
                    TaxDetail.SetFilter("Effective Date", '<=%1', Date);
                TaxDetail.SetRange("Tax Type", 0);//TaxDetail."Tax Type"::"Sales and Use Tax";
                if GlobalTempPOSTaxAmountLine."Use Tax" then
                    TaxDetail.SetFilter("Tax Type", '%1|%2', 0, //TaxDetail."Tax Type"::"Sales and Use Tax",
                      3)//TaxDetail."Tax Type"::"Use Tax Only")
                else
                    TaxDetail.SetFilter("Tax Type", '%1|%2', 0, //TaxDetail."Tax Type"::"Sales and Use Tax",
                      3);//TaxDetail."Tax Type"::"Sales Tax Only");
                if TaxDetail.FindLast() then
                    TaxDetailFound := true
                else
                    GlobalTempPOSTaxAmountLine.Delete();
                TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Excise Tax");
                if TaxDetail.FindLast() then begin
                    TaxDetailFound := true;
                    GlobalTempPOSTaxAmountLine."Tax Type" := GlobalTempPOSTaxAmountLine."Tax Type"::"Excise Tax";
                    GlobalTempPOSTaxAmountLine.Insert();
                    GlobalTempPOSTaxAmountLine."Tax Type" := GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax";
                end;
                if not TaxDetailFound and not Posted then
                    Error(
                      Text1020002,
                      TaxDetail.TableCaption,
                      GlobalTempPOSTaxAmountLine.FieldCaption("Tax Jurisdiction Code"), GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code",
                      GlobalTempPOSTaxAmountLine.FieldCaption("Tax Group Code"), GlobalTempPOSTaxAmountLine."Tax Group Code",
                      TaxDetail.FieldCaption("Effective Date"), TaxDetail.GetFilter("Effective Date"));
            until GlobalTempPOSTaxAmountLine.Next() = 0;
        GlobalTempPOSTaxAmountLine.Reset();
        GlobalTempPOSTaxAmountLine.SetCurrentKey("Tax Area Code for Key", "Tax Group Code", "Tax Type", "Calculation Order");
        if GlobalTempPOSTaxAmountLine.FindLast() then begin
            LastTaxAreaCode := GlobalTempPOSTaxAmountLine."Tax Area Code for Key";
            LastCalculationOrder := -9999;
            LastTaxGroupCode := GlobalTempPOSTaxAmountLine."Tax Group Code";
            RoundTax := GlobalTempPOSTaxAmountLine."Round Tax";
            repeat
                if (LastTaxAreaCode <> GlobalTempPOSTaxAmountLine."Tax Area Code for Key") or
                   (LastTaxGroupCode <> GlobalTempPOSTaxAmountLine."Tax Group Code")
                then begin
                    HandleRoundTaxUpOrDown(POSTaxAmountLine2, RoundTax, TotalTaxAmount, LastTaxAreaCode, LastTaxGroupCode);
                    LastTaxAreaCode := GlobalTempPOSTaxAmountLine."Tax Area Code for Key";
                    LastTaxGroupCode := GlobalTempPOSTaxAmountLine."Tax Group Code";
                    TaxOnTaxCalculated := false;
                    LastCalculationOrder := -9999;
                    CalculationOrderViolation := false;
                    TotalTaxAmount := 0;
                    RoundTax := GlobalTempPOSTaxAmountLine."Round Tax";
                end;
                if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax" then
                    TaxBaseAmt := GlobalTempPOSTaxAmountLine."Tax Base Amount"
                else
                    TaxBaseAmt := GlobalTempPOSTaxAmountLine.Quantity;
                if LastCalculationOrder = GlobalTempPOSTaxAmountLine."Calculation Order" then
                    CalculationOrderViolation := true;
                LastCalculationOrder := GlobalTempPOSTaxAmountLine."Calculation Order";

                TaxDetail.Reset();
                TaxDetail.SetRange("Tax Jurisdiction Code", GlobalTempPOSTaxAmountLine."Tax Jurisdiction Code");
                if GlobalTempPOSTaxAmountLine."Tax Group Code" = '' then
                    TaxDetail.SetFilter("Tax Group Code", '%1', GlobalTempPOSTaxAmountLine."Tax Group Code")
                else
                    TaxDetail.SetFilter("Tax Group Code", '%1|%2', '', GlobalTempPOSTaxAmountLine."Tax Group Code");
                if Date = 0D then
                    TaxDetail.SetFilter("Effective Date", '<=%1', WorkDate())
                else
                    TaxDetail.SetFilter("Effective Date", '<=%1', Date);
                TaxDetail.SetRange("Tax Type", GlobalTempPOSTaxAmountLine."Tax Type");
                if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax" then
                    if GlobalTempPOSTaxAmountLine."Use Tax" then
                        TaxDetail.SetFilter("Tax Type", '%1|%2', GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax",
                          GlobalTempPOSTaxAmountLine."Tax Type"::"Use Tax Only")
                    else
                        TaxDetail.SetFilter("Tax Type", '%1|%2', GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax",
                          GlobalTempPOSTaxAmountLine."Tax Type"::"Sales Tax Only");
                if TaxDetail.FindLast() then begin
                    TaxOnTaxCalculated := TaxOnTaxCalculated or TaxDetail."Calculate Tax on Tax";
                    if TaxDetail."Calculate Tax on Tax" and (GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax") then
                        TaxBaseAmt := GlobalTempPOSTaxAmountLine."Tax Base Amount" + TotalTaxAmount;
                    if GlobalTempPOSTaxAmountLine."Tax Liable" then begin
                        if (Abs(TaxBaseAmt) <= TaxDetail."Maximum Amount/Qty.") or
                           (TaxDetail."Maximum Amount/Qty." = 0)
                        then
                            AddedTaxAmount := TaxBaseAmt * TaxDetail."Tax Below Maximum"
                        else begin
                            if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax" then
                                MaxAmount := TaxBaseAmt / Abs(GlobalTempPOSTaxAmountLine."Tax Base Amount") * TaxDetail."Maximum Amount/Qty."
                            else
                                MaxAmount := GlobalTempPOSTaxAmountLine.Quantity / Abs(GlobalTempPOSTaxAmountLine.Quantity) * TaxDetail."Maximum Amount/Qty.";
                            AddedTaxAmount :=
                              (MaxAmount * TaxDetail."Tax Below Maximum") +
                              ((TaxBaseAmt - MaxAmount) * TaxDetail."Tax Above Maximum");
                        end;
                        if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax" then
                            AddedTaxAmount := AddedTaxAmount / 100.0;
                    end else
                        AddedTaxAmount := 0;
                    GlobalTempPOSTaxAmountLine."Tax Amount" := GlobalTempPOSTaxAmountLine."Tax Amount" + AddedTaxAmount;
                    TotalTaxAmount := TotalTaxAmount + AddedTaxAmount;
                end;
                GlobalTempPOSTaxAmountLine."Tax Amount" := GlobalTempPOSTaxAmountLine."Tax Amount" + GlobalTempPOSTaxAmountLine."Tax Difference";
                TotalTaxAmount := TotalTaxAmount + GlobalTempPOSTaxAmountLine."Tax Difference";
                GlobalTempPOSTaxAmountLine."Amount Including Tax" := GlobalTempPOSTaxAmountLine."Tax Amount" + GlobalTempPOSTaxAmountLine."Tax Base Amount";
                if TaxOnTaxCalculated and CalculationOrderViolation then
                    Error(
                      Text000,
                      GlobalTempPOSTaxAmountLine.FieldCaption("Calculation Order"), TaxArea.TableCaption, GlobalTempPOSTaxAmountLine."POS Entry No.",
                      TaxDetail.FieldCaption("Calculate Tax on Tax"), CalculationOrderViolation);
                POSTaxAmountLine2.Copy(GlobalTempPOSTaxAmountLine);
                if GlobalTempPOSTaxAmountLine."Tax Type" = GlobalTempPOSTaxAmountLine."Tax Type"::"Excise Tax" then
                    POSTaxAmountLine2."Tax %" := 0
                else
                    if GlobalTempPOSTaxAmountLine."Tax Base Amount" <> 0 then
                        POSTaxAmountLine2."Tax %" := 100 * (GlobalTempPOSTaxAmountLine."Amount Including Tax" - GlobalTempPOSTaxAmountLine."Tax Base Amount") / GlobalTempPOSTaxAmountLine."Tax Base Amount"
                    else
                        POSTaxAmountLine2."Tax %" := GlobalTempPOSTaxAmountLine."Tax %";
                POSTaxAmountLine2.Insert();
            until GlobalTempPOSTaxAmountLine.Next(-1) = 0;
            HandleRoundTaxUpOrDown(POSTaxAmountLine2, RoundTax, TotalTaxAmount, LastTaxAreaCode, LastTaxGroupCode);
        end;
        GlobalTempPOSTaxAmountLine.DeleteAll();
        POSTaxAmountLine2.Reset();
        if POSTaxAmountLine2.FindSet() then
            repeat
                GlobalTempPOSTaxAmountLine.Copy(POSTaxAmountLine2);
                GlobalTempPOSTaxAmountLine.Insert();
            until POSTaxAmountLine2.Next() = 0;
    end;

    procedure GetSalesTaxAmountLineTable(var POSTaxAmountLine2: Record "NPR POS Entry Tax Line" temporary)
    begin
        GlobalTempPOSTaxAmountLine.Reset();
        if GlobalTempPOSTaxAmountLine.FindSet() then
            repeat
                POSTaxAmountLine2.Copy(GlobalTempPOSTaxAmountLine);
                POSTaxAmountLine2.Insert();
            until GlobalTempPOSTaxAmountLine.Next() = 0;
    end;

    procedure SetTaxBaseAmount(var POSTaxAmountLine: Record "NPR POS Entry Tax Line"; Value: Decimal; ExchangeFactor: Decimal; Increment: Boolean)
    begin
        if Increment then
            POSTaxAmountLine."Tax Base Amount FCY" += Value
        else
            POSTaxAmountLine."Tax Base Amount FCY" := Value;
        POSTaxAmountLine."Tax Base Amount" := POSTaxAmountLine."Tax Base Amount FCY" / ExchangeFactor;
    end;

    local procedure CheckTaxAmtLinePos(SalesLineAmt: Decimal; TaxAmtLinePos: Boolean): Boolean
    begin
        exit(
          ((SalesLineAmt > 0) and TaxAmtLinePos) or
          ((SalesLineAmt <= 0) and not TaxAmtLinePos)
          );
    end;

    procedure HandleRoundTaxUpOrDown(var POSTaxAmountLine: Record "NPR POS Entry Tax Line"; RoundTax: Option "To Nearest",Up,Down; TotalTaxAmount: Decimal; TaxAreaCode: Code[20]; TaxGroupCode: Code[20])
    var
        RoundedAmount: Decimal;
        RoundingError: Decimal;
    begin
        if (RoundTax = RoundTax::"To Nearest") or (TotalTaxAmount = 0) then
            exit;
        case RoundTax of
            RoundTax::Up:
                RoundedAmount := Round(TotalTaxAmount, 0.01, '>');
            RoundTax::Down:
                RoundedAmount := Round(TotalTaxAmount, 0.01, '<');
        end;
        RoundingError := RoundedAmount - TotalTaxAmount;
        POSTaxAmountLine.Reset();
        POSTaxAmountLine.SetRange("Tax Area Code for Key", TaxAreaCode);
        POSTaxAmountLine.SetRange("Tax Group Code", TaxGroupCode);
        POSTaxAmountLine.SetRange("Is Report-to Jurisdiction", true);
        if POSTaxAmountLine.FindFirst() then begin
            POSTaxAmountLine.Delete();
            POSTaxAmountLine."Tax Amount" := POSTaxAmountLine."Tax Amount" + RoundingError;
            POSTaxAmountLine."Amount Including Tax" := POSTaxAmountLine."Tax Amount" + POSTaxAmountLine."Tax Base Amount";
            if POSTaxAmountLine."Tax Type" = POSTaxAmountLine."Tax Type"::"Excise Tax" then
                POSTaxAmountLine."Tax %" := 0
            else
                if POSTaxAmountLine."Tax Base Amount" <> 0 then
                    POSTaxAmountLine."Tax %" := 100 * (POSTaxAmountLine."Amount Including Tax" - POSTaxAmountLine."Tax Base Amount") / POSTaxAmountLine."Tax Base Amount";
            POSTaxAmountLine.Insert();
        end;
    end;
}

