codeunit 6151603 "NPR NpDc Non-POS App. Mgt."
{
    Access = Internal;

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
        TempSalePOS_: Record "NPR POS Sale" temporary;
        TempSaleLinePOS_: Record "NPR POS Sale Line" temporary;
        TempNpDcExtCouponBuffer_: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        FunctionToRun: Option " ","Apply Discount";

    procedure ApplyDiscount(var TempSalePOSIn: Record "NPR POS Sale" temporary; var TempSaleLinePOSIn: Record "NPR POS Sale Line" temporary; var TempNpDcExtCouponBufferIn: Record "NPR NpDc Ext. Coupon Buffer" temporary; Self: Codeunit "NPR NpDc Non-POS App. Mgt.")
    var
        LastErrorText: Text;
    begin
        FunctionToRun := FunctionToRun::"Apply Discount";
        TempSalePOS_.Copy(TempSalePOSIn, true);
        TempSaleLinePOS_.Copy(TempSaleLinePOSIn, true);
        TempNpDcExtCouponBuffer_.Copy(TempNpDcExtCouponBufferIn, true);

        ClearLastError();

        if Self.Run() then;

        LastErrorText := GetLastErrorText();
        if (LastErrorText <> '') then
            Error(LastErrorText);

        FunctionToRun := FunctionToRun::" ";
        TempSalePOSIn.Copy(TempSalePOS_, true);
        TempSaleLinePOSIn.Copy(TempSaleLinePOS_, true);
    end;

    // **
    // Note: There is a commit in ScanCoupons for the insert extra items implementation.
    // Make sure roll back will undo the changes done to persistent tables
    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure ApplyDiscount_OnRun()
    var
        SalePOS: Record "NPR POS Sale";
    begin
        InsertPOSSale(TempSalePOS_, TempSaleLinePOS_, SalePOS);

        RemoveCouponReservations(TempNpDcExtCouponBuffer_);
        ScanCoupons(SalePOS, TempNpDcExtCouponBuffer_);

        TransferPOSSalesLines(SalePOS, TempSaleLinePOS_);

        Error('');  //Roll back all the changes done to persistent tables
    end;

    procedure CheckCoupons(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
    begin
        if TempNpDcExtCouponBuffer.FindSet() then
            repeat
                if FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon) then begin
                    TempNpDcExtCouponBuffer2.Init();
                    TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
                    Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
                    TempNpDcExtCouponBuffer2.Insert();
                end;
            until TempNpDcExtCouponBuffer.Next() = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    procedure ReserveCoupons(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
        InsertCouponReservations(TempNpDcExtCouponBuffer);
    end;

    procedure CancelCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        RemoveCouponReservations(TempNpDcExtCouponBuffer);
    end;

    local procedure InsertPOSSale(var TempSalePOS: Record "NPR POS Sale" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var SalePOS: Record "NPR POS Sale")
    begin
        TempSalePOS.FindFirst();
        InsertSalePOS(SalePOS);

        if (TempSaleLinePOS.FindSet()) then
            repeat
                InsertSaleLinePOS(SalePOS, TempSaleLinePOS);
            until TempSaleLinePOS.Next() = 0;
    end;

    local procedure InsertSalePOS(var POSSale: Record "NPR POS Sale")
    var
        SalePos: Codeunit "NPR POS Sale";
        PosSession: Codeunit "NPR POS Session";
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if (not UserSetup.Get(UserId)) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        if (UserSetup."NPR POS Unit No." = '') then begin
            POSUnit.SetFilter(Status, '=%1', POSUnit.Status::OPEN);
            if (not POSUnit.FindFirst()) then
                Error('No open POS unit found for user %1', UserId);
            UserSetup."NPR POS Unit No." := POSUnit."No.";
            UserSetup.Modify();
        end;

        POSSession.ConstructFromWebserviceSession(true, '', '');
        PosSession.StartPOSSession();
        PosSession.StartTransaction();

        PosSession.GetSale(SalePOS);
        SalePos.GetCurrentSale(POSSale);

    end;

    local procedure InsertSaleLinePOS(SalePOS: Record "NPR POS Sale"; TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := Today();
        SaleLinePOS."Line No." := TempSaleLinePOS."Line No.";
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
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

        SaleLinePOS.Insert();
    end;

    local procedure InsertCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcCouponType: Record "NPR NpDc Coupon Type";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        SalePOS: Record "NPR POS Sale";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
        LineNo: Integer;
    begin
        if not TempNpDcExtCouponBuffer.FindSet() then
            exit;

        repeat
            FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon);
            NpDcCouponType.Get(NpDcCoupon."Coupon Type");
            NpDcCouponType.TestField(Enabled);
            SalePOS."Sales Ticket No." := TempNpDcExtCouponBuffer."Document No.";
            NpDcModuleValidateDefault.ValidateCoupon(SalePOS, NpDcCoupon);

            NpDcExtCouponSalesLine.SetRange("External Document No.", TempNpDcExtCouponBuffer."Document No.");
            if NpDcExtCouponSalesLine.FindLast() then;
            LineNo := NpDcExtCouponSalesLine."Line No." + 10000;
            NpDcExtCouponSalesLine.Init();
            NpDcExtCouponSalesLine."External Document No." := TempNpDcExtCouponBuffer."Document No.";
            NpDcExtCouponSalesLine."Line No." := LineNo;
            NpDcExtCouponSalesLine."Coupon No." := NpDcCoupon."No.";
            NpDcExtCouponSalesLine."Coupon Type" := NpDcCoupon."Coupon Type";
            NpDcExtCouponSalesLine.Description := NpDcCoupon.Description;
            NpDcExtCouponSalesLine."Reference No." := NpDcCoupon."Reference No.";
            NpDcExtCouponSalesLine.Insert(true);

            TempNpDcExtCouponBuffer2.Init();
            TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
            Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
            TempNpDcExtCouponBuffer2.Insert();
        until TempNpDcExtCouponBuffer.Next() = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    local procedure RemoveCouponReservations(var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary;
    begin
        if not TempNpDcExtCouponBuffer.FindSet() then
            exit;

        repeat
            FindCoupon(TempNpDcExtCouponBuffer."Reference No.", NpDcCoupon);

            NpDcExtCouponSalesLine.SetRange("External Document No.", TempNpDcExtCouponBuffer."Document No.");
            NpDcExtCouponSalesLine.SetRange("Reference No.", TempNpDcExtCouponBuffer."Reference No.");
            if NpDcExtCouponSalesLine.FindFirst() then
                NpDcExtCouponSalesLine.Delete();

            TempNpDcExtCouponBuffer2.Init();
            TempNpDcExtCouponBuffer2 := TempNpDcExtCouponBuffer;
            Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer2);
            TempNpDcExtCouponBuffer2.Insert();
        until TempNpDcExtCouponBuffer.Next() = 0;

        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;

    local procedure ScanCoupons(SalePOS: Record "NPR POS Sale"; var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    var
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
    begin
        POSSession.ConstructFromWebserviceSession(false, SalePOS."Register No.", SalePOS."Sales Ticket No.");

        POSSession.GetSale(POSSale);
        POSSale.SetPosition(SalePOS.GetPosition(false));
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSetup(POSSetup);
        POSSession.GetFrontEnd(POSFrontEndMgt);
        POSSaleLine.Init(SalePOS."Register No.", SalePOS."Sales Ticket No.", POSSale, POSSetup, POSFrontEndMgt);
        TempNpDcExtCouponBuffer.FindSet();
        repeat
            NpDcCouponMgt.ScanCoupon(POSSession, TempNpDcExtCouponBuffer."Reference No.");
        until TempNpDcExtCouponBuffer.Next() = 0;
    end;

    local procedure TransferPOSSalesLines(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        if SaleLinePOS.FindSet() then
            repeat
                TempSaleLinePOS.Init();
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();
            until SaleLinePOS.Next() = 0;
    end;

    [TryFunction]
    local procedure FindCoupon(ReferenceNo: Text; var NpDcCoupon: Record "NPR NpDc Coupon")
    begin
        NpDcCoupon.SetRange("Reference No.", ReferenceNo);
        NpDcCoupon.FindFirst();
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

    internal procedure InitNpDcNonPOSCouponWS()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR NpDc Non-POS Coupon WS", 'discount_coupon_service', true);
    end;
}
