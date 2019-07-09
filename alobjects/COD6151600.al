codeunit 6151600 "NpDc Module Issue - On-Sale"
{
    // NPR5.36/MHA /20170831  CASE 286812 Object created - Discount Coupon Issue Module
    // NPR5.38/MHA /20171204  CASE 298276 Replaced DiscountItemBuffer with NpDcItemBuffer
    // NPR5.39/MHA /20180214  CASE 305146 CouponType must be Enabled in FindActiveOnSaleCouponTypes()
    // NPR5.41/MHA /20180412  CASE 307048 Discount is now predefined in NpDcSaleLinePOSNewCoupon
    // NPR5.43/MHA /20180604  CASE 308980 Added Issue Coupon POS Action
    // NPR5.43/MHA /20180619  CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Issue Coupon - Default';
        Text001: Label 'On-Sale Coupons can only be issued through POS Sale';
        Text002: Label 'New Discount Coupon: %1';
        Text003: Label 'This action Issues Discount Coupons.';
        Text004: Label 'Issue Discount Coupons';
        Text005: Label 'Enter Quantity:';
        Text006: Label 'Checks On-Sale Discount Coupons on Sale Line Insert';

    local procedure "--- Issue Coupon"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(SalePOS: Record "Sale POS")
    var
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        TempCoupon: Record "NpDc Coupon" temporary;
    begin
        if not FindNewCoupons(SalePOS,NpDcSaleLinePOSNewCoupon) then
          exit;

        NpDcSaleLinePOSNewCoupon.FindSet;
        repeat
          IssueCoupon(NpDcSaleLinePOSNewCoupon,TempCoupon);
        until NpDcSaleLinePOSNewCoupon.Next = 0;
        NpDcSaleLinePOSNewCoupon.DeleteAll;

        PrintCoupons(TempCoupon);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure AddNewOnSaleCoupons(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SaleLinePOS: Record "Sale Line POS")
    var
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.43 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'AddNewOnSaleCoupons' then
          exit;
        //+NPR5.43 [319425]
        if not TriggerOnSaleCoupon(SaleLinePOS,SalePOS) then
          exit;

        AddNewCoupons(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Sender: Codeunit "POS Sale Line";SaleLinePOS: Record "Sale Line POS")
    var
        SalePOS: Record "Sale POS";
    begin
        if not TriggerOnSaleCoupon(SaleLinePOS,SalePOS) then begin
          if SaleLinePOS.Type = SaleLinePOS.Type::Comment then
            RemoveNewCouponsSalesLinePOS(SaleLinePOS);
          exit;
        end;

        AddNewCoupons(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterSetQuantity', '', true, true)]
    local procedure OnAfterSetQuantity(var Sender: Codeunit "POS Sale Line";SaleLinePOS: Record "Sale Line POS")
    var
        SalePOS: Record "Sale POS";
    begin
        if not TriggerOnSaleCoupon(SaleLinePOS,SalePOS) then
          exit;

        AddNewCoupons(SalePOS);
    end;

    local procedure IssueCoupon(NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";var TempCoupon: Record "NpDc Coupon" temporary)
    var
        Coupon: Record "NpDc Coupon";
        CouponMgt: Codeunit "NpDc Coupon Mgt.";
    begin
        Coupon.Init;
        Coupon.Validate("Coupon Type",NpDcSaleLinePOSNewCoupon."Coupon Type");
        Coupon."No." := '';
        //-NPR5.41 [307048]
        Coupon."Starting Date" := NpDcSaleLinePOSNewCoupon."Starting Date";
        Coupon."Ending Date" := NpDcSaleLinePOSNewCoupon."Ending Date";
        Coupon."Discount Type" := NpDcSaleLinePOSNewCoupon."Discount Type";
        Coupon."Discount %" := NpDcSaleLinePOSNewCoupon."Discount %";
        Coupon."Max. Discount Amount" := NpDcSaleLinePOSNewCoupon."Max. Discount Amount";
        Coupon."Discount Amount" := NpDcSaleLinePOSNewCoupon."Amount per Qty.";
        Coupon."Max Use per Sale" := NpDcSaleLinePOSNewCoupon."Max Use per Sale";
        //+NPR5.41 [307048]
        Coupon.Insert(true);

        //-NPR5.41 [307048]
        //CouponMgt.PostIssueCoupon(Coupon);
        CouponMgt.PostIssueCoupon2(Coupon,NpDcSaleLinePOSNewCoupon.Quantity,NpDcSaleLinePOSNewCoupon."Discount Type");
        //+NPR5.41 [307048]

        TempCoupon.Init;
        TempCoupon := Coupon;
        TempCoupon.Insert;
    end;

    local procedure PrintCoupons(var TempCoupon: Record "NpDc Coupon" temporary)
    var
        Coupon: Record "NpDc Coupon";
        NpDcCouponMgt: Codeunit "NpDc Coupon Mgt.";
    begin
        if not TempCoupon.FindSet then
          exit;

        repeat
          Coupon.Get(TempCoupon."No.");
          if Coupon."Print Template Code" <> '' then
            NpDcCouponMgt.PrintCoupon(Coupon);
        until TempCoupon.Next = 0;
    end;

    local procedure AddNewCoupons(SalePOS: Record "Sale POS")
    var
        CouponType: Record "NpDc Coupon Type";
        CouponQty: Integer;
        NewCouponQty: Integer;
    begin
        if not FindActiveOnSaleCouponTypes(CouponType) then
          exit;

        CouponType.FindSet;
        repeat
          NewCouponQty := IssueOnSaleAchieved(SalePOS,CouponType);
          CouponQty := CountCouponQty(SalePOS,CouponType);
          if NewCouponQty > CouponQty then
            InsertNewCoupons(SalePOS,CouponType,NewCouponQty - CouponQty);
          if NewCouponQty < CouponQty then
            RemoveNewCoupons(SalePOS,CouponType,CouponQty - NewCouponQty);
        until CouponType.Next = 0;
    end;

    local procedure InsertNewCoupons(SalePOS: Record "Sale POS";CouponType: Record "NpDc Coupon Type";NewCouponQty: Integer)
    var
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
        i: Integer;
    begin
        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then;
        LineNo := SaleLinePOS."Line No.";

        for i := 1 to NewCouponQty do begin
          LineNo += 10000;
          SaleLinePOS.Init;
          SaleLinePOS."Register No." := SalePOS."Register No.";
          SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS."Line No." := LineNo;
          SaleLinePOS.Type := SaleLinePOS.Type::Comment;
          SaleLinePOS.Description := CopyStr(StrSubstNo(Text002,CouponType.Description),1,MaxStrLen(SaleLinePOS.Description));
          SaleLinePOS.Insert(true);

          NpDcSaleLinePOSNewCoupon.Init;
          NpDcSaleLinePOSNewCoupon."Register No." := SaleLinePOS."Register No.";
          NpDcSaleLinePOSNewCoupon."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          NpDcSaleLinePOSNewCoupon."Sale Type" := SaleLinePOS."Sale Type";
          NpDcSaleLinePOSNewCoupon."Sale Date" := SaleLinePOS.Date;
          NpDcSaleLinePOSNewCoupon."Sale Line No." := SaleLinePOS."Line No.";
          NpDcSaleLinePOSNewCoupon."Line No." := 10000;
          NpDcSaleLinePOSNewCoupon."Coupon Type" := CouponType.Code;
          //-NPR5.41 [307048]
          NpDcSaleLinePOSNewCoupon."Starting Date" := CouponType."Starting Date";
          NpDcSaleLinePOSNewCoupon."Ending Date" := CouponType."Ending Date";
          NpDcSaleLinePOSNewCoupon."Discount Type" := CouponType."Discount Type";
          NpDcSaleLinePOSNewCoupon."Discount %" := CouponType."Discount %";
          NpDcSaleLinePOSNewCoupon."Max. Discount Amount" := CouponType."Max. Discount Amount";
          NpDcSaleLinePOSNewCoupon."Amount per Qty." := CouponType."Discount Amount";
          NpDcSaleLinePOSNewCoupon."Max Use per Sale" := CouponType."Max Use per Sale";
          NpDcSaleLinePOSNewCoupon.Quantity := 1;
          if CouponType."Multi-Use Coupon" and (CouponType."Multi-Use Qty." > 0) then
            NpDcSaleLinePOSNewCoupon.Quantity := CouponType."Multi-Use Qty.";
          //+NPR5.41 [307048]
          NpDcSaleLinePOSNewCoupon.Insert(true);
        end;
    end;

    local procedure RemoveNewCoupons(SalePOS: Record "Sale POS";CouponType: Record "NpDc Coupon Type";RemoveCouponQty: Integer)
    var
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        SaleLinePOS: Record "Sale Line POS";
        CouponQtyRemoved: Integer;
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.",SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Coupon Type",CouponType.Code);
        if not NpDcSaleLinePOSNewCoupon.FindSet then
          exit;

        SaleLinePOS.SetSkipCalcDiscount(true);
        repeat
          CouponQtyRemoved += 1;
          if SaleLinePOS.Get(NpDcSaleLinePOSNewCoupon."Register No.",NpDcSaleLinePOSNewCoupon."Sales Ticket No.",
                             NpDcSaleLinePOSNewCoupon."Sale Date",NpDcSaleLinePOSNewCoupon."Sale Type",NpDcSaleLinePOSNewCoupon."Sale Line No.") then
            SaleLinePOS.Delete(true);
          NpDcSaleLinePOSNewCoupon.Delete;
        until (NpDcSaleLinePOSNewCoupon.Next = 0) or (CouponQtyRemoved >= RemoveCouponQty);
    end;

    local procedure RemoveNewCouponsSalesLinePOS(SaleLinePOS: Record "Sale Line POS")
    var
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.",SaleLinePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        if NpDcSaleLinePOSNewCoupon.IsEmpty then
          exit;

        NpDcSaleLinePOSNewCoupon.DeleteAll;
    end;

    local procedure "--- POS Issue"()
    begin
    end;

    local procedure IssueCouponActionCode(): Text
    begin
        //-NPR5.43 [308980]
        exit ('ISSUE_COUPON');
        //+NPR5.43 [308980]
    end;

    local procedure IssueCouponActionVersion(): Text
    begin
        //-NPR5.43 [308980]
        exit ('1.0');
        //+NPR5.43 [308980]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverIssueCouponAction(var Sender: Record "POS Action")
    begin
        //-NPR5.43 [308980]
        if not Sender.DiscoverAction(
          IssueCouponActionCode(),
          Text003,
          IssueCouponActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep('coupon_type_input','if (!param.CouponTypeCode) {respond()} else {context.CouponTypeCode = param.CouponTypeCode}');
        Sender.RegisterWorkflowStep('qty_input','if(param.Quantity <= 0) {intpad({title: labels.IssueCouponTitle,caption: labels.Quantity,value: 1,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$qty_input = {"numpad": param.Quantity}};');
        Sender.RegisterWorkflowStep ('issue_coupon','respond ();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('CouponTypeCode','');
        Sender.RegisterIntegerParameter('Quantity',0);
        //+NPR5.43 [308980]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeIssueCouponCaptions(Captions: Codeunit "POS Caption Management")
    begin
        //-NPR5.43 [308980]
        Captions.AddActionCaption(IssueCouponActionCode,'IssueCouponTitle',Text004);
        Captions.AddActionCaption(IssueCouponActionCode,'Quantity',Text005);
        //+NPR5.43 [308980]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        JSON: Codeunit "POS JSON Management";
    begin
        //-NPR5.43 [308980]
        if Handled then
          exit;

        if not Action.IsThisAction(IssueCouponActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
          'coupon_type_input':
            OnActionCouponTypeInput(JSON,FrontEnd);
          'issue_coupon':
            OnActionIssueCoupon(JSON,POSSession);
        end;
        //+NPR5.43 [308980]
    end;

    local procedure OnActionCouponTypeInput(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        CouponType: Record "NpDc Coupon Type";
        CouponTypeCode: Text;
    begin
        //-NPR5.43 [308980]
        if not SelectCouponType(CouponTypeCode) then
          Error('');

        JSON.SetScope('parameters',true);
        JSON.SetContext('CouponTypeCode',CouponTypeCode);
        FrontEnd.SetActionContext(IssueCouponActionCode(),JSON);
        //+NPR5.43 [308980]
    end;

    local procedure OnActionIssueCoupon(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        CouponType: Record "NpDc Coupon Type";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        CouponTypeCode: Text;
        Quantity: Integer;
    begin
        //-NPR5.43 [308980]
        CouponTypeCode := UpperCase(JSON.GetString('CouponTypeCode',true));
        CouponType.Get(CouponTypeCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        JSON.SetScope('/',true);
        JSON.SetScope('$qty_input',true);
        Quantity := JSON.GetInteger('numpad',true);
        InsertNewCoupons(SalePOS,CouponType,Quantity);

        POSSession.RequestRefreshData();
        //+NPR5.43 [308980]
    end;

    local procedure SelectCouponType(var CouponTypeCode: Text): Boolean
    var
        CouponType: Record "NpDc Coupon Type";
    begin
        //-NPR5.43 [308980]
        CouponTypeCode := '';
        if PAGE.RunModal(0,CouponType) <>  ACTION::LookupOK then
          exit(false);

        CouponTypeCode := CouponType.Code;
        exit(true);
        //+NPR5.43 [308980]
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure CountCouponQty(SalePOS: Record "Sale POS";CouponType: Record "NpDc Coupon Type"): Integer
    var
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
    begin
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.",SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Coupon Type",CouponType.Code);
        exit(NpDcSaleLinePOSNewCoupon.Count);
    end;

    local procedure FindActiveOnSaleCouponTypes(var CouponType: Record "NpDc Coupon Type"): Boolean
    var
        CheckDT: DateTime;
    begin
        Clear(CouponType);
        CouponType.SetRange("Issue Coupon Module",ModuleCode);
        //-NPR5.39 [305146]
        CouponType.SetRange(Enabled,true);
        //+NPR5.39 [305146]
        CheckDT := CurrentDateTime;
        CouponType.SetFilter("Starting Date",'<=%1',CheckDT);
        CouponType.SetFilter("Ending Date",'>=%1|%2',CheckDT,0DT);
        CouponType.SetFilter("Reference No. Pattern",'<>%1','');
        exit(CouponType.FindFirst);
    end;

    local procedure FindNewCoupons(SalePOS: Record "Sale POS";var NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon"): Boolean
    begin
        Clear(NpDcSaleLinePOSNewCoupon);
        NpDcSaleLinePOSNewCoupon.SetRange("Register No.",SalePOS."Register No.");
        NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        exit(NpDcSaleLinePOSNewCoupon.FindFirst);
    end;

    local procedure IssueOnSaleAchieved(SalePOS: Record "Sale POS";CouponType: Record "NpDc Coupon Type") NewCouponQty: Integer
    var
        NpDcIssueOnSaleSetup: Record "NpDc Issue On-Sale Setup";
        NpDcItemBuffer: Record "NpDc Item Buffer" temporary;
        SalesAmount: Decimal;
        ItemQty: Decimal;
    begin
        if not NpDcIssueOnSaleSetup.Get(CouponType.Code) then
          exit;

        //-NPR5.38 [298276]
        // SalePOS2DiscBuffer(SalePOS,CouponType,DiscountItemBuffer);
        // DiscountItemBuffer.CALCSUMS("Line Amount",Quantity);
        // CASE NpDcIssueOnSaleSetup.Type OF
        //  NpDcIssueOnSaleSetup.Type::"Item Sales Amount":
        //    NewCouponQty := DiscountItemBuffer."Line Amount" DIV NpDcIssueOnSaleSetup."Item Sales Amount";
        //  NpDcIssueOnSaleSetup.Type::"Item Sales Qty.":
        //    NewCouponQty := DiscountItemBuffer.Quantity DIV NpDcIssueOnSaleSetup."Item Sales Qty.";
        //  NpDcIssueOnSaleSetup.Type::Lot:
        //    BEGIN
        //      NewCouponQty := GetLotQty(NpDcIssueOnSaleSetup,DiscountItemBuffer);
        //    END;
        //  ELSE
        //    EXIT(0);
        // END;
        SalePOS2DiscBuffer(SalePOS,CouponType,NpDcItemBuffer);
        NpDcItemBuffer.CalcSums("Line Amount",Quantity);
        case NpDcIssueOnSaleSetup.Type of
          NpDcIssueOnSaleSetup.Type::"Item Sales Amount":
            NewCouponQty := NpDcItemBuffer."Line Amount" div NpDcIssueOnSaleSetup."Item Sales Amount";
          NpDcIssueOnSaleSetup.Type::"Item Sales Qty.":
            NewCouponQty := NpDcItemBuffer.Quantity div NpDcIssueOnSaleSetup."Item Sales Qty.";
          NpDcIssueOnSaleSetup.Type::Lot:
            begin
              NewCouponQty := GetLotQty(NpDcIssueOnSaleSetup,NpDcItemBuffer);
            end;
          else
            exit(0);
        end;
        //+NPR5.38 [298276]

        if (NewCouponQty > NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale") and (NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale" > 0) then
          NewCouponQty := NpDcIssueOnSaleSetup."Max. Allowed Issues per Sale";

        exit(NewCouponQty);
    end;

    local procedure GetLotQty(NpDcIssueOnSaleSetup: Record "NpDc Issue On-Sale Setup";var NpDcItemBuffer: Record "NpDc Item Buffer" temporary) LotQty: Decimal
    var
        NpDcIssueOnSaleSetupLine: Record "NpDc Issue On-Sale Setup Line";
        LotLineQty: Decimal;
    begin
        NpDcIssueOnSaleSetupLine.SetRange("Coupon Type",NpDcIssueOnSaleSetup."Coupon Type");
        NpDcIssueOnSaleSetupLine.SetFilter("No.",'<>%1','');
        NpDcIssueOnSaleSetupLine.SetFilter("Lot Quantity",'>%1',0);
        if not NpDcIssueOnSaleSetupLine.FindSet then
          exit(0);

        repeat
          //-NPR5.38 [298276]
          // CLEAR(DiscountItemBuffer);
          // CASE NpDcIssueOnSaleSetupLine.Type OF
          //  NpDcIssueOnSaleSetupLine.Type::Item:
          //    DiscountItemBuffer.SETRANGE(Delete,NpDcIssueOnSaleSetupLine."No.");
          //  NpDcIssueOnSaleSetupLine.Type::"Item Group":
          //    DiscountItemBuffer.SETRANGE("Item Group",NpDcIssueOnSaleSetupLine."No.");
          //  NpDcIssueOnSaleSetupLine.Type::Item:
          //    DiscountItemBuffer.SETRANGE("Item Disc. Group",NpDcIssueOnSaleSetupLine."No.");
          // END;
          // DiscountItemBuffer.SETFILTER("Variant Code",NpDcIssueOnSaleSetupLine."Variant Code");
          //  DiscountItemBuffer.CALCSUMS(Quantity);
          //
          // LotLineQty := DiscountItemBuffer.Quantity DIV NpDcIssueOnSaleSetupLine."Lot Quantity";
          // IF LotLineQty <= 0 THEN
          //  EXIT(0);
          // IF (LotQty = 0) OR (LotLineQty < LotQty) THEN
          //  LotQty := LotLineQty;
          //
          // DiscountItemBuffer.DELETEALL;
          Clear(NpDcItemBuffer);
          case NpDcIssueOnSaleSetupLine.Type of
            NpDcIssueOnSaleSetupLine.Type::Item:
              NpDcItemBuffer.SetRange("Item No.",NpDcIssueOnSaleSetupLine."No.");
            NpDcIssueOnSaleSetupLine.Type::"Item Group":
              NpDcItemBuffer.SetRange("Item Group",NpDcIssueOnSaleSetupLine."No.");
            NpDcIssueOnSaleSetupLine.Type::"Item Disc. Group":
              NpDcItemBuffer.SetRange("Item Disc. Group",NpDcIssueOnSaleSetupLine."No.");
          end;
          NpDcItemBuffer.SetFilter("Variant Code",NpDcIssueOnSaleSetupLine."Variant Code");
          NpDcItemBuffer.CalcSums(Quantity);

          LotLineQty := NpDcItemBuffer.Quantity div NpDcIssueOnSaleSetupLine."Lot Quantity";
          if LotLineQty <= 0 then
          exit(0);
          if (LotQty = 0) or (LotLineQty < LotQty) then
          LotQty := LotLineQty;

          NpDcItemBuffer.DeleteAll;
          //+NPR5.38 [298276]
        until NpDcIssueOnSaleSetupLine.Next = 0;

        exit(LotQty);
    end;

    local procedure SalePOS2DiscBuffer(SalePOS: Record "Sale POS";CouponType: Record "NpDc Coupon Type";var NpDcItemBuffer: Record "NpDc Item Buffer" temporary): Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        NpDcIssueOnSaleSetupLine: Record "NpDc Issue On-Sale Setup Line";
    begin
        //-NPR5.38 [298276]
        // DiscountItemBuffer.DELETEALL;
        //
        // NpDcIssueOnSaleSetupLine.SETRANGE("Coupon Type",CouponType.Code);
        // NpDcIssueOnSaleSetupLine.SETFILTER("No.",'<>%1','');
        // IF NOT NpDcIssueOnSaleSetupLine.FINDSET THEN BEGIN
        //  SaleLinePOS.SETRANGE("Register No.",SalePOS."Register No.");
        //  SaleLinePOS.SETRANGE("Sales Ticket No.",SalePOS."Sales Ticket No.");
        //  SaleLinePOS.SETRANGE(Type,SaleLinePOS.Type::Item);
        //  SaleLinePOS.SETFILTER(Quantity,'>%1',0);
        //  SaleLinePOS2DiscBuffer(SaleLinePOS,DiscountItemBuffer);
        //  EXIT;
        // END;
        //
        // REPEAT
        //  CLEAR(SaleLinePOS);
        //  SaleLinePOS.SETRANGE("Register No.",SalePOS."Register No.");
        //  SaleLinePOS.SETRANGE("Sales Ticket No.",SalePOS."Sales Ticket No.");
        //  SaleLinePOS.SETRANGE(Type,SaleLinePOS.Type::Item);
        //  SaleLinePOS.SETFILTER("Variant Code",NpDcIssueOnSaleSetupLine."Variant Code");
        //  SaleLinePOS.SETFILTER(Quantity,'>%1',0);
        //  CASE NpDcIssueOnSaleSetupLine.Type OF
        //    NpDcIssueOnSaleSetupLine.Type::Item:
        //      SaleLinePOS.SETRANGE("No.",NpDcIssueOnSaleSetupLine."No.");
        //    NpDcIssueOnSaleSetupLine.Type::"Item Group":
        //      SaleLinePOS.SETRANGE("Item Group",NpDcIssueOnSaleSetupLine."No.");
        //    NpDcIssueOnSaleSetupLine.Type::Item:
        //      SaleLinePOS.SETRANGE("Item Disc. Group",NpDcIssueOnSaleSetupLine."No.");
        //  END;
        //  SaleLinePOS2DiscBuffer(SaleLinePOS,DiscountItemBuffer);
        // UNTIL NpDcIssueOnSaleSetupLine.NEXT = 0;
        NpDcItemBuffer.DeleteAll;

        NpDcIssueOnSaleSetupLine.SetRange("Coupon Type",CouponType.Code);
        NpDcIssueOnSaleSetupLine.SetFilter("No.",'<>%1','');
        if not NpDcIssueOnSaleSetupLine.FindSet then begin
          SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
          SaleLinePOS.SetFilter(Quantity,'>%1',0);
          SaleLinePOS2DiscBuffer(SaleLinePOS,NpDcItemBuffer);
          exit;
        end;

        repeat
          Clear(SaleLinePOS);
          SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
          SaleLinePOS.SetFilter("Variant Code",NpDcIssueOnSaleSetupLine."Variant Code");
          SaleLinePOS.SetFilter(Quantity,'>%1',0);
          case NpDcIssueOnSaleSetupLine.Type of
            NpDcIssueOnSaleSetupLine.Type::Item:
              SaleLinePOS.SetRange("No.",NpDcIssueOnSaleSetupLine."No.");
            NpDcIssueOnSaleSetupLine.Type::"Item Group":
              SaleLinePOS.SetRange("Item Group",NpDcIssueOnSaleSetupLine."No.");
            NpDcIssueOnSaleSetupLine.Type::"Item Disc. Group":
              SaleLinePOS.SetRange("Item Disc. Group",NpDcIssueOnSaleSetupLine."No.");
          end;
          SaleLinePOS2DiscBuffer(SaleLinePOS,NpDcItemBuffer);
        until NpDcIssueOnSaleSetupLine.Next = 0;
        //+NPR5.38 [298276]
    end;

    local procedure SaleLinePOS2DiscBuffer(var SaleLinePOS: Record "Sale Line POS";var NpDcItemBuffer: Record "NpDc Item Buffer" temporary): Decimal
    begin
        //-NPR5.38 [298276]
        // IF NOT SaleLinePOS.FINDSET THEN
        //  EXIT;
        //
        // REPEAT
        //  IF DiscountItemBuffer.GET(SaleLinePOS."No.",SaleLinePOS."Variant Code",
        //                            SaleLinePOS."Item Group",SaleLinePOS."Item Disc. Group",SaleLinePOS."Unit Price",0,'') THEN BEGIN
        //    DiscountItemBuffer.Quantity += SaleLinePOS.Quantity;
        //    DiscountItemBuffer."Line Amount" += SaleLinePOS."Amount Including VAT";
        //    DiscountItemBuffer.MODIFY;
        //  END ELSE BEGIN
        //    DiscountItemBuffer.INIT;
        //    DiscountItemBuffer.Delete := SaleLinePOS."No.";
        //    DiscountItemBuffer."Variant Code" := SaleLinePOS."Variant Code";
        //    DiscountItemBuffer."Item Group" := SaleLinePOS."Item Group";
        //    DiscountItemBuffer."Item Disc. Group" := SaleLinePOS."Item Disc. Group";
        //    DiscountItemBuffer."Unit Price" := SaleLinePOS."Unit Price";
        //    DiscountItemBuffer."Discount Type" := 0;
        //    DiscountItemBuffer."Discount Code" := '';
        //    DiscountItemBuffer.Quantity := SaleLinePOS.Quantity;
        //    DiscountItemBuffer."Line Amount" := SaleLinePOS."Amount Including VAT";
        //    DiscountItemBuffer.INSERT;
        //  END;
        // UNTIL SaleLinePOS.NEXT = 0;
        if not SaleLinePOS.FindSet then
          exit;

        repeat
          if NpDcItemBuffer.Get(SaleLinePOS."No.",SaleLinePOS."Variant Code",
                                    SaleLinePOS."Item Group",SaleLinePOS."Item Disc. Group",SaleLinePOS."Unit Price",0,'') then begin
            NpDcItemBuffer.Quantity += SaleLinePOS.Quantity;
            NpDcItemBuffer."Line Amount" += SaleLinePOS."Amount Including VAT";
            NpDcItemBuffer.Modify;
          end else begin
            NpDcItemBuffer.Init;
            NpDcItemBuffer."Item No." := SaleLinePOS."No.";
            NpDcItemBuffer."Variant Code" := SaleLinePOS."Variant Code";
            NpDcItemBuffer."Item Group" := SaleLinePOS."Item Group";
            NpDcItemBuffer."Item Disc. Group" := SaleLinePOS."Item Disc. Group";
            NpDcItemBuffer."Unit Price" := SaleLinePOS."Unit Price";
            NpDcItemBuffer."Discount Type" := 0;
            NpDcItemBuffer."Discount Code" := '';
            NpDcItemBuffer.Quantity := SaleLinePOS.Quantity;
            NpDcItemBuffer."Line Amount" := SaleLinePOS."Amount Including VAT";
            NpDcItemBuffer.Insert;
          end;
        until SaleLinePOS.Next = 0;
        //+NPR5.38 [298276]
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon",ModuleCode()) then
          exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasIssueCouponSetup', '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NpDc Coupon Type";var HasIssueSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
          exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NpDc Coupon Type")
    var
        NpDcIssueOnSaleSetup: Record "NpDc Issue On-Sale Setup";
    begin
        if not IsSubscriber(CouponType) then
          exit;

        if not NpDcIssueOnSaleSetup.Get(CouponType.Code) then begin
          NpDcIssueOnSaleSetup.Init;
          NpDcIssueOnSaleSetup."Coupon Type" := CouponType.Code;
          NpDcIssueOnSaleSetup.Insert;
        end;

        PAGE.Run(PAGE::"NpDc Issue On-Sale Setup",NpDcIssueOnSaleSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NpDc Coupon Type";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(CouponType) then
          exit;

        Handled := true;

        Error(Text001);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure TriggerOnSaleCoupon(SaleLinePOS: Record "Sale Line POS";var SalePOS: Record "Sale POS"): Boolean
    begin
        if SaleLinePOS.IsTemporary then
          exit(false);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit(false);

        exit(SalePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No."));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpDc Module Issue - On-Sale");
    end;

    local procedure IsSubscriber(CouponType: Record "NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('ON-SALE');
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.43 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        case Rec."Subscriber Function" of
          'AddNewOnSaleCoupons':
            begin
              Rec.Description := Text006;
              Rec."Sequence No." := 40;
            end;
        end;
        //+NPR5.43 [319425]
    end;
}

