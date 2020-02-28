codeunit 6151603 "NpDc Non-POS Application Mgt."
{
    // NPR5.51/MHA /20190724  CASE 343352 Object created
    // NPR5.53/MHA /20190115  CASE 343352 Added VAT % from request


    trigger OnRun()
    begin
    end;

    procedure ApplyDiscount(var TempSalePOS: Record "Sale POS" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        SalePOS: Record "Sale POS";
        LastErrorText: Text;
    begin
        asserterror begin
          InsertPOSSale(TempSalePOS,TempSaleLinePOS,SalePOS);

          RemoveCouponReservations(TempNpDcExtCouponBuffer);
          ScanCoupons(SalePOS,TempNpDcExtCouponBuffer);

          TransferPOSSalesLines(SalePOS,TempSaleLinePOS);
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          Error(LastErrorText);
    end;

    procedure CheckCoupons(var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NpDc Coupon";
        TempNpDcExtCouponBuffer2: Record "NpDc Ext. Coupon Buffer" temporary;
    begin
        if TempNpDcExtCouponBuffer.FindSet then
          repeat
            if FindCoupon(TempNpDcExtCouponBuffer."Reference No.",NpDcCoupon) then begin
              TempNpDcExtCouponBuffer2.Init;
              TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
              Coupon2Buffer(NpDcCoupon,TempNpDcExtCouponBuffer2);
              TempNpDcExtCouponBuffer2.Insert;
            end;
          until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2,true);
    end;

    procedure ReserveCoupons(var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NpDc Coupon";
        TempNpDcExtCouponBuffer2: Record "NpDc Ext. Coupon Buffer" temporary;
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
        InsertCouponReservations(TempNpDcExtCouponBuffer);
    end;

    procedure CancelCouponReservations(var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
    end;

    local procedure InsertPOSSale(var TempSalePOS: Record "Sale POS" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var SalePOS: Record "Sale POS")
    begin
        TempSalePOS.FindFirst;
        InsertSalePOS(TempSalePOS,SalePOS);

        TempSaleLinePOS.FindSet;
        repeat
          InsertSaleLinePOS(SalePOS,TempSaleLinePOS);
        until TempSaleLinePOS.Next = 0;
    end;

    local procedure InsertSalePOS(TempSalePOS: Record "Sale POS" temporary;var SalePOS: Record "Sale POS")
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
        POSSale: Codeunit "POS Sale";
        SalesTicketNo: Code[20];
    begin
        if not Register.Get('-_-') then begin
          Register.Init;
          Register."Register No." := '-_-';
          Register.Insert;
        end;

        if not UserSetup.Get(UserId) then begin
          UserSetup.Init;
          UserSetup."User ID" := UserId;
          UserSetup."Backoffice Register No." := Register."Register No.";
          UserSetup.Insert;
        end else if UserSetup."Backoffice Register No." = '' then begin
          UserSetup."Backoffice Register No." := Register."Register No.";
          UserSetup.Modify;
        end;

        SalesTicketNo := DelChr(Format(CurrentDateTime,0,9),'=',' -:.ZT');
        while SalePOS.Get(Register."Register No.",'-' + SalesTicketNo) do
          SalesTicketNo := IncStr(SalesTicketNo);

        SalePOS.Init;
        SalePOS."Register No." := Register."Register No.";
        SalePOS."Sales Ticket No." := '-' + SalesTicketNo;
        SalePOS.Date := Today;
        SalePOS.Insert;
    end;

    local procedure InsertSaleLinePOS(SalePOS: Record "Sale POS";TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        Item: Record Item;
        SaleLinePOS: Record "Sale Line POS";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        SaleLinePOS.Init;
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := Today;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS."Line No." := TempSaleLinePOS."Line No.";
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := TempSaleLinePOS."No.";
        SaleLinePOS."Variant Code" := TempSaleLinePOS."Variant Code";
        //-NPR5.53 [343352]
        SaleLinePOS."VAT %" := TempSaleLinePOS."VAT %";
        //+NPR5.53 [343352]
        SaleLinePOS.Description := TempSaleLinePOS.Description;
        SaleLinePOS."Description 2" := TempSaleLinePOS."Description 2";
        SaleLinePOS."Unit Price" := TempSaleLinePOS."Unit Price";
        SaleLinePOS.Quantity := TempSaleLinePOS.Quantity;
        SaleLinePOS."Amount Including VAT" := TempSaleLinePOS."Amount Including VAT";
        SaleLinePOS."Discount Amount" := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - SaleLinePOS."Amount Including VAT";
        Item.Get(SaleLinePOS."No.");
        SaleLinePOS."Unit of Measure Code" := Item."Sales Unit of Measure";
        if TempSaleLinePOS."Unit of Measure Code" <> '' then
          SaleLinePOS."Unit of Measure Code" := TempSaleLinePOS."Unit of Measure Code";
        SaleLinePOS."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item,SaleLinePOS."Unit of Measure Code");
        SaleLinePOS."Quantity (Base)" := UOMMgt.CalcBaseQty(SaleLinePOS.Quantity,SaleLinePOS."Qty. per Unit of Measure");
        //-NPR5.53 [343352]
        //SaleLinePOS.UpdateAmounts(SaleLinePOS);
        //+NPR5.53 [343352]
        SaleLinePOS.Insert;
    end;

    local procedure InsertCouponReservations(var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NpDc Coupon";
        NpDcCouponType: Record "NpDc Coupon Type";
        NpDcExtCouponSalesLine: Record "NpDc Ext. Coupon Reservation";
        TempNpDcExtCouponBuffer2: Record "NpDc Ext. Coupon Buffer" temporary;
        SalePOS: Record "Sale POS";
        NpDcModuleValidateDefault: Codeunit "NpDc Module Validate - Default";
        LineNo: Integer;
    begin
        if not TempNpDcExtCouponBuffer.FindSet then
          exit;

        repeat
          FindCoupon(TempNpDcExtCouponBuffer."Reference No.",NpDcCoupon);
          NpDcCouponType.Get(NpDcCoupon."Coupon Type");
          NpDcCouponType.TestField(Enabled);
          SalePOS."Sales Ticket No." := TempNpDcExtCouponBuffer."Document No.";
          NpDcModuleValidateDefault.ValidateCoupon(SalePOS,NpDcCoupon);

          NpDcExtCouponSalesLine.SetRange("External Document No.",TempNpDcExtCouponBuffer."Document No.");
          if NpDcExtCouponSalesLine.FindLast then;
          LineNo := NpDcExtCouponSalesLine."Line No." + 10000;
          NpDcExtCouponSalesLine.Init;
          NpDcExtCouponSalesLine."External Document No." := TempNpDcExtCouponBuffer."Document No.";
          NpDcExtCouponSalesLine."Line No." := LineNo;
          NpDcExtCouponSalesLine."Coupon No." := NpDcCoupon."No.";
          NpDcExtCouponSalesLine."Coupon Type" := NpDcCoupon."Coupon Type";
          NpDcExtCouponSalesLine.Description := NpDcCoupon.Description;
          NpDcExtCouponSalesLine."Reference No." := NpDcCoupon."Reference No.";
          NpDcExtCouponSalesLine.Insert(true);

          TempNpDcExtCouponBuffer2.Init;
          TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
          Coupon2Buffer(NpDcCoupon,TempNpDcExtCouponBuffer2);
          TempNpDcExtCouponBuffer2.Insert;
        until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2,true);
    end;

    local procedure RemoveCouponReservations(var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NpDc Coupon";
        NpDcExtCouponSalesLine: Record "NpDc Ext. Coupon Reservation";
        TempNpDcExtCouponBuffer2: Record "NpDc Ext. Coupon Buffer" temporary;
    begin
        if not TempNpDcExtCouponBuffer.FindSet then
          exit;

        repeat
          FindCoupon(TempNpDcExtCouponBuffer."Reference No.",NpDcCoupon);

          NpDcExtCouponSalesLine.SetRange("External Document No.",TempNpDcExtCouponBuffer."Document No.");
          NpDcExtCouponSalesLine.SetRange("Reference No.",TempNpDcExtCouponBuffer."Reference No.");
          if NpDcExtCouponSalesLine.FindFirst then
            NpDcExtCouponSalesLine.Delete;

          TempNpDcExtCouponBuffer2.Init;
          TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
          Coupon2Buffer(NpDcCoupon,TempNpDcExtCouponBuffer2);
          TempNpDcExtCouponBuffer2.Insert;
        until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2,true);
    end;

    local procedure ScanCoupons(SalePOS: Record "Sale POS";var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCouponMgt: Codeunit "NpDc Coupon Mgt.";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        POSFrontEndMgt: Codeunit "POS Front End Management";
    begin
        POSSession.GetSale(POSSale);
        POSSale.SetPosition(SalePOS.GetPosition(false));
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.Init(SalePOS."Register No.",SalePOS."Sales Ticket No.",POSSale,POSSetup,POSFrontEndMgt);
        TempNpDcExtCouponBuffer.FindSet;
        repeat
          NpDcCouponMgt.ScanCoupon(POSSession,TempNpDcExtCouponBuffer."Reference No.");
        until TempNpDcExtCouponBuffer.Next = 0;
    end;

    local procedure TransferPOSSalesLines(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll;
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        if SaleLinePOS.FindSet then
          repeat
            TempSaleLinePOS.Init;
            TempSaleLinePOS := SaleLinePOS;
            TempSaleLinePOS.Insert;
          until SaleLinePOS.Next = 0;
    end;

    [TryFunction]
    local procedure FindCoupon(ReferenceNo: Text;var NpDcCoupon: Record "NpDc Coupon")
    begin
        NpDcCoupon.SetRange("Reference No.",ReferenceNo);
        NpDcCoupon.FindFirst;
        NpDcCoupon.TestField("Reference No.");
    end;

    procedure Coupon2Buffer(NpDcCoupon: Record "NpDc Coupon";var TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary)
    begin
        NpDcCoupon.CalcFields(Open,"Remaining Quantity");

        TempNpDcExtCouponBuffer."Reference No." := NpDcCoupon."Reference No.";
        TempNpDcExtCouponBuffer."Coupon Type" := NpDcCoupon."Coupon Type";
        TempNpDcExtCouponBuffer.Description := NpDcCoupon.Description;
        TempNpDcExtCouponBuffer."Starting Date" := NpDcCoupon."Starting Date";
        TempNpDcExtCouponBuffer."Ending Date" := NpDcCoupon."Ending Date";
        TempNpDcExtCouponBuffer.Open := NpDcCoupon.Open;
        TempNpDcExtCouponBuffer."Remaining Quantity" := NpDcCoupon."Remaining Quantity";
        TempNpDcExtCouponBuffer."In-use Quantity" := NpDcCoupon.CalcInUseQty();
    end;
}

