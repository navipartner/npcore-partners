﻿codeunit 6151600 "NPR NpDc Module Issue: OnSale"
{
    Access = Internal;

    var
        Text000: Label 'Issue Coupon - Default';
        Text001: Label 'On-Sale Coupons can only be issued through POS Sale';
        Text002: Label 'New Discount Coupon: %1';
        Text003: Label 'This action Issues Discount Coupons.';
        Text004: Label 'Issue Discount Coupons';
        Text005: Label 'Enter Quantity';
        Text006: Label 'Checks On-Sale Discount Coupons on Sale Line Insert';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    var
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
    begin
        if not FindNewCoupons(SalePOS, NpDcSaleLinePOSNewCoupon) then
            exit;

        NpDcSaleLinePOSNewCoupon.FindSet();
        repeat
            IssueCoupon(NpDcSaleLinePOSNewCoupon, TempCoupon);
        until NpDcSaleLinePOSNewCoupon.Next() = 0;
        NpDcSaleLinePOSNewCoupon.DeleteAll();

        PrintCoupons(TempCoupon);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertSaleLine', '', true, true)]
    local procedure AddNewOnSaleCoupons(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'AddNewOnSaleCoupons' then
            exit;
        if not TriggerOnSaleCoupon(SaleLinePOS, SalePOS) then
            exit;

        AddNewCoupons(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if not TriggerOnSaleCoupon(SaleLinePOS, SalePOS) then begin
            if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment then
                RemoveNewCouponsSalesLinePOS(SaleLinePOS);
            exit;
        end;

        AddNewCoupons(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, true)]
    local procedure OnAfterSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if not TriggerOnSaleCoupon(SaleLinePOS, SalePOS) then
            exit;

        AddNewCoupons(SalePOS);
    end;

    local procedure IssueCoupon(NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon"; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        Coupon.Init();
        Coupon.Validate("Coupon Type", NpDcSaleLinePOSNewCoupon."Coupon Type");
        Coupon."No." := '';
        Coupon."Starting Date" := NpDcSaleLinePOSNewCoupon."Starting Date";
        Coupon."Ending Date" := NpDcSaleLinePOSNewCoupon."Ending Date";
        Coupon."Discount Type" := NpDcSaleLinePOSNewCoupon."Discount Type";
        Coupon."Discount %" := NpDcSaleLinePOSNewCoupon."Discount %";
        Coupon."Max. Discount Amount" := NpDcSaleLinePOSNewCoupon."Max. Discount Amount";
        Coupon."Discount Amount" := NpDcSaleLinePOSNewCoupon."Amount per Qty.";
        Coupon."Max Use per Sale" := NpDcSaleLinePOSNewCoupon."Max Use per Sale";
        Coupon.Insert(true);

        CouponMgt.PostIssueCoupon2(Coupon, NpDcSaleLinePOSNewCoupon.Quantity, NpDcSaleLinePOSNewCoupon."Discount Type");

        TempCoupon.Init();
        TempCoupon := Coupon;
        TempCoupon.Insert();
    end;

    local procedure PrintCoupons(var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        if not TempCoupon.FindSet() then
            exit;

        repeat
            Coupon.Get(TempCoupon."No.");
            if Coupon."Print Template Code" <> '' then
                NpDcCouponMgt.PrintCoupon(Coupon);
        until TempCoupon.Next() = 0;
    end;

    local procedure AddNewCoupons(SalePOS: Record "NPR POS Sale")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        CouponQty: Integer;
        NewCouponQty: Integer;
    begin
        if not FindActiveOnSaleCouponTypes(CouponType) then
            exit;

        CouponType.FindSet();
        repeat
            NewCouponQty := IssueOnSaleAchieved(SalePOS, CouponType);
            CouponQty := CountCouponQty(SalePOS, CouponType);
            if NewCouponQty > CouponQty then
                InsertNewCoupons(SalePOS, CouponType, NewCouponQty - CouponQty);
            if NewCouponQty < CouponQty then
                RemoveNewCoupons(SalePOS, CouponType, CouponQty - NewCouponQty);
        until CouponType.Next() = 0;
    end;

    local procedure InsertNewCoupons(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type"; NewCouponQty: Integer)
    var
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
        i: Integer;
    begin
        if CheckIfCouponTypeSettingsAreNotValid(SalePOS, CouponType) then
            exit;
        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast() then;
        LineNo := SaleLinePOS."Line No.";

        for i := 1 to NewCouponQty do begin
            LineNo += 10000;
            SaleLinePOS.Init();
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Line No." := LineNo;
            SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
            SaleLinePOS.Description := CopyStr(StrSubstNo(Text002, CouponType.Description), 1, MaxStrLen(SaleLinePOS.Description));
            SaleLinePOS.Insert(true);

            NpDcSaleLinePOSNewCoupon.Init();
            NpDcSaleLinePOSNewCoupon."Register No." := SaleLinePOS."Register No.";
            NpDcSaleLinePOSNewCoupon."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            NpDcSaleLinePOSNewCoupon."Sale Date" := SaleLinePOS.Date;
            NpDcSaleLinePOSNewCoupon."Sale Line No." := SaleLinePOS."Line No.";
            NpDcSaleLinePOSNewCoupon."Line No." := 10000;
            NpDcSaleLinePOSNewCoupon."Coupon Type" := CouponType.Code;
            NpDcSaleLinePOSNewCoupon."Starting Date" := CouponType."Starting Date";
            if ((CouponType."Starting Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Starting Date DateFormula") <> '')) then
                NpDcSaleLinePOSNewCoupon."Starting Date" := CreateDateTime(CalcDate(CouponType."Starting Date DateFormula"), 0T);
            NpDcSaleLinePOSNewCoupon."Ending Date" := CouponType."Ending Date";
            if ((CouponType."Ending Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Ending Date DateFormula") <> '')) then
                NpDcSaleLinePOSNewCoupon."Ending Date" := CreateDateTime(CalcDate(CouponType."Ending Date DateFormula"), 235959T);
            NpDcSaleLinePOSNewCoupon."Discount Type" := CouponType."Discount Type";
            NpDcSaleLinePOSNewCoupon."Discount %" := CouponType."Discount %";
            NpDcSaleLinePOSNewCoupon."Max. Discount Amount" := CouponType."Max. Discount Amount";
            NpDcSaleLinePOSNewCoupon."Amount per Qty." := CouponType."Discount Amount";
            NpDcSaleLinePOSNewCoupon."Max Use per Sale" := CouponType."Max Use per Sale";
            NpDcSaleLinePOSNewCoupon.Quantity := 1;
            if CouponType."Multi-Use Coupon" and (CouponType."Multi-Use Qty." > 0) then
                NpDcSaleLinePOSNewCoupon.Quantity := CouponType."Multi-Use Qty.";
            NpDcSaleLinePOSNewCoupon.Insert(true);
        end;
    end;

    local procedure RemoveNewCoupons(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type"; RemoveCouponQty: Integer)
    var
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
        SaleLinePOS: Record "NPR POS Sale Line";
        CouponQtyRemoved: Integer;
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Coupon Type", CouponType.Code);
        if not NpDcSaleLinePOSNewCoupon.FindSet() then
            exit;

        SaleLinePOS.SetSkipCalcDiscount(true);
        repeat
            CouponQtyRemoved += 1;
            if SaleLinePOS.Get(NpDcSaleLinePOSNewCoupon."Register No.", NpDcSaleLinePOSNewCoupon."Sales Ticket No.",
                               NpDcSaleLinePOSNewCoupon."Sale Date", NpDcSaleLinePOSNewCoupon."Sale Type", NpDcSaleLinePOSNewCoupon."Sale Line No.") then
                SaleLinePOS.Delete(true);
            NpDcSaleLinePOSNewCoupon.Delete();
        until (NpDcSaleLinePOSNewCoupon.Next() = 0) or (CouponQtyRemoved >= RemoveCouponQty);
    end;

    local procedure RemoveNewCouponsSalesLinePOS(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if NpDcSaleLinePOSNewCoupon.IsEmpty then
            exit;

        NpDcSaleLinePOSNewCoupon.DeleteAll();
    end;

    local procedure IssueCouponActionCode(): Code[20]
    begin
        exit('ISSUE_COUPON');
    end;

    local procedure IssueCouponActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverIssueCouponAction(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          IssueCouponActionCode(),
          Text003,
          IssueCouponActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('coupon_type_input', 'if (!param.CouponTypeCode) {respond()} else {context.CouponTypeCode = param.CouponTypeCode}');
        Sender.RegisterWorkflowStep('qty_input', 'if(param.Quantity <= 0) {intpad({title: labels.IssueCouponTitle,caption: labels.Quantity,value: 1,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$qty_input = {"numpad": param.Quantity}};');
        Sender.RegisterWorkflowStep('issue_coupon', 'respond ();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('CouponTypeCode', '');
        Sender.RegisterIntegerParameter('Quantity', 0);
        Sender.RegisterBooleanParameter('InstantIssue', false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeIssueCouponCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(IssueCouponActionCode(), 'IssueCouponTitle', Text004);
        Captions.AddActionCaption(IssueCouponActionCode(), 'Quantity', Text005);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Handled then
            exit;

        if not Action.IsThisAction(IssueCouponActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
            'coupon_type_input':
                OnActionCouponTypeInput(JSON, FrontEnd);
            'issue_coupon':
                OnActionIssueCoupon(JSON, POSSession);
        end;
    end;

    local procedure OnActionCouponTypeInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        CouponTypeCode: Text;
    begin
        if not SelectCouponType(CouponTypeCode) then
            Error('');

        JSON.SetScopeParameters(IssueCouponActionCode());
        JSON.SetContext('CouponTypeCode', CouponTypeCode);
        FrontEnd.SetActionContext(IssueCouponActionCode(), JSON);
    end;

    local procedure OnActionIssueCoupon(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        SalePOS: Record "NPR POS Sale";
        NpDcModuleIssueDefault: Codeunit "NPR NpDc Module Issue: Default";
        POSSale: Codeunit "NPR POS Sale";
        CouponTypeCode: Text;
        Quantity: Integer;
        ReadingFromActionIssueCoupon: Label 'reading in OnActionIssueCoupon';
        SettingScopeErr: Label 'setting scope';
    begin
        CouponTypeCode := UpperCase(JSON.GetStringOrFail('CouponTypeCode', ReadingFromActionIssueCoupon));
        CouponType.Get(CouponTypeCode);

        JSON.SetScopeRoot();
        JSON.SetScope('$qty_input', SettingScopeErr);
        Quantity := JSON.GetIntegerOrFail('numpad', ReadingFromActionIssueCoupon);

        if JSON.GetBooleanParameter('InstantIssue') then begin
            NpDcModuleIssueDefault.IssueCoupons(CouponType, Quantity);
            exit;
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        InsertNewCoupons(SalePOS, CouponType, Quantity);

        POSSession.RequestRefreshData();
    end;

    local procedure SelectCouponType(var CouponTypeCode: Text): Boolean
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        CouponTypeCode := '';
        if PAGE.RunModal(0, CouponType) <> ACTION::LookupOK then
            exit(false);

        CouponTypeCode := CouponType.Code;
        exit(true);
    end;

    local procedure CountCouponQty(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type"): Integer
    var
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Coupon Type", CouponType.Code);
        exit(NpDcSaleLinePOSNewCoupon.Count());
    end;

    local procedure FindActiveOnSaleCouponTypes(var CouponType: Record "NPR NpDc Coupon Type"): Boolean
    var
        CheckDT: DateTime;
    begin
        Clear(CouponType);
        CouponType.SetRange("Issue Coupon Module", ModuleCode());
        CouponType.SetRange(Enabled, true);
        CheckDT := CurrentDateTime;
        CouponType.SetFilter("Starting Date", '<=%1', CheckDT);
        CouponType.SetFilter("Ending Date", '>=%1|%2', CheckDT, 0DT);
        CouponType.SetFilter("Reference No. Pattern", '<>%1', '');
        exit(CouponType.FindFirst());
    end;

    local procedure FindNewCoupons(SalePOS: Record "NPR POS Sale"; var NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon"): Boolean
    begin
        Clear(NpDcSaleLinePOSNewCoupon);
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(NpDcSaleLinePOSNewCoupon.FindFirst());
    end;

    local procedure IssueOnSaleAchieved(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type") NewCouponQty: Integer
    var
        NpDcIssueOnSaleSetup: Record "NPR NpDc Iss.OnSale Setup";
        TempNpDcItemBuffer: Record "NPR NpDc Item Buffer 2" temporary;
    begin
        if not NpDcIssueOnSaleSetup.Get(CouponType.Code) then
            exit;

        SalePOS2DiscBuffer(SalePOS, CouponType, TempNpDcItemBuffer);
        TempNpDcItemBuffer.CalcSums("Line Amount", Quantity);
        case NpDcIssueOnSaleSetup.Type of
            NpDcIssueOnSaleSetup.Type::"Item Sales Amount":
                NewCouponQty := TempNpDcItemBuffer."Line Amount" div NpDcIssueOnSaleSetup."Item Sales Amount";
            NpDcIssueOnSaleSetup.Type::"Item Sales Qty.":
                NewCouponQty := TempNpDcItemBuffer.Quantity div NpDcIssueOnSaleSetup."Item Sales Qty.";
            NpDcIssueOnSaleSetup.Type::Lot:
                begin
                    NewCouponQty := GetLotQty(NpDcIssueOnSaleSetup, TempNpDcItemBuffer);
                end;
            else
                exit(0);
        end;

        if (NewCouponQty > NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale") and (NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale" > 0) then
            NewCouponQty := NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale";

        exit(NewCouponQty);
    end;

    local procedure GetLotQty(NpDcIssueOnSaleSetup: Record "NPR NpDc Iss.OnSale Setup"; var NpDcItemBuffer: Record "NPR NpDc Item Buffer 2" temporary) LotQty: Decimal
    var
        NpDcIssueOnSaleSetupLine: Record "NPR NpDc Iss.OnSale Setup Line";
        LotLineQty: Decimal;
    begin
        NpDcIssueOnSaleSetupLine.SetRange("Coupon Type", NpDcIssueOnSaleSetup."Coupon Type");
        NpDcIssueOnSaleSetupLine.SetFilter("No.", '<>%1', '');
        NpDcIssueOnSaleSetupLine.SetFilter("Lot Quantity", '>%1', 0);
        if not NpDcIssueOnSaleSetupLine.FindSet() then
            exit(0);

        repeat
            Clear(NpDcItemBuffer);
            case NpDcIssueOnSaleSetupLine.Type of
                NpDcIssueOnSaleSetupLine.Type::Item:
                    NpDcItemBuffer.SetRange("Item No.", NpDcIssueOnSaleSetupLine."No.");
                NpDcIssueOnSaleSetupLine.Type::"Item Group":
                    NpDcItemBuffer.SetRange("Item Category Code", NpDcIssueOnSaleSetupLine."No.");
                NpDcIssueOnSaleSetupLine.Type::"Item Disc. Group":
                    NpDcItemBuffer.SetRange("Item Disc. Group", NpDcIssueOnSaleSetupLine."No.");
            end;
            NpDcItemBuffer.SetFilter("Variant Code", NpDcIssueOnSaleSetupLine."Variant Code");
            NpDcItemBuffer.CalcSums(Quantity);

            LotLineQty := NpDcItemBuffer.Quantity div NpDcIssueOnSaleSetupLine."Lot Quantity";
            if LotLineQty <= 0 then
                exit(0);
            if (LotQty = 0) or (LotLineQty < LotQty) then
                LotQty := LotLineQty;

            NpDcItemBuffer.DeleteAll();
        until NpDcIssueOnSaleSetupLine.Next() = 0;

        exit(LotQty);
    end;

    local procedure SalePOS2DiscBuffer(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type"; var NpDcItemBuffer: Record "NPR NpDc Item Buffer 2" temporary): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpDcIssueOnSaleSetupLine: Record "NPR NpDc Iss.OnSale Setup Line";
    begin
        NpDcItemBuffer.DeleteAll();

        NpDcIssueOnSaleSetupLine.SetRange("Coupon Type", CouponType.Code);
        NpDcIssueOnSaleSetupLine.SetFilter("No.", '<>%1', '');
        if not NpDcIssueOnSaleSetupLine.FindSet() then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
            SaleLinePOS.SetFilter(Quantity, '>%1', 0);
            SaleLinePOS2DiscBuffer(SaleLinePOS, NpDcItemBuffer);
            exit;
        end;

        repeat
            Clear(SaleLinePOS);
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
            SaleLinePOS.SetFilter("Variant Code", NpDcIssueOnSaleSetupLine."Variant Code");
            SaleLinePOS.SetFilter(Quantity, '>%1', 0);
            case NpDcIssueOnSaleSetupLine.Type of
                NpDcIssueOnSaleSetupLine.Type::Item:
                    SaleLinePOS.SetRange("No.", NpDcIssueOnSaleSetupLine."No.");
                NpDcIssueOnSaleSetupLine.Type::"Item Group":
                    SaleLinePOS.SetRange("Item Category Code", NpDcIssueOnSaleSetupLine."No.");
                NpDcIssueOnSaleSetupLine.Type::"Item Disc. Group":
                    SaleLinePOS.SetRange("Item Disc. Group", NpDcIssueOnSaleSetupLine."No.");
            end;
            SaleLinePOS2DiscBuffer(SaleLinePOS, NpDcItemBuffer);
        until NpDcIssueOnSaleSetupLine.Next() = 0;
    end;

    local procedure SaleLinePOS2DiscBuffer(var SaleLinePOS: Record "NPR POS Sale Line"; var NpDcItemBuffer: Record "NPR NpDc Item Buffer 2" temporary): Decimal
    begin
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            if NpDcItemBuffer.Get(
                SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Item Category Code", SaleLinePOS."Item Disc. Group", SaleLinePOS."Unit Price", 0, '')
            then begin
                NpDcItemBuffer.Quantity += SaleLinePOS.Quantity;
                NpDcItemBuffer."Line Amount" += SaleLinePOS."Amount Including VAT";
                NpDcItemBuffer.Modify();
            end else begin
                NpDcItemBuffer.Init();
                NpDcItemBuffer."Item No." := SaleLinePOS."No.";
                NpDcItemBuffer."Variant Code" := SaleLinePOS."Variant Code";
                NpDcItemBuffer."Item Category Code" := SaleLinePOS."Item Category Code";
                NpDcItemBuffer."Item Disc. Group" := SaleLinePOS."Item Disc. Group";
                NpDcItemBuffer."Unit Price" := SaleLinePOS."Unit Price";
                NpDcItemBuffer."Discount Type" := 0;
                NpDcItemBuffer."Discount Code" := '';
                NpDcItemBuffer.Quantity := SaleLinePOS.Quantity;
                NpDcItemBuffer."Line Amount" := SaleLinePOS."Amount Including VAT";
                NpDcItemBuffer.Insert();
            end;
        until SaleLinePOS.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnHasIssueCouponSetup', '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        NpDcIssueOnSaleSetup: Record "NPR NpDc Iss.OnSale Setup";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        if not NpDcIssueOnSaleSetup.Get(CouponType.Code) then begin
            NpDcIssueOnSaleSetup.Init();
            NpDcIssueOnSaleSetup."Coupon Type" := CouponType.Code;
            NpDcIssueOnSaleSetup.Insert();
        end;

        PAGE.Run(PAGE::"NPR NpDc Iss.OnSale Setup", NpDcIssueOnSaleSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(CouponType) then
            exit;

        Handled := true;

        Error(Text001);
    end;

    local procedure TriggerOnSaleCoupon(SaleLinePOS: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"): Boolean
    begin
        if SaleLinePOS.IsTemporary then
            exit(false);
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit(false);

        exit(SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No."));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Module Issue: OnSale");
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('ON-SALE');
    end;

    local procedure CheckIfCouponTypeSettingsAreNotValid(SalePOS: Record "NPR POS Sale"; CouponType: Record "NPR NpDc Coupon Type"): Boolean
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
    begin
        if CouponType."POS Store Group" = '' then
            exit;
        if not CouponType."Match POS Store Group" then
            exit;
        POSStoreGroupLine.SetRange("No.", CouponType."POS Store Group");
        POSStoreGroupLine.SetRange("POS Store", SalePOS."POS Store Code");
        if POSStoreGroupLine.IsEmpty() then
            exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'AddNewOnSaleCoupons':
                begin
                    Rec.Description := Text006;
                    Rec."Sequence No." := 40;
                end;
        end;
    end;
}
