codeunit 6014432 "Quantity Discount Management"
{
    // NPR5.27/LS  /20161020 CASE 255541 Issue when finding multiple Unit price using only Main No.
    // NPR5.31/MHA /20170210  CASE 262904 Applied Event triggered Discount Calculation: OnInitDiscountPriority(),OnApplyDiscount(),IsSubscribedDiscount(),DiscSourceTableId(),DiscCalcCodeunitId()
    // NPR5.38/BHR /20170630  CASE 270508 Skip Discount when we have customer price group
    // NPR5.38/MHA /20171204  CASE 298276 Removed Discount Cache
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization
    // NPR5.42/MMV /20180514  CASE 313873 Set "Discount Modified" field correctly.
    // NPR5.44/MMV /20180627  CASE 312154 Fixed incorrect cross line discount handling when different types collided.
    // NPR5.48/TSA /20181210 CASE 339434 Unit Price was assumed to be the same across all lines
    // NPR5.48/MMV /20181210 CASE 339413 Event discover subscriber was not setting cross line parameter.
    // NPR5.48/TSA /20181214 CASE 339434 Also added Unit Price consideration and VAT inclustion. Ignoring negative discounts
    // NPR5.55/TJ  /20200420 CASE 400524 Setting "Discount Code" as basis for dimension transfer


    trigger OnRun()
    begin
    end;

    procedure ApplyQuantityDiscounts(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";RecalculateAllLines: Boolean): Boolean
    var
        TempQuantityDiscountLine: Record "Quantity Discount Line" temporary;
        TempQuantityDiscountHeader: Record "Quantity Discount Header" temporary;
        ItemQuantity: Decimal;
        DiscountPercent: Decimal;
    begin

        if TempSaleLinePOS."Customer Price Group" <> '' then
          exit;

        Clear(TempSaleLinePOS);

        //-NPR5.44 [312154]
        // TempSaleLinePOS.SETRANGE("No.", Rec."No.");
        if not RecalculateAllLines then
          TempSaleLinePOS.SetRange("No.", Rec."No.");
        TempSaleLinePOS.SetRange("Discount Type",TempSaleLinePOS."Discount Type"::" ");
        //+NPR5.44 [312154]

        if TempSaleLinePOS.IsEmpty then
          exit;

        GetQuantityDiscounts(TempSaleLinePOS,TempQuantityDiscountHeader,TempQuantityDiscountLine);
        if TempQuantityDiscountHeader.IsEmpty then
          exit;
        TempQuantityDiscountHeader.FindSet;
        repeat
          ItemQuantity := 0;
          TempSaleLinePOS.SetRange( "No.", TempQuantityDiscountHeader."Item No." );
          if TempSaleLinePOS.FindSet then repeat
            ItemQuantity += TempSaleLinePOS.Quantity;
          until TempSaleLinePOS.Next = 0;

          TempQuantityDiscountLine.SetRange("Main no.",TempQuantityDiscountHeader."Main No.");
          TempQuantityDiscountLine.SetRange("Item No.",TempQuantityDiscountHeader."Item No.");
          TempQuantityDiscountLine.SetFilter( Quantity, '>%1&<=%2', 0, Abs(ItemQuantity));

          if TempQuantityDiscountLine.FindLast then begin
            //-NPR5.48 [339434]
            // DiscountPercent := 100 - TempQuantityDiscountLine."Unit Price" / TempSaleLinePOS."Unit Price" * 100;
            //+NPR5.48 [339434]

            TempSaleLinePOS.SetRange("No.",TempQuantityDiscountLine."Item No.");

            if TempSaleLinePOS.FindSet then repeat

              //-NPR5.48 [339434]
              TempQuantityDiscountLine.CalcFields ("Price Includes VAT");
              DiscountPercent := 0;
              if (TempSaleLinePOS."Unit Price" <> 0) then begin

                if (TempQuantityDiscountLine."Price Includes VAT" = TempSaleLinePOS."Price Includes VAT") then begin
                  DiscountPercent := 100 - TempQuantityDiscountLine."Unit Price" / TempSaleLinePOS."Unit Price" * 100;

                end else begin
                  if (TempSaleLinePOS."Price Includes VAT") then
                    DiscountPercent := 100 - (TempQuantityDiscountLine."Unit Price" * (100 +TempSaleLinePOS."VAT %") / 100) / TempSaleLinePOS."Unit Price" * 100;

                  if (TempQuantityDiscountLine."Price Includes VAT") then
                    DiscountPercent := 100 - (TempQuantityDiscountLine."Unit Price" / (TempSaleLinePOS."Unit Price" * (100 +TempSaleLinePOS."VAT %") / 100) * 100);
                end;

              end;
              //+NPR5.48 [339434]

              TempSaleLinePOS."Discount %" := DiscountPercent;
              TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::Quantity;
              //-NPR5.55 [400524]
              TempSaleLinePOS."Discount Code" := TempQuantityDiscountLine."Main no.";
              //+NPR5.55 [400524]
              TempSaleLinePOS."FP Anvendt"    := true;

              //-NPR5.48 [338181]
              //TempSaleLinePOS.MODIFY;
              if (DiscountPercent >= 0) then
                TempSaleLinePOS.Modify;
              //+NPR5.48 [338181]

            until TempSaleLinePOS.Next = 0;
          end;
        until TempQuantityDiscountHeader.Next = 0;
    end;

    procedure GetQuantityDiscounts(var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempQuantityDiscountHeader: Record "Quantity Discount Header" temporary;var TempQuantityDiscountLine: Record "Quantity Discount Line")
    var
        QuantityDiscountLine: Record "Quantity Discount Line";
        QuantityDiscountHeader: Record "Quantity Discount Header";
    begin
        if TempSaleLinePOS.FindSet then repeat
          QuantityDiscountHeader.SetCurrentKey( "Item No.", Status, "Starting Date", "Closing Date" );
          QuantityDiscountHeader.SetRange( "Item No.", TempSaleLinePOS."No." );
          QuantityDiscountHeader.SetRange( Status, QuantityDiscountHeader.Status::Active );
          QuantityDiscountHeader.SetFilter( "Starting Date", '<=%1|=%2', Today, 0D );
          QuantityDiscountHeader.SetFilter( "Closing Date", '>=%1|=%2', Today, 0D );
          QuantityDiscountHeader.SetFilter( "Starting Time", '<=%1|=%2', Time, 0T );
          QuantityDiscountHeader.SetFilter( "Closing Time", '>=%1|=%2', Time, 0T );
          QuantityDiscountHeader.SetFilter( "Global Dimension 1 Code", '=%1|=%2', TempSaleLinePOS."Shortcut Dimension 1 Code", '' );
          QuantityDiscountHeader.SetFilter( "Global Dimension 2 Code", '=%1|=%2', TempSaleLinePOS."Shortcut Dimension 2 Code", '' );

          //-NPR5.42 [313873]
          //IF QuantityDiscountHeader.FINDSET THEN REPEAT
          if QuantityDiscountHeader.FindSet then begin
            TempSaleLinePOS."Discount Calculated" := true;
            TempSaleLinePOS.Modify;
            repeat
          //+NPR5.42 [313873]
              QuantityDiscountLine.SetRange( "Main no.", QuantityDiscountHeader."Main No." );
              QuantityDiscountLine.SetRange("Item No.",QuantityDiscountHeader."Item No.");

              TempQuantityDiscountHeader.Init;
              TempQuantityDiscountHeader.TransferFields(QuantityDiscountHeader);

              if TempQuantityDiscountHeader.Insert then begin
                if QuantityDiscountLine.FindSet then repeat
                  TempQuantityDiscountLine.Init;
                  TempQuantityDiscountLine.TransferFields(QuantityDiscountLine);
                  TempQuantityDiscountLine.Insert;
                until QuantityDiscountLine.Next = 0;
                //-NPR5.42 [313873]
                //-NPR5.40 [294655]
        //        TempSaleLinePOS."Discount Modified" := TRUE;
        //        TempSaleLinePOS.MODIFY;
                //+NPR5.40 [294655]
                //+NPR5.42 [313873]
              end;
            until QuantityDiscountHeader.Next = 0;
          //-NPR5.42 [313873]
          end;
          //+NPR5.42 [313873]
        until TempSaleLinePOS.Next = 0;
    end;

    local procedure "--- Subscription"()
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
        DiscountPriority.Priority := 4;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        //-NPR5.48 [339413]
        DiscountPriority."Cross Line Calculation" := true;
        //+NPR5.48 [339413]
        DiscountPriority.Insert(true);
        //+NPR5.31 [262904]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "Discount Priority";SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete;RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;

        //-NPR5.44 [312154]
        //ApplyQuantityDiscounts(SalePOS,TempSaleLinePOS, Rec);
        ApplyQuantityDiscounts(SalePOS,TempSaleLinePOS, Rec, RecalculateAllLines);
        //+NPR5.44 [312154]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "Discount Priority" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete)
    var
        QuantityDiscountHeader: Record "Quantity Discount Header";
        IsActive: Boolean;
        DiscountPriority: Record "Discount Priority";
    begin
        //-NPR5.40 [294655]
        if not DiscountPriority.Get(DiscSourceTableId()) then
          exit;
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;
        if not IsValidLineOperation(Rec, xRec, LineOperation) then
          exit;

        QuantityDiscountHeader.SetCurrentKey( "Item No.", Status, "Starting Date", "Closing Date" );
        QuantityDiscountHeader.SetRange( "Item No.", Rec."No." );
        QuantityDiscountHeader.SetRange( Status, QuantityDiscountHeader.Status::Active );
        QuantityDiscountHeader.SetFilter( "Starting Date", '<=%1|=%2', Today, 0D );
        QuantityDiscountHeader.SetFilter( "Closing Date", '>=%1|=%2', Today, 0D );
        if not QuantityDiscountHeader.IsEmpty then begin
          tmpDiscountPriority.Init;
          tmpDiscountPriority := DiscountPriority;
          tmpDiscountPriority.Insert;
        end;
        //+NPR5.40 [294655]
    end;

    local procedure IsValidLineOperation(Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.44 [312154]
        // IF LineOperation = LineOperation::Delete THEN BEGIN
        //  //Check if any other line has the same item no. - If not, the operation should not trigger discount calculation in sale.
        //  SaleLinePOS.SETRANGE("Register No.", Rec."Register No.");
        //  SaleLinePOS.SETRANGE("Sales Ticket No.", Rec."Sales Ticket No.");
        //  SaleLinePOS.SETRANGE(Date, Rec.Date);
        //  SaleLinePOS.SETRANGE("Sale Type", Rec."Sale Type");
        //  SaleLinePOS.SETRANGE(Type, Rec.Type);
        //  SaleLinePOS.SETRANGE("No.", Rec."No.");
        //  SaleLinePOS.SETFILTER("Line No.", '<>%1', Rec."Line No.");
        //  EXIT(NOT SaleLinePOS.ISEMPTY);
        // END;
        //+NPR5.44 [312154]

        exit(true);
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

    local procedure DiscSourceTableId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(DATABASE::"Quantity Discount Header");
        //+NPR5.31 [262904]
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(CODEUNIT::"Quantity Discount Management");
        //+NPR5.31 [262904]
    end;

    local procedure DiscountActiveNow(var QuantityDiscountHeader: Record "Quantity Discount Header"): Boolean
    var
        CurrDate: Date;
        CurrTime: Time;
    begin
        //-NPR5.31 [262904]
        if QuantityDiscountHeader.IsTemporary then
          exit(false);

        if QuantityDiscountHeader.Status <> QuantityDiscountHeader.Status::Active then
          exit(false);
        if QuantityDiscountHeader."Starting Date" = 0D then
          exit(false);
        if QuantityDiscountHeader."Closing Date" = 0D then
          exit(false);

        CurrDate := Today;
        CurrTime := Time;
        if QuantityDiscountHeader."Starting Date" > CurrDate then
          exit(false);
        if QuantityDiscountHeader."Closing Date" < CurrDate then
          exit(false);
        if (QuantityDiscountHeader."Starting Date" = CurrDate) and (QuantityDiscountHeader."Starting Time" > CurrTime) then
          exit(false);
        if (QuantityDiscountHeader."Closing Date" = CurrDate) and (QuantityDiscountHeader."Closing Time" < CurrTime) then
          exit(false);

        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure DiscountLineActiveNow(var QuantityDiscountLine: Record "Quantity Discount Line"): Boolean
    var
        QuantityDiscountHeader: Record "Quantity Discount Header";
    begin
        //-NPR5.31 [262904]
        if QuantityDiscountLine.IsTemporary then
          exit(false);

        if not QuantityDiscountHeader.Get(QuantityDiscountLine."Item No.",QuantityDiscountLine."Main no.") then
          exit(false);

        exit(DiscountActiveNow(QuantityDiscountHeader));
        //+NPR5.31 [262904]
    end;
}

