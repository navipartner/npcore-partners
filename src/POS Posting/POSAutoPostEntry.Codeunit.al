codeunit 6150638 "NPR POS Auto Post Entry"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created
    // NPR5.52/ALPO/20190923  CASE 365326 POS Posting related fields moved to POS Posting Profiles from NP Retail Setup

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
        //-NPR5.52 [365326]-revoked
        //ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        //POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile("POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        //+NPR5.52 [365326]
        SetRange("Entry No.", "Entry No.");
        POSPostingControl.PostEntry(Rec, ItemPost, POSPost);
    end;
}

