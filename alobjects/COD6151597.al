codeunit 6151597 "NpDc Module Validate - Item L."
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.38/MHA /20180105  CASE 301053 Corrected CASE for "Item Disc. Group" in SaleLinePOSItemExists()
    // NPR5.46/MHA /20180925  CASE 327366 Added Validation Quantity


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Coupon is not Valid';
        Text001: Label 'Coupon is being used';
        Text002: Label 'Max Use per Sale is %1';
        Text003: Label 'Coupon Items have not been defined on Coupon %1 (%2)';
        Text004: Label 'None of the Coupon Items have been added to the Sale';
        Text005: Label 'Not all required Coupon Items have been added to the Sale';

    procedure ValidateCoupon(SalePOS: Record "Sale POS";Coupon: Record "NpDc Coupon")
    var
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        NpDcCouponListItemTotal: Record "NpDc Coupon List Item";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcModuleValidateDefault: Codeunit "NpDc Module Validate - Default";
    begin
        NpDcModuleValidateDefault.ValidateCoupon(SalePOS,Coupon);

        if not FindCouponListItems(Coupon,NpDcCouponListItem) then
          Error(Text003,Coupon."No.",Coupon."Coupon Type");

        //-NPR5.46 [327366]
        // NpDcCouponListItem.FINDSET;
        // REPEAT
        //  IF SaleLinePOSItemExists(SalePOS,Coupon,NpDcCouponListItem) THEN
        //    EXIT;
        // UNTIL NpDcCouponListItem.NEXT = 0;
        // ERROR(Text004);
        if NpDcCouponListItemTotal.Get(Coupon."Coupon Type",-1) then begin
          if NpDcCouponListItemTotal."Lot Validation" then begin
            ValidateCouponLot(SalePOS,NpDcCouponListItem);
            exit;
          end;

          if NpDcCouponListItemTotal."Validation Quantity" > 0 then begin
            ValidateCouponQuantity(SalePOS,NpDcCouponListItem,NpDcCouponListItemTotal."Validation Quantity");
            exit;
          end;
        end;

        ValidateCouponExists(SalePOS,NpDcCouponListItem);
        //+NPR5.46 [327366]
    end;

    local procedure ValidateCouponLot(SalePOS: Record "Sale POS";var NpDcCouponListItem: Record "NpDc Coupon List Item")
    var
        LineQty: Decimal;
    begin
        //-NPR5.46 [327366]
        NpDcCouponListItem.FindSet;
        repeat
          LineQty := CalcSaleLinePOSItemQty(SalePOS,NpDcCouponListItem);
          if LineQty < NpDcCouponListItem."Validation Quantity" then
            Error(Text005);
        until NpDcCouponListItem.Next = 0;
        //+NPR5.46 [327366]
    end;

    local procedure ValidateCouponQuantity(SalePOS: Record "Sale POS";var NpDcCouponListItem: Record "NpDc Coupon List Item";var ValidationQty: Decimal)
    var
        TotalQty: Decimal;
    begin
        //-NPR5.46 [327366]
        NpDcCouponListItem.FindSet;
        repeat
          TotalQty += CalcSaleLinePOSItemQty(SalePOS,NpDcCouponListItem);
          if TotalQty >= ValidationQty then
            exit;
        until NpDcCouponListItem.Next = 0;
        if TotalQty < ValidationQty then
          Error(Text005);
        //+NPR5.46 [327366]
    end;

    local procedure ValidateCouponExists(SalePOS: Record "Sale POS";var NpDcCouponListItem: Record "NpDc Coupon List Item")
    begin
        //-NPR5.46 [327366]
        NpDcCouponListItem.FindSet;
        repeat
          if SaleLinePOSItemExists(SalePOS,NpDcCouponListItem) then
            exit;
        until NpDcCouponListItem.Next = 0;
        Error(Text004);
        //+NPR5.46 [327366]
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Validate Coupon",ModuleCode()) then
          exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Validate Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := 'Validate Coupon - Item List';
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasValidateCouponSetup', '', true, true)]
    local procedure OnHasValidateCouponSetup(CouponType: Record "NpDc Coupon Type";var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
          exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupValidateCoupon', '', true, true)]
    local procedure OnSetupValidateCoupon(var CouponType: Record "NpDc Coupon Type")
    var
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        NpDcCouponListItems: Page "NpDc Coupon List Items";
    begin
        if not IsSubscriber(CouponType) then
          exit;

        NpDcCouponListItem.FilterGroup(2);
        NpDcCouponListItem.SetRange("Coupon Type",CouponType.Code);
        NpDcCouponListItem.FilterGroup(0);
        //-NPR5.46 [327366]
        //PAGE.RUN(PAGE::"NpDc Coupon List Items",NpDcCouponListItem);
        NpDcCouponListItems.SetTableView(NpDcCouponListItem);
        NpDcCouponListItems.SetValidationView(true);
        NpDcCouponListItems.Run;
        //+NPR5.46 [327366]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunValidateCoupon', '', true, true)]
    local procedure OnRunValidateCoupon(SalePOS: Record "Sale POS";Coupon: Record "NpDc Coupon";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriberCoupon(Coupon) then
          exit;

        Handled := true;

        ValidateCoupon(SalePOS,Coupon);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpDc Module Validate - Item L.");
    end;

    local procedure FindCouponListItems(Coupon: Record "NpDc Coupon";var NpDcCouponListItem: Record "NpDc Coupon List Item"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type",Coupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.",'<>%1','');
        exit(NpDcCouponListItem.FindFirst);
    end;

    local procedure SaleLinePOSItemExists(SalePOS: Record "Sale POS";NpDcCouponListItem: Record "NpDc Coupon List Item"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
          NpDcCouponListItem.Type::Item:
            begin
              SaleLinePOS.SetRange("No.",NpDcCouponListItem."No.");
            end;
          NpDcCouponListItem.Type::"Item Group":
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Group",NpDcCouponListItem."No.");
            end;
          //-NPR5.38 [301053]
          //NpDcCouponListItem.Type::Item:
          NpDcCouponListItem.Type::"Item Disc. Group":
          //+NPR5.38 [301053]
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Disc. Group",NpDcCouponListItem."No.");
            end;
        end;
        SaleLinePOS.SetFilter(Quantity,'>%1',0);
        exit(SaleLinePOS.FindFirst);
    end;

    local procedure CalcSaleLinePOSItemQty(SalePOS: Record "Sale POS";NpDcCouponListItem: Record "NpDc Coupon List Item"): Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.46 [327366]
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
          NpDcCouponListItem.Type::Item:
            begin
              SaleLinePOS.SetRange("No.",NpDcCouponListItem."No.");
            end;
          NpDcCouponListItem.Type::"Item Group":
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Group",NpDcCouponListItem."No.");
            end;
          NpDcCouponListItem.Type::"Item Disc. Group":
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Disc. Group",NpDcCouponListItem."No.");
            end;
        end;
        SaleLinePOS.SetFilter(Quantity,'>%1',0);
        if not SaleLinePOS.FindFirst then
          exit(0);

        SaleLinePOS.CalcSums(Quantity);
        exit(SaleLinePOS.Quantity);
        //+NPR5.46 [327366]
    end;

    local procedure IsSubscriber(CouponType: Record "NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Validate Coupon Module" = ModuleCode());
    end;

    local procedure IsSubscriberCoupon(Coupon: Record "NpDc Coupon"): Boolean
    begin
        Coupon.CalcFields("Validate Coupon Module");
        exit(Coupon."Validate Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('ITEM_LIST');
    end;
}

