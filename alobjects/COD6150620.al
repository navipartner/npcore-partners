codeunit 6150620 "POS Post Item Transaction"
{
    // NPR5.53/TSA /20191106 CASE 376362 Fixed POS Item Entry posting commit scope error

    TableNo = "POS Entry";

    trigger OnRun()
    begin

        Code (Rec);
    end;

    local procedure "Code"(var POSEntry: Record "POS Entry")
    var
        POSPostItemEntries: Codeunit "POS Post Item Entries";
    begin

        POSEntry.Validate ("Post Item Entry Status", POSEntry."Post Item Entry Status"::"Error while Posting");
        POSEntry.Modify ();
        Commit;

        if (not POSPostItemEntries.PostAssemblyOrders (POSEntry, false)) then
          exit;

        POSPostItemEntries.Run (POSEntry);
        POSEntry.Validate ("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.Modify ();

        Commit;
    end;
}

