codeunit 6150639 "POS Auto Post Period Register"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created

    TableNo = "POS Period Register";

    trigger OnRun()
    var
        POSPostingControl: Codeunit "POS Posting Control";
        NPRetailSetup: Record "NP Retail Setup";
        POSEntry: Record "POS Entry";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        NPRetailSetup.Get;
        ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        POSEntry.SetRange(POSEntry."POS Period Register No.","No.");
        POSPostingControl.PostEntry(POSEntry,ItemPost,POSPost);
    end;
}

