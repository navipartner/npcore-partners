codeunit 6150638 "NPR POS Auto Post Entry"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    var
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSPostingControl: Codeunit "NPR POS Posting Control";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        POSUnit.GetPostingProfile(Rec."POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        SetRange("Entry No.", "Entry No.");
        POSPostingControl.PostEntry(Rec, ItemPost, POSPost);
    end;
}

