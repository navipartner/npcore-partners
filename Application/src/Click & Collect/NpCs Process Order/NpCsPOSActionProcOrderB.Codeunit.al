codeunit 6151325 "NPR NpCs POSAction Proc.OrderB"
{
    Access = Internal;
    procedure RunCollectInStoreOrders(LocationFilter: Text; Sort: Integer)
    var
        NpCsDocument: Record "NPR NpCs Document";
        Sorting: Option "Entry No.","Reference No.","Processing expires at","Entry No. (Desc.)";
    begin
        SetUnprocessedFilter(LocationFilter, NpCsDocument);
        case Sort of
            Sorting::"Entry No.":
                begin
                    NpCsDocument.SetCurrentKey("Entry No.");
                end;
            Sorting::"Reference No.":
                begin
                    NpCsDocument.SetCurrentKey("Reference No.");
                end;
            Sorting::"Processing expires at":
                begin
                    NpCsDocument.SetCurrentKey("Processing expires at");
                end;
            Sorting::"Entry No. (Desc.)":
                begin
                    NpCsDocument.SetCurrentKey("Entry No.");
                    NpCsDocument.Ascending(false);
                end;
        end;
        Page.RunModal(PAGE::"NPR NpCs Coll. Store Orders", NpCsDocument);
    end;

    procedure GetUnprocessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetUnprocessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.FindFirst());
    end;

    procedure GetUnprocessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        UnprocessedOrderQty: Decimal;
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeGetUnprocessedOrderQty(LocationFilter, UnprocessedOrderQty, IsHandled);
        if IsHandled then
            exit(UnprocessedOrderQty);
        SetUnprocessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count());
    end;

    procedure SetUnprocessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeSetUnprocessedFilter(LocationFilter, NpCsDocument, IsHandled);
        if IsHandled then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::" ");
        NpCsDocument.SetFilter("Location Code", LocationFilter);
    end;

}