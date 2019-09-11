codeunit 6150633 "POS Tax Calculation"
{
    // NPR5.36/BR  /20170727  CASE 279552  Object Created
    // NPR5.38/BR  /20180125  CASE 302803  Extended Error handling
    // NPR5.39/BR  /20180221  CASE 305795  Exception for non-prod environment
    // NPR5.41/MMV /20180413  CASE 311309  Replaced pos entry line distribution with a warning on discrepancy.
    //                                     Added support for tax calculation on active sale lines and rearranged functions.
    //                                     Replaced UpdateTaxFields with ValidateTaxFields
    //                                     Removed OnRun trigger.
    //                                     NA specific functionality handled via recref & fieldref.
    // NPR5.45/MHA /20180817  CASE 321875 DistTaxOverSaleLinePOS() should not trigger new discount calculation
    // NPR5.48/JDH /20181206  CASE 335967  Changed Tax calculation
    // NPR5.48/MMV /20190207  CASE 345317 Skip rounding line in new tax check
    // NPR5.50/TJ  /20190508  CASE 354322 Testing voucher without 0% check
    // NPR5.51/MHA /20190718  CASE 362329 Skip "Exclude from Posting" Sales Lines
    // NPR5.51/MHA /20190722  CASE 358985 Added function OnGetVATPostingSetup()


    trigger OnRun()
    begin
        //-NPR5.41 [311309]
        // POSEntry.SETRANGE("Entry No.");
        // IF POSEntry.FINDSET THEN REPEAT
        //  RefreshPOSTaxLines(POSEntry);
        // UNTIL POSEntry.NEXT = 0;
        //+NPR5.41 [311309]
    end;

    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        POSEntry: Record "POS Entry";
        GlobalTempPOSTaxAmountLine: Record "POS Tax Amount Line" temporary;
        TempPOSTaxAmountLine2: Record "POS Tax Amount Line" temporary;
        GlobalPOSSalesLine: Record "POS Sales Line";
        POSSalesLine2: Record "POS Sales Line";
        Currency: Record Currency;
        Text000: Label '%1 in %2 %3 must be filled in with unique values when %4 is %5.';
        TextErrorUpdating: Label 'Error updaing the %1 table for %2 %3.';
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
        TextTaxError: Label 'There is an error in calculating the tax. The POS Entry will not be able to be posted. Do you wish to continue?';

    local procedure "-- POS Entry Calculation"()
    begin
    end;

    procedure RefreshPOSTaxLines(var POSEntryIn: Record "POS Entry")
    var
        PersistentPOSTaxAmountLine: Record "POS Tax Amount Line";
        POSPostEntries: Codeunit "POS Post Entries";
        NPRetailSetup: Record "NP Retail Setup";
    begin
        OnBeforeRefreshTaxPOSEntry(POSEntryIn);
        if  POSEntryIn."Post Entry Status" >= POSEntryIn."Post Entry Status"::Posted then
          exit;

        //-NPR5.41 [311309]
        //UpdateTaxFields(POSEntryIn);
        ValidateTaxFields(POSEntryIn);
        //+NPR5.41 [311309]

        GlobalTempPOSTaxAmountLine.DeleteAll;
        PersistentPOSTaxAmountLine.SetRange("POS Entry No.",POSEntryIn."Entry No.");
        PersistentPOSTaxAmountLine.DeleteAll;

        CalculateSalesTaxLinesPOSEntry(POSEntryIn);
        PersistSalesTaxAmountLines(POSEntryIn);

        if not HasSalesTaxLines(POSEntryIn."Entry No.") then begin
          CalcVATAmountLines(POSEntryIn,TempVATAmountLine);
          //-NPR5.48 [335967]
          //UpdateVATOnLines(POSEntryIn,TempVATAmountLine);
          TestVATOnLines(POSEntryIn,TempVATAmountLine);
          //+NPR5.48 [335967]

          PersistVATAmountLines(POSEntryIn,TempVATAmountLine);
        end;

        NPRetailSetup.Get;
        if NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD then begin
          if not POSPostEntries.CheckPOSTaxAmountLines(POSEntryIn,false) then
            if not Confirm(TextTaxError) then
        //-NPR5.41 [311309]
        //      ERROR(TextErrorUpdating,TempPOSTaxAmountLine2.TABLECAPTION,POSEntryIn.TABLECAPTION,POSEntryIn."Entry No.");
              Error(GetLastErrorText);
        //+NPR5.41 [311309]
        end else
        //-NPR5.41 [311309]
        //  IF NOT POSPostEntries.CheckPOSTaxAmountLines(POSEntryIn,TRUE) THEN
        //    ERROR(TextErrorUpdating,TempPOSTaxAmountLine2.TABLECAPTION,POSEntryIn.TABLECAPTION,POSEntryIn."Entry No.");
          if not POSPostEntries.CheckPOSTaxAmountLines(POSEntryIn,false) then
            Message(GetLastErrorText);
        //+NPR5.41 [311309]

        OnAfterRefreshTaxPOSEntry(POSEntryIn);
    end;

    procedure CalculateSalesTaxLinesPOSEntry(POSEntryIn: Record "POS Entry")
    var
        POSSalesLine: Record "POS Sales Line";
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

        with POSSalesLine do begin
          SetRange("POS Entry No.",POSEntry."Entry No.");
          //-NPR5.41 [311309]
          //SETFILTER("Tax Group Code",'<>%1','');
          SetFilter(Type, '<>%1', Type::Rounding);
          SetRange("VAT Calculation Type", "VAT Calculation Type"::"Sales Tax");
          //+NPR5.41 [311309]
          //-NPR5.51 [362329]
          SetRange("Exclude from Posting",false);
          //+NPR5.51 [362329]
          if FindSet then
            repeat
              AddPOSSalesLine(POSSalesLine);
            until Next = 0;
        end;
        EndSalesTaxCalculation(POSEntry."Posting Date");

        //-NPR5.41 [311309]
        // POSSalesLine2.COPYFILTERS(POSSalesLine);
        // DistTaxOverPOSSalesLines(POSSalesLine);
        // POSSalesLine.COPYFILTERS(POSSalesLine2);
        //+NPR5.41 [311309]
    end;

    procedure AddPOSSalesLine(POSSalesLine: Record "POS Sales Line")
    var
        RecRef: RecordRef;
    begin
        //-NPR5.51 [362329]
        if POSSalesLine."Exclude from Posting" then
          exit;
        //+NPR5.51 [362329]
        if not GetSalesTaxCountry(POSSalesLine."Tax Area Code") then
          exit;

        POSSalesLine.TestField("Tax Group Code");

        with GlobalTempPOSTaxAmountLine do begin
          Reset;
          case TaxCountry of
            TaxCountry::US:  // Area Code
              begin
                SetRange("Tax Area Code for Key",POSSalesLine."Tax Area Code");
                "Tax Area Code for Key" := POSSalesLine."Tax Area Code";
              end;
            TaxCountry::CA:  // Jurisdictions
              begin
                SetRange("Tax Area Code for Key",'');
                "Tax Area Code for Key" := '';
              end;
          end;
          SetRange("Tax Group Code",POSSalesLine."Tax Group Code");
          TaxAreaLine.SetCurrentKey("Tax Area","Calculation Order");
          TaxAreaLine.SetRange("Tax Area",POSSalesLine."Tax Area Code");
          TaxAreaLine.FindSet;
          repeat
            SetRange("Tax Jurisdiction Code",TaxAreaLine."Tax Jurisdiction Code");
            SetRange(Positive,POSSalesLine."Amount Excl. VAT"> 0);

            "Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
            if not FindFirst then begin
              Init;
              "Tax Calculation Type" := "Tax Calculation Type"::"Sales Tax";
              "Tax Group Code" := POSSalesLine."Tax Group Code";
              "Tax Area Code" :=  POSSalesLine."Tax Area Code";
              "Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
              //-NPR5.41 [311309]
        //      IF TaxCountry = TaxCountry::US THEN BEGIN
        //        TaxJurisdiction.GET("Tax Jurisdiction Code");
        //        "Is Report-to Jurisdiction" := ("Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
        //      END;
              TaxJurisdiction.Get("Tax Jurisdiction Code");
              if TaxCountry = TaxCountry::US then begin
                RecRef.GetTable(TaxArea);
                "Round Tax" := RecRef.Field(10011).Value; //TaxArea."Round Tax" in NA localization
                "Is Report-to Jurisdiction" := ("Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
                "Print Order" := 0;
                "Print Description" := TaxArea.Description;
              end;
              if TaxCountry = TaxCountry::CA then begin
                RecRef.GetTable(TaxJurisdiction);
                "Print Order" := RecRef.Field(10020).Value; //TaxJurisdiction."Print Order" in NA localization
                "Print Description" := RecRef.Field(10030).Value; //TaxJurisdiction."Print Description" in NA localization
              end;
              //+NPR5.41 [311309]
              SetTaxBaseAmount(
                GlobalTempPOSTaxAmountLine,POSSalesLine."Amount Excl. VAT",ExchangeFactor,false);
              "Line Amount" := POSSalesLine."Amount Excl. VAT"/ ExchangeFactor;
              "Tax Liable" := POSSalesLine."Tax Liable";
              Quantity := POSSalesLine."Quantity (Base)";
              "Invoice Discount Amount" := 0;
              "Calculation Order" := TaxAreaLine."Calculation Order";

              Positive := POSSalesLine."Amount Excl. VAT" > 0;

              Insert;
            end else begin
              "Line Amount" := "Line Amount" + (POSSalesLine."Amount Excl. VAT" / ExchangeFactor);
              if POSSalesLine."Tax Liable" then
                "Tax Liable" := POSSalesLine."Tax Liable";
              SetTaxBaseAmount(
                GlobalTempPOSTaxAmountLine,POSSalesLine."Amount Excl. VAT" ,ExchangeFactor,true);
              "Tax Amount" := 0;
              Quantity := Quantity + POSSalesLine."Quantity (Base)";
              "Invoice Discount Amount" := "Invoice Discount Amount" + 0;
              Modify;
            end;
          until TaxAreaLine.Next = 0;
        end;
    end;

    procedure DistTaxOverPOSSalesLines(var POSSalesLine: Record "POS Sales Line")
    var
        POSSalesLine2: Record "POS Sales Line" temporary;
        TaxAmount: Decimal;
        Amount: Decimal;
        ReturnTaxAmount: Decimal;
    begin
        //-NPR5.41 [311309]
        // TotalTaxAmountRounding := 0;
        //  SetUpCurrency(POSEntry."Currency Code");
        //  IF POSEntry."Currency Factor" = 0 THEN
        //    ExchangeFactor := 1
        //  ELSE
        //    ExchangeFactor := POSEntry."Currency Factor";
        //
        // WITH GlobalTempPOSTaxAmountLine DO BEGIN
        //  RESET;
        //  IF FINDSET THEN
        //    REPEAT
        //      IF ("Tax Jurisdiction Code" <> TempPOSTaxAmountLine2."Tax Jurisdiction Code") AND (TaxCountry = TaxCountry::CA) THEN BEGIN
        //        TempPOSTaxAmountLine2."Tax Jurisdiction Code" := "Tax Jurisdiction Code";
        //        TotalTaxAmountRounding := 0;
        //      END;
        //      IF TaxCountry = TaxCountry::US THEN
        //        POSSalesLine.SETRANGE("Tax Area Code","Tax Area Code");
        //      POSSalesLine.SETRANGE("Tax Group Code","Tax Group Code");
        //      POSSalesLine.FINDSET(TRUE);
        //      REPEAT
        //        IF ((TaxCountry = TaxCountry::US) OR
        //            ((TaxCountry = TaxCountry::CA) AND TaxAreaLine.GET(POSSalesLine."Tax Area Code","Tax Jurisdiction Code"))) AND
        //           CheckTaxAmtLinePos(POSSalesLine."Amount Excl. VAT",
        //             Positive)
        //        THEN BEGIN
        //          IF "Tax Type" = "Tax Type"::"Sales and Use Tax" THEN BEGIN
        //            Amount := (POSSalesLine."Amount Excl. VAT");
        //            IF "Tax Difference" <> 0 THEN
        //              TaxAmount := Amount * "Tax Amount" / "Tax Base Amount"
        //            ELSE
        //              TaxAmount := Amount * "Tax %" / 100;
        //          END ELSE BEGIN
        //            IF (POSSalesLine."Quantity (Base)" = 0) OR (Quantity = 0) THEN
        //              TaxAmount := 0
        //            ELSE
        //              TaxAmount := "Tax Amount" * ExchangeFactor * POSSalesLine."Quantity (Base)" / Quantity;
        //          END;
        //          IF TaxAmount = 0 THEN
        //            ReturnTaxAmount := 0
        //          ELSE BEGIN
        //            ReturnTaxAmount := ROUND(TaxAmount + TotalTaxAmountRounding,Currency."Amount Rounding Precision");
        //            TotalTaxAmountRounding := TaxAmount + TotalTaxAmountRounding - ReturnTaxAmount;
        //          END;
        //          IF POSSalesLine2.GET(POSSalesLine."POS Entry No.",POSSalesLine."Line No.") THEN BEGIN
        //            POSSalesLine2."Amount Incl. VAT" := POSSalesLine2."Amount Incl. VAT" + ReturnTaxAmount;
        //            POSSalesLine2.MODIFY;
        //          END ELSE BEGIN
        //            POSSalesLine2.COPY(POSSalesLine);
        //            POSSalesLine2."Amount Incl. VAT" := POSSalesLine."Amount Excl. VAT" + ReturnTaxAmount;
        //            POSSalesLine2.INSERT;
        //          END;
        //          IF  POSSalesLine."Tax Liable" THEN
        //            POSSalesLine."Amount Incl. VAT" := POSSalesLine2."Amount Incl. VAT"
        //          ELSE
        //            POSSalesLine."Amount Incl. VAT" := POSSalesLine."Amount Excl. VAT";
        //          IF POSSalesLine."Amount Excl. VAT"  <> 0 THEN
        //            POSSalesLine."VAT %" :=
        //              ROUND(100 * (POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT") / POSSalesLine."Amount Excl. VAT",0.00001)
        //          ELSE
        //            POSSalesLine."VAT %" := 0;
        //          POSSalesLine.MODIFY;
        //        END;
        //      UNTIL POSSalesLine.NEXT = 0;
        //    UNTIL NEXT = 0;
        //  POSSalesLine.SETRANGE("Tax Area Code");
        //  POSSalesLine.SETRANGE("Tax Group Code");
        //  POSSalesLine.SETRANGE("POS Entry No.",POSEntry."Entry No.");
        //  IF POSSalesLine.FINDSET(TRUE) THEN
        //    REPEAT
        //      POSSalesLine."Amount Incl. VAT" := ROUND(POSSalesLine."Amount Incl. VAT",Currency."Amount Rounding Precision");
        //      POSSalesLine."Amount Excl. VAT" :=
        //        ROUND(POSSalesLine."Amount Excl. VAT",Currency."Amount Rounding Precision");
        //      POSSalesLine."VAT Base Amount" := POSSalesLine."Amount Excl. VAT";
        //      IF (((POSSalesLine."Tax Area Code" = '') AND ("Tax Area Code" <> '')) OR (POSSalesLine."Tax Group Code" = '')) OR
        //        (POSSalesLine.Type = POSSalesLine.Type::Voucher) THEN //Vouchers always excluding VAT
        //          POSSalesLine."Amount Incl. VAT" := POSSalesLine."Amount Excl. VAT";
        //      POSSalesLine.MODIFY;
        //    UNTIL POSSalesLine.NEXT = 0;
        // END;
        //+NPR5.41 [311309]
    end;

    local procedure UpdateTaxFields(var POSEntryIn: Record "POS Entry")
    var
        POSSalesLine: Record "POS Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        GLAccount: Record "G/L Account";
    begin
        //-NPR5.41 [311309]
        // POSSalesLine.SETRANGE("POS Entry No.",POSEntryIn."Entry No.");
        // IF POSSalesLine.FINDSET THEN REPEAT
        //  IF (POSSalesLine."VAT Identifier" = '') THEN BEGIN
        //    IF (POSSalesLine."VAT Prod. Posting Group" = '') THEN BEGIN
        //      CASE POSSalesLine.Type OF
        //        POSSalesLine.Type::Item :
        //          BEGIN
        //            IF Item.GET(POSSalesLine."No.") THEN
        //               POSSalesLine."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        //          END;
        //        POSSalesLine.Type::"G/L Account",POSSalesLine.Type::Voucher:
        //          BEGIN
        //             IF GLAccount.GET(POSSalesLine."No.") THEN
        //               POSSalesLine."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        //          END;
        //      END;
        //    END;
        //    IF (POSSalesLine."VAT Prod. Posting Group" <> '') THEN BEGIN
        //      VATPostingSetup.GET(POSSalesLine."VAT Bus. Posting Group",POSSalesLine."VAT Prod. Posting Group");
        //      IF (POSSalesLine.Type = POSSalesLine.Type::Voucher) AND (VATPostingSetup."VAT %" <> 0) THEN BEGIN //Vouchers MUST have 0 VAT
        //        VATPostingSetup.SETRANGE("VAT Bus. Posting Group",VATPostingSetup."VAT Bus. Posting Group");
        //        VATPostingSetup.SETRANGE("VAT %",0);
        //        VATPostingSetup.FINDFIRST;
        //      END;
        //      POSSalesLine."VAT Difference" := 0;
        //      POSSalesLine."VAT %" := VATPostingSetup."VAT %";
        //      POSSalesLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
        //      POSSalesLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
        //      CASE POSSalesLine."VAT Calculation Type" OF
        //        POSSalesLine."VAT Calculation Type"::"Reverse Charge VAT",
        //        POSSalesLine."VAT Calculation Type"::"Sales Tax":
        //          POSSalesLine."VAT %" := 0;
        //        POSSalesLine."VAT Calculation Type"::"Full VAT":
        //          BEGIN
        //            POSSalesLine.TESTFIELD(Type,POSSalesLine.Type::"G/L Account");
        //            VATPostingSetup.TESTFIELD("Sales VAT Account");
        //            POSSalesLine.TESTFIELD("No.",VATPostingSetup."Sales VAT Account");
        //          END;
        //      END;
        //      POSSalesLine.MODIFY;
        //    END;
        //  END;
        // UNTIL POSSalesLine.NEXT  = 0;
        //+NPR5.41 [311309]
    end;

    local procedure ValidateTaxFields(var POSEntryIn: Record "POS Entry")
    var
        POSSalesLine: Record "POS Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        GLAccount: Record "G/L Account";
    begin
        //-NPR5.41 [311309]
        POSSalesLine.SetRange("POS Entry No.",POSEntryIn."Entry No.");
        //-NPR5.51 [362329]
        POSSalesLine.SetRange("Exclude from Posting",false);
        //+NPR5.51 [362329]
        if POSSalesLine.FindSet then repeat
          if POSSalesLine.Type = POSSalesLine.Type::Voucher then begin
            VATPostingSetup.Get(POSSalesLine."VAT Bus. Posting Group", POSSalesLine."VAT Prod. Posting Group");
            //-NPR5.50 [354322]
            //VATPostingSetup.TESTFIELD("VAT %", 0);
            //+NPR5.50 [354322]
          end;
          if (POSSalesLine."VAT Calculation Type" = POSSalesLine."VAT Calculation Type"::"Full VAT") and (POSSalesLine."VAT Prod. Posting Group" <> '') then begin
            VATPostingSetup.Get(POSSalesLine."VAT Bus. Posting Group",POSSalesLine."VAT Prod. Posting Group");
            POSSalesLine.TestField(Type,POSSalesLine.Type::"G/L Account");
            VATPostingSetup.TestField("Sales VAT Account");
            POSSalesLine.TestField("No.",VATPostingSetup."Sales VAT Account");
          end;
        until POSSalesLine.Next  = 0;
        //+NPR5.41 [311309]
    end;

    local procedure PersistSalesTaxAmountLines(var POSEntryIn: Record "POS Entry")
    var
        PersistentPOSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        if GlobalTempPOSTaxAmountLine.FindSet then repeat
          PersistentPOSTaxAmountLine.Init;
          PersistentPOSTaxAmountLine := GlobalTempPOSTaxAmountLine;
          PersistentPOSTaxAmountLine."POS Entry No." := POSEntryIn."Entry No.";
          PersistentPOSTaxAmountLine.Insert;
        until GlobalTempPOSTaxAmountLine.Next  = 0;
    end;

    local procedure PersistVATAmountLines(var POSEntryIn: Record "POS Entry";var VATAmountLine: Record "VAT Amount Line")
    var
        PersistentPOSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        if VATAmountLine.FindSet then repeat
          PersistentPOSTaxAmountLine.Init;
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
          PersistentPOSTaxAmountLine.Insert;
        until VATAmountLine.Next  = 0;
    end;

    procedure UpdateVATOnLines(var POSEntryIn: Record "POS Entry";var VATAmountLine: Record "VAT Amount Line")
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

        TempVATAmountLineRemainder.DeleteAll;

        with GlobalPOSSalesLine do begin
          SetRange("POS Entry No.",POSEntry."Entry No.");
          //-NPR5.51 [362329]
          SetRange("Exclude from Posting",false);
          //+NPR5.51 [362329]
          LockTable;
          if FindSet then
            repeat
              if ((("Unit Price" <> 0) and (Quantity <> 0)) or ("Amount Excl. VAT" <> 0)) then begin
                if "VAT Base Amount" <> 0 then
                  DeferralAmount := "VAT Base Amount"
                else
                  DeferralAmount := "Amount Excl. VAT";
                VATAmountLine.Get("VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Amount Excl. VAT" >= 0);
                if VATAmountLine.Modified then begin
                  if not TempVATAmountLineRemainder.Get(
                       "VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Amount Excl. VAT" >= 0)
                  then begin
                    TempVATAmountLineRemainder := VATAmountLine;
                    TempVATAmountLineRemainder.Init;
                    TempVATAmountLineRemainder.Insert;
                  end;

                  LineAmountToInvoice := "Amount Excl. VAT";
        //        In the POS, the Line Amount is always excl. VAT
        //            IF POSEntry."Prices Including VAT" THEN BEGIN
        //              IF (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount" = 0) OR
        //                 ("Amount Excl. VAT" = 0)
        //              THEN BEGIN
        //                VATAmount := 0;
        //                NewAmountIncludingVAT := 0;
        //              END ELSE BEGIN
        //                VATAmount :=
        //                  TempVATAmountLineRemainder."VAT Amount" +
        //                  VATAmountLine."VAT Amount" *
        //                  ("Amount Excl. VAT") /
        //                  (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount");
        //                NewAmountIncludingVAT :=
        //                  TempVATAmountLineRemainder."Amount Including VAT" +
        //                  VATAmountLine."Amount Including VAT" *
        //                  ("Amount Excl. VAT") /
        //                  (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount");
        //              END;
        //              NewAmount :=
        //                ROUND(NewAmountIncludingVAT,Currency."Amount Rounding Precision") -
        //                ROUND(VATAmount,Currency."Amount Rounding Precision");
        //              NewVATBaseAmount :=
        //                ROUND(
        //                  NewAmount,
        //                  Currency."Amount Rounding Precision");
        //            END ELSE BEGIN
        //
                      if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then begin
                        VATAmount := "Amount Excl. VAT";
                        NewAmount := 0;
                        NewVATBaseAmount := 0;
                      end else begin
                        NewAmount := "Amount Excl. VAT";
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
                      NewAmountIncludingVAT := NewAmount + Round(VATAmount,Currency."Amount Rounding Precision");

        //            END;

                  "Amount Excl. VAT" := NewAmount;
                  "Amount Incl. VAT" := Round(NewAmountIncludingVAT,Currency."Amount Rounding Precision");
                  "VAT Base Amount" := NewVATBaseAmount;

                  UpdateLCYAmounts;

                  Modify;
        //          IF ("Deferral Code" <> '') AND (DeferralAmount <> GetDeferralAmount) THEN
        //            UpdateDeferralAmounts;

                  TempVATAmountLineRemainder."Amount Including VAT" :=
                    NewAmountIncludingVAT - Round(NewAmountIncludingVAT,Currency."Amount Rounding Precision");
                  TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                  TempVATAmountLineRemainder."VAT Difference" := VATDifference - "VAT Difference";
                  TempVATAmountLineRemainder.Modify;
                end;
              end;
            until Next = 0;
        end;
    end;

    procedure TestVATOnLines(var POSEntryIn: Record "POS Entry";var VATAmountLine: Record "VAT Amount Line")
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
        POSSalesLine: Record "POS Sales Line";
    begin
        //-NPR5.48 [335967]
        POSEntry := POSEntryIn;
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;

        if  (not VATAmountLine.FindFirst ()) then
          exit;

        repeat
          POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
          POSSalesLine.SetRange("VAT Identifier", VATAmountLine."VAT Identifier");
          POSSalesLine.SetRange("Tax Group Code", VATAmountLine."Tax Group Code");
        //-NPR5.48 [345317]
          POSSalesLine.SetFilter(Type, '<>%1', POSSalesLine.Type::Rounding);
        //+NPR5.48 [345317]
          if VATAmountLine.Positive then
            POSSalesLine.SetFilter("Amount Excl. VAT", '>=%1', 0)
          else
            POSSalesLine.SetFilter("Amount Excl. VAT", '<%1', 0);
          //-NPR5.51 [362329]
          POSSalesLine.SetRange("Exclude from Posting",false);
          //+NPR5.51 [362329]
          POSSalesLine.CalcSums("Line Amount", "Amount Excl. VAT" ,"Amount Incl. VAT");

          VATAmountLine.TestField("VAT Base", POSSalesLine."Amount Excl. VAT");
          VATAmountLine.TestField("Amount Including VAT", POSSalesLine."Amount Incl. VAT");
          VATAmountLine.TestField("VAT Amount", POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT");
        until VATAmountLine.Next = 0;
        //+NPR5.48 [335967]
    end;

    procedure CalcVATAmountLines(var POSEntryIn: Record "POS Entry";var VATAmountLine: Record "VAT Amount Line")
    var
        PrevVatAmountLine: Record "VAT Amount Line";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalVATAmount: Decimal;
        QtyToHandle: Decimal;
        RoundingLineInserted: Boolean;
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

        VATAmountLine.DeleteAll;

        with GlobalPOSSalesLine do begin
          SetRange("POS Entry No.",POSEntryIn."Entry No.");
          //-NPR5.41 [311309]
          SetFilter(Type, '<>%1', Type::Rounding);
          //+NPR5.41 [311309]
          //-NPR5.51 [362329]
          SetRange("Exclude from Posting",false);
          //+NPR5.51 [362329]
          if FindSet then
            repeat
              if (("Unit Price" <> 0) and (Quantity <> 0)) or ("Amount Excl. VAT" <> 0) then begin
                if ("VAT Calculation Type" in
                   ["VAT Calculation Type"::"Reverse Charge VAT","VAT Calculation Type"::"Sales Tax"])
                //-NPR5.50 [354322]
                //OR (Type = Type::Voucher) THEN //Vouchers exluded from VAT
                then
                //+NPR5.50 [354322]
                  "VAT %" := 0;
                if not VATAmountLine.Get(
                     //-NPR5.48 [335967]
                     //"VAT Identifier","VAT Calculation Type","Tax Group Code",FALSE,"Amount Excl. VAT" >= 0)
                     "VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Line Amount" >= 0)
                     //+NPR5.48 [335967]
                then begin
                  VATAmountLine.Init;
                  VATAmountLine."VAT Identifier" := "VAT Identifier";
                  VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                  VATAmountLine."Tax Group Code" := "Tax Group Code";
                  VATAmountLine."VAT %" := "VAT %";
                  VATAmountLine.Modified := true;
                  //-NPR5.48 [335967]
                  //VATAmountLine.Positive := "Amount Excl. VAT" >= 0;
                  VATAmountLine.Positive := "Line Amount" >= 0;
                  //+NPR5.48 [335967]
                  VATAmountLine.Insert;
                end;
                VATAmountLine.Quantity := VATAmountLine.Quantity + "Quantity (Base)";
                //-NPR5.48 [335967]
                //VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + "Amount Excl. VAT";
                //VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + "VAT Difference";
                VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + "Line Amount";
                //+NPR5.48 [335967]

                VATAmountLine.Modify;
                TotalVATAmount := TotalVATAmount + "Amount Incl. VAT" - "Amount Excl. VAT";
              end;
            until Next = 0;
        end;

        //-NPR5.48 [335967]
        //Copyed CalcVATAmountLines from T37, and commented previous version
        // WITH VATAmountLine DO
        //  IF FINDSET THEN
        //    REPEAT
        //      IF (PrevVatAmountLine."VAT Identifier" <> "VAT Identifier") OR
        //         (PrevVatAmountLine."VAT Calculation Type" <> "VAT Calculation Type") OR
        //         (PrevVatAmountLine."Tax Group Code" <> "Tax Group Code") OR
        //         (PrevVatAmountLine."Use Tax" <> "Use Tax")
        //      THEN
        //        PrevVatAmountLine.INIT;
        //     // VAT Calculation independendant of price (unlike in Sales Order
        // //      IF POSEntry."Prices Including VAT" THEN BEGIN
        // //        CASE "VAT Calculation Type" OF
        // //          "VAT Calculation Type"::"Normal VAT",
        // //          "VAT Calculation Type"::"Reverse Charge VAT":
        // //            BEGIN
        // //              "VAT Base" :=
        // //                ROUND(
        // //                  ("Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
        // //                  Currency."Amount Rounding Precision") - "VAT Difference";
        // //              "VAT Amount" :=
        // //                "VAT Difference" +
        // //                ROUND(
        // //                  PrevVatAmountLine."VAT Amount" +
        // //                  ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference"),
        // //                  Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
        // //              "Amount Including VAT" := "VAT Base" + "VAT Amount";
        // //              IF Positive THEN
        // //                PrevVatAmountLine.INIT
        // //              ELSE BEGIN
        // //                PrevVatAmountLine := VATAmountLine;
        // //                PrevVatAmountLine."VAT Amount" :=
        // //                  ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference");
        // //                PrevVatAmountLine."VAT Amount" :=
        // //                  PrevVatAmountLine."VAT Amount" -
        // //                  ROUND(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
        // //              END;
        // //            END;
        // //          "VAT Calculation Type"::"Full VAT":
        // //            BEGIN
        // //              "VAT Base" := 0;
        // //              "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
        // //              "Amount Including VAT" := "VAT Amount";
        // //            END;
        // //          "VAT Calculation Type"::"Sales Tax":
        // //            BEGIN
        // //              "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount";
        // //              "VAT Base" :=
        // //                ROUND(
        // //                  SalesTaxCalculate.ReverseCalculateTax(
        // //                    GlobalPOSSalesLine."Tax Area Code","Tax Group Code",GlobalPOSSalesLine."Tax Liable",
        // //                    POSEntry."Posting Date","Amount Including VAT",Quantity,POSEntry."Currency Factor"),
        // //                  Currency."Amount Rounding Precision");
        // //              "VAT Amount" := "VAT Difference" + "Amount Including VAT" - "VAT Base";
        // //              IF "VAT Base" = 0 THEN
        // //                "VAT %" := 0
        // //              ELSE
        // //                "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base",0.00001);
        // //            END;
        // //        END;
        // //      END ELSE
        //        CASE "VAT Calculation Type" OF
        //          "VAT Calculation Type"::"Normal VAT",
        //          "VAT Calculation Type"::"Reverse Charge VAT":
        //            BEGIN
        //              "VAT Base" := "Line Amount" - "Invoice Discount Amount";
        //              "VAT Amount" :=
        //                "VAT Difference" +
        //                ROUND(
        //                  PrevVatAmountLine."VAT Amount" +
        //                  "VAT Base" * "VAT %" / 100,
        //                  Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
        //              "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount" + "VAT Amount";
        //              IF Positive THEN
        //                PrevVatAmountLine.INIT
        //              ELSE
        //                IF NOT "Includes Prepayment" THEN BEGIN
        //                  PrevVatAmountLine := VATAmountLine;
        //                  PrevVatAmountLine."VAT Amount" :=
        //                    "VAT Base" * "VAT %" / 100 ;
        //                  PrevVatAmountLine."VAT Amount" :=
        //                    PrevVatAmountLine."VAT Amount" -
        //                    ROUND(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
        //                END;
        //            END;
        //          "VAT Calculation Type"::"Full VAT":
        //            BEGIN
        //              "VAT Base" := 0;
        //              "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
        //              "Amount Including VAT" := "VAT Amount";
        //            END;
        //          "VAT Calculation Type"::"Sales Tax":
        //            BEGIN
        //              "VAT Base" := "Line Amount" - "Invoice Discount Amount";
        //              "VAT Amount" :=
        //                SalesTaxCalculate.CalculateTax(
        //                  GlobalPOSSalesLine."Tax Area Code","Tax Group Code",GlobalPOSSalesLine."Tax Liable",
        //                  POSEntry."Posting Date","VAT Base",Quantity,POSEntry."Currency Factor");
        //              IF "VAT Base" = 0 THEN
        //                "VAT %" := 0
        //              ELSE
        //                "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base",0.00001);
        //              "VAT Amount" :=
        //                "VAT Difference" +
        //                ROUND("VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
        //              "Amount Including VAT" := "VAT Base" + "VAT Amount";
        //            END;
        //        END;
        //
        //      IF RoundingLineInserted THEN
        //        TotalVATAmount := TotalVATAmount - "VAT Amount";
        //      "Calculated VAT Amount" := "VAT Amount" - "VAT Difference";
        //      MODIFY;
        //    UNTIL NEXT = 0;
        //
        // IF RoundingLineInserted AND (TotalVATAmount <> 0) THEN
        //  IF VATAmountLine.GET(GlobalPOSSalesLine."VAT Identifier",GlobalPOSSalesLine."VAT Calculation Type",
        //       GlobalPOSSalesLine."Tax Group Code",FALSE,GlobalPOSSalesLine."Amount Excl. VAT" >= 0)
        //  THEN BEGIN
        //    VATAmountLine."VAT Amount" := VATAmountLine."VAT Amount" + TotalVATAmount;
        //    VATAmountLine."Amount Including VAT" := VATAmountLine."Amount Including VAT" + TotalVATAmount;
        //    VATAmountLine."Calculated VAT Amount" := VATAmountLine."Calculated VAT Amount" + TotalVATAmount;
        //    VATAmountLine.MODIFY;
        //  END;


        with VATAmountLine do
          if FindSet then
            repeat
              if (PrevVatAmountLine."VAT Identifier" <> "VAT Identifier") or
                 (PrevVatAmountLine."VAT Calculation Type" <> "VAT Calculation Type") or
                 (PrevVatAmountLine."Tax Group Code" <> "Tax Group Code") or
                 (PrevVatAmountLine."Use Tax" <> "Use Tax")
              then
                PrevVatAmountLine.Init;
              if POSEntry."Prices Including VAT" then begin
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      "VAT Base" :=
                        Round(
                          ("Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
                          Currency."Amount Rounding Precision") - "VAT Difference";
                      "VAT Amount" :=
                        "VAT Difference" +
                        Round(
                          PrevVatAmountLine."VAT Amount" +
                          ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference"),
                          Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "VAT Base" + "VAT Amount";
                      if Positive then
                        PrevVatAmountLine.Init
                      else begin
                        PrevVatAmountLine := VATAmountLine;
                        PrevVatAmountLine."VAT Amount" :=
                          ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference");
                        PrevVatAmountLine."VAT Amount" :=
                          PrevVatAmountLine."VAT Amount" -
                          Round(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      end;
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      "VAT Base" := 0;
                      "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                      "Amount Including VAT" := "VAT Amount";
                    end;
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Base" :=
                        Round(
                          SalesTaxCalculate.ReverseCalculateTax(
                            POSEntry."Tax Area Code","Tax Group Code",GlobalPOSSalesLine."Tax Liable",
                            POSEntry."Posting Date","Amount Including VAT",Quantity,POSEntry."Currency Factor"),
                          Currency."Amount Rounding Precision");
                      "VAT Amount" := "VAT Difference" + "Amount Including VAT" - "VAT Base";
                      if "VAT Base" = 0 then
                        "VAT %" := 0
                      else
                        "VAT %" := Round(100 * "VAT Amount" / "VAT Base",0.00001);
                    end;
                end;
              end else
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Amount" :=
                        "VAT Difference" +
                        Round(
                          PrevVatAmountLine."VAT Amount" +
                          "VAT Base" * "VAT %" / 100,
                          Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount" + "VAT Amount";
                      if Positive then
                        PrevVatAmountLine.Init
                      else
                        if not "Includes Prepayment" then begin
                          PrevVatAmountLine := VATAmountLine;
                          PrevVatAmountLine."VAT Amount" :=
                            "VAT Base" * "VAT %" / 100;
                          PrevVatAmountLine."VAT Amount" :=
                            PrevVatAmountLine."VAT Amount" -
                            Round(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                        end;
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      "VAT Base" := 0;
                      "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                      "Amount Including VAT" := "VAT Amount";
                    end;
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Amount" :=
                        SalesTaxCalculate.CalculateTax(
                          POSEntry."Tax Area Code","Tax Group Code",GlobalPOSSalesLine."Tax Liable",
                          POSEntry."Posting Date","VAT Base",Quantity,POSEntry."Currency Factor");
                      if "VAT Base" = 0 then
                        "VAT %" := 0
                      else
                        "VAT %" := Round(100 * "VAT Amount" / "VAT Base",0.00001);
                      "VAT Amount" :=
                        "VAT Difference" +
                        Round("VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "VAT Base" + "VAT Amount";
                    end;
                end;

              "Calculated VAT Amount" := "VAT Amount" - "VAT Difference";
              Modify;
            until Next = 0;
        //+NPR5.48 [335967]
    end;

    local procedure HasSalesTaxLines(POSEntryNo: Integer): Boolean
    var
        POSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        POSTaxAmountLine.SetRange("POS Entry No.",POSEntryNo);
        POSTaxAmountLine.SetRange("Tax Calculation Type",POSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
        exit(not POSTaxAmountLine.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRefreshTaxPOSEntry(var POSEntry: Record "POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRefreshTaxPOSEntry(var POSEntry: Record "POS Entry")
    begin
    end;

    local procedure "-- Active POS Line Calculation"()
    begin
    end;

    procedure CalculateSalesTaxSaleLinePOS(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    var
        TaxArea: Record "Tax Area";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin
        //-NPR5.41 [311309]
        if SalePOS."Tax Area Code" = '' then
          exit;
        if SalePOS."Price including VAT" then
          exit;
        TaxArea.Get(SalePOS."Tax Area Code");
        SetUpCurrency('');
        ExchangeFactor := 1;

        with SaleLinePOS do begin
          SetRange("Register No.", SalePOS."Register No.");
          SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
          SetRange(Date, SalePOS.Date);
          SetRange("VAT Calculation Type", "VAT Calculation Type"::"Sales Tax");
          SetFilter("Sale Type", '%1|%2|%3|%4|%5', "Sale Type"::Sale, "Sale Type"::"Gift Voucher", "Sale Type"::"Credit Voucher", "Sale Type"::Deposit, "Sale Type"::"Out payment");
          if FindSet then
            repeat
              if (not (("Sale Type" = "Sale Type"::"Out payment") and (Type <> Type::"G/L Entry"))) then
                AddSaleLinePOS(SaleLinePOS);
            until Next = 0
          else
            exit;
        end;

        EndSalesTaxCalculation(SalePOS.Date);
        DistTaxOverSaleLinePOS(SaleLinePOS);
        //+NPR5.41 [311309]
    end;

    local procedure AddSaleLinePOS(SaleLinePOS: Record "Sale Line POS")
    var
        POSCreateEntry: Codeunit "POS Create Entry";
        RecRef: RecordRef;
    begin
        //-NPR5.51 [362329]
        if POSCreateEntry.ExcludeFromPosting(SaleLinePOS) then
          exit;
        //+NPR5.51 [362329]
        //-NPR5.41 [311309]
        if not GetSalesTaxCountry(SaleLinePOS."Tax Area Code") then
          exit;

        SaleLinePOS.TestField("Tax Group Code");

        with GlobalTempPOSTaxAmountLine do begin
          Reset;
          case TaxCountry of
            TaxCountry::US:  // Area Code
              begin
                SetRange("Tax Area Code for Key",SaleLinePOS."Tax Area Code");
                "Tax Area Code for Key" := SaleLinePOS."Tax Area Code";
              end;
            TaxCountry::CA:  // Jurisdictions
              begin
                SetRange("Tax Area Code for Key",'');
                "Tax Area Code for Key" := '';
              end;
          end;
          SetRange("Tax Group Code",SaleLinePOS."Tax Group Code");
          TaxAreaLine.SetCurrentKey("Tax Area","Calculation Order");
          TaxAreaLine.SetRange("Tax Area",SaleLinePOS."Tax Area Code");
          TaxAreaLine.FindSet;
          repeat
            SetRange("Tax Jurisdiction Code",TaxAreaLine."Tax Jurisdiction Code");
            SetRange(Positive,SaleLinePOS.Amount > 0);

            "Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
            if not FindFirst then begin
              Init;
              "Tax Calculation Type" := "Tax Calculation Type"::"Sales Tax";
              "Tax Group Code" := SaleLinePOS."Tax Group Code";
              "Tax Area Code" :=  SaleLinePOS."Tax Area Code";
              "Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
              TaxJurisdiction.Get("Tax Jurisdiction Code");
              if TaxCountry = TaxCountry::US then begin
                RecRef.GetTable(TaxArea);
                "Round Tax" := RecRef.Field(10011).Value; //TaxArea."Round Tax" in NA localization
                "Is Report-to Jurisdiction" := ("Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
                "Print Order" := 0;
                "Print Description" := TaxArea.Description;
              end;
              if TaxCountry = TaxCountry::CA then begin
                RecRef.GetTable(TaxJurisdiction);
                "Print Order" := RecRef.Field(10020).Value; //TaxJurisdiction."Print Order" in NA localization
                "Print Description" := RecRef.Field(10030).Value; //TaxJurisdiction."Print Description" in NA localization
              end;
              SetTaxBaseAmount(
                GlobalTempPOSTaxAmountLine,SaleLinePOS.Amount,ExchangeFactor,false);
              "Line Amount" := SaleLinePOS.Amount/ ExchangeFactor;
              "Tax Liable" := SaleLinePOS."Tax Liable";
              Quantity := SaleLinePOS."Quantity (Base)";
              "Invoice Discount Amount" := 0;
              "Calculation Order" := TaxAreaLine."Calculation Order";

              Positive := SaleLinePOS.Amount > 0;

              Insert;
            end else begin
              "Line Amount" := "Line Amount" + (SaleLinePOS.Amount / ExchangeFactor);
              if SaleLinePOS."Tax Liable" then
                "Tax Liable" := SaleLinePOS."Tax Liable";
              SetTaxBaseAmount(
                GlobalTempPOSTaxAmountLine,SaleLinePOS.Amount ,ExchangeFactor,true);
              "Tax Amount" := 0;
              Quantity := Quantity + SaleLinePOS."Quantity (Base)";
              "Invoice Discount Amount" := "Invoice Discount Amount" + 0;
              Modify;
            end;
          until TaxAreaLine.Next = 0;
        end;
        //+NPR5.41 [311309]
    end;

    local procedure DistTaxOverSaleLinePOS(var SaleLinePOS: Record "Sale Line POS")
    var
        tmpSaleLinePOS: Record "Sale Line POS" temporary;
        Amount: Decimal;
        TaxAmount: Decimal;
        ReturnTaxAmount: Decimal;
    begin
        //+NPR5.41 [311309]
        TotalTaxAmountRounding := 0;
        SetUpCurrency(POSEntry."Currency Code");
        if POSEntry."Currency Factor" = 0 then
          ExchangeFactor := 1
        else
          ExchangeFactor := POSEntry."Currency Factor";
        //-NPR5.45 [321875]
        SaleLinePOS.SetSkipCalcDiscount(true);
        //+NPR5.45 [321875]
        with GlobalTempPOSTaxAmountLine do begin
          Reset;
          if FindSet then
            repeat
              if ("Tax Jurisdiction Code" <> TempPOSTaxAmountLine2."Tax Jurisdiction Code") and (TaxCountry = TaxCountry::CA) then begin
                TempPOSTaxAmountLine2."Tax Jurisdiction Code" := "Tax Jurisdiction Code";
                TotalTaxAmountRounding := 0;
              end;
              if TaxCountry = TaxCountry::US then
                SaleLinePOS.SetRange("Tax Area Code","Tax Area Code");
              SaleLinePOS.SetRange("Tax Group Code","Tax Group Code");
              SaleLinePOS.FindSet(true);
              repeat
                if ((TaxCountry = TaxCountry::US) or
                    ((TaxCountry = TaxCountry::CA) and TaxAreaLine.Get(SaleLinePOS."Tax Area Code","Tax Jurisdiction Code"))) and
                   CheckTaxAmtLinePos(SaleLinePOS.Amount,
                     Positive)
                then begin
                  if "Tax Type" = "Tax Type"::"Sales and Use Tax" then begin
                    Amount := (SaleLinePOS.Amount);
                    if "Tax Difference" <> 0 then
                      TaxAmount := Amount * "Tax Amount" / "Tax Base Amount"
                    else
                      TaxAmount := Amount * "Tax %" / 100;
                  end else begin
                    if (SaleLinePOS."Quantity (Base)" = 0) or (Quantity = 0) then
                      TaxAmount := 0
                    else
                      TaxAmount := "Tax Amount" * ExchangeFactor * SaleLinePOS."Quantity (Base)" / Quantity;
                  end;
                  if TaxAmount = 0 then
                    ReturnTaxAmount := 0
                  else begin
                    ReturnTaxAmount := Round(TaxAmount + TotalTaxAmountRounding,Currency."Amount Rounding Precision");
                    TotalTaxAmountRounding := TaxAmount + TotalTaxAmountRounding - ReturnTaxAmount;
                  end;
                  if tmpSaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Line No.") then begin
                    tmpSaleLinePOS."Amount Including VAT" := tmpSaleLinePOS."Amount Including VAT" + ReturnTaxAmount;
                    tmpSaleLinePOS.Modify;
                  end else begin
                    tmpSaleLinePOS.Copy(SaleLinePOS);
                    tmpSaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount + ReturnTaxAmount;
                    tmpSaleLinePOS.Insert;
                  end;
                  if SaleLinePOS."Tax Liable" then
                    SaleLinePOS."Amount Including VAT" := tmpSaleLinePOS."Amount Including VAT"
                  else
                    SaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount;
                  if SaleLinePOS.Amount <> 0 then
                    SaleLinePOS."VAT %" :=
                      Round(100 * (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount) / SaleLinePOS.Amount,0.00001)
                  else
                    SaleLinePOS."VAT %" := 0;
                  SaleLinePOS.Modify;
                end;
              until SaleLinePOS.Next = 0;
            until Next = 0;
          SaleLinePOS.SetRange("Tax Area Code");
          SaleLinePOS.SetRange("Tax Group Code");
          if SaleLinePOS.FindSet(true) then
            repeat
              SaleLinePOS."Amount Including VAT" := Round(SaleLinePOS."Amount Including VAT",Currency."Amount Rounding Precision");
              SaleLinePOS.Amount :=
                Round(SaleLinePOS.Amount,Currency."Amount Rounding Precision");
              SaleLinePOS."VAT Base Amount" := SaleLinePOS.Amount;
              if (((SaleLinePOS."Tax Area Code" = '') and ("Tax Area Code" <> '')) or (SaleLinePOS."Tax Group Code" = '')) or
                (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::"Credit Voucher", SaleLinePOS."Sale Type"::"Gift Voucher"]) then //Vouchers always excluding VAT
                  SaleLinePOS."Amount Including VAT" := SaleLinePOS.Amount;
              SaleLinePOS.Modify;
            until SaleLinePOS.Next = 0;
        end;
        //+NPR5.41 [311309]
    end;

    local procedure "-- Hooks"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup";var Handled: Boolean)
    begin
    end;

    local procedure "-- Aux"()
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
        //-NPR5.41 [311309]
        //  IF TaxArea.GET(TaxAreaCode) THEN
        //    EXIT(TRUE);
          if TaxArea.Get(TaxAreaCode) then begin
            RecRef.GetTable(TaxArea);
            NewTaxCountry := RecRef.Field(10010).Value; //TaxArea."Country/Region" in NA localization.
            if TaxCountry <> NewTaxCountry then
              Error(Text1020000,NewTaxCountry,TaxCountry)
            else
              exit(true);
          end;
        //+NPR5.41 [311309]
        end else
          if TaxArea.Get(TaxAreaCode) then begin
            TaxAreaRead := true;
        //-NPR5.41 [311309]
            RecRef.GetTable(TaxArea);
            TaxCountry := RecRef.Field(10010).Value; //TaxArea."Country/Region" in NA localization.
        //+NPR5.41 [311309]
            exit(true);
          end;

        exit(false);
    end;

    procedure EndSalesTaxCalculation(Date: Date)
    var
        POSTaxAmountLine2: Record "POS Tax Amount Line" temporary;
        TaxDetail: Record "Tax Detail";
        AddedTaxAmount: Decimal;
        TotalTaxAmount: Decimal;
        MaxAmount: Decimal;
        TaxBaseAmt: Decimal;
        TaxDetailFound: Boolean;
        LastTaxAreaCode: Code[20];
        LastTaxType: Integer;
        LastTaxGroupCode: Code[10];
        RoundTax: Option "To Nearest",Up,Down;
    begin
        with GlobalTempPOSTaxAmountLine do begin
          Reset;
          SetRange("Tax Type","Tax Type"::"Sales and Use Tax");
          if FindSet then
            repeat
              TaxDetailFound := false;
              TaxDetail.Reset;
              TaxDetail.SetRange("Tax Jurisdiction Code","Tax Jurisdiction Code");
              if "Tax Group Code" = '' then
                TaxDetail.SetFilter("Tax Group Code",'%1',"Tax Group Code")
              else
                TaxDetail.SetFilter("Tax Group Code",'%1|%2','',"Tax Group Code");
              if Date = 0D then
                TaxDetail.SetFilter("Effective Date",'<=%1',WorkDate)
              else
                TaxDetail.SetFilter("Effective Date",'<=%1',Date);
              TaxDetail.SetRange("Tax Type",0);//TaxDetail."Tax Type"::"Sales and Use Tax";
              if "Use Tax" then
                TaxDetail.SetFilter("Tax Type",'%1|%2',0, //TaxDetail."Tax Type"::"Sales and Use Tax",
                  3)//TaxDetail."Tax Type"::"Use Tax Only")
              else
                TaxDetail.SetFilter("Tax Type",'%1|%2',0, //TaxDetail."Tax Type"::"Sales and Use Tax",
                  3);//TaxDetail."Tax Type"::"Sales Tax Only");
              if TaxDetail.FindLast then
                TaxDetailFound := true
              else
                Delete;
              TaxDetail.SetRange("Tax Type",TaxDetail."Tax Type"::"Excise Tax");
              if TaxDetail.FindLast then begin
                TaxDetailFound := true;
                "Tax Type" := "Tax Type"::"Excise Tax";
                Insert;
                "Tax Type" := "Tax Type"::"Sales and Use Tax";
              end;
              if not TaxDetailFound and not Posted then
                Error(
                  Text1020002,
                  TaxDetail.TableCaption,
                  FieldCaption("Tax Jurisdiction Code"),"Tax Jurisdiction Code",
                  FieldCaption("Tax Group Code"),"Tax Group Code",
                  TaxDetail.FieldCaption("Effective Date"),TaxDetail.GetFilter("Effective Date"));
            until Next = 0;
          Reset;
        //TO-DO (If it turns out this is necessary for POS transactions)
        //  IF FINDSET(TRUE) THEN
        //    REPEAT
        //      TempTaxAmountDifference.RESET;
        //      TempTaxAmountDifference.SETRANGE("Tax Area Code","Tax Area Code for Key");
        //      TempTaxAmountDifference.SETRANGE("Tax Jurisdiction Code","Tax Jurisdiction Code");
        //      TempTaxAmountDifference.SETRANGE("Tax Group Code","Tax Group Code");
        //      TempTaxAmountDifference.SETRANGE("Expense/Capitalize","Expense/Capitalize");
        //      TempTaxAmountDifference.SETRANGE("Tax Type","Tax Type");
        //      TempTaxAmountDifference.SETRANGE("Use Tax","Use Tax");
        //      IF TempTaxAmountDifference.FINDFIRST THEN BEGIN
        //        "Tax Difference" := TempTaxAmountDifference."Tax Difference";
        //        MODIFY;
        //      END;
        //    UNTIL NEXT = 0;
          Reset;
          SetCurrentKey("Tax Area Code for Key","Tax Group Code","Tax Type","Calculation Order");
          if FindLast then begin
            LastTaxAreaCode := "Tax Area Code for Key";
            LastCalculationOrder := -9999;
            LastTaxType := "Tax Type";
            LastTaxGroupCode := "Tax Group Code";
            RoundTax := "Round Tax";
            repeat
              if (LastTaxAreaCode <> "Tax Area Code for Key") or
                 (LastTaxGroupCode <> "Tax Group Code")
              then begin
                HandleRoundTaxUpOrDown(POSTaxAmountLine2,RoundTax,TotalTaxAmount,LastTaxAreaCode,LastTaxGroupCode);
                LastTaxAreaCode := "Tax Area Code for Key";
                LastTaxType := "Tax Type";
                LastTaxGroupCode := "Tax Group Code";
                TaxOnTaxCalculated := false;
                LastCalculationOrder := -9999;
                CalculationOrderViolation := false;
                TotalTaxAmount := 0;
                RoundTax := "Round Tax";
              end;
              if "Tax Type" = "Tax Type"::"Sales and Use Tax" then
                TaxBaseAmt := "Tax Base Amount"
              else
                TaxBaseAmt := Quantity;
              if LastCalculationOrder = "Calculation Order" then
                CalculationOrderViolation := true;
              LastCalculationOrder := "Calculation Order";

              TaxDetail.Reset;
              TaxDetail.SetRange("Tax Jurisdiction Code","Tax Jurisdiction Code");
              if "Tax Group Code" = '' then
                TaxDetail.SetFilter("Tax Group Code",'%1',"Tax Group Code")
              else
                TaxDetail.SetFilter("Tax Group Code",'%1|%2','',"Tax Group Code");
              if Date = 0D then
                TaxDetail.SetFilter("Effective Date",'<=%1',WorkDate)
              else
                TaxDetail.SetFilter("Effective Date",'<=%1',Date);
              TaxDetail.SetRange("Tax Type","Tax Type");
              if "Tax Type" = "Tax Type"::"Sales and Use Tax" then
                if "Use Tax" then
                  TaxDetail.SetFilter("Tax Type",'%1|%2',"Tax Type"::"Sales and Use Tax",
                    "Tax Type"::"Use Tax Only")
                else
                  TaxDetail.SetFilter("Tax Type",'%1|%2',"Tax Type"::"Sales and Use Tax",
                    "Tax Type"::"Sales Tax Only");
              if TaxDetail.FindLast then begin
                TaxOnTaxCalculated := TaxOnTaxCalculated or TaxDetail."Calculate Tax on Tax";
                if TaxDetail."Calculate Tax on Tax" and ("Tax Type" = "Tax Type"::"Sales and Use Tax") then
                  TaxBaseAmt := "Tax Base Amount" + TotalTaxAmount;
                if "Tax Liable" then begin
                  if (Abs(TaxBaseAmt) <= TaxDetail."Maximum Amount/Qty.") or
                     (TaxDetail."Maximum Amount/Qty." = 0)
                  then
                    AddedTaxAmount := TaxBaseAmt * TaxDetail."Tax Below Maximum"
                  else begin
                    if "Tax Type" = "Tax Type"::"Sales and Use Tax" then
                      MaxAmount := TaxBaseAmt / Abs("Tax Base Amount") * TaxDetail."Maximum Amount/Qty."
                    else
                      MaxAmount := Quantity / Abs(Quantity) * TaxDetail."Maximum Amount/Qty.";
                    AddedTaxAmount :=
                      (MaxAmount * TaxDetail."Tax Below Maximum") +
                      ((TaxBaseAmt - MaxAmount) * TaxDetail."Tax Above Maximum");
                  end;
                  if "Tax Type" = "Tax Type"::"Sales and Use Tax" then
                    AddedTaxAmount := AddedTaxAmount / 100.0;
                end else
                  AddedTaxAmount := 0;
                "Tax Amount" := "Tax Amount" + AddedTaxAmount;
                TotalTaxAmount := TotalTaxAmount + AddedTaxAmount;
              end;
              "Tax Amount" := "Tax Amount" + "Tax Difference";
              TotalTaxAmount := TotalTaxAmount + "Tax Difference";
              "Amount Including Tax" := "Tax Amount" + "Tax Base Amount";
              if TaxOnTaxCalculated and CalculationOrderViolation then
                Error(
                  Text000,
                  FieldCaption("Calculation Order"),TaxArea.TableCaption,"POS Entry No.",
                  TaxDetail.FieldCaption("Calculate Tax on Tax"),CalculationOrderViolation);
              POSTaxAmountLine2.Copy(GlobalTempPOSTaxAmountLine);
              if "Tax Type" = "Tax Type"::"Excise Tax" then
                POSTaxAmountLine2."Tax %" := 0
              else
                if "Tax Base Amount" <> 0 then
                  POSTaxAmountLine2."Tax %" := 100 * ("Amount Including Tax" - "Tax Base Amount") / "Tax Base Amount"
                else
                  POSTaxAmountLine2."Tax %" := "Tax %";
              POSTaxAmountLine2.Insert;
            until Next(-1) = 0;
            HandleRoundTaxUpOrDown(POSTaxAmountLine2,RoundTax,TotalTaxAmount,LastTaxAreaCode,LastTaxGroupCode);
          end;
          DeleteAll;
          POSTaxAmountLine2.Reset;
          if POSTaxAmountLine2.FindSet then
            repeat
              Copy(POSTaxAmountLine2);
              Insert;
            until POSTaxAmountLine2.Next = 0;
        end;
    end;

    procedure GetSalesTaxAmountLineTable(var POSTaxAmountLine2: Record "POS Tax Amount Line" temporary)
    begin
        GlobalTempPOSTaxAmountLine.Reset;
        if GlobalTempPOSTaxAmountLine.FindSet then
          repeat
            POSTaxAmountLine2.Copy(GlobalTempPOSTaxAmountLine);
            POSTaxAmountLine2.Insert;
          until GlobalTempPOSTaxAmountLine.Next = 0;
    end;

    procedure SetTaxBaseAmount(var POSTaxAmountLine: Record "POS Tax Amount Line";Value: Decimal;ExchangeFactor: Decimal;Increment: Boolean)
    begin
        with POSTaxAmountLine do begin
          if Increment then
            "Tax Base Amount FCY" += Value
          else
            "Tax Base Amount FCY" := Value;
          "Tax Base Amount" := "Tax Base Amount FCY" / ExchangeFactor;
        end;
    end;

    local procedure CheckTaxAmtLinePos(SalesLineAmt: Decimal;TaxAmtLinePos: Boolean): Boolean
    begin
        exit(
          ((SalesLineAmt > 0) and TaxAmtLinePos) or
          ((SalesLineAmt <= 0) and not TaxAmtLinePos)
          );
    end;

    procedure HandleRoundTaxUpOrDown(var POSTaxAmountLine: Record "POS Tax Amount Line";RoundTax: Option "To Nearest",Up,Down;TotalTaxAmount: Decimal;TaxAreaCode: Code[20];TaxGroupCode: Code[10])
    var
        RoundedAmount: Decimal;
        RoundingError: Decimal;
    begin
        if (RoundTax = RoundTax::"To Nearest") or (TotalTaxAmount = 0) then
          exit;
        case RoundTax of
          RoundTax::Up:
            RoundedAmount := Round(TotalTaxAmount,0.01,'>');
          RoundTax::Down:
            RoundedAmount := Round(TotalTaxAmount,0.01,'<');
        end;
        RoundingError := RoundedAmount - TotalTaxAmount;
        with POSTaxAmountLine do begin
          Reset;
          SetRange("Tax Area Code for Key",TaxAreaCode);
          SetRange("Tax Group Code",TaxGroupCode);
          SetRange("Is Report-to Jurisdiction",true);
          if FindFirst then begin
            Delete;
            "Tax Amount" := "Tax Amount" + RoundingError;
            "Amount Including Tax" := "Tax Amount" + "Tax Base Amount";
            if "Tax Type" = "Tax Type"::"Excise Tax" then
              "Tax %" := 0
            else
              if "Tax Base Amount" <> 0 then
                "Tax %" := 100 * ("Amount Including Tax" - "Tax Base Amount") / "Tax Base Amount";
            Insert;
          end;
        end;
    end;
}

