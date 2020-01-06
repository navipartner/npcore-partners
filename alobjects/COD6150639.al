codeunit 6150639 "POS Auto Post Period Register"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created
    // NPR5.52/ALPO/20190923  CASE 365326 POS Posting related fields moved to POS Posting Profiles from NP Retail Setup

    TableNo = "POS Period Register";

    trigger OnRun()
    var
        POSPostingControl: Codeunit "POS Posting Control";
        NPRetailSetup: Record "NP Retail Setup";
        POSEntry: Record "POS Entry";
        POSPostingProfile: Record "POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
    begin
        NPRetailSetup.Get;
        //-NPR5.52 [365326]-revoked
        //ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        //POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile("POS Unit No.",POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        //+NPR5.52 [365326]
        POSEntry.SetRange(POSEntry."POS Period Register No.","No.");
        POSPostingControl.PostEntry(POSEntry,ItemPost,POSPost);
    end;
}

