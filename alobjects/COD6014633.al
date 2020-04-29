codeunit 6014633 "Touch - Static Subscribers"
{
    // NPR5.23/MHA/20160610  CASE 244040 OnDatabase Subscriber functions deleted


    trigger OnRun()
    begin
    end;

    local procedure AfterGlobalChange(RecRef: RecordRef)
    var
        CacheLog: Record "Lookup Cache Log";
        SessionMgt: Codeunit "POS Web Session Management";
    begin
        if not IsTableSupported(RecRef.Number) then
          exit;

        with CacheLog do begin
          "Table No." := RecRef.Number;
          if not Find() then
            Insert(false);
          "Last Change" := CurrentDateTime;
          Modify(false);
        end;

        SessionMgt.InvalidateLookupCache(RecRef);
    end;

    local procedure IsTableSupported(TableNo: Integer): Boolean
    begin
        exit (TableNo in
          [
            DATABASE::Customer,
            DATABASE::Item
          ]);
    end;
}

