codeunit 6014415 "Period Discount Management"
{
    // Rulle1 : Betalinger
    // Rulle2 : Udbetaling, Salg, Indbetaling
    // Rulle3 : Afrunding
    // 
    // Afrunding udregnes udfra betaling, derfor �ndring 001 den 1-6-2001
    // NPR5.31/MHA /20170210  CASE 262904 Applied Event triggered Discount Calculation: OnInitDiscountPriority(),OnApplyDiscount(),IsSubscribedDiscount(),DiscSourceTableId(),DiscCalcCodeunitId()
    // NPR5.31/MHA /20170213  CASE 265229 Added "Customer Disc. Group Filter" to Condition and removed Global Dimensions and Location
    // NPR5.38/MHA /20171204  CASE 298276 Removed Discount Cache
    // NPR5.38/MHA /20171222  CASE 298809 Sales Line Discount
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization
    // NPR5.42/MHA /20180521  CASE 315554 Reworked PeriodDiscountLineIsValid() to include IsValidDay()
    // NPR5.44/MMV /20180627  CASE 312154 Fixed incorrect cross line discount handling when different types collided.
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.46/JDH /20181009 CASE 294354  Changed how the POS Header is used - working on the parameter that is included in the subscriber instead of a GET (allow Temp POS header usage)
    // NPR5.48/JDH /20181206 CASE 338339  Possible to use temp Sale pos header


    trigger OnRun()
    begin
    end;

    procedure ApplyPeriodDiscounts(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete;RecalculateAllLines: Boolean)
    begin
        //-NPR5.40 [294655]
        // CLEAR(TempSaleLinePOS);
        // TempSaleLinePOS.SETRANGE("Register No.",SalePOS."Register No." );
        // TempSaleLinePOS.SETRANGE("Sales Ticket No.",SalePOS."Sales Ticket No." );
        // TempSaleLinePOS.SETRANGE(Date,SalePOS.Date);
        // TempSaleLinePOS.SETRANGE("Sale Type",TempSaleLinePOS."Sale Type"::Sale);
        // TempSaleLinePOS.SETRANGE(Type,TempSaleLinePOS.Type::Item);
        // TempSaleLinePOS.SETRANGE("Discount Type",TempSaleLinePOS."Discount Type"::" ");
        // IF TempSaleLinePOS.ISEMPTY THEN
        //  EXIT;
        //
        // TempSaleLinePOS.FINDSET;

        // REPEAT
        //  ApplyPeriodDiscountOnLine(TempSaleLinePOS);
        //  TempSaleLinePOS.MODIFY;
        //
        //  //-NPR5.38 [298809]
        //  IF TempSaleLinePOS."Allow Line Discount" AND TempSaleLinePOS.ISTEMPORARY THEN BEGIN
        //    SalePOS.GET(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.");
        //    TempSaleLinePOSLineDisc.COPY(TempSaleLinePOS,TRUE);
        //    POSSalesPriceCalcMgt.FindSalesLineLineDisc(SalePOS,TempSaleLinePOSLineDisc);
        //    IF TempSaleLinePOSLineDisc."Discount %" > TempSaleLinePOS."Discount %" THEN BEGIN
        //      TempSaleLinePOSLineDisc."Discount Type" := TempSaleLinePOS."Discount Type"::Customer;
        //      TempSaleLinePOSLineDisc.MODIFY;
        //    END;
        //  END;
        //  //+NPR5.38 [298809]
        // UNTIL TempSaleLinePOS.NEXT = 0;

        //-NPR5.44 [312154]
        // IF NOT TempSaleLinePOS.GET(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") THEN
        //  EXIT;
        //
        // IF TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " THEN BEGIN
        //  ApplyPeriodDiscountOnLine(TempSaleLinePOS);
        //  TempSaleLinePOS.MODIFY;
        // END;
        //
        // IF TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Customer THEN BEGIN
        //  TempSaleLinePOS2.COPY(TempSaleLinePOS,TRUE);
        //  ApplyPeriodDiscountOnLine(TempSaleLinePOS2);
        //  IF TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" THEN
        //    EXIT;
        //  TempSaleLinePOS2.MODIFY;
        // END;

        Clear(TempSaleLinePOS);
        if RecalculateAllLines then begin
          TempSaleLinePOS.SetRange("Register No.", Rec."Register No.");
          TempSaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
          TempSaleLinePOS.SetRange(Date, Rec.Date);
          TempSaleLinePOS.SetRange("Sale Type", Rec."Sale Type");
          TempSaleLinePOS.SetFilter("Discount Type", '=%1|=%2', TempSaleLinePOS."Discount Type"::" ", TempSaleLinePOS."Discount Type"::Customer);
          if TempSaleLinePOS.FindSet then
            repeat
              //-NPR5.46 [294354]
              //ApplyDiscountOnLine(TempSaleLinePOS);
              ApplyDiscountOnLine(TempSaleLinePOS, SalePOS);
              //+NPR5.46 [294354]
            until TempSaleLinePOS.Next = 0;
        end else
          if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
            //-NPR5.46 [294354]
            //ApplyDiscountOnLine(TempSaleLinePOS);
            ApplyDiscountOnLine(TempSaleLinePOS, SalePOS);
            //+NPR5.46 [294354]

        //+NPR5.44 [312154]
    end;

    local procedure ApplyDiscountOnLine(var TempSaleLinePOS: Record "Sale Line POS" temporary;TempSalePOS: Record "Sale POS" temporary)
    var
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
    begin
        //-NPR5.44 [312154]
        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " then begin
          //-NPR5.46 [294354]
          //ApplyPeriodDiscountOnLine(TempSaleLinePOS);
          ApplyPeriodDiscountOnLine(TempSaleLinePOS, TempSalePOS);
          //+NPR5.46 [294354]
          TempSaleLinePOS.Modify;
        end;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Customer then begin
          TempSaleLinePOS2.Copy(TempSaleLinePOS,true);
          //-NPR5.46 [294354]
          //ApplyPeriodDiscountOnLine(TempSaleLinePOS2);
          ApplyPeriodDiscountOnLine(TempSaleLinePOS2, TempSalePOS);
          //+NPR5.46 [294354]

          if TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" then
            exit;
          TempSaleLinePOS2.Modify;
        end;
        //+NPR5.44 [312154]
    end;

    procedure ApplyPeriodDiscountOnLine(var TempSaleLinePOS: Record "Sale Line POS" temporary;TempSalePOS: Record "Sale POS" temporary)
    var
        Customer: Record Customer;
        Item: Record Item;
        PeriodDiscount: Record "Period Discount";
        PeriodDiscountLine: Record "Period Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetup2: Record "VAT Posting Setup";
        Price: Decimal;
        UnitPrice: Decimal;
        BestCode: Code[20];
        BestVariant: Code[10];
    begin
        //SetPeriodeRabat()
        with TempSaleLinePOS do begin
          if "No." = '' then
            exit;
          Item.Get( "No." );
          PeriodDiscountLine.Reset;
          PeriodDiscountLine.SetCurrentKey( "Item No." );
          PeriodDiscountLine.SetRange( Status, PeriodDiscountLine.Status::Active );
          PeriodDiscountLine.SetFilter( "Starting Date", '<=%1', Today );
          PeriodDiscountLine.SetFilter( "Ending Date", '>=%1', Today );
          PeriodDiscountLine.SetRange( "Item No.", "No." );
          PeriodDiscountLine.SetFilter( "Variant Code", '=%1|=%2', "Variant Code", '' );
          if not PeriodDiscountLine.FindFirst then
            exit;

          //-NPR5.48 [338339]
          TempSaleLinePOS.SetPOSHeader(TempSalePOS);
          //+NPR5.48 [338339]

          //-NPR5.45 [323705]
          //UnitPrice := FindItemSalesPrice( TempSaleLinePOS );
          UnitPrice := TempSaleLinePOS.FindItemSalesPrice();
          //+NPR5.45 [323705]
          "Discount Amount" := 0;
          "Discount %" := 0;
          Price := 999999999999.99;

          if PeriodDiscountLine.FindSet then repeat
            if PeriodDiscountLineIsValid(PeriodDiscountLine, TempSaleLinePOS) then begin
              PeriodDiscountLine.CalcFields( "Unit Price Incl. VAT" );
              if PeriodDiscountLine."Unit Price Incl. VAT" then
                PeriodDiscountLine."Unit Price" := PeriodDiscountLine."Unit Price" / ( 100 + "VAT %" ) * 100;
              if PeriodDiscountLine."Campaign Unit Price" < Price then begin
                Price       := PeriodDiscountLine."Campaign Unit Price";
                BestCode    := PeriodDiscountLine.Code;
                BestVariant := PeriodDiscountLine."Variant Code";
              end;
            end;
          until PeriodDiscountLine.Next = 0;

          if PeriodDiscountLine.Get( BestCode, "No.", BestVariant ) then begin
            //-NPR5.46 [294354]
            //SalePOS.GET( "Register No.", "Sales Ticket No." );
            //+NPR5.46 [294354]
            PeriodDiscountLine.CalcFields( "Unit Price Incl. VAT" );
            //-NPR5.46 [294354]
            //IF Customer.GET( SalePOS."Customer No." ) AND PeriodDiscountLine."Unit Price Incl. VAT" THEN BEGIN
            if Customer.Get( TempSalePOS."Customer No." ) and PeriodDiscountLine."Unit Price Incl. VAT" then begin
            //+NPR5.46 [294354]
              VATPostingSetup.SetRange( "VAT Bus. Posting Group", Item."VAT Bus. Posting Gr. (Price)" );
              VATPostingSetup.SetRange( "VAT Prod. Posting Group", Item."VAT Prod. Posting Group" );
              VATPostingSetup2.SetRange( "VAT Bus. Posting Group", Customer."VAT Bus. Posting Group" );
              VATPostingSetup2.SetRange( "VAT Prod. Posting Group", "VAT Prod. Posting Group" );
              if VATPostingSetup.FindFirst then;
              if VATPostingSetup2.FindFirst then;
              PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" /
                                                          ( 100 + VATPostingSetup."VAT %" ) *
                                                          ( 100 + VATPostingSetup2."VAT %" );
            end;

            if "Price Includes VAT" then begin
              if not PeriodDiscountLine."Unit Price Incl. VAT" then
                PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" * ( 100 + "VAT %" ) / 100;
            end else begin
              if PeriodDiscountLine."Unit Price Incl. VAT" then
                PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" / ( 100 + "VAT %" ) * 100;
            end;

            if PeriodDiscountLine."Campaign Unit Price" <= UnitPrice then begin
              "Discount %"    := 100 - PeriodDiscountLine."Campaign Unit Price" / UnitPrice * 100;
              "Discount Type" := "Discount Type"::Campaign;
              "Discount Code" := PeriodDiscountLine.Code;
              "Period Discount code" := PeriodDiscountLine.Code;
              PeriodDiscount.Get( PeriodDiscountLine.Code );
              "Custom Disc Blocked" := PeriodDiscount."Block Custom Disc.";
            end;

            //Apply unit cost for the period if specified
            if PeriodDiscountLine."Campaign Unit Cost" <> 0 then
              "Unit Cost" := PeriodDiscountLine."Campaign Unit Cost";
          end;

          "Discount Calculated" := true;
        end;
    end;

    procedure "-- Aux"()
    begin
    end;

    procedure PeriodDiscountLineIsValid(var PeriodDiscountLine: Record "Period Discount Line";var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        PeriodDiscount: Record "Period Discount";
    begin
        //-NPR5.42 [315554]
        // WITH TempSaleLinePOS DO BEGIN
        //  IsValid := TRUE;
        //  PeriodDiscount.GET( PeriodDiscountLine.Code );
        //  IF PeriodDiscount."Starting Time" <> 0T THEN
        //    IF PeriodDiscount."Starting Time" > TIME THEN
        //      IsValid := FALSE;
        //
        //  IF PeriodDiscount."Ending Time" <> 0T THEN
        //    IF PeriodDiscount."Ending Time" < TIME THEN
        //      IsValid := FALSE;
        //
        //  IF PeriodDiscount."Customer Disc. Group Filter" <> '' THEN BEGIN
        //    IF NOT SalePOS.GET("Register No.","Sales Ticket No.") THEN
        //      EXIT(FALSE);
        //    SalePOS.SETRECFILTER;
        //    SalePOS.SETFILTER("Customer Disc. Group",PeriodDiscount."Customer Disc. Group Filter");
        //    EXIT(SalePOS.FINDFIRST);
        //  END;
        // END;
        if not PeriodDiscount.Get(PeriodDiscountLine.Code) then
          exit(false);

        if not IsValidDay(PeriodDiscount,Today) then
          exit(false);

        if not IsValidTime(PeriodDiscount,Time) then
          exit(false);

        if not IsValidCustDiscGroup(PeriodDiscount,TempSaleLinePOS) then
          exit(false);

        exit(true);
        //+NPR5.42 [315554]
    end;

    local procedure IsValidCustDiscGroup(PeriodDiscount: Record "Period Discount";var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.42 [315554]
        if PeriodDiscount."Customer Disc. Group Filter" = '' then
          exit(true);

        if not SalePOS.Get(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.") then
          exit(false);

        SalePOS.SetRecFilter;
        SalePOS.SetFilter("Customer Disc. Group",PeriodDiscount."Customer Disc. Group Filter");
        exit(SalePOS.FindFirst);
        //+NPR5.42 [315554]
    end;

    local procedure IsValidDay(PeriodDiscount: Record "Period Discount";CheckDate: Date): Boolean
    begin
        //-NPR5.42 [315554]
        case PeriodDiscount."Period Type" of
          PeriodDiscount."Period Type"::"Every Day":
            begin
              exit(true);
            end;
          PeriodDiscount."Period Type"::Weekly:
            begin
              case Date2DWY(CheckDate,1) of
                1:
                  exit(PeriodDiscount.Monday);
                2:
                  exit(PeriodDiscount.Tuesday);
                3:
                  exit(PeriodDiscount.Wednesday);
                4:
                  exit(PeriodDiscount.Thursday);
                5:
                  exit(PeriodDiscount.Friday);
                6:
                  exit(PeriodDiscount.Saturday);
                7:
                  exit(PeriodDiscount.Sunday);
              end;
            end;
          else
            exit(false);
        end;
        //+NPR5.42 [315554]
    end;

    local procedure IsValidTime(PeriodDiscount: Record "Period Discount";CheckTime: Time): Boolean
    begin
        //-NPR5.42 [315554]
        if (PeriodDiscount."Starting Time" <> 0T) and (PeriodDiscount."Starting Time" > CheckTime) then
          exit(false);

        if (PeriodDiscount."Ending Time" <> 0T) and (PeriodDiscount."Ending Time" < CheckTime) then
          exit(false);

        exit(true);
        //+NPR5.42 [315554]
    end;

    local procedure "--- Discount Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "Discount Priority")
    begin
        //-NPR5.31 [262904]
        if DiscountPriority.Get(DiscSourceTableId()) then
          exit;

        DiscountPriority.Init;
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 3;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority.Insert(true);
        //+NPR5.31 [262904]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "Discount Priority";SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete;RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;

        //-NPR5.44 [312154]
        //ApplyPeriodDiscounts(SalePOS,TempSaleLinePOS,Rec,xRec,LineOperation);
        ApplyPeriodDiscounts(SalePOS,TempSaleLinePOS,Rec,xRec,LineOperation,RecalculateAllLines);
        //-NPR5.44 [312154]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "Discount Priority" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete)
    var
        DiscountPriority: Record "Discount Priority";
        PeriodDiscountLine: Record "Period Discount Line";
    begin
        //-NPR5.40 [294655]
        if not DiscountPriority.Get(DiscSourceTableId()) then
          exit;
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;
        if not IsValidLineOperation(Rec,xRec,LineOperation) then
          exit;

        PeriodDiscountLine.SetCurrentKey("Item No.","Variant Code","Starting Date","Ending Date",Status);
        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
        PeriodDiscountLine.SetFilter("Variant Code",'%1|%2','',Rec."Variant Code");
        PeriodDiscountLine.SetRange(Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
        PeriodDiscountLine.SetFilter("Ending Date", '>=%1|=%2', Today, 0D);
        if not PeriodDiscountLine.IsEmpty then begin
          tmpDiscountPriority.Init;
          tmpDiscountPriority := DiscountPriority;
          tmpDiscountPriority.Insert;
        end;
        //+NPR5.40 [294655]
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "Discount Priority"): Boolean
    begin
        //-NPR5.31 [262904]
        if DiscountPriority.Disabled then
          exit(false);
        if DiscountPriority."Table ID" <> DiscSourceTableId() then
          exit(false);
        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId()) then
          exit(false);

        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure IsValidLineOperation(Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete): Boolean
    begin
        //-NPR5.40 [294655]
        // IF LineOperation = LineOperation::Modify THEN
        //  IF (Rec.Type = Rec.Type::Item) AND (Rec.Type = xRec.Type) AND (Rec."No." = xRec."No.") THEN
        //    EXIT(FALSE); //Period discounts does not rely on quantity, so correct discount has already been calculated.
        if LineOperation = LineOperation::Delete then
          exit(false);
        exit(true);
        //+NPR5.40 [294655]
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(DATABASE::"Period Discount");
        //+NPR5.31 [262904]
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(CODEUNIT::"Period Discount Management");
        //+NPR5.31 [262904]
    end;
}

