codeunit 6150638 "POS Auto Post Entry"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created

    TableNo = "POS Entry";

    trigger OnRun()
    var
        POSPostingControl: Codeunit "POS Posting Control";
        NPRetailSetup: Record "NP Retail Setup";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        NPRetailSetup.Get;
        ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        SetRange("Entry No.","Entry No.");
        POSPostingControl.PostEntry(Rec,ItemPost,POSPost);
    end;
}

