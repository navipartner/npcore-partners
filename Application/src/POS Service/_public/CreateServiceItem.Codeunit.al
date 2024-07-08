codeunit 6059838 "NPR Create Service Item"
{
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        GLSetup: Record "General Ledger Setup";

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"; Item: Record Item)
    begin
        IF SkipCreatingServiceItem(POSSaleLine, POSSale, Item) then
            exit;
        CopyFromPOS(POSSaleLine, POSSale);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure CreateDeleteServiceItem(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        Item: Record Item;
    begin
        if SkipCreatingDeletingServiceItem(POSEntrySalesLine, POSEntry, Item) then
            exit;

        if POSEntrySalesLine.Quantity > 0 then
            CreateServiceItem(POSEntry, POSEntrySalesLine, Item)
        else
            DeleteServiceItem(POSEntry, POSEntrySalesLine);
    end;

    local procedure CopyFromPOS(POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    var
        ServiceItem: Record "Service Item";
        RunTrigger: Boolean;
    begin
        RunTrigger := true;
        ServiceItem.Init();
        OnAfterInitBeforeInsert(ServiceItem, POSSaleLine, POSSale, RunTrigger);
        ServiceItem.Insert(true);
        ServiceItem.Validate("Item No.", POSSaleLine."No.");
        ServiceItem.Validate("Serial No.", POSSaleLine."Serial No.");
        ServiceItem.Validate(Status, ServiceItem.Status::Installed);
        ServiceItem.Validate("Warranty Starting Date (Labor)", POSSale.Date);
        ServiceItem.Validate("Warranty Ending Date (Labor)", CalcDate('<+1Y>', POSSale.Date));
        ServiceItem.Validate("Customer No.", POSSale."Customer No.");
        ServiceItem.Validate("Unit of Measure Code", POSSaleLine."Unit of Measure Code");
        ServiceItem.Validate("Sales Date", POSSale.Date);
        OnBeforeModifyServiceItemFromActivePOSSale(ServiceItem, POSSaleLine, POSSale);
        ServiceItem.Modify();
    end;

    [Obsolete('Replaced by CreateServiceItem(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; Item: Record Item)', 'NPR23.0')]
    procedure CreateServiceItem(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin

    end;


    [CommitBehavior(CommitBehavior::Error)]
    procedure CreateServiceItem(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; Item: Record Item)
    var
        ServiceItem: Record "Service Item";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        ServLogMgt: Codeunit ServLogManagement;
        TrackingLinesExist: Boolean;
        ServItemWithSerialNoExist: Boolean;
        NoOfServiceItems: Integer;
        ServItemLbl: Label '%1 / %2 / %3', Locked = true;
    begin
        ServiceMgtSetup.Get();
        GLSetup.Get();
        TrackingLinesExist := POSEntrySalesLine."Serial No." <> '';

        for NoOfServiceItems := 1 to POSEntrySalesLine.Quantity do begin
            Clear(ServiceItem);

            ServItemWithSerialNoExist := false;
            if TrackingLinesExist then begin
                ServiceItem.SetRange("Item No.", POSEntrySalesLine."No.");
                ServiceItem.SetRange("Serial No.", POSEntrySalesLine."Serial No.");
                ServItemWithSerialNoExist := ServiceItem.FindFirst();
            end;

            if (not TrackingLinesExist) or (not ServItemWithSerialNoExist) then begin
                ServiceItem.Init();
                ServiceMgtSetup.TestField("Service Item Nos.");
                NoSeriesMgt.InitSeries(ServiceMgtSetup."Service Item Nos.", ServiceItem."No. Series", 0D, ServiceItem."No.", ServiceItem."No. Series");
                ServiceItem.Insert();
            end;

            POSEntrySalesDocLink.LinkServiceItem2Line(POSEntry."Entry No.", POSEntrySalesLine."Line No.", ServiceItem."No.");

            ServiceItem."Shipment Type" := ServiceItem."Shipment Type"::Sales;
            ServiceItem.Validate(Description, CopyStr(POSEntrySalesLine.Description, 1, MaxStrLen(ServiceItem.Description)));
            ServiceItem."Description 2" := CopyStr(StrSubstNo(ServItemLbl, POSEntrySalesLine."POS Store Code", POSEntrySalesLine."POS Unit No.", POSEntrySalesLine."Document No."), 1, MaxStrLen(ServiceItem."Description 2"));

            ServiceItem.Validate("Customer No.", POSEntry."Customer No.");

            ServiceItem.OmitAssignResSkills(true);
            ServiceItem.Validate("Item No.", Item."No.");
            ServiceItem.OmitAssignResSkills(false);

            if TrackingLinesExist then
                ServiceItem."Serial No." := POSEntrySalesLine."Serial No.";

            ServiceItem."Variant Code" := POSEntrySalesLine."Variant Code";
            ItemUnitOfMeasure.Get(Item."No.", POSEntrySalesLine."Unit of Measure Code");
            ServiceItem.Validate("Sales Unit Cost", Round(POSEntrySalesLine."Unit Cost (LCY)" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            if POSEntry."Currency Code" <> '' then
                ServiceItem.Validate("Sales Unit Price", AmountToLCY(
                                                            Round(POSEntrySalesLine."Unit Price" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"),
                                                            POSEntry."Currency Factor",
                                                            POSEntry."Currency Code",
                                                            POSEntry."Posting Date"))
            else
                ServiceItem.Validate("Sales Unit Price", Round(POSEntrySalesLine."Unit Price" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            ServiceItem."Vendor No." := Item."Vendor No.";
            ServiceItem."Vendor Item No." := Item."Vendor Item No.";
            ServiceItem."Unit of Measure Code" := Item."Base Unit of Measure";
            ServiceItem."Sales Date" := POSEntry."Posting Date";
            ServiceItem."Installation Date" := POSEntry."Posting Date";

            SetWarrantyParts(Item, ServiceItem, POSEntry);
            SetWarrantyLabor(Item, ServiceItem, POSEntry);

            OnBeforeModifyServiceItemFromPostedPOSSale(ServiceItem, Item, POSEntrySalesLine, POSEntry);

            ServiceItem.Modify();

            ResSkillMgt.AssignServItemResSkills(ServiceItem);

            CreateComponents(POSEntrySalesLine, POSEntry, ServiceItem);

            ServLogMgt.ServItemAutoCreated(ServiceItem);
        end;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        ServiceItem: Record "Service Item";
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        ServLogMgt: Codeunit ServLogManagement;
        TrackingLinesExist: Boolean;
        ServItemWithSerialNoExist: Boolean;
        NoOfServiceItems: Integer;
        ServItemLbl: Label '%1 / %2 / %3', Locked = true;
    begin
        if SkipCreatingServiceItem(POSEntrySalesLine, POSEntry, Item) then
            exit;

        ServiceMgtSetup.Get();
        GLSetup.Get();
        TrackingLinesExist := POSEntrySalesLine."Serial No." <> '';

        for NoOfServiceItems := 1 to POSEntrySalesLine.Quantity do begin
            Clear(ServiceItem);

            ServItemWithSerialNoExist := false;
            if TrackingLinesExist then begin
                ServiceItem.SetRange("Item No.", POSEntrySalesLine."No.");
                ServiceItem.SetRange("Serial No.", POSEntrySalesLine."Serial No.");
                ServItemWithSerialNoExist := ServiceItem.FindFirst();
            end;

            if (not TrackingLinesExist) or (not ServItemWithSerialNoExist) then begin
                ServiceItem.Init();
                ServiceMgtSetup.TestField("Service Item Nos.");
                NoSeriesMgt.InitSeries(ServiceMgtSetup."Service Item Nos.", ServiceItem."No. Series", 0D, ServiceItem."No.", ServiceItem."No. Series");
                ServiceItem.Insert();
            end;

            POSEntrySalesDocLink.LinkServiceItem2Line(POSEntry."Entry No.", POSEntrySalesLine."Line No.", ServiceItem."No.");

            ServiceItem."Shipment Type" := ServiceItem."Shipment Type"::Sales;
            ServiceItem.Validate(Description, CopyStr(POSEntrySalesLine.Description, 1, MaxStrLen(ServiceItem.Description)));
            ServiceItem."Description 2" := CopyStr(StrSubstNo(ServItemLbl, POSEntrySalesLine."POS Store Code", POSEntrySalesLine."POS Unit No.", POSEntrySalesLine."Document No."), 1, MaxStrLen(ServiceItem."Description 2"));

            ServiceItem.Validate("Customer No.", POSEntry."Customer No.");

            ServiceItem.OmitAssignResSkills(true);
            ServiceItem.Validate("Item No.", Item."No.");
            ServiceItem.OmitAssignResSkills(false);

            if TrackingLinesExist then
                ServiceItem."Serial No." := POSEntrySalesLine."Serial No.";

            ServiceItem."Variant Code" := POSEntrySalesLine."Variant Code";
            ItemUnitOfMeasure.Get(Item."No.", POSEntrySalesLine."Unit of Measure Code");
            ServiceItem.Validate("Sales Unit Cost", Round(POSEntrySalesLine."Unit Cost (LCY)" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            if POSEntry."Currency Code" <> '' then
                ServiceItem.Validate("Sales Unit Price", AmountToLCY(
                                                            Round(POSEntrySalesLine."Unit Price" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"),
                                                            POSEntry."Currency Factor",
                                                            POSEntry."Currency Code",
                                                            POSEntry."Posting Date"))
            else
                ServiceItem.Validate("Sales Unit Price", Round(POSEntrySalesLine."Unit Price" / ItemUnitOfMeasure."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));

            ServiceItem."Vendor No." := Item."Vendor No.";
            ServiceItem."Vendor Item No." := Item."Vendor Item No.";
            ServiceItem."Unit of Measure Code" := Item."Base Unit of Measure";
            ServiceItem."Sales Date" := POSEntry."Posting Date";
            ServiceItem."Installation Date" := POSEntry."Posting Date";

            SetWarrantyParts(Item, ServiceItem, POSEntry);
            SetWarrantyLabor(Item, ServiceItem, POSEntry);

            OnBeforeModifyServiceItemFromPostedPOSSale(ServiceItem, Item, POSEntrySalesLine, POSEntry);

            ServiceItem.Modify();

            ResSkillMgt.AssignServItemResSkills(ServiceItem);

            CreateComponents(POSEntrySalesLine, POSEntry, ServiceItem);

            ServLogMgt.ServItemAutoCreated(ServiceItem);
        end;
    end;

    local procedure SkipCreatingServiceItem(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; var Item: Record Item): Boolean
    var
        ServiceItemGroup: Record "Service Item Group";
        Skip, IsHandled : Boolean;
    begin
        OnBeforeCheckConditionsForCreatingServiceItemPostedSale(POSEntrySalesLine, POSEntry, IsHandled, Skip);
        if IsHandled then
            exit(Skip);

        if POSEntrySalesLine.Type <> POSEntrySalesLine.Type::Item then
            exit(true);

        if POSEntrySalesLine.Quantity <= 0 then
            exit(true);

        if POSEntrySalesLine.Quantity <> Round(POSEntrySalesLine.Quantity, 1) then
            exit(true);

        Item.Get(POSEntrySalesLine."No.");
        if Item."Service Item Group" = '' then
            exit(true);

        if not ServiceItemGroup.Get(Item."Service Item Group") then
            exit(true);

        if not ServiceItemGroup."Create Service Item" then
            exit(true);

        OnAfterCheckConditionsForCreatingServiceItem(Item, ServiceItemGroup, Skip);
        exit(Skip);
    end;

    local procedure SkipCreatingServiceItem(POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"; Item: Record Item): Boolean
    var
        ServiceItemGroup: Record "Service Item Group";
        ServiceNoCustErr: Label 'A Customer must be chosen, because the sale contains items which are to be transferred to service items.';
        Skip, IsHandled : Boolean;
    begin
        OnBeforeCheckConditionsForCreatingServiceItemActiveSale(POSSaleLine, POSSale, IsHandled, Skip);
        if IsHandled then
            exit(Skip);

        if Item."Service Item Group" = '' then
            exit(true);

        if POSSaleLine.Quantity <= 0 then
            exit(true);

        ServiceItemGroup.Get(Item."Service Item Group");

        if not ServiceItemGroup."Create Service Item" then
            exit(true);

        if not (POSSale."Customer No." <> '') then
            Error(ServiceNoCustErr);

        OnAfterCheckConditionsForCreatingServiceItem(Item, ServiceItemGroup, Skip);
        exit(Skip);
    end;

    local procedure SkipCreatingDeletingServiceItem(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; var Item: Record Item): Boolean
    var
        ServiceItemGroup: Record "Service Item Group";
        Skip, IsHandled : Boolean;
    begin
        OnBeforeCheckConditionsForCreateDeleteServiceItemPostedSale(POSEntrySalesLine, POSEntry, IsHandled, Skip);
        if IsHandled then
            exit(Skip);

        if POSEntrySalesLine.Type <> POSEntrySalesLine.Type::Item then
            exit(true);

        if POSEntrySalesLine.Quantity = 0 then
            exit(true);

        if POSEntrySalesLine.Quantity <> Round(POSEntrySalesLine.Quantity, 1) then
            exit(true);

        Item.Get(POSEntrySalesLine."No.");
        if Item."Service Item Group" = '' then
            exit(true);

        if not ServiceItemGroup.Get(Item."Service Item Group") then
            exit(true);

        if not ServiceItemGroup."Create Service Item" then
            exit(true);

        OnAfterCheckConditionsForCreateDeleteServiceItem(Item, ServiceItemGroup, Skip);
    end;

    local procedure SetWarrantyParts(Item: Record Item; var ServiceItem: Record "Service Item"; POSEntry: Record "NPR POS Entry")
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ServiceItem."Warranty % (Parts)" := ServiceMgtSetup."Warranty Disc. % (Parts)";
        ServiceItem."Warranty Starting Date (Parts)" := POSEntry."Posting Date";

        if ItemTrackingCode.Get(Item."Item Tracking Code") then
            ItemTrackingCode.Init();
        if Format(ItemTrackingCode."Warranty Date Formula") <> '' then
            ServiceItem."Warranty Ending Date (Parts)" := CalcDate(ItemTrackingCode."Warranty Date Formula", POSEntry."Posting Date")
        else
            ServiceItem."Warranty Ending Date (Parts)" := CalcDate(ServiceMgtSetup."Default Warranty Duration", POSEntry."Posting Date");

        OnAfterInitWarrantyParts(Item, ServiceItem, POSEntry, ItemTrackingCode, ServiceMgtSetup);
    end;

    local procedure SetWarrantyLabor(Item: Record Item; var ServiceItem: Record "Service Item"; POSEntry: Record "NPR POS Entry")
    begin
        ServiceItem."Warranty % (Labor)" := ServiceMgtSetup."Warranty Disc. % (Labor)";
        ServiceItem."Warranty Starting Date (Labor)" := POSEntry."Posting Date";
        ServiceItem."Warranty Ending Date (Labor)" := CalcDate(ServiceMgtSetup."Default Warranty Duration", POSEntry."Posting Date");

        OnAfterInitWarrantyLabor(Item, ServiceItem, POSEntry, ServiceMgtSetup);
    end;

    local procedure AmountToLCY(FCYAmount: Decimal; CurrencyFactor: Decimal; CurrencyCode: Code[10]; CurrencyDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        Currency.TestField("Unit-Amount Rounding Precision");
        exit(Round(CurrExchRate.ExchangeAmtFCYToLCY(CurrencyDate, CurrencyCode, FCYAmount, CurrencyFactor), Currency."Unit-Amount Rounding Precision"));
    end;

    local procedure CreateComponents(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; ServiceItem: Record "Service Item")
    var
        BOMComponent, BOMComponent2 : Record "BOM Component";
        ServItemComponent: Record "Service Item Component";
        NoOfServiceItemComponents, NextLineNo : Integer;
    begin
        if POSEntrySalesLine."BOM Item No." = '' then
            exit;

        BOMComponent.SetRange("Parent Item No.", POSEntrySalesLine."BOM Item No.");
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        BOMComponent.SetRange("No.", POSEntrySalesLine."No.");
        BOMComponent.SetRange("Installed in Line No.", 0);
        OnAfterSetBOMComponentFilter(BOMComponent, POSEntrySalesLine);

        if BOMComponent.FindSet() then
            repeat
                Clear(BOMComponent2);
                BOMComponent2.SetRange("Parent Item No.", POSEntrySalesLine."BOM Item No.");
                BOMComponent2.SetRange("Installed in Line No.", BOMComponent."Line No.");
                NextLineNo := 0;
                OnAfterSetInstalledInBOMComponentFilter(BOMComponent, POSEntrySalesLine);

                if BOMComponent2.FindSet() then
                    repeat
                        for NoOfServiceItemComponents := 1 to Round(BOMComponent2."Quantity per", 1) do begin
                            NextLineNo := NextLineNo + 10000;
                            CreateComponent(ServItemComponent, BOMComponent2, POSEntrySalesLine, POSEntry, ServiceItem, NextLineNo);
                            OnAfterCreateComponent(ServItemComponent, BOMComponent, BOMComponent2, POSEntrySalesLine, POSEntry, ServiceItem)
                        end;
                    until BOMComponent2.Next() = 0;
            until BOMComponent.Next() = 0;
    end;

    local procedure CreateComponent(var ServItemComponent: Record "Service Item Component"; BOMComponent: Record "BOM Component"; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; ServiceItem: Record "Service Item"; NextLineNo: Integer)
    begin
        ServItemComponent."Parent Service Item No." := ServiceItem."No.";
        ServItemComponent."Line No." := NextLineNo;
        ServItemComponent.Active := true;
        ServItemComponent.Init();
        ServItemComponent.Type := ServItemComponent.Type::Item;
        ServItemComponent."No." := BOMComponent."No.";
        ServItemComponent."Date Installed" := POSEntry."Posting Date";
        ServItemComponent.Description := CopyStr(BOMComponent.Description, 1, MaxStrLen(ServItemComponent.Description));
        ServItemComponent."Serial No." := '';
        ServItemComponent."Variant Code" := BOMComponent."Variant Code";
        OnBeforeInsertServiceItemComponent(ServItemComponent, BOMComponent, ServiceItem, POSEntrySalesLine);

        ServItemComponent.Insert();
    end;

    local procedure DeleteServiceItem(POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        ServItem: Record "Service Item";
    begin
        ServItem.SetRange("Item No.", POSEntrySalesLine."No.");
        ServItem.SetRange("Customer No.", POSEntry."Customer No.");
        ServItem.SetRange("Serial No.", POSEntrySalesLine."Serial No.");
        if ServItem.FindFirst() then
            if ServItem.CheckIfCanBeDeleted() <> '' then begin
                ServItem.Validate(Status, ServItem.Status::" ");
                ServItem.Modify(true);
            end else
                ServItem.Delete(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitBeforeInsert(var ServiceItem: Record "Service Item"; POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"; var RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyServiceItemFromActivePOSSale(var ServiceItem: Record "Service Item"; POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyServiceItemFromPostedPOSSale(var ServiceItem: Record "Service Item"; Item: Record Item; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckConditionsForCreatingServiceItem(Item: Record Item; ServiceItemGroup: Record "Service Item Group"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckConditionsForCreateDeleteServiceItem(Item: Record Item; ServiceItemGroup: Record "Service Item Group"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitWarrantyParts(Item: Record Item; var ServiceItem: Record "Service Item"; POSEntry: Record "NPR POS Entry"; ItemTrackingCode: Record "Item Tracking Code"; ServiceMgtSetup: Record "Service Mgt. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitWarrantyLabor(Item: Record Item; var ServiceItem: Record "Service Item"; POSEntry: Record "NPR POS Entry"; ServiceMgtSetup: Record "Service Mgt. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckConditionsForCreatingServiceItemActiveSale(POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"; var IsHandled: Boolean; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckConditionsForCreatingServiceItemPostedSale(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; var IsHandled: Boolean; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetBOMComponentFilter(var BOMComponent: Record "BOM Component"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetInstalledInBOMComponentFilter(var BOMComponent: Record "BOM Component"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertServiceItemComponent(var ServItemComponent: Record "Service Item Component"; BOMComponent: Record "BOM Component"; ServiceItem: Record "Service Item"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateComponent(ServItemComponent: Record "Service Item Component"; BOMComponent: Record "BOM Component"; BOMComponent2: Record "BOM Component"; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; ServiceItem: Record "Service Item")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckConditionsForCreateDeleteServiceItemPostedSale(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; var IsHandled: Boolean; Skip: Boolean)
    begin
    end;
}
