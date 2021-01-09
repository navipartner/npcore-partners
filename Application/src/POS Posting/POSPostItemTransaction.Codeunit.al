codeunit 6150620 "NPR POS Post Item Transaction"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    begin

        Code(Rec);
    end;

    local procedure "Code"(var POSEntry: Record "NPR POS Entry")
    var
        POSPostItemEntries: Codeunit "NPR POS Post Item Entries";
    begin

        POSEntry.Validate("Post Item Entry Status", POSEntry."Post Item Entry Status"::"Error while Posting");
        POSEntry.Modify();
        Commit;

        if (not POSPostItemEntries.PostAssemblyOrders(POSEntry, false)) then
            exit;

        POSPostItemEntries.Run(POSEntry);
        POSEntry.Validate("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.Modify();

        Commit;
    end;
}

