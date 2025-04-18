﻿codeunit 6060100 "NPR Data Cleanup GCVI Line"
{
    Access = Internal;
    TableNo = "NPR Data Cleanup GCVI";

    trigger OnRun()
    begin
        case Rec.Type of
            Rec.Type::Customer:
                begin
                    Customer.Get(Rec."No.");
                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Delete then
                        Customer.Delete(true);
                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Rename then
                        Customer.Rename(Rec."NewNo.");
                end;
            Rec.Type::Vendor:
                begin
                    Vendor.Get(Rec."No.");
                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Delete then
                        Vendor.Delete(true);

                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Rename then
                        Vendor.Rename(Rec."NewNo.");
                end;
            Rec.Type::Item:
                begin
                    _Item.Get(Rec."No.");
                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Delete then
                        _Item.Delete(true);

                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Rename then
                        _Item.Rename(Rec."NewNo.");
                end;
            Rec.Type::"G/L Account":
                begin
                    _GLAccount.Get(Rec."No.");
                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Delete then
                        _GLAccount.Delete(true);

                    if Rec."Cleanup Action" = Rec."Cleanup Action"::Rename then
                        _GLAccount.Rename(Rec."NewNo.");
                end;
        end;
    end;

    var
        Customer: Record Customer;
        _GLAccount: Record "G/L Account";
        _Item: Record Item;
        Vendor: Record Vendor;

    procedure TestRun(var DataCleanupCVI: Record "NPR Data Cleanup GCVI"): Boolean
    var
        TempCustomer: Record Customer temporary;
        TempGLAccount: Record "G/L Account" temporary;
        TempItem: Record Item temporary;
        TempVendor: Record Vendor temporary;
    begin
        if (DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename) and (DataCleanupCVI."NewNo." = '') then
            exit(false);

        case DataCleanupCVI.Type of
            DataCleanupCVI.Type::Customer:
                begin
                    Customer.Get(DataCleanupCVI."No.");
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                        if not MoveCustEntriesTest(Customer) then
                            exit(false);
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                        TempCustomer.Init();
                        TempCustomer.Copy(Customer);
                        TempCustomer."No." := DataCleanupCVI."NewNo.";
                        if not TempCustomer.Insert(false) then
                            exit(false);
                    end;
                end;
            DataCleanupCVI.Type::Vendor:
                begin
                    Vendor.Get(DataCleanupCVI."No.");
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                        if not MoveVendorEntriesTest(Vendor) then
                            exit(false);
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                        TempVendor.Init();
                        TempVendor.Copy(Vendor);
                        TempVendor."No." := DataCleanupCVI."NewNo.";
                        if not TempVendor.Insert(false) then
                            exit(false);
                    end;
                end;
            DataCleanupCVI.Type::Item:
                begin
                    _Item.Get(DataCleanupCVI."No.");
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                        if not MoveItemEntriesTest(_Item) then
                            exit(false);
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                        TempItem.Init();
                        TempItem.Copy(_Item);
                        TempItem."No." := DataCleanupCVI."NewNo.";
                        if not TempItem.Insert(false) then
                            exit(false);
                    end;
                end;
            DataCleanupCVI.Type::"G/L Account":
                begin
                    _GLAccount.Get(DataCleanupCVI."No.");
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                        if not MoveGLEntriesTest(_GLAccount) then
                            exit(false);
                    if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                        TempGLAccount.Init();
                        TempGLAccount.Copy(_GLAccount);
                        TempGLAccount."No." := DataCleanupCVI."NewNo.";
                        if not TempGLAccount.Insert(false) then
                            exit(false);
                    end;
                end;
        end;

        exit(true);
    end;

    procedure MoveCustEntriesTest(Cust: Record Customer): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ServLedgEntry: Record "Service Ledger Entry";
    begin
        CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date");
        CustLedgEntry.SetRange("Customer No.", Cust."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            CustLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if CustLedgEntry.Find('-') then
            exit(false);

        CustLedgEntry.Reset();
        if not CustLedgEntry.SetCurrentKey("Customer No.", Open) then
            CustLedgEntry.SetCurrentKey("Customer No.");
        CustLedgEntry.SetRange("Customer No.", Cust."No.");
        CustLedgEntry.SetRange(Open, true);
        if CustLedgEntry.Find('+') then
            exit(false);

        ServLedgEntry.Reset();
        ServLedgEntry.SetRange("Customer No.", Cust."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            ServLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
            exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open, true);
        if ServLedgEntry.Find('+') then
            exit(false);

        ServLedgEntry.Reset();
        ServLedgEntry.SetRange("Bill-to Customer No.", Cust."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            ServLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
            exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open, true);
        if ServLedgEntry.Find('+') then
            exit(false);

        exit(true);
    end;

    procedure MoveVendorEntriesTest(Vend: Record Vendor): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.SetCurrentKey("Vendor No.", "Posting Date");
        VendLedgEntry.SetRange("Vendor No.", Vend."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            VendLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if VendLedgEntry.Find('-') then
            exit(false);

        VendLedgEntry.Reset();
        if not VendLedgEntry.SetCurrentKey("Vendor No.", Open) then
            VendLedgEntry.SetCurrentKey("Vendor No.");
        VendLedgEntry.SetRange("Vendor No.", Vend."No.");
        VendLedgEntry.SetRange(Open, true);
        if VendLedgEntry.Find('+') then
            exit(false);

        exit(true);
    end;

    procedure MoveItemEntriesTest(Item: Record Item): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        AvgCostAdjmt: Record "Avg. Cost Adjmt. Entry Point";
        ItemLedgEntry: Record "Item Ledger Entry";
        ServLedgEntry: Record "Service Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            ItemLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if ItemLedgEntry.Find('-') then
            exit(false);

        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        ItemLedgEntry.SetRange("Completely Invoiced", false);
        if ItemLedgEntry.Find('-') then
            exit(false);

        ItemLedgEntry.SetRange("Completely Invoiced");
        ItemLedgEntry.SetCurrentKey("Item No.", Open);
        ItemLedgEntry.SetRange(Open, true);
        if ItemLedgEntry.Find('+') then
            exit(false);

        ItemLedgEntry.SetCurrentKey("Item No.", "Applied Entry to Adjust");
        ItemLedgEntry.SetRange(Open, false);
        ItemLedgEntry.SetRange("Applied Entry to Adjust", true);
        if ItemLedgEntry.Find('-') then
            exit(false);
        ItemLedgEntry.SetRange("Applied Entry to Adjust");

        if Item."Costing Method" = Item."Costing Method"::Average then begin
            AvgCostAdjmt.Reset();
            AvgCostAdjmt.SetRange("Item No.", Item."No.");
            AvgCostAdjmt.SetRange("Cost Is Adjusted", false);
            if AvgCostAdjmt.Find('-') then
                exit(false);
        end;

        ServLedgEntry.Reset();
        ServLedgEntry.SetRange("Item No. (Serviced)", Item."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            ServLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
            exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open, true);
        if ServLedgEntry.Find('+') then
            exit(false);

        ServLedgEntry.SetRange("Item No. (Serviced)");
        ServLedgEntry.SetRange(Type, ServLedgEntry.Type::Item);
        ServLedgEntry.SetRange("No.", Item."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            ServLedgEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
            exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open, true);
        if ServLedgEntry.Find('+') then
            exit(false);

        exit(true);
    end;

    procedure MoveGLEntriesTest(GLAccount: Record "G/L Account"): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("G/L Account No.");
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.Find('-') then
            GLEntry.SetFilter("Posting Date", '>=%1', AccountingPeriod."Starting Date");
        if GLEntry.Find('-') then
            exit(false);

        GLEntry.Reset();
        if not GLEntry.SetCurrentKey("G/L Account No.") then
            GLEntry.SetCurrentKey("G/L Account No.");
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        if GLEntry.Find('+') then
            exit(false);

        exit(true);
    end;
}

