codeunit 6014434 "NPR NF Retail Code"
{
    // //001 - Ohm
    //   Der skal ikke oprettes en kunde ved oprettelse af debitor
    // //002 - ABP
    //   CR426DebitorOnInsert: Overf¢rsel af Rykkerbetingelse fra opsætning
    // //4.001.001 - Jerome
    //   CR426DebitorOnInsert & CR426DebitorOnInsertTDC moved to Std. Table Code
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.18/RMT/20160128 CASE 233094 only require item "Costing Method" = Specific if required by item tracking
    // NPR5.22/TJ/20160408 CASE 238601 Created new function CS22InitValueEntry2 as a copy of CS22InitValueEntry so we can include it into standard event
    //                                    Reworked function CR426KLNummerOV1
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX solution
    // NPR5.26/MHA /20160810 CASE 248288 Functions deleted: CR426KLOpretVare() and CR426KLNummerOV1() and references removed to deleted Item Fields: 6014417 "NPK Created" and 6014421 ISBN
    // NPR5.27/BHR /20161018 CASE 253261 skip filtering of dimension on Itemledger for Serialno.
    // NPR5.27/JDH /20161018 CASE 252676 Removed obsolete functions
    // NPR5.29/TJ  /20161223 CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.30/TJ  /20170222 CASE 266866 Commented out code in function CS22InitValueEntry2
    // NPR5.36/TJ  /20170918 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Changed type from undefined Option to Int for variables DocType and Type in TR408CreateInvFromCreditVoucher(),TR409CreateInvFromGiftVoucher(),TR408-9CreateInv()
    // NPR5.43/ZESO/20182906 CASE 312575 Added field Item Category Code
    // NPR5.45/MHA /20180803 CASE 323705 Deleted redundant mediator function TR406FindItemSalesPrice()
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.48/JDH /20181206 CASE 335967 Testing for Costing method = specific is way too late. Should be done when creating the item instead.

    Permissions = TableData Contact = rimd,
                  TableData "Contact Business Relation" = rimd;

    trigger OnRun()
    begin
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Text10600000: Label 'Redeem giftvoucher number';
        Text10600001: Label 'redeem giftvoucher number';
        Text10600002: Label '%1 %2 %3 was updated.';

    procedure TR406CheckSerialNoApplication(var SaleLinePOS: Record "NPR Sale Line POS"; var TotalItemLedgerEntryQuantity: Decimal; ItemNo: Code[20]; SerialNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Text: Text[20];
        t001: Label '%2 %1 has two open %3 posts! \';
        t002: Label 'Adjust the inventory first, and then continue the transaction!';
    begin
        //TR406TjekSerienummerudligning
        //attain
        with SaleLinePOS do begin
            ItemLedgerEntry.Reset;
            ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
            ItemLedgerEntry.SetRange("Item No.", "No.");
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
            if ItemLedgerEntry.FindFirst then begin
                ItemLedgerEntry.CalcSums(Quantity);
                TotalItemLedgerEntryQuantity := ItemLedgerEntry.Quantity;
                if ItemLedgerEntry.Count > 1 then
                    Error(t001 + t002, "Serial No.", FieldName("Serial No."), Text);
            end;
        end;
    end;

    procedure TR406SerialNoOnValidate(var SaleLinePOS: Record "NPR Sale Line POS"; var TotalNonAppliedQuantity: Decimal; var TotalAuditRollQuantity: Decimal; var TotalItemLedgerEntryQuantity: Decimal)
    var
        SaleLinePOS2: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        SeriesFound: Boolean;
        Positive: Boolean;
        Txt001: Label 'Quantity in a serial number sale must be 1 or -1!';
        Txt002: Label '%2 %1 has already been used in another transaction! \';
        Txt003: Label 'try to check saved receipts';
        Txt004: Label '%2 %1 has already sold!';
        Txt005: Label '%2 %1 is already in stock!';
    begin
        //TR406SerienrOnValidate
        //-NPR5.27 [253261]
        RetailSetup.Get;
        //+NPR5.27 [253261]
        with SaleLinePOS do begin
            SeriesFound := false;
            TotalNonAppliedQuantity := 0;
            TotalAuditRollQuantity := 0;
            TotalItemLedgerEntryQuantity := 0;
            TestField("Sale Type", "Sale Type"::Sale);
            Item.Get("No.");
            //-NPR4.18
            //Vare.TESTFIELD("Costing Method",Vare."Costing Method"::Specific);
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            //-NPR5.48 [335967]
            //  IF ItemTrackingCode."SN Specific Tracking" THEN
            //    Item.TESTFIELD("Costing Method",Item."Costing Method"::Specific);
            //+NPR5.48 [335967]

            //+NPR4.18
            if Quantity = 0 then
                Error(Txt001);

            if "Serial No." <> '' then begin
                Commit;
                SaleLinePOS2.SetCurrentKey("Serial No.");
                SaleLinePOS2.SetRange("Serial No.", "Serial No.");
                if SaleLinePOS2.FindSet then
                    repeat
                        SalePOS.Get(SaleLinePOS2."Register No.", SaleLinePOS2."Sales Ticket No.");
                        if not SalePOS."Saved Sale" then
                            if (SaleLinePOS2."Sales Ticket No." <> "Sales Ticket No.") or (SaleLinePOS2."Line No." <> "Line No.") then
                                Error(Txt001 + Txt002, "Serial No.", FieldName("Serial No."));
                    until SaleLinePOS2.Next = 0;

                //-attain

                if Quantity > 0 then begin
                    ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                    ItemLedgerEntry.SetRange("Item No.", "No.");
                    ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                    ItemLedgerEntry.SetRange(Open, true);
                    ItemLedgerEntry.SetRange(Positive, true);
                    ItemLedgerEntry.SetRange("Location Code", "Location Code");
                    //-NPR5.27 [253261]
                    if RetailSetup."Not use Dim filter SerialNo" = false then
                        //+NPR5.27 [253261]
                        ItemLedgerEntry.SetRange("Global Dimension 1 Code", SaleLinePOS."Shortcut Dimension 1 Code");
                    if ItemLedgerEntry.FindFirst then;
                    //        "Serial No." := '';
                end;
                /*
                Varepost1.SETCURRENTKEY("Item No.","Serienr.");
                Varepost1.SETRANGE("Item No.",Nummer);
                Varepost1.SETRANGE("Serienr.","Serienr.");
                IF NOT Varepost1.FINDFIRST THEN BEGIN
                  Antal := -1;
                  Bel¢b := -ABS(Bel¢b);
                  "Bel¢b inkl. moms" := -ABS("Bel¢b inkl. moms");
                  "Momsgrundlag (bel¢b)" := -ABS("Momsgrundlag (bel¢b)");
                */
                //      MODIFY;
                if Quantity <> Abs(1) then
                    Quantity := 1 * (Quantity / Abs(Quantity));
                Positive := (Quantity >= 0);

                //    END else
                //    EkspLinie."Kostpris (DKK)":=Varepost1."Cost Amount (Actual)";
                //+attain
                //  IF Antal > 0 THEN


                //-NPR4.18
                if ItemTrackingCode."SN Specific Tracking" then begin
                    //+NPR4.18
                    CheckSerialNoApplication("No.", "Serial No.");
                    CheckSerialNoAuditRoll("No.", "Serial No.", Positive);
                    if not NoWarning then begin
                        if Positive then begin
                            TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
                            if (TotalNonAppliedQuantity < 0) then begin
                                //          error(t004,"Serial No.",FIELDNAME("Serial No."));
                                Message(Txt004, "Serial No.", FieldName("Serial No."));
                                "Serial No." := '';
                            end;
                        end else begin
                            TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
                            if TotalNonAppliedQuantity > 1 then begin
                                //          ERROR(t005,"Serial No.",FIELDNAME("Serial No."));
                                Message(Txt005, "Serial No.", FieldName("Serial No."));
                                "Serial No." := '';
                            end;
                        end;
                    end;
                    //-NPR4.18
                end;
                //+NPR4.18
            end;
        end;

    end;

    procedure TR406SerialNoOnLookup(var SaleLinePOS: Record "NPR Sale Line POS"): Boolean
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ActionTaken: Action;
        Vare: Record Item;
    begin
        //TR406SerienrOnLookup()
        //-NPR5.27 [253261]
        RetailSetup.Get;
        //+NPR5.27 [253261]
        with SaleLinePOS do begin
            TestField("Sale Type", "Sale Type"::Sale);
            TestField(Type, Type::Item);
            TestField("No.", "No.");
            Vare.Get("No.");
            Vare.TestField("Costing Method", Vare."Costing Method"::Specific);
            ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetFilter("Serial No.", '<> %1', '');
            ItemLedgerEntry.SetRange("Item No.", "No.");
            ItemLedgerEntry.SetRange("Location Code", SaleLinePOS."Location Code");
            //-NPR5.27 [253261]
            if RetailSetup."Not use Dim filter SerialNo" = false then
                //+NPR5.27 [253261]
                ItemLedgerEntry.SetRange("Global Dimension 1 Code", SaleLinePOS."Shortcut Dimension 1 Code");
            if ItemLedgerEntry.Find('-') then
                repeat
                    ItemLedgerEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
                    ItemLedgerEntry.FindLast;
                    TempItemLedgerEntry := ItemLedgerEntry;
                    TempItemLedgerEntry.Insert;
                    ItemLedgerEntry.SetRange("Serial No.");
                until ItemLedgerEntry.Next = 0;

            ActionTaken := PAGE.RunModal(PAGE::"NPR Item - Series Number", TempItemLedgerEntry);
            if ActionTaken = ACTION::LookupOK then
                //"Serial No." := SerieVarepost."Serial No."
                Validate("Serial No.", TempItemLedgerEntry."Serial No.")
            else
                exit(false);
            ItemLedgerEntry.CalcFields(ItemLedgerEntry."Cost Amount (Actual)");
            SaleLinePOS."Unit Cost" := ItemLedgerEntry."Cost Amount (Actual)";
            //-NPR5.45 [324395]
            //SaleLinePOS."Unit Price (LCY)" := ItemLedgerEntry."Cost Amount (Actual)";
            SaleLinePOS."Unit Cost (LCY)" := ItemLedgerEntry."Cost Amount (Actual)";
            //+NPR5.45 [324395]
            SaleLinePOS.Cost := ItemLedgerEntry."Cost Amount (Actual)";
            exit(true);
        end;
    end;

    procedure TR406FindItemCostPrice(var SaleLinePOS: Record "NPR Sale Line POS"; var Item2: Record Item; Color: Code[20]; Size: Code[20]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
        PriceMult: Decimal;
        TxtNoSerial: Label 'No open Item Ledger Entry has been found with the Serial No. %2';
    begin
        //TR406FindVareKostPris()
        with SaleLinePOS do begin
            if "Custom Cost" then
                exit("Unit Cost");

            //-NPR5.23 [240916]
            //VareRec.CALCFIELDS("Unit cost differentiation");
            //+NPR5.23 [240916]

            ItemUnitOfMeasure.Reset;
            ItemUnitOfMeasure.SetRange("Item No.", SaleLinePOS."No.");
            ItemUnitOfMeasure.SetRange(Code, SaleLinePOS."Unit of Measure Code");
            if ItemUnitOfMeasure.FindFirst then
                PriceMult := ItemUnitOfMeasure."Qty. per Unit of Measure"
            else
                PriceMult := 1;

            if ("Serial No." <> '') and (Quantity > 0) then begin
                //-NPR4.18
                Item.Get(SaleLinePOS."No.");
                Item.TestField("Item Tracking Code");
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."SN Specific Tracking" then begin
                    //+NPR4.18
                    ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                    ItemLedgerEntry.SetRange(Open, true);
                    ItemLedgerEntry.SetRange(Positive, true);
                    ItemLedgerEntry.SetRange("Item No.", "No.");
                    ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                    if not ItemLedgerEntry.FindFirst then begin
                        Message(TxtNoSerial, "Serial No.");
                        exit(0);
                    end;
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                    //    ERROR( FORMAT( Varepost."Cost Amount (Actual)"));
                    exit(ItemLedgerEntry."Cost Amount (Actual)");
                    //-NPR4.18
                end;
                //+NPR4.18
            end;

            //-NPR4.04
            //IF (VareRec."Unit price differentiation") AND (Color <> '') AND (Size <> '') THEN BEGIN
            //  Variation.SETCURRENTKEY("Item Code",Color,Size);
            //  Variation.SETRANGE("Item Code",VareRec."No.");
            //  Variation.SETRANGE(Color,Color);
            //  Variation.SETRANGE(Size,Size);
            //  IF Variation.FINDFIRST THEN BEGIN
            //    IF Variation."Unit Cost" <> 0 THEN
            //      EXIT(Variation."Unit Cost" * PriceMult )
            //    ELSE
            //      EXIT(VareRec."Last Direct Cost" * PriceMult );
            //  END ELSE
            //    EXIT(VareRec."Last Direct Cost" * PriceMult );
            //END;
            //+NPR4.04

            //-NPR5.23 [240916]
            //  IF Opsætning."Use VariaX module" AND ("Variant Code" <> '') THEN BEGIN
            //    IF STRLEN( "Variant Code" ) <= 10 THEN
            //      IF VariaXInfo.GET( "Variant Code" ) THEN
            //        EXIT( VariaXInfo."Unit Cost" * PriceMult );
            //  END;
            //+NPR5.23 [240916]

        end;
    end;

    procedure CR414PostTodaysGLEntries(var GenJnlLine: Record "Gen. Journal Line")
    begin
        //CR414Bogf¢rDagensPosteringer()
        GenJnlPostLine.RunWithoutCheck(GenJnlLine);
    end;

    procedure TS37SerieNoCopy(var SalesLine: Record "Sales Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        //TS37SerieNrCopy()
        //Do nothing
    end;

    procedure CS22InitValueEntry2(var ValueEntry: Record "Value Entry"; var ItemJnlLine: Record "Item Journal Line")
    begin
        //CS22InitValueEntry2()
        ValueEntry."NPR Item Group No." := ItemJnlLine."NPR Item Group No.";
        ValueEntry."NPR Vendor No." := ItemJnlLine."NPR Vendor No.";
        ValueEntry."NPR Discount Type" := ItemJnlLine."NPR Discount Type";
        ValueEntry."NPR Discount Code" := ItemJnlLine."NPR Discount Code";
        //-NPR5.30 [266866]
        //VEntry."Period discount code" := ItemJnlLine."Term Discount Code";
        //VEntry."Range code" := ItemJnlLine."Line Code";
        //+NPR5.30 [266866]
        //-NPR4.04
        //VEntry.Color := ILEntry.Color;
        //VEntry.Size := ILEntry.Size;
        //+NPR4.04
        ValueEntry."NPR Register No." := ItemJnlLine."NPR Register Number";
        ValueEntry."NPR Group Sale" := ItemJnlLine."NPR Group Sale";
        ValueEntry."NPR Salesperson Code" := ItemJnlLine."Salespers./Purch. Code";

        //- NPR5.43 [312575]
        ValueEntry."NPR Item Category Code" := ItemJnlLine."Item Category Code";
        //+ NPR5.43 [312575]
    end;

    procedure TR406FindSerialNo(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // TR406FindSerialNo
        // Attain
        if not Item.Get(SaleLinePOS."No.") then begin
            ItemLedgerEntry.SetCurrentKey("Item No.", "Serial No.", "Location Code", "Global Dimension 1 Code");
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetRange("Serial No.", SaleLinePOS."No.");
            if ItemLedgerEntry.FindFirst then
                if Item.Get(ItemLedgerEntry."Item No.") then begin
                    SaleLinePOS."No." := ItemLedgerEntry."Item No.";
                    SaleLinePOS."Serial No." := ItemLedgerEntry."Serial No.";
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                    //-NPR5.45 [324395]
                    //SaleLinePOS."Unit Price (LCY)" := ItemLedgerEntry."Cost Amount (Actual)";
                    SaleLinePOS."Unit Cost (LCY)" := ItemLedgerEntry."Cost Amount (Actual)";
                    //+NPR5.45 [324395]
                end;
        end;
    end;

    procedure TR400SerialNoKeyExists(): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        exit(ItemLedgerEntry.SetCurrentKey(Open, Positive, "Serial No.", "Item No."));
    end;

    procedure TR408CreateInvFromCreditVoucher(var CreditVoucher: Record "NPR Credit Voucher")
    var
        Register: Record "NPR Register";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        DocType: Integer;
        Type: Integer;
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //TR408CreateInvFromTilgBevis
        CreditVoucher.TestField("Customer No");
        CreditVoucher.TestField(Invoiced, false);
        Register.Get(RetailFormCode.FetchRegisterNumber);
        Register.TestField("Credit Voucher Account");
        PaymentTypePOS.SetCurrentKey("Processing Type");
        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Foreign Credit Voucher");
        PaymentTypePOS.FindFirst;
        DocType := 2;
        Type := 1;
        CreditVoucher."Invoiced on enclosure no." :=
          "TR408-9CreateInv"(
            CreditVoucher."Customer No",
            DocType,
            Type,
            PaymentTypePOS."G/L Account No.",
            //Kasse."Credit Voucher Account",
            Text10600001 + ' ' + CreditVoucher.Reference,
            CreditVoucher.Amount,
            CreditVoucher."No.",
            CreditVoucher.Salesperson);

        CreditVoucher.Validate(Invoiced, true);
        CreditVoucher.Validate("Invoiced on enclosure", DocType);
        CreditVoucher.Validate("Invoiced on enclosure no.");
        CreditVoucher.Modify(true);
    end;

    procedure TR409CreateInvFromGiftVoucher(var GiftVoucher: Record "NPR Gift Voucher")
    var
        Register: Record "NPR Register";
        RetailSetup2: Record "NPR Retail Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        AmountToInvoice: Decimal;
        DocType: Integer;
        Type: Integer;
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //TR409CreateInvFromGavekort
        GiftVoucher.TestField("Customer No.");
        GiftVoucher.TestField(Invoiced, false);
        Register.Get(RetailFormCode.FetchRegisterNumber);
        Register.TestField("Gift Voucher Account");
        RetailSetup2.Get;
        AmountToInvoice := Round(GiftVoucher.Amount * (100 - RetailSetup2."Profit on Gifvouchers") / 100);
        PaymentTypePOS.SetCurrentKey("Processing Type");
        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Foreign Gift Voucher");
        PaymentTypePOS.FindFirst;
        DocType := 2;
        Type := 1;
        GiftVoucher."Invoiced by Document No." :=
          "TR408-9CreateInv"(
            GiftVoucher."Customer No.",
            DocType,
            Type,
            PaymentTypePOS."G/L Account No.",
            Text10600000 + ' ' + GiftVoucher.Reference,
            AmountToInvoice,
            GiftVoucher."No.",
            GiftVoucher.Salesperson);

        GiftVoucher.Validate(Invoiced, true);
        GiftVoucher.Validate("Invoiced by Document No.");
        GiftVoucher.Validate("Invoiced by Document Type", DocType);
        GiftVoucher.Modify(true);
    end;

    procedure "TR408-9CreateInv"(CustomerNo: Code[20]; DocType: Integer; Type: Integer; No: Code[20]; Text: Text[50]; Amount: Decimal; ExtDocNo: Code[20]; SalesPerson: Code[20]): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NewLineNo: Integer;
    begin
        //TR408-9CreateInv
        //Create Header
        SalesHeader.SetRange("Document Type", DocType);
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        NewLineNo := 10000;
        if SalesHeader.FindLast then begin  // Tilf¢j til eksisterende ordre
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindLast then
                NewLineNo := SalesLine."Line No." + 10000
        end else begin  //Create Header
            SalesHeader.Validate("Document Type", DocType);
            SalesHeader.Insert(true);
            SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
            SalesHeader.Validate("Prices Including VAT", true);
            SalesHeader.Validate(SalesHeader."Salesperson Code", SalesPerson);
            SalesHeader.Modify(true);
        end;

        //Create Line
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", NewLineNo);
        SalesLine.Insert(true);
        SalesLine.Validate(Type, Type);
        SalesLine.Validate("No.", No);
        SalesLine.Validate(Description, Text + ExtDocNo);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Validate(Quantity, 1);
        //SalesLine.VALIDATE("Gen. Prod. Posting Group", ...
        SalesLine.Modify(true);

        Commit;
        Message(Text10600002, SalesHeader."Document Type", SalesHeader.FieldCaption("No."), SalesHeader."No.");
        exit(SalesHeader."No.");
        // SalesHeader.SETRANGE("Document Type",SalesHeader."Document Type");
        // SalesHeader.SETRANGE("No.",SalesHeader."No.");
        // SalesInvoiceFrm.SETTABLEVIEW(SalesHeader);
        // SalesInvoiceFrm.RUN;
    end;

    procedure CR403SetEntryKey(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //CR403SetEntryKey()
        //Varepost.SETCURRENTKEY( Open, Positive, "Item No.", "Serial No." );
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.");
    end;

    procedure CR403SetEntryRange(var ItemLedgerEntry: Record "Item Ledger Entry"; SerialNo: Code[20])
    begin
        //CR403SetEntryRange()
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
    end;

    procedure CR403GetEntrySerial(ItemLedgerEntry: Record "Item Ledger Entry"): Code[20]
    begin
        //CR403GetEntrySerial()
        exit(ItemLedgerEntry."Serial No.");
    end;

    procedure StatusCalcItemCost(var Item: Record Item; Value: Decimal; Difference: Decimal; StartDate: Date; EndDate: Date; var Win: Dialog): Decimal
    begin
        //StatusCalcItemCost()
        /*
        WITH Item DO BEGIN
          nVarepost := 0;
          Varepost.SETCURRENTKEY(
          "Item No.","Posting Date","Location Code","Global Dimension 1 Code","Variant Code","Serial No.",Open,Positive);
          Varepost.SETRANGE( "Item No.", "No." );
          Varepost.SETFILTER( "Variant Code", GETFILTER( "Variant Filter" ));
          Varepost.SETFILTER( "Location Code", GETFILTER( "Location Filter" ));
          Varepost.SETFILTER( "Global Dimension 1 Code", GETFILTER( "Global Dimension 1 Code" ));
          Varepost.SETFILTER( "Global Dimension 2 Code", GETFILTER( "Global Dimension 2 Code" ));
          IF EndDate <> 0D THEN
            Varepost.SETRANGE( "Posting Date", 0D, EndDate );
          Win.UPDATE( 4, Varepost.COUNT );
          IF Varepost.FINDSET THEN REPEAT
            nVarepost += 1;
            Win.UPDATE( 3, nVarepost );
            IF Varepost."Posting Date" < StartDate THEN
              QtyOnHand += Varepost.Quantity
            ELSE BEGIN
              IF ( Varepost."Entry Type" IN
                 [ Varepost."Entry Type"::Purchase, Varepost."Entry Type"::"Positive Adjmt.",
                   Varepost."Entry Type"::Output ])
              THEN
                RcdInc += Varepost.Quantity
              ELSE
                ShipDec += -Varepost.Quantity;
            END;
            Værdipost.SETCURRENTKEY( "Item Ledger Entry No." );
            Værdipost.SETRANGE( "Item Ledger Entry No.", Varepost."Entry No." );
            Værdipost.SETFILTER( "Variant Code", GETFILTER( "Variant Filter" ));
            Værdipost.SETFILTER( "Location Code", GETFILTER( "Location Filter" ));
            Værdipost.SETFILTER( "Global Dimension 1 Code", GETFILTER( "Global Dimension 1 Code" ));
            Værdipost.SETFILTER( "Global Dimension 2 Code", GETFILTER( "Global Dimension 2 Code" ));
            IF Værdipost.FINDSET THEN REPEAT
              IF NOT (( EndDate <> 0D ) AND ( Værdipost."Posting Date" > EndDate )) THEN BEGIN
                IF Varepost."Posting Date" < StartDate THEN BEGIN
                  ValQtyOnHand  += Værdipost."Cost Amount (Expected)";
                  ValInvQty     += Værdipost."Cost Amount (Actual)";
                  InvQty        += Værdipost."Invoiced Quantity";
                END ELSE IF ( Værdipost."Item Ledger Entry Type" IN
                             [Værdipost."Item Ledger Entry Type"::Purchase,
                              Værdipost."Item Ledger Entry Type"::"Positive Adjmt.",
                              Værdipost."Item Ledger Entry Type"::Output ])
                THEN BEGIN
                  ValRcdInc   += Værdipost."Cost Amount (Expected)";
                  ValInvInc   += Værdipost."Cost Amount (Actual)";
                  InvInc      += Værdipost."Invoiced Quantity";
                END ELSE BEGIN
                  CostShipDec += -Værdipost."Cost Amount (Expected)";
                  CostInvDec  += -Værdipost."Cost Amount (Actual)";
                  InvDec      += -Værdipost."Invoiced Quantity";
                END;
                IF Værdipost."Expected Cost" THEN BEGIN
                  CostToGL    += Værdipost."Cost Posted to G/L";
                  ExpCostToGL += Værdipost."Cost Posted to G/L";
                END ELSE
                  InvCostToGL += Værdipost."Cost Posted to G/L";
                ValCostAmount += Værdipost."Cost Amount (Actual)";
              END;
            UNTIL Værdipost.NEXT = 0;
            ValQtyOnHand  += ValInvQty;
            ValRcdInc     += ValInvInc;
            CostShipDec   += CostInvDec;
            CostToGL      += InvCostToGL;
          UNTIL Varepost.NEXT = 0;
        END;
        Win.UPDATE( 3, 0 );
        Win.UPDATE( 4, 0 );
        IF ValCostAmount=0 THEN BEGIN
          IF Difference <> 0 THEN
            EXIT((Item."Last Direct Cost"-Værdi) /Difference)
          ELSE
           EXIT(Item."Last Direct Cost")
        END ELSE BEGIN
          IF Difference <> 0 THEN
            EXIT(( ValCostAmount - Værdi ) / Difference )
          ELSE
            EXIT( ValCostAmount );
        END;
         */
        if Difference > 0 then
            exit(Item."Unit Cost")
        else
            exit(Item."Last Direct Cost");

    end;
}

