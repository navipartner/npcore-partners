codeunit 6150617 "POS-Audit Roll Integration"
{
    // NPR5.36/BR  /20170628  CASE 279551  Created Codeunit as temporary integration of new POS Entries into Old Audit Roll
    // NPR5.36/BR  /20170628  CASE 279552  Added a subscriber to insert POS Entries
    // NPR5.37/BR  /20171011  CASE 293133  Compare Audit Roll and POS Entry Posting
    // NPR5.38/BR  /20171214  CASE 299888  Renamed from POSLedgerRegister to POSPeriodRegister
    // NPR5.38/BR  /20180109  CASE 301600  Corrected spelling funtion, added posting source tracking
    // NPR5.39/MHA /20180202  CASE 302779 Deleted deprecated function OnAfterAuditRollPostingPostItemEntries()
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.41/JDH /20180426 CASE 312935  When Data Import is triggered, a test record is inserted, to find out if there is autoincrement in the PK. This causes an error in subscriber OnInsertPOSUnitInsertRegister
    // #361931/ALST/20190715 CASE 361931 removed MarkAuditRollPosted, PostItemEntries, OnClosingPOSPeriodRegisterPostItemEntries, SaleIsPostedInAuditRoll, POSEntryIsPostedInAuditRoll - unused
    // #361931/ALST/20190715 CASE 361931 removed FindPOSEntryNo, TryOpenPOSUnit - unused

    Permissions = TableData "Audit Roll" = rimd;

    trigger OnRun()
    begin
        BatchCreatePOSEntryFromSalePOS; //FOR TESTING ONLY
    end;

    var
        TextNotCreated: Label '%1 not created because of error:\ %2';
        TextNotOpened: Label '%1 %2 not opened because of error:\ %3';
        PrefixExistingPostingTxt: Label 'OLD-';
        TextAllReadyPosted: Label '%1 %2 has allready been posted through %3 %4.';

    local procedure BatchCreatePOSEntryFromSalePOS()
    var
        SalePOS: Record "Sale POS";
        AuditRoll: Record "Audit Roll";
        POSCreateEntry: Codeunit "POS Create Entry";
        DiaWindow: Dialog;
        TextSure: Label 'Are you sure you want to create POS Entries? This should only be done to test.';
        TextCounter: Label 'Creating POS Entries @1@@@@@@@@@@@@@@@@@@';
        LineCount: Integer;
        NoOfRecords: Integer;
    begin
        if not Confirm(TextSure) then
            exit;
        DiaWindow.Open(TextCounter);
        NoOfRecords := SalePOS.Count;

        if SalePOS.FindSet then
            repeat
                LineCount := LineCount + 1;
                DiaWindow.Update(1, Round(LineCount / NoOfRecords * 10000, 1));
                AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                AuditRoll.SetRange("Register No.", SalePOS."Register No.");
                if not AuditRoll.IsEmpty then
                    POSCreateEntry.Run(SalePOS);
            until SalePOS.Next = 0;

        DiaWindow.Close;
    end;

    local procedure TryCreateSalePOS(var SalePOS: Record "Sale POS"; ShowError: Boolean)
    var
        POSCreateEntry: Codeunit "POS Create Entry";
        POSEntry: Record "POS Entry";
    begin
        if not POSCreateEntry.Run(SalePOS) then
            if ShowError then
                Message(TextNotCreated, POSEntry.TableCaption, GetLastErrorText);
    end;

    local procedure OpenPOSUnit(var POSUnit: Record "POS Unit")
    var
        POSOpenPOSUnit: Codeunit "POS Manage POS Unit";
    begin
        POSOpenPOSUnit.Run(POSUnit);
    end;

    procedure InsertAuditRollEntryLinkFromPOSEntry(var POSEntry: Record "POS Entry")
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
        AuditRoll: Record "Audit Roll";
    begin
        AuditRoll.Reset;
        AuditRoll.SetRange("Register No.", POSEntry."POS Unit No.");
        AuditRoll.SetRange("Sales Ticket No.", POSEntry."Document No.");
        AuditRoll.SetRange("Sale Date", POSEntry."Entry Date");
        if AuditRoll.FindSet then
            repeat
                AuditRolltoPOSEntryLink.Init;
                AuditRolltoPOSEntryLink."Link Entry No." := 0; //Auto Increment
                AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
                AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                case POSEntry."Entry Type" of
                    POSEntry."Entry Type"::"Direct Sale":
                        AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Sale
                end;
                AuditRolltoPOSEntryLink."POS Period Register No." := POSEntry."POS Period Register No.";
                AuditRolltoPOSEntryLink."Line No." := AuditRoll."Line No.";
                AuditRolltoPOSEntryLink.Insert;
            until AuditRoll.Next = 0;
    end;

    procedure PrepareAuditRollCompare(var POSEntry: Record "POS Entry")
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
        AuditRoll: Record "Audit Roll";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        AuditRollDocNo: Code[20];
    begin
        //-NPR5.37 [293133];
        if POSEntry.FindSet then
            repeat
                AuditRollDocNo := '';
                AuditRoll.Reset;
                AuditRoll.SetRange("Sale Date", POSEntry."Posting Date");
                AuditRoll.SetRange("Sales Ticket No.", POSEntry."Document No.");
                AuditRoll.SetFilter("Posted Doc. No.", '<>%1', '');
                if AuditRoll.FindFirst then begin
                    AuditRollDocNo := AuditRoll."Posted Doc. No.";
                end else begin
                    AuditRolltoPOSEntryLink.SetRange("POS Entry No.", POSEntry."Entry No.");
                    if AuditRolltoPOSEntryLink.FindFirst then begin
                        AuditRoll.Reset;
                        AuditRoll.SetRange("Clustered Key", AuditRolltoPOSEntryLink."Audit Roll Clustered Key");
                        if AuditRoll.FindFirst then
                            AuditRollDocNo := AuditRoll."Posted Doc. No.";
                    end;
                end;
                if AuditRollDocNo = '' then
                    Error('Audit Roll not found');
                //AuditRollDocNo := 'POS '+ POSEntry."POS Unit No." + '-' + POSEntry."Document No.";
                CopyPostedEntriesToPreview(AuditRollDocNo, POSEntry."Posting Date");
            until POSEntry.Next = 0;
        //+NPR5.37 [293133]
    end;

    local procedure CopyPostedEntriesToPreview(DocumentNo: Code[20]; PostingDate: Date)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        Error('Function not possible in 2017');
        /*
        //-NPR5.37 [293133]
        WITH GLEntry DO BEGIN
          SETRANGE("Document No.",DocumentNo);
          GLEntry.SETRANGE("Posting Date",PostingDate);
          IF GLEntry.FINDFIRST THEN REPEAT
            GLEntry.Description := COPYSTR(PrefixExistingPostingTxt + GLEntry.Description,1,MAXSTRLEN(GLEntry.Description));
            GLEntry."Source Code" := COPYSTR(PrefixExistingPostingTxt + GLEntry."Source Code",1,MAXSTRLEN(GLEntry."Source Code"));
            GenJnlPostPreview.SaveGLEntry(GLEntry);
          UNTIL GLEntry.NEXT = 0;
        END;
        
        WITH VATEntry DO BEGIN
          SETRANGE("Document No.",DocumentNo);
          SETRANGE("Posting Date",PostingDate);
          IF FINDFIRST THEN REPEAT
            "Source Code" := COPYSTR(PrefixExistingPostingTxt + "Source Code",1,MAXSTRLEN("Source Code"));
            "Internal Ref. No." := COPYSTR(PrefixExistingPostingTxt + "Internal Ref. No.",1,MAXSTRLEN("Internal Ref. No."));
            GenJnlPostPreview.SaveVATEntry(VATEntry);
          UNTIL NEXT = 0;
        END;
        
        WITH ValueEntry DO BEGIN
          SETRANGE("Document No.",DocumentNo);
          SETRANGE("Posting Date",PostingDate);
          IF FINDFIRST THEN REPEAT
            "Source Code" := COPYSTR(PrefixExistingPostingTxt + "Source Code",1,MAXSTRLEN("Source Code"));
            GenJnlPostPreview.SaveValueEntry(ValueEntry);
          UNTIL NEXT = 0;
        END;
        
        WITH ItemLedgerEntry DO BEGIN
          SETRANGE("Document No.",DocumentNo);
          SETRANGE("Posting Date",PostingDate);
          IF FINDFIRST THEN REPEAT
            Description := COPYSTR(PrefixExistingPostingTxt + Description,1,MAXSTRLEN(Description));
            GenJnlPostPreview.SaveItemLedgEntry(ItemLedgerEntry);
          UNTIL NEXT = 0;
        END;
        
        WITH BankAccountLedgerEntry DO BEGIN
          SETRANGE("Document No.",DocumentNo);
          SETRANGE("Posting Date",PostingDate);
          IF FINDFIRST THEN REPEAT
            Description := COPYSTR(PrefixExistingPostingTxt + Description,1,MAXSTRLEN(Description));
            "Source Code" := COPYSTR(PrefixExistingPostingTxt + "Source Code",1,MAXSTRLEN("Source Code"));
            GenJnlPostPreview.SaveBankAccLedgEntry(BankAccountLedgerEntry);
          UNTIL NEXT = 0;
        END;
        //+NPR5.37 [293133]
        */

    end;

    procedure UpdatePostingStatusFromAuditRoll(var AuditRoll: Record "Audit Roll")
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
    begin
        //-NPR5.38 [301600]
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRoll."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if AuditRoll."Item Entry Posted" then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll";
                if AuditRoll.Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"Audit Roll";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
        //+NPR5.38 [301600]
    end;

    procedure UpdatePostingStatusFromAuditRollPosting(var AuditRollPosting: Record "Audit Roll Posting")
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
    begin
        //-NPR5.38 [301600]
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRollPosting."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if AuditRollPosting."Item Entry Posted" then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll";
                if AuditRollPosting.Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"Audit Roll";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
        //+NPR5.38 [301600]
    end;

    procedure UpdatePostingStatusFromPOSEntry(var POSEntry: Record "POS Entry")
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
    begin
        //-NPR5.38 [301600]
        AuditRolltoPOSEntryLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"POS Entry";
                if POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"POS Entry";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
        //+NPR5.38 [301600]
    end;

    procedure CheckPostingStatusFromAuditRollPosting(var AuditRollPosting: Record "Audit Roll Posting"; ItemPosting: Boolean; Posting: Boolean)
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.38 [301600]
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRollPosting."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if (ItemPosting and (AuditRolltoPOSEntryLink."Item Entry Posted By" = AuditRolltoPOSEntryLink."Item Entry Posted By"::"POS Entry")) or
                   (Posting and (AuditRolltoPOSEntryLink."Posted By" = AuditRolltoPOSEntryLink."Posted By"::"POS Entry")) then
                    Error(TextAllReadyPosted, AuditRollPosting.TableCaption, Format(AuditRollPosting.RecordId), POSEntry.TableCaption, AuditRolltoPOSEntryLink."POS Entry No.");
            until AuditRolltoPOSEntryLink.Next = 0;
        //+NPR5.38 [301600]
    end;

    procedure CheckPostingStatusFromPOSEntry(var POSEntry: Record "POS Entry"; ItemPosting: Boolean; Posting: Boolean)
    var
        AuditRolltoPOSEntryLink: Record "Audit Roll to POS Entry Link";
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.38 [301600]
        AuditRolltoPOSEntryLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if (ItemPosting and (AuditRolltoPOSEntryLink."Item Entry Posted By" = AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll")) or
                   (Posting and (AuditRolltoPOSEntryLink."Posted By" = AuditRolltoPOSEntryLink."Posted By"::"Audit Roll")) then
                    Error(TextAllReadyPosted, POSEntry.TableCaption, POSEntry."Entry No.", AuditRoll.TableCaption, AuditRolltoPOSEntryLink."Audit Roll Clustered Key");
            until AuditRolltoPOSEntryLink.Next = 0;
        //+NPR5.38 [301600]
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150615, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPOSUnitInsertRegister(var Rec: Record "POS Unit"; RunTrigger: Boolean)
    var
        Register: Record Register;
        POSStore: Record "POS Store";
    begin
        if Register.Get(Rec."No.") then
            exit;
        //-NPR5.41 [312935]
        if Rec."POS Store Code" = '' then
            exit;
        //+NPR5.41 [312935]

        Register.Init;
        Register."Register No." := Rec."No.";
        POSStore.Get(Rec."POS Store Code");
        Register."Sales Ticket Series" := POSStore."POS Entry Doc. No. Series";
        Register."Location Code" := POSStore."Location Code";
        Register.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnBeforeEndSale', '', true, true)]
    local procedure OnBeforeEndSaleCreatePOSEntry(var Sender: Codeunit "POS Sale"; SaleHeader: Record "Sale POS")
    var
        NPRetailSetup: Record "NP Retail Setup";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.36 [279552]
        exit;
        if not NPRetailSetup.Get then
            exit;
        //IF NOT (NPRetailSetup."Environment Type" IN [NPRetailSetup."Environment Type"::DEV,NPRetailSetup."Environment Type"::TEST]) THEN
        //  EXIT;
        if not NPRetailSetup."Advanced POS Entries Activated" then
            exit;
        Sender.GetCurrentSale(SalePOS);
        TryCreateSalePOS(SalePOS, NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD);
        //+NPR5.36 [279552]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014505, 'OnBeforeRegisterOpen', '', true, true)]
    local procedure OnBeforeRegisterOpenCreatePOSPeriodRegister(Register: Record Register)
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSUnit: Record "POS Unit";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        if not NPRetailSetup.Get then
            exit;
        if not NPRetailSetup."Advanced POS Entries Activated" then
            exit;
        if not POSUnit.Get(Register."Register No.") then
            exit;
        ///TryOpenPOSUnit(POSUnit,NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD);
        OpenPOSUnit(POSUnit);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnAfterPostPOSEntry', '', true, true)]
    local procedure OnAfterPOSPostEntry(var POSEntry: Record "POS Entry"; PreviewMode: Boolean)
    begin
        //-NPR5.38 [301600]
        if PreviewMode then
            exit;
        UpdatePostingStatusFromPOSEntry(POSEntry);
        //+NPR5.38 [301600]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnCheckPostingRestrictions', '', true, true)]
    local procedure OnBeforePOSPostEntry(var POSEntry: Record "POS Entry"; PreviewMode: Boolean)
    begin
        //-NPR5.38 [301600]
        if PreviewMode then
            exit;
        CheckPostingStatusFromPOSEntry(POSEntry, true, false);
        //+NPR5.38 [301600]
    end;
}

