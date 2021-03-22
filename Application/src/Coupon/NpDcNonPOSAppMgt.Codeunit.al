codeunit 6151603 "NPR NpDc Non-POS App. Mgt."
{
    trigger OnRun()
    var
        NotInitialized: Label 'Codeunit 6151603 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        case FunctionToRun of
            FunctionToRun::"Apply Discount":
                ApplyDiscount_OnRun();
            else
                Error(NotInitialized);
        end;
    end;

    var
        TempSalePOS: Record "NPR Sale POS" temporary;
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        FunctionToRun: Option " ","Apply Discount";

    procedure ApplyDiscount(var TempSalePOSIn: Record "NPR Sale POS" temporary; var TempSaleLinePOSIn: Record "NPR Sale Line POS" temporary; var TempNpDcExtCouponBufferIn: Record "NPR NpDc Ext. Coupon Buffer" temporary; Self: Codeunit "NPR NpDc Non-POS App. Mgt.")
    begin
        FunctionToRun := FunctionToRun::"Apply Discount";
        TempSalePOS.Copy(TempSalePOSIn, true);
        TempSaleLinePOS.Copy(TempSaleLinePOSIn, true);
        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBufferIn, true);

        if Self.Run() then;

        FunctionToRun := FunctionToRun::" ";
        TempSalePOSIn.Copy(TempSalePOS, true);
        TempSaleLinePOSIn.Copy(TempSaleLinePOS, true);
    end;

    local procedure ApplyDiscount_OnRun()
    var
        SalePOS: Record "NPR Sale POS";
    begin
        InsertPOSSale(TempSalePOS, TempSaleLinePOS, SalePOS);

        RemoveCouponReservations(TempNpDcExtCouponBuffer);
        ScanCoupons(SalePOS, TempNpDcExtCouponBuffer);

        TransferPOSSalesLines(SalePOS, TempSaleLinePOS);

        Error('');  //Roll back all the changes done to persistent tables
    end;

    procedure CheckCoupons(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
    begin
        if TempNpDcExtCouponBuffer.FindSet then
            repeat
                if FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon) then begin
                    TempNpDcExtCouponBuffer2.Init;
                    TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
                    Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
                    TempNpDcExtCouponBuffer2.Insert;
                end;
            until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    procedure ReserveCoupons(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
        InsertCouponReservations(TempNpDcExtCouponBuffer);
    end;

    procedure CancelCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
    end;

    local procedure InsertPOSSale(var TempSalePOS: Record "NPR Sale POS" temporary; var TempSaleLinePOS: Record "NPR Sale Line POS" temporary; var SalePOS: Record "NPR Sale POS")
    begin
        TempSalePOS.FindFirst;
        InsertSalePOS(TempSalePOS, SalePOS);

        TempSaleLinePOS.FindSet;
        repeat
            InsertSaleLinePOS(SalePOS, TempSaleLinePOS);
        until TempSaleLinePOS.Next = 0;
    end;

    local procedure InsertSalePOS(TempSalePOS: Record "NPR Sale POS" temporary; var SalePOS: Record "NPR Sale POS")
    var
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        POSSale: Codeunit "NPR POS Sale";
        SalesTicketNo: Code[20];
    begin
        if not POSUnit.Get('-_-') then begin
            POSUnit.Init();
            POSUnit."No." := '-_-';
            POSUnit.Insert();
        end;

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init;
            UserSetup."User ID" := UserId;
            UserSetup."NPR Backoffice Register No." := POSUnit."No.";
            UserSetup.Insert;
        end else
            if UserSetup."NPR Backoffice Register No." = '' then begin
                UserSetup."NPR Backoffice Register No." := POSUnit."No.";
                UserSetup.Modify;
            end;

        SalesTicketNo := DelChr(Format(CurrentDateTime, 0, 9), '=', ' -:.ZT');
        while SalePOS.Get(POSUnit."No.", '-' + SalesTicketNo) do
            SalesTicketNo := IncStr(SalesTicketNo);

        SalePOS.Init();
        SalePOS."Register No." := POSUnit."No.";
        SalePOS."Sales Ticket No." := '-' + SalesTicketNo;
        SalePOS.Date := Today();
        SalePOS.Insert();
    end;

    local procedure InsertSaleLinePOS(SalePOS: Record "NPR Sale POS"; TempSaleLinePOS: Record "NPR Sale Line POS" temporary)
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR Sale Line POS";
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
        SaleLinePOS."VAT %" := TempSaleLinePOS."VAT %";
        SaleLinePOS.Description := TempSaleLinePOS.Description;
        SaleLinePOS."Description 2" := TempSaleLinePOS."Description 2";
        SaleLinePOS."Magento Brand" := TempSaleLinePOS."Magento Brand";
        SaleLinePOS."Unit Price" := TempSaleLinePOS."Unit Price";
        SaleLinePOS.Quantity := TempSaleLinePOS.Quantity;
        SaleLinePOS."Amount Including VAT" := TempSaleLinePOS."Amount Including VAT";
        SaleLinePOS."Discount Amount" := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - SaleLinePOS."Amount Including VAT";
        Item.Get(SaleLinePOS."No.");
        SaleLinePOS."Unit of Measure Code" := Item."Sales Unit of Measure";
        if TempSaleLinePOS."Unit of Measure Code" <> '' then
            SaleLinePOS."Unit of Measure Code" := TempSaleLinePOS."Unit of Measure Code";
        SaleLinePOS."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, SaleLinePOS."Unit of Measure Code");
        SaleLinePOS."Quantity (Base)" := UOMMgt.CalcBaseQty(SaleLinePOS.Quantity, SaleLinePOS."Qty. per Unit of Measure");

        SaleLinePOS."Price Includes VAT" := (SaleLinePOS."VAT %" > 0);
        if (not SaleLinePOS."Price Includes VAT") then
            SaleLinePOS.Amount := TempSaleLinePOS."Amount Including VAT";

        SaleLinePOS.Insert;
    end;

    local procedure InsertCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcCouponType: Record "NPR NpDc Coupon Type";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        SalePOS: Record "NPR Sale POS";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
        LineNo: Integer;
    begin
        if not TempNpDcExtCouponBuffer.FindSet then
            exit;

        repeat
            FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon);
            NpDcCouponType.Get(NpDcCoupon."Coupon Type");
            NpDcCouponType.TestField(Enabled);
            SalePOS."Sales Ticket No." := TempNpDcExtCouponBuffer."Document No.";
            NpDcModuleValidateDefault.ValidateCoupon(SalePOS, NpDcCoupon);

            NpDcExtCouponSalesLine.SetRange("External Document No.", TempNpDcExtCouponBuffer."Document No.");
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
            Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
            TempNpDcExtCouponBuffer2.Insert;
        until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    local procedure RemoveCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
    begin
        if not TempNpDcExtCouponBuffer.FindSet then
            exit;

        repeat
            FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon);

            NpDcExtCouponSalesLine.SetRange("External Document No.", TempNpDcExtCouponBuffer."Document No.");
            NpDcExtCouponSalesLine.SetRange("Reference No.", TempNpDcExtCouponBuffer."Reference No.");
            if NpDcExtCouponSalesLine.FindFirst then
                NpDcExtCouponSalesLine.Delete;

            TempNpDcExtCouponBuffer2.Init;
            TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
            Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
            TempNpDcExtCouponBuffer2.Insert;
        until TempNpDcExtCouponBuffer.Next = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    local procedure ScanCoupons(SalePOS: Record "NPR Sale POS"; var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetSale(POSSale);
        POSSale.SetPosition(SalePOS.GetPosition(false));
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.Init(SalePOS."Register No.", SalePOS."Sales Ticket No.", POSSale, POSSetup, POSFrontEndMgt);
        TempNpDcExtCouponBuffer.FindSet;
        repeat
            NpDcCouponMgt.ScanCoupon(POSSession, TempNpDcExtCouponBuffer."Reference No.");
        until TempNpDcExtCouponBuffer.Next = 0;
    end;

    local procedure TransferPOSSalesLines(SalePOS: Record "NPR Sale POS"; var TempSaleLinePOS: Record "NPR Sale Line POS" temporary)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        if SaleLinePOS.FindSet then
            repeat
                TempSaleLinePOS.Init;
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert;
            until SaleLinePOS.Next = 0;
    end;

    [TryFunction]
    local procedure FindCoupon(ReferenceNo: Text; var NpDcCoupon: Record "NPR NpDc Coupon")
    begin
        NpDcCoupon.SetRange("Reference No.", ReferenceNo);
        NpDcCoupon.FindFirst;
        NpDcCoupon.TestField("Reference No.");
    end;

    procedure Coupon2Buffer(NpDcCoupon: Record "NPR NpDc Coupon"; var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        NpDcCoupon.CalcFields(Open, "Remaining Quantity");

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