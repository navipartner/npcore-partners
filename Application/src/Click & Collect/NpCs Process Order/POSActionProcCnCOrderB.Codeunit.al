codeunit 6151325 "NPR POSAction Proc. CnC OrderB"
{
    Access = Internal;

    procedure RunCollectInStoreOrders(LocationFilter: Text; Sort: Integer)
    var
        NpCsDocument: Record "NPR NpCs Document";
        ClickCollectDataSourceExt: Codeunit "NPR NpCs Data Source Extension";
        Sorting: Option "Entry No.","Reference No.","Processing expires at","Entry No. (Desc.)";
    begin
        ClickCollectDataSourceExt.SetUnprocessedFilter(LocationFilter, NpCsDocument);
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
}