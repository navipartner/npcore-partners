codeunit 6150637 "POS Posting Control"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created
    // NPR5.38/BR  /20180119  CASE 302791 Handle Separate session posting and regular posting the same way, commitwise
    // NPR5.42/MMV /20180504  CASE 314110 Incorrect posting parameter was set.
    // NPR5.52/ALPO/20190923  CASE 365326 POS Posting related fields moved to POS Posting Profiles from NP Retail Setup


    trigger OnRun()
    begin
    end;

    var
        TextCouldNotBePosted: Label 'The POS Entry could not be posted. Please contact your system administrator to adjust the posting setup.';

    procedure AutomaticPostPeriodRegister(var POSPeriodRegister: Record "POS Period Register")
    var
        POSEntry: Record "POS Entry";
        NPRetailSetup: Record "NP Retail Setup";
        POSPostingProfile: Record "POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        //-NPR5.52 [365326]-revoked
        /*CASE NPRetailSetup."Automatic Item Posting" OF
          NPRetailSetup."Automatic Item Posting"::No,
          NPRetailSetup."Automatic Item Posting"::AfterSale                : ItemPost := FALSE;
          NPRetailSetup."Automatic Item Posting"::AfterEndOfDay            : ItemPost := TRUE;
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        END;
        CASE NPRetailSetup."Automatic POS Posting"OF
        //-NPR5.42 [314110]
        //  NPRetailSetup."Automatic POS Posting"::No,
        //  NPRetailSetup."Automatic POS Posting"::AfterSale                : ItemPost := FALSE;
        //  NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : ItemPost := TRUE;
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
          NPRetailSetup."Automatic POS Posting"::No,
          NPRetailSetup."Automatic POS Posting"::AfterSale                : POSPost := FALSE;
          NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : POSPost := TRUE;
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        //+NPR5.42 [314110]
        END;*/
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSPeriodRegister."POS Unit No.",POSPostingProfile);
        case POSPostingProfile."Automatic Item Posting" of
          POSPostingProfile."Automatic Item Posting"::No,
          POSPostingProfile."Automatic Item Posting"::AfterSale: ItemPost := false;
          POSPostingProfile."Automatic Item Posting"::AfterEndOfDay: ItemPost := true;
          POSPostingProfile."Automatic Item Posting"::AfterLastEndofDayStore: ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          POSPostingProfile."Automatic Item Posting"::AfterLastEndofDayCompany: ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        end;
        case POSPostingProfile."Automatic POS Posting" of
          POSPostingProfile."Automatic POS Posting"::No,
          POSPostingProfile."Automatic POS Posting"::AfterSale: POSPost := false;
          POSPostingProfile."Automatic POS Posting"::AfterEndOfDay: POSPost := true;
          POSPostingProfile."Automatic POS Posting"::AfterLastEndofDayStore: POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          POSPostingProfile."Automatic POS Posting"::AfterLastEndofDayCompany: POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        end;
        //+NPR5.52 [365326]
        
        //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct THEN BEGIN  //NPR5.52 [365326]-revoked
        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin  //NPR5.52 [365326]
          POSEntry.SetRange(POSEntry."POS Period Register No.",POSPeriodRegister."No.");
          PostEntry(POSEntry,ItemPost,POSPost)
        end else begin
          //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession THEN BEGIN  //NPR5.52 [365326]-revoked
          if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin  //NPR5.52 [365326]
            if ItemPost or POSPost then begin
              Commit;
              if not StartSession(SessionNo,CODEUNIT::"POS Auto Post Period Register",CompanyName,POSPeriodRegister) then begin
                POSEntry.SetRange(POSEntry."POS Period Register No.",POSPeriodRegister."No.");
                PostEntry(POSEntry,ItemPost,POSPost)
              end;
            end;
          end;
        end;

    end;

    local procedure AutomaticPostEntry(var POSEntry: Record "POS Entry")
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSPostingProfile: Record "POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        //-NPR5.52 [365326]-revoked
        //ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        //POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct THEN BEGIN
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSEntry."POS Unit No.",POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin
        //+NPR5.52 [365326]
          POSEntry.SetRange("Entry No.",POSEntry."Entry No.");
          PostEntry(POSEntry,ItemPost,POSPost);
        end else begin
          //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession THEN BEGIN  //NPR5.52 [365326]-revoked
          if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin  //NPR5.52 [365326]
            if ItemPost or POSPost then begin
              Commit;
              if not StartSession(SessionNo,CODEUNIT::"POS Auto Post Entry",CompanyName,POSEntry) then begin
                POSEntry.SetRange("Entry No.",POSEntry."Entry No.");
                PostEntry(POSEntry,ItemPost,POSPost);
              end;
            end;
          end;
        end;
    end;

    procedure PostEntry(var POSEntry: Record "POS Entry";ItemPost: Boolean;POSPost: Boolean)
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSPostEntries: Codeunit "POS Post Entries";
    begin
        NPRetailSetup.Get;
        if not NPRetailSetup."Advanced POS Entries Activated" then
          exit;
        if not NPRetailSetup."Advanced Posting Activated" then
          exit;
        if (not ItemPost) and (not POSPost) then
          exit;
        Commit;
        POSPostEntries.SetPostItemEntries(ItemPost);
        POSPostEntries.SetPostPOSEntries(POSPost);
        //-NPR5.38 [302791]
        //POSPostEntries.RUN(POSEntry);
        if not POSPostEntries.Run(POSEntry) then
          Message(TextCouldNotBePosted);
        //+NPR5.38 [302791]
    end;

    local procedure PostEntriesInSeparateSession(var POSEntry: Record "POS Entry";ItemPost: Boolean;POSPost: Boolean)
    var
        SessionNo: Integer;
        POSPostingLog: Record "POS Posting Log";
    begin
        if not StartSession(SessionNo, CODEUNIT::"POS Post Entries" , CompanyName ,POSEntry) then
          PostEntry(POSEntry,ItemPost,POSPost);
    end;

    local procedure OtherPOSUnitsAreClosed(var POSPeriodRegister: Record "POS Period Register";POSStoreCode: Code[10]): Boolean
    var
        POSUnit: Record "POS Unit";
    begin
        POSUnit.SetFilter(Status,'<>%1',POSUnit.Status::CLOSED);
        POSUnit.SetFilter("No.",'<>%1',POSPeriodRegister."POS Unit No.");
        if POSStoreCode <> '' then
          POSUnit.SetFilter("POS Store Code",POSPeriodRegister."POS Store Code");
        exit(not POSUnit.IsEmpty);
    end;

    local procedure "---- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSEntry', '', true, true)]
    local procedure OnAfterInsertPOSEntryPost(var SalePOS: Record "Sale POS";var POSEntry: Record "POS Entry")
    begin
        AutomaticPostEntry(POSEntry);
    end;
}

