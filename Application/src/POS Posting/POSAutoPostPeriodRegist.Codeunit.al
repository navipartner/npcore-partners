codeunit 6150639 "NPR POS AutoPost PeriodRegist."
{
    TableNo = "NPR POS Period Register";

    trigger OnRun()
    var
        POSStore: Record "NPR POS Store";
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSPostingControl: Codeunit "NPR POS Posting Control";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        POSStore.GetProfile(Rec."POS Store Code", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        POSEntry.SetRange(POSEntry."POS Period Register No.", Rec."No.");
        POSPostingControl.PostEntry(POSEntry, ItemPost, POSPost);
    end;
}

