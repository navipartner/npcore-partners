codeunit 6014436 "Retail Sales Line Code"
{
    // NPR70.00.01.04/BHR/20150120 CASE 203485. Block Item Sales on pos
    // NPR4.10/VB  /20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.16/TS  /20150818  CASE 218497 Added code to search Item in Item Cross Reference
    // NPR4.16/BHR /20151014  CASE 224603 Checks for totalAmount Discount < total sales amount
    //                                    Corrected bug in case amountincludingvat=0 , discount should still be calculated.
    // NPR4.16/JDH /20151110  CASE 225285 Removed Color and Size functionality
    // NPR5.00/VB  /20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.00/VB  /20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 229375 NP Retail 2016
    // NPR5.26/BHR /20160811  CASE 246712 Exclude discount on -ve enties and prevent discount when total is less than 0
    // NPR5.26/MMV /20160830  CASE 241549 Updated register closing print.
    // NPR5.27/JDH /20161017  CASE 252191 Removed validation from accessory lines to MainItemline.
    // NPR5.29/JDH /20170105  CASE 260472 Moved description Control to new CU
    // NPR5.29/MHA /20170117  CASE 263043 Added functions to restructure sequence in GetTrueItemNo(): UpdSaleLineFromAlternativeNo(), UpdSaleLineFromEan(), UpdSaleLineFromItemCrossRef()
    // NPR5.29/BHR /20172301  CASE 264081 Condition To validate field for type::Service
    // NPR5.30/MHA /20170221  CASE 266782 Added Check on string is Number before STRCHECKSUM in UpdSaleLineFromEan()
    // NPR5.31/BR  /20170321  CASE 267602 Check on blocked Variant
    // NPR5.31/MHA /20170210  CASE 262904 Deleted Functions: InitDiscountPriorities(),RunDiscounts(),RunDiscount(),ApplyTempSaleLines(),GenerateTempSalesLines()
    // NPR5.31/AP  /20170302  CASE 248534 Refactoring VAT, Sales Tax
    // NPR5.31/AP  /20170302  CASE 266785 Removing wrong usage of location codes, dimensions etc.
    // NPR5.31/MHA /20170413  CASE 272109 BOM Parent Items is set to Type "BOM List" which will result in Comment Line in BomComponent()
    // NPR5.38/MMV /20171123  CASE 297223 Pull item base UoM until the POS properly supports working in non base UoM.
    // NPR5.40/TSA /20180214  CASE 305045 Added cascade of quantity to accessory items in QuantityValidate(), not depending on accessory line number scheme
    // NPR5.40/MMV /20180220  CASE 294655 Performance optimization
    // NPR5.40.01/JDH/20180417 CASE 311666 Changed Calculation of line amount to after unit price has been updated
    // NPR5.41/JC  /20180424  CASE 312492 Disable Item group check as some customers might not use it
    // NPR5.41/MMV /20180430  CASE 313378 Changed implementation of 311666 to fix unit price bug.
    // NPR5.42/MMV /20180504  CASE 297569 Allow custom discount block by default.
    // NPR5.42/MMV /20180524  CASE 315838 SQL performance
    // NPR5.43/JDH /20180703  CASE 321227 Reintroduced a modifyall, that was needed before a Findset, due to changing values in the current key
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.45/MHA /20180821  CASE 324395 Deleted functions BOMComponent(),GetTrueItemNo(),SetItemData(),TestItem(),UpdSaleLineFromAlternativeNo(),UpdSaleLineFromEan(),UpdSaleLineFromItemCrossRef(),Unit()
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    TableNo = "Sale POS";

    trigger OnRun()
    var
        npc: Record "Retail Setup";
        Revisionsrulle: Record "Audit Roll";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
        RetailReportSelMgt: Codeunit "Retail Report Selection Mgt.";
    begin
        npc.Get;

        if npc."Print Register Report" then begin
            Clear(Revisionsrulle);
            Revisionsrulle.SetRange("Register No.", "Register No.");
            Revisionsrulle.SetRange("Sales Ticket No.", "Sales Ticket No.");
            if (Revisionsrulle.Count <> 0) then begin
                //-NPR5.26 [24154]
                RecRef.GetTable(Revisionsrulle);
                RetailReportSelMgt.SetRegisterNo("Register No.");
                RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Register Balancing");
                //+NPR5.26 [24154]
            end;
        end;
    end;

    procedure CalcAmounts(var SaleLinePOS: Record "Sale Line POS")
    var
        Item: Record Item;
    begin
        Item.Get(SaleLinePOS."No.");
        SaleLinePOS.GetAmount(SaleLinePOS, Item, SaleLinePOS."Unit Price");
    end;

    procedure GetSalesAmountInclVAT(SalePOS: Record "Sale POS") Total: Decimal
    var
        SalesLinePOS: Record "Sale Line POS";
    begin
        with SalePOS do begin
            SalesLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
            SalesLinePOS.SetRange("Register No.", "Register No.");
            SalesLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SalesLinePOS.SetFilter(Type, '%1|%2', SalesLinePOS.Type::Item, SalesLinePOS.Type::"G/L Entry");
            SalesLinePOS.SetFilter("Sale Type", '%1|%2', SalesLinePOS."Sale Type"::Sale, SalesLinePOS."Sale Type"::Deposit);
            SalesLinePOS.CalcSums(Amount, "Amount Including VAT");
            exit(SalesLinePOS."Amount Including VAT");
        end;
    end;

    procedure LineExists(var Eksp: Record "Sale POS"): Boolean
    var
        EkspLinie: Record "Sale Line POS";
    begin
        EkspLinie.SetRange("Register No.", Eksp."Register No.");
        EkspLinie.SetRange("Sales Ticket No.", Eksp."Sales Ticket No.");
        EkspLinie.SetRange(Date, Eksp.Date);
        if EkspLinie.FindFirst then
            exit(true)
        else
            exit(false);
    end;

    procedure SetupObjectNoList(var TempObject: Record AllObj temporary)
    var
        "Object": Record AllObj;
        DiscountPriorities: array[5] of Integer;
        Index: Integer;
        NumberOfObjects: Integer;
    begin
        NumberOfObjects := 4;
        DiscountPriorities[1] := DATABASE::"Mixed Discount";
        DiscountPriorities[2] := DATABASE::"Sales Line Discount";
        DiscountPriorities[3] := DATABASE::"Period Discount";
        DiscountPriorities[4] := DATABASE::"Quantity Discount Header";

        //-NPR5.46 [322752]
        //Object.SETRANGE(Type,Object.Type::Table);
        Object.SetRange("Object Type", Object."Object Type"::Table);
        //+NPR5.46 [322752]
        for Index := 1 to NumberOfObjects do begin
            //-NPR5.46 [322752]
            //Object.SETRANGE(Object.ID,DiscountPriorities[Index]);
            Object.SetRange("Object ID", DiscountPriorities[Index]);
            //+NPR5.46 [322752]
            if Object.FindFirst then begin
                TempObject := Object;
                TempObject.Insert;
            end;
        end;
    end;
}
