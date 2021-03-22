codeunit 6014480 "NPR NpDc Mod. Val. Item L. M."
{
    Description = 'Coupon Module Validation Item List with Magento Brand support';

    var
        Text003: Label 'Coupon Items have not been defined on Coupon %1 (%2)';
        Text004: Label 'None of the Coupon Items have been added to the Sale';
        Text005: Label 'Not all required Coupon Items have been added to the Sale';

    procedure ValidateCoupon(SalePOS: Record "NPR Sale POS"; Coupon: Record "NPR NpDc Coupon")
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        NpDcCouponListItemTotal: Record "NPR NpDc Coupon List Item";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
    begin
        NpDcModuleValidateDefault.ValidateCoupon(SalePOS, Coupon);

        if not FindCouponListItems(Coupon, NpDcCouponListItem) then
            Error(Text003, Coupon."No.", Coupon."Coupon Type");

        if NpDcCouponListItemTotal.Get(Coupon."Coupon Type", -1) then begin
            if NpDcCouponListItemTotal."Lot Validation" then begin
                ValidateCouponLot(SalePOS, NpDcCouponListItem);
                exit;
            end;

            if NpDcCouponListItemTotal."Validation Quantity" > 0 then begin
                ValidateCouponQuantity(SalePOS, NpDcCouponListItem, NpDcCouponListItemTotal."Validation Quantity");
                exit;
            end;
        end;

        ValidateCouponExists(SalePOS, NpDcCouponListItem);
    end;

    local procedure ValidateCouponLot(SalePOS: Record "NPR Sale POS"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item")
    var
        LineQty: Decimal;
    begin
        NpDcCouponListItem.FindSet;
        repeat
            LineQty := CalcSaleLinePOSItemQty(SalePOS, NpDcCouponListItem);
            if LineQty < NpDcCouponListItem."Validation Quantity" then
                Error(Text005);
        until NpDcCouponListItem.Next = 0;
    end;

    local procedure ValidateCouponQuantity(SalePOS: Record "NPR Sale POS"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var ValidationQty: Decimal)
    var
        TotalQty: Decimal;
    begin
        NpDcCouponListItem.FindSet;
        repeat
            TotalQty += CalcSaleLinePOSItemQty(SalePOS, NpDcCouponListItem);
            if TotalQty >= ValidationQty then
                exit;
        until NpDcCouponListItem.Next = 0;
        if TotalQty < ValidationQty then
            Error(Text005);
    end;

    local procedure ValidateCouponExists(SalePOS: Record "NPR Sale POS"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item")
    begin
        NpDcCouponListItem.FindSet;
        repeat
            if SaleLinePOSItemExists(SalePOS, NpDcCouponListItem) then
                exit;
        until NpDcCouponListItem.Next = 0;
        Error(Text004);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Validate Coupon", ModuleCode()) then
            exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Validate Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := CopyStr('Val. Coupon - Item Lst. Magento', 1, MaxStrLen(CouponModule.Description));
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnHasValidateCouponSetup', '', true, true)]
    local procedure OnHasValidateCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupValidateCoupon', '', true, true)]
    local procedure OnSetupValidateCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        NpDcCouponListItems: Page "NPR NpDc Coupon List Items";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        NpDcCouponListItem.FilterGroup(2);
        NpDcCouponListItem.SetRange("Coupon Type", CouponType.Code);
        NpDcCouponListItem.FilterGroup(0);
        NpDcCouponListItems.SetTableView(NpDcCouponListItem);
        NpDcCouponListItems.SetValidationView(true);
        NpDcCouponListItems.Run;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnRunValidateCoupon', '', true, true)]
    local procedure OnRunValidateCoupon(SalePOS: Record "NPR Sale POS"; Coupon: Record "NPR NpDc Coupon"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriberCoupon(Coupon) then
            exit;

        Handled := true;

        ValidateCoupon(SalePOS, Coupon);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Mod. Val. Item L. M.");
    end;

    local procedure FindCouponListItems(Coupon: Record "NPR NpDc Coupon"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type", Coupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.", '<>%1', '');
        exit(NpDcCouponListItem.FindFirst);
    end;

    local procedure SaleLinePOSItemExists(SalePOS: Record "NPR Sale POS"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
            NpDcCouponListItem.Type::Item:
                begin
                    SaleLinePOS.SetRange("No.", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Group":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Category Code", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Disc. Group":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Disc. Group", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Magento Brand":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Magento Brand", NpDcCouponListItem."No.");
                end;
        end;
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        exit(SaleLinePOS.FindFirst);
    end;

    local procedure CalcSaleLinePOSItemQty(SalePOS: Record "NPR Sale POS"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
            NpDcCouponListItem.Type::Item:
                begin
                    SaleLinePOS.SetRange("No.", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Group":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Category Code", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Disc. Group":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Disc. Group", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Magento Brand":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Magento Brand", NpDcCouponListItem."No.");
                end;
        end;
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        if not SaleLinePOS.FindFirst then
            exit(0);

        SaleLinePOS.CalcSums(Quantity);
        exit(SaleLinePOS.Quantity);
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Validate Coupon Module" = ModuleCode());
    end;

    local procedure IsSubscriberCoupon(Coupon: Record "NPR NpDc Coupon"): Boolean
    begin
        Coupon.CalcFields("Validate Coupon Module");
        exit(Coupon."Validate Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('ITEM_LIST_MAG');
    end;
}

