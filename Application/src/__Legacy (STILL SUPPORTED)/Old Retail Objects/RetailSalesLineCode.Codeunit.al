codeunit 6014436 "NPR Retail Sales Line Code"
{
    TableNo = "NPR Sale POS";

    trigger OnRun()
    var
        npc: Record "NPR Retail Setup";
        Revisionsrulle: Record "NPR Audit Roll";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RecRef: RecordRef;
        RetailReportSelMgt: Codeunit "NPR Retail Report Select. Mgt.";
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

    procedure CalcAmounts(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        Item: Record Item;
    begin
        Item.Get(SaleLinePOS."No.");
        SaleLinePOS.GetAmount(SaleLinePOS, Item, SaleLinePOS."Unit Price");
    end;

    procedure GetSalesAmountInclVAT(SalePOS: Record "NPR Sale POS") Total: Decimal
    var
        SalesLinePOS: Record "NPR Sale Line POS";
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

    procedure LineExists(var Eksp: Record "NPR Sale POS"): Boolean
    var
        EkspLinie: Record "NPR Sale Line POS";
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
        DiscountPriorities[1] := DATABASE::"NPR Mixed Discount";
        DiscountPriorities[2] := DATABASE::"Sales Line Discount";
        DiscountPriorities[3] := DATABASE::"NPR Period Discount";
        DiscountPriorities[4] := DATABASE::"NPR Quantity Discount Header";

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
