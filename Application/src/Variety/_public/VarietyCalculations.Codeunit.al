﻿codeunit 6059979 "NPR Variety Calculations"
{

    trigger OnRun()
    begin
    end;

    var
        BlankLocation: Label '<BLANK>';
        GrossRequirement: Decimal;
        PlannedOrderRcpt: Decimal;
        PlannedOrderReleases: Decimal;
        ProjAvailableBalance: Decimal;
        ExpectedInventory: Decimal;
        QtyAvailable: Decimal;
        QtyAvailabletoPromise: Decimal;
        CalculatedForVariant: Code[10];
        CalculatedForItem: Code[20];
        ScheduledReceipt: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupInventoryPerLocation(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        TempInvBuffer: Record "Inventory Buffer" temporary;
        Location: Record Location;
        Item: Record Item;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupInventoryPerLocation') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");
        if Location.FindSet(false) then
            repeat
                Item.SetRange("Location Filter", Location.Code);
                Item.CalcFields("Net Change");
                TempInvBuffer.Init();
                TempInvBuffer."Item No." := TMPVrtBuffer."Item No.";
                TempInvBuffer."Variant Code" := TMPVrtBuffer."Variant Code";
                TempInvBuffer."Location Code" := Location.Code;
                TempInvBuffer.Quantity := Item."Net Change";
                TempInvBuffer.Insert();
            until Location.Next() = 0;
        Item.SetFilter("Location Filter", '');
        Item.CalcFields("Net Change");
        if Item."Net Change" <> 0 then begin
            TempInvBuffer.Init();
            TempInvBuffer."Item No." := TMPVrtBuffer."Item No.";
            TempInvBuffer."Variant Code" := TMPVrtBuffer."Variant Code";
            TempInvBuffer."Location Code" := BlankLocation;
            TempInvBuffer.Quantity := Item."Net Change";
            TempInvBuffer.Insert();
        end;

        if UseReturnValue(CalledFrom, VrtFieldSetup) then begin
            if PAGE.RunModal(6059976, TempInvBuffer) = ACTION::LookupOK then
                FieldValue := TempInvBuffer."Location Code";
        end else
            PAGE.RunModal(6059976, TempInvBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupLocation(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        Location: Record Location;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupLocation') then
            exit;

        Location.SetRange(Code, FieldValue);
        if Location.FindFirst() then;
        Location.SetRange(Code);

        if UseReturnValue(CalledFrom, VrtFieldSetup) then begin
            if PAGE.RunModal(0, Location) = ACTION::LookupOK then
                FieldValue := Location.Code;
        end else
            PAGE.RunModal(0, Location);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupItemReference(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        ItemReference: Record "Item Reference";
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupItemReference') then
            exit;

        ItemReference.SetRange("Reference No.", FieldValue);
        if ItemReference.FindFirst() then;
        ItemReference.SetRange("Reference No.");

        if UseReturnValue(CalledFrom, VrtFieldSetup) then begin
            if PAGE.RunModal(0, ItemReference) = ACTION::LookupOK then
                FieldValue := ItemReference."Reference No.";
        end else
            PAGE.RunModal(0, ItemReference);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupAvailabilityByEvent(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item: Record Item;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupAvailabilityByEvent') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");

        ItemAvailFormsMgt.ShowItemAvailFromItem(Item, ItemAvailFormsMgt.ByEvent());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupAvailabilityByVariant(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item: Record Item;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupAvailabilityByVariant') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");

        ItemAvailFormsMgt.ShowItemAvailFromItem(Item, ItemAvailFormsMgt.ByVariant());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupAvailabilityByLocation(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item: Record Item;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupAvailabilityByLocation') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");

        ItemAvailFormsMgt.ShowItemAvailFromItem(Item, ItemAvailFormsMgt.ByLocation());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupAvailabilityByPeriod(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item: Record Item;
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupAvailabilityByPeriod') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");

        ItemAvailFormsMgt.ShowItemAvailFromItem(Item, ItemAvailFormsMgt.ByPeriod());
    end;

#IF NOT CLOUD
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownVarietyMatrix', '', true, false)]
    local procedure LookupAvailabilityByTimeLine(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    var
        Item: Record Item;
        ItemAvailByTimeline: Page "Item Availability by Timeline";
    begin
        if not CheckIsMe(CalledFrom, VrtFieldSetup, 'LookupAvailabilityByTimeLine') then
            exit;

        Item.Get(TMPVrtBuffer."Item No.");
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");

        ItemAvailByTimeline.SetItem(Item);
        ItemAvailByTimeline.Run();
    end;
#ENDIF

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetItemReference(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    var
        ItemRef: Record "Item Reference";
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetItemReference') then
            exit;

        ItemRef.SetRange("Item No.", TMPVrtBuffer."Item No.");
        ItemRef.SetRange("Variant Code", TMPVrtBuffer."Variant Code");
        if ItemRef.FindFirst() then
            FieldValue := ItemRef."Reference No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetQuantityAvailable(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetQuantityAvailable') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(QtyAvailable);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetExpectedInventory(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetExpectedInventory') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(ExpectedInventory);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetProjAvailableBalance(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetProjAvailableBalance') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(ProjAvailableBalance);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetPlannedOrderReleases(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetPlannedOrderReleases') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(PlannedOrderReleases);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetScheduledRcpt(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetScheduledRcpt') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(ScheduledReceipt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetPlannedOrderRcpt(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetPlannedOrderRcpt') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(PlannedOrderRcpt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetGrossRequirement(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetGrossRequirement') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(GrossRequirement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetQuantityAvailableToPromise(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    var
        AvailableToPromise: Codeunit "Available to Promise";
#IF (BC17 or BC18 or BC19 or BC20)
        PeriodType: Option Day,Week,Month,Quarter,Year;
#else
        PeriodType: Enum "Analysis Period Type";
#endif
        AvailabilityDate: Date;
        LookaheadDateformula: DateFormula;
        Item: Record Item;
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetQuantityAvailableToPromise') then
            exit;

        Item.Get(ItemFilters."No.");
        Item.Reset();
        if ItemFilters.GetFilter("Date Filter") = '' then
            Item.SetRange("Date Filter", 0D, WorkDate())
        else
            Item.SetRange("Date Filter", 0D, ItemFilters.GetRangeMax("Date Filter"));
        Item.SetRange("Variant Filter", TMPVrtBuffer."Variant Code");
        Item.SetRange("Location Filter", ItemFilters.GetFilter("Location Filter"));
        Item.SetRange("Drop Shipment Filter", false);

        FieldValue := Format(
#IF (BC17 or BC18 or BC19 or BC20)
          AvailableToPromise.QtyAvailabletoPromise(
#else
        AvailableToPromise.CalcQtyAvailabletoPromise(
#endif
            Item,
            GrossRequirement,
            ScheduledReceipt,
            AvailabilityDate,
            PeriodType,
            LookaheadDateformula));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'GetVarietyMatrixFieldValue', '', true, false)]
    local procedure GetQuantityAvailableToPromise2(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
        if not CheckIsMe2(CalledFrom, VrtFieldSetup, 'GetQuantityAvailableToPromise2') then
            exit;

        CalcAvailQuantities(ItemFilters, TMPVrtBuffer."Variant Code");

        FieldValue := Format(QtyAvailabletoPromise);
    end;

    internal procedure UseReturnValue(CalledFrom: Option OnDrillDown,OnLookup; VrtFieldSetup: Record "NPR Variety Field Setup"): Boolean
    begin
        exit(((CalledFrom = CalledFrom::OnDrillDown) and VrtFieldSetup."Use OnDrillDown Return Value") or
              ((CalledFrom = CalledFrom::OnLookup) and VrtFieldSetup."Use OnLookup Return Value"));
    end;

    procedure CheckIsMe(CalledFrom: Option OnDrillDown,OnLookup; VrtFieldSetup: Record "NPR Variety Field Setup"; CurrFunctionName: Text): Boolean
    begin
        if (CalledFrom = CalledFrom::OnDrillDown) and (VrtFieldSetup."OnDrillDown Subscriber" = CurrFunctionName) then
            exit(true);

        if (CalledFrom = CalledFrom::OnLookup) and (VrtFieldSetup."OnLookup Subscriber" = CurrFunctionName) then
            exit(true);

        exit(false);
    end;

    procedure CheckIsMe2(CalledFrom: Option PrimaryField,SecondaryField; VrtFieldSetup: Record "NPR Variety Field Setup"; CurrFunctionName: Text): Boolean
    begin
        if (CalledFrom = CalledFrom::PrimaryField) and (VrtFieldSetup."Variety Matrix Subscriber 1" = CurrFunctionName) then
            exit(true);

        if (CalledFrom = CalledFrom::SecondaryField) and (VrtFieldSetup."Variety Matrix Subscriber 2" = CurrFunctionName) then
            exit(true);

        exit(false);
    end;

    local procedure CalcAvailQuantities(var Item: Record Item; VariantCode: Code[10])
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item2: Record Item;
    begin
        if ((CalculatedForItem = Item."No.") and (CalculatedForVariant = VariantCode)) then
            exit;

        CalculatedForItem := Item."No.";
        CalculatedForVariant := VariantCode;
        /*
        EVALUATE(LookaheadDateformula, '<+1Y>');
        Item2.GET(Item."No.");
        Item2.Reset();
        IF Item.GETFILTER("Date Filter") = '' THEN
          Item2.SETRANGE("Date Filter",0D, WorkDate())
        ELSE
          Item2.SETRANGE("Date Filter",0D, Item.GETRANGEMAX("Date Filter"));
        Item2.SETRANGE("Variant Filter", VariantCode);
        Item2.SETRANGE("Location Filter",Item.GETFILTER("Location Filter"));
        Item2.SETRANGE("Drop Shipment Filter",FALSE);
        
        QtyAvailabletoPromise := AvailableToPromise.QtyAvailabletoPromise(
            Item2,
            GrossRequirement,
            ScheduledReceipt,
            WORKDATE,
            PeriodType,
            LookaheadDateformula);
        
        
        EXIT;
        */
        Item2.Copy(Item);
        Item2.SetFilter("Variant Filter", VariantCode);
        Item2.SetFilter("Date Filter", '%1..%2', Item.GetRangeMax("Date Filter"), 99991231D);
        ItemAvailFormsMgt.CalcAvailQuantities(Item2, false, GrossRequirement, PlannedOrderRcpt, ScheduledReceipt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);

    end;
}

