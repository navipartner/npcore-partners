codeunit 6150639 "NPR POS AutoPost PeriodRegist."
{
    TableNo = "NPR POS Period Register";

    trigger OnRun()
    var
        POSPostingControl: Codeunit "NPR POS Posting Control";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        NPRetailSetup.Get;
        NPRetailSetup.GetPostingProfile("POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        POSEntry.SetRange(POSEntry."POS Period Register No.", "No.");
        POSPostingControl.PostEntry(POSEntry, ItemPost, POSPost);
    end;
}

