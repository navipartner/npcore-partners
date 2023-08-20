codeunit 6151039 "NPR POS Post Sales Doc. Trans."
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    trigger OnRun()
    begin
        Code(Rec);
    end;

    local procedure "Code"(var POSEntry: Record "NPR POS Entry")
    var
        POSPostSalesDocEntries: Codeunit "NPR POS Post Sales Doc.Entries";
    begin
        POSEntry.Validate("Post Sales Document Status", POSEntry."Post Sales Document Status"::"Error while Posting");
        POSEntry.Modify();
        Commit();
        POSPostSalesDocEntries.Run(POSEntry);

        POSEntry.Validate("Post Sales Document Status", POSEntry."Post Sales Document Status"::Posted);
        POSEntry.Modify();
        Commit();
    end;

}
