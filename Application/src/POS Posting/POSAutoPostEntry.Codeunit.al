codeunit 6150638 "NPR POS Auto Post Entry"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    var
        POSPostingControl: Codeunit "NPR POS Posting Control";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        NPRetailSetup.Get;
        NPRetailSetup.GetPostingProfile("POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        SetRange("Entry No.", "Entry No.");
        POSPostingControl.PostEntry(Rec, ItemPost, POSPost);
    end;
}

