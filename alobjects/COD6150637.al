codeunit 6150637 "POS Posting Control"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created
    // NPR5.38/BR  /20180119  CASE 302791 Handle Separate session posting and regular posting the same way, commitwise
    // NPR5.42/MMV /20180504  CASE 314110 Incorrect posting parameter was set.


    trigger OnRun()
    begin
    end;

    var
        TextCouldNotBePosted: Label 'The POS Entry could not be posted. Please contact your system administrator to adjust the posting setup.';

    procedure AutomaticPostPeriodRegister(var POSPeriodRegister: Record "POS Period Register")
    var
        POSEntry: Record "POS Entry";
        NPRetailSetup: Record "NP Retail Setup";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        case NPRetailSetup."Automatic Item Posting" of
          NPRetailSetup."Automatic Item Posting"::No,
          NPRetailSetup."Automatic Item Posting"::AfterSale                : ItemPost := false;
          NPRetailSetup."Automatic Item Posting"::AfterEndOfDay            : ItemPost := true;
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        end;
        case NPRetailSetup."Automatic POS Posting"of
        //-NPR5.42 [314110]
        //  NPRetailSetup."Automatic POS Posting"::No,
        //  NPRetailSetup."Automatic POS Posting"::AfterSale                : ItemPost := FALSE;
        //  NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : ItemPost := TRUE;
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
          NPRetailSetup."Automatic POS Posting"::No,
          NPRetailSetup."Automatic POS Posting"::AfterSale                : POSPost := false;
          NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : POSPost := true;
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        //+NPR5.42 [314110]
        end;

        if NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct then begin
          POSEntry.SetRange(POSEntry."POS Period Register No.",POSPeriodRegister."No.");
          PostEntry(POSEntry,ItemPost,POSPost)
        end else begin
          if NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession then begin
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
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        if NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct then begin
          POSEntry.SetRange("Entry No.",POSEntry."Entry No.");
          PostEntry(POSEntry,ItemPost,POSPost);
        end else begin
          if NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession then begin
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

