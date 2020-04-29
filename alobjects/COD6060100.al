codeunit 6060100 "Data Cleanup GCVI Line"
{
    // NPR4.10/JC/20150318  CASE 207094 Data collect for Customer, Vendor and Item
    // NPR5.23/JC/20160330  CASE 237816 Extend with G/L account & rename

    TableNo = "Data Cleanup GCVI";

    trigger OnRun()
    begin
        case Rec.Type of
          Rec.Type::Customer :
            begin
              Customer.Get(Rec."No.");
              if "Cleanup Action" = "Cleanup Action"::Delete then //-NPR5.23
                Customer.Delete(true);
              //-NPR5.23
              if "Cleanup Action" = "Cleanup Action"::Rename then
                Customer.Rename("NewNo.");
              //+NPR5.23
            end;

          Rec.Type::Vendor :
            begin
              Vendor.Get(Rec."No.");
              if "Cleanup Action" = "Cleanup Action"::Delete then //-NPR5.23
                Vendor.Delete(true);
              //-NPR5.23
              if "Cleanup Action" = "Cleanup Action"::Rename then
                Vendor.Rename("NewNo.");
              //+NPR5.23
            end;

          Rec.Type::Item :
            begin
              Item.Get(Rec."No.");
              if "Cleanup Action" = "Cleanup Action"::Delete then //-NPR5.23
                Item.Delete(true);
              //-NPR5.23
              if "Cleanup Action" = "Cleanup Action"::Rename then
                Item.Rename("NewNo.");
              //+NPR5.23
            end;
          //-NPR5.23
          Rec.Type::"G/L Account" :
            begin
              GLAccount.Get(Rec."No.");
              if "Cleanup Action" = "Cleanup Action"::Delete then //-NPR5.23
                GLAccount.Delete(true);
              //-NPR5.23
              if "Cleanup Action" = "Cleanup Action"::Rename then
                GLAccount.Rename("NewNo.");
              //+NPR5.23

            end;
          //+NPR5.23
        end;
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        GLAccount: Record "G/L Account";

    procedure TestRun(var DataCleanupCVI: Record "Data Cleanup GCVI"): Boolean
    var
        CustomerTmp: Record Customer temporary;
        VendorTmp: Record Vendor temporary;
        ItemTmp: Record Item temporary;
        GLAccountTmp: Record "G/L Account" temporary;
    begin
        //-NPR5.23

        if (DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename) and (DataCleanupCVI."NewNo." = '') then
          exit(false);

        case DataCleanupCVI.Type of
          DataCleanupCVI.Type::Customer :
            begin
              Customer.Get(DataCleanupCVI."No.");
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                if not MoveCustEntriesTest(Customer) then
                  exit(false);
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                CustomerTmp.Init;
                CustomerTmp.Copy(Customer);
                CustomerTmp."No." := DataCleanupCVI."NewNo." ;
                if not CustomerTmp.Insert(false) then
                  exit(false);
              end;
            end;

          DataCleanupCVI.Type::Vendor :
            begin
              Vendor.Get(DataCleanupCVI."No.");
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                if not MoveVendorEntriesTest(Vendor) then
                  exit(false);
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                VendorTmp.Init;
                VendorTmp.Copy(Vendor);
                VendorTmp."No." := DataCleanupCVI."NewNo." ;
                if not VendorTmp.Insert(false) then
                  exit(false);
              end;
            end;

          DataCleanupCVI.Type::Item :
            begin
              Item.Get(DataCleanupCVI."No.");
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                if not MoveItemEntriesTest(Item) then
                  exit(false);
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                ItemTmp.Init;
                ItemTmp.Copy(Item);
                ItemTmp."No." := DataCleanupCVI."NewNo." ;
                if not ItemTmp.Insert(false) then
                  exit(false);
              end;
            end;
          DataCleanupCVI.Type::"G/L Account" :
            begin
              GLAccount.Get(DataCleanupCVI."No.");
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Delete then
                if not MoveGLEntriesTest(GLAccount) then
                  exit(false);
              if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
                GLAccountTmp.Init;
                GLAccountTmp.Copy(GLAccount);
                GLAccountTmp."No." := DataCleanupCVI."NewNo." ;
                if not GLAccountTmp.Insert(false) then
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
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        CheckLedgEntry: Record "Check Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        JobLedgEntry: Record "Job Ledger Entry";
        PurchOrderLine: Record "Purchase Line";
        ReminderEntry: Record "Reminder/Fin. Charge Entry";
        ValueEntry: Record "Value Entry";
        AvgCostAdjmt: Record "Avg. Cost Adjmt. Entry Point";
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        ServLedgEntry: Record "Service Ledger Entry";
        WarrantyLedgEntry: Record "Warranty Ledger Entry";
    begin
        CustLedgEntry.Reset;
        CustLedgEntry.SetCurrentKey("Customer No.","Posting Date");
        CustLedgEntry.SetRange("Customer No.",Cust."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          CustLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if CustLedgEntry.Find('-') then
          exit(false);

        CustLedgEntry.Reset;
        if not CustLedgEntry.SetCurrentKey("Customer No.",Open) then
          CustLedgEntry.SetCurrentKey("Customer No.");
        CustLedgEntry.SetRange("Customer No.",Cust."No.");
        CustLedgEntry.SetRange(Open,true);
        if CustLedgEntry.Find('+') then
          exit(false);

        ServLedgEntry.Reset;
        ServLedgEntry.SetRange("Customer No.",Cust."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          ServLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
          exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open,true);
        if ServLedgEntry.Find('+') then
          exit(false);

        ServLedgEntry.Reset;
        ServLedgEntry.SetRange("Bill-to Customer No.",Cust."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          ServLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
          exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open,true);
        if ServLedgEntry.Find('+') then
          exit(false);

        exit(true);
    end;

    procedure MoveVendorEntriesTest(Vend: Record Vendor): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        CheckLedgEntry: Record "Check Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        JobLedgEntry: Record "Job Ledger Entry";
        PurchOrderLine: Record "Purchase Line";
        ReminderEntry: Record "Reminder/Fin. Charge Entry";
        ValueEntry: Record "Value Entry";
        AvgCostAdjmt: Record "Avg. Cost Adjmt. Entry Point";
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        ServLedgEntry: Record "Service Ledger Entry";
        WarrantyLedgEntry: Record "Warranty Ledger Entry";
    begin
        VendLedgEntry.Reset;
        VendLedgEntry.SetCurrentKey("Vendor No.","Posting Date");
        VendLedgEntry.SetRange("Vendor No.",Vend."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          VendLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if VendLedgEntry.Find('-') then
          exit(false);

        VendLedgEntry.Reset;
        if not VendLedgEntry.SetCurrentKey("Vendor No.",Open) then
          VendLedgEntry.SetCurrentKey("Vendor No.");
        VendLedgEntry.SetRange("Vendor No.",Vend."No.");
        VendLedgEntry.SetRange(Open,true);
        if VendLedgEntry.Find('+') then
          exit(false);


        exit(true);
    end;

    procedure MoveItemEntriesTest(Item: Record Item): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        CheckLedgEntry: Record "Check Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        JobLedgEntry: Record "Job Ledger Entry";
        PurchOrderLine: Record "Purchase Line";
        ReminderEntry: Record "Reminder/Fin. Charge Entry";
        ValueEntry: Record "Value Entry";
        AvgCostAdjmt: Record "Avg. Cost Adjmt. Entry Point";
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        ServLedgEntry: Record "Service Ledger Entry";
        WarrantyLedgEntry: Record "Warranty Ledger Entry";
    begin
        ItemLedgEntry.Reset;
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.",Item."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          ItemLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if ItemLedgEntry.Find('-') then
          exit(false);

        ItemLedgEntry.Reset;
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.",Item."No.");
        ItemLedgEntry.SetRange("Completely Invoiced",false);
        if ItemLedgEntry.Find('-') then
          exit(false);
        ItemLedgEntry.SetRange("Completely Invoiced");

        ItemLedgEntry.SetCurrentKey("Item No.",Open);
        ItemLedgEntry.SetRange(Open,true);
        if ItemLedgEntry.Find('+') then
          exit(false);

        ItemLedgEntry.SetCurrentKey("Item No.","Applied Entry to Adjust");
        ItemLedgEntry.SetRange(Open,false);
        ItemLedgEntry.SetRange("Applied Entry to Adjust",true);
        if ItemLedgEntry.Find('-') then
          exit(false);
        ItemLedgEntry.SetRange("Applied Entry to Adjust");

        if Item."Costing Method" = Item."Costing Method"::Average then begin
          AvgCostAdjmt.Reset;
          AvgCostAdjmt.SetRange("Item No.",Item."No.");
          AvgCostAdjmt.SetRange("Cost Is Adjusted",false);
          if AvgCostAdjmt.Find('-') then
            exit(false);
        end;



        ServLedgEntry.Reset;
        ServLedgEntry.SetRange("Item No. (Serviced)",Item."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          ServLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
          exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open,true);
        if ServLedgEntry.Find('+') then
          exit(false);

        ServLedgEntry.SetRange("Item No. (Serviced)");
        ServLedgEntry.SetRange(Type,ServLedgEntry.Type::Item);
        ServLedgEntry.SetRange("No.",Item."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          ServLedgEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if ServLedgEntry.Find('-') then
          exit(false);

        ServLedgEntry.SetRange("Posting Date");
        ServLedgEntry.SetRange(Open,true);
        if ServLedgEntry.Find('+') then
          exit(false);


        exit(true);
    end;

    procedure MoveGLEntriesTest(GLAccount: Record "G/L Account"): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Reset;
        GLEntry.SetCurrentKey("G/L Account No.");
        GLEntry.SetRange("G/L Account No.",GLAccount."No.");
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.Find('-') then
          GLEntry.SetFilter("Posting Date",'>=%1',AccountingPeriod."Starting Date");
        if GLEntry.Find('-') then
          exit(false);

        GLEntry.Reset;
        if not GLEntry.SetCurrentKey("G/L Account No.") then
          GLEntry.SetCurrentKey("G/L Account No.");
        GLEntry.SetRange("G/L Account No.",GLAccount."No.");
        if GLEntry.Find('+') then
          exit(false);


        exit(true);
    end;
}

