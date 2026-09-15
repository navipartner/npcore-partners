codeunit 6151194 "NPR Spfy Change Tracker Mgt."
{
    Access = Internal;

    procedure RegisterEnabledTables()
    var
        EnabledTables: List of [Integer];
    begin
        RegisterEnabledTables(EnabledTables);
    end;

    // Returns the set of tables registered this cycle so RunDetection polls only currently-enabled areas.
    procedure RegisterEnabledTables(var EnabledTables: List of [Integer])
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        Clear(EnabledTables);
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items) then
            RegisterItemsPolledTables(EnabledTables);
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
            RegisterInventoryPolledTables(EnabledTables);
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices") then
            RegisterItemPricesPolledTables(EnabledTables);
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders") then
            RegisterCustomerPolledTables(EnabledTables);
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers") then
            RegisterVouchersPolledTables(EnabledTables);
    end;

    procedure RegisterArea(IntegrationArea: Enum "NPR Spfy Integration Area")
    var
        EnabledTables: List of [Integer];
    begin
        case IntegrationArea of
            "NPR Spfy Integration Area"::Items:
                RegisterItemsPolledTables(EnabledTables);
            "NPR Spfy Integration Area"::"Inventory Levels":
                RegisterInventoryPolledTables(EnabledTables);
            "NPR Spfy Integration Area"::"Item Prices":
                RegisterItemPricesPolledTables(EnabledTables);
            "NPR Spfy Integration Area"::"Sales Orders":
                RegisterCustomerPolledTables(EnabledTables);
            "NPR Spfy Integration Area"::"Retail Vouchers":
                RegisterVouchersPolledTables(EnabledTables);
        end;
    end;

    local procedure RegisterPolled(TableNo: Integer; var EnabledTables: List of [Integer])
    begin
        RegisterPolled(TableNo, 0, EnabledTables);
    end;

    local procedure RegisterPolled(TableNo: Integer; ProcessingOrder: Integer; var EnabledTables: List of [Integer])
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        ChangeTrackerMgt.RegisterTable("NPR Integration Type"::Shopify, TableNo, ProcessingOrder);
        if not EnabledTables.Contains(TableNo) then
            EnabledTables.Add(TableNo);
    end;

    procedure RegisterInventoryPolledTables(var EnabledTables: List of [Integer])
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        RegisterPolled(Database::"Item Ledger Entry", EnabledTables);
        RegisterPolled(Database::"Stockkeeping Unit", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Inventory Level", 1000, EnabledTables);   // must be polled LAST so a same-cycle recompute is sent same cycle
        RegisterPolled(Database::"NPR Spfy Store-Item Link", EnabledTables);
        RegisterPolled(Database::Item, EnabledTables);
        RegisterPolled(Database::"Sales Line", EnabledTables);
        if SpfyIntegrationMgt.IncludeTrasferOrdersAnyStore() then
            RegisterPolled(Database::"Transfer Line", EnabledTables);
        RegisterPolled(Database::"Item Variant", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Item Variant Modif.", EnabledTables);
    end;

    procedure RegisterItemsPolledTables(var EnabledTables: List of [Integer])
    begin
        RegisterPolled(Database::Item, EnabledTables);
        RegisterPolled(Database::"Item Variant", EnabledTables);
        RegisterPolled(Database::"Item Reference", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Store-Item Link", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Item Variant Modif.", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Entity Metafield", EnabledTables);
    end;

    procedure RegisterItemPricesPolledTables(var EnabledTables: List of [Integer])
    begin
        RegisterPolled(Database::"NPR Spfy Item Price", EnabledTables);
        RegisterPolled(Database::"Item Variant", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Item Variant Modif.", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Store-Item Link", EnabledTables);
    end;

    procedure RegisterVouchersPolledTables(var EnabledTables: List of [Integer])
    begin
        RegisterPolled(Database::"NPR NpRv Voucher", EnabledTables);
        RegisterPolled(Database::"NPR NpRv Voucher Entry", EnabledTables);
        RegisterPolled(Database::"NPR NpRv Arch. Voucher", EnabledTables);
    end;

    procedure RegisterCustomerPolledTables(var EnabledTables: List of [Integer])
    begin
        RegisterPolled(Database::"NPR Spfy Store-Customer Link", EnabledTables);
        RegisterPolled(Database::"NPR Spfy Entity Metafield", EnabledTables);
    end;

    procedure IntegrationAreaForTable(TableNo: Integer): Enum "NPR Spfy Integration Area"
    begin
        case TableNo of
            Database::Item,
            Database::"Item Variant",
            Database::"Item Reference",
            Database::"NPR Spfy Store-Item Link",
            Database::"NPR Spfy Item Variant Modif.":
                exit("NPR Spfy Integration Area"::Items);
            Database::"NPR Spfy Entity Metafield":
                exit("NPR Spfy Integration Area"::Metafields);
            Database::"Item Ledger Entry",
            Database::"Sales Line",
            Database::"Transfer Line",
            Database::"Stockkeeping Unit",
            Database::"NPR Spfy Inventory Level":
                exit("NPR Spfy Integration Area"::"Inventory Levels");
            Database::"NPR Spfy Item Price":
                exit("NPR Spfy Integration Area"::"Item Prices");
            Database::"NPR Spfy Store-Customer Link",
            Database::Customer:
                exit("NPR Spfy Integration Area"::"Sales Orders");
            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Voucher Entry",
            Database::"NPR NpRv Arch. Voucher":
                exit("NPR Spfy Integration Area"::"Retail Vouchers");
        end;
        exit("NPR Spfy Integration Area"::" ");
    end;

    procedure MetafieldOwnerOnRowVersionPoll(OwnerTableNo: Integer): Boolean
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit(false);
        case OwnerTableNo of
            Database::"NPR Spfy Store-Item Link":
                exit(true);
            Database::"NPR Spfy Store-Customer Link":
                exit(true);
        end;
        exit(false);
    end;

    procedure InventoryOnRowVersionPoll(): Boolean
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        exit(SpfyRowVersionFeature.IsFeatureEnabled());
    end;
}
