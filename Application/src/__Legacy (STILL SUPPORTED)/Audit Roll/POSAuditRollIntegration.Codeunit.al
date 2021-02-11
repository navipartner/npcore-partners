codeunit 6150617 "NPR POS-Audit Roll Integration"
{
    Permissions = TableData "NPR Audit Roll" = rimd;

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
        SalePOS: Record "NPR Sale POS";
        AuditRoll: Record "NPR Audit Roll";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
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

    local procedure TryCreateSalePOS(var SalePOS: Record "NPR Sale POS"; ShowError: Boolean)
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSEntry: Record "NPR POS Entry";
    begin
        if not POSCreateEntry.Run(SalePOS) then
            if ShowError then
                Message(TextNotCreated, POSEntry.TableCaption, GetLastErrorText);
    end;

    local procedure OpenPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin
        POSOpenPOSUnit.Run(POSUnit);
    end;

    procedure InsertAuditRollEntryLinkFromPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        AuditRoll: Record "NPR Audit Roll";
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

    procedure UpdatePostingStatusFromAuditRoll(var AuditRoll: Record "NPR Audit Roll")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
    begin
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRoll."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if AuditRoll."Item Entry Posted" then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll";
                if AuditRoll.Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"Audit Roll";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
    end;

    procedure UpdatePostingStatusFromAuditRollPosting(var AuditRollPosting: Record "NPR Audit Roll Posting")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
    begin
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRollPosting."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if AuditRollPosting."Item Entry Posted" then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll";
                if AuditRollPosting.Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"Audit Roll";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
    end;

    procedure UpdatePostingStatusFromPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
    begin
        AuditRolltoPOSEntryLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted then
                    AuditRolltoPOSEntryLink."Item Entry Posted By" := AuditRolltoPOSEntryLink."Item Entry Posted By"::"POS Entry";
                if POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted then
                    AuditRolltoPOSEntryLink."Posted By" := AuditRolltoPOSEntryLink."Posted By"::"POS Entry";
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
    end;

    procedure CheckPostingStatusFromAuditRollPosting(var AuditRollPosting: Record "NPR Audit Roll Posting"; ItemPosting: Boolean; Posting: Boolean)
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
    begin
        AuditRolltoPOSEntryLink.SetRange("Audit Roll Clustered Key", AuditRollPosting."Clustered Key");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if (ItemPosting and (AuditRolltoPOSEntryLink."Item Entry Posted By" = AuditRolltoPOSEntryLink."Item Entry Posted By"::"POS Entry")) or
                   (Posting and (AuditRolltoPOSEntryLink."Posted By" = AuditRolltoPOSEntryLink."Posted By"::"POS Entry")) then
                    Error(TextAllReadyPosted, AuditRollPosting.TableCaption, Format(AuditRollPosting.RecordId), POSEntry.TableCaption, AuditRolltoPOSEntryLink."POS Entry No.");
            until AuditRolltoPOSEntryLink.Next = 0;
    end;

    procedure CheckPostingStatusFromPOSEntry(var POSEntry: Record "NPR POS Entry"; ItemPosting: Boolean; Posting: Boolean)
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRolltoPOSEntryLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if (ItemPosting and (AuditRolltoPOSEntryLink."Item Entry Posted By" = AuditRolltoPOSEntryLink."Item Entry Posted By"::"Audit Roll")) or
                   (Posting and (AuditRolltoPOSEntryLink."Posted By" = AuditRolltoPOSEntryLink."Posted By"::"Audit Roll")) then
                    Error(TextAllReadyPosted, POSEntry.TableCaption, POSEntry."Entry No.", AuditRoll.TableCaption, AuditRolltoPOSEntryLink."Audit Roll Clustered Key");
            until AuditRolltoPOSEntryLink.Next = 0;
    end;

    //Subscribers

    [EventSubscriber(ObjectType::Table, 6150615, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPOSUnitInsertRegister(var Rec: Record "NPR POS Unit"; RunTrigger: Boolean)
    var
        Register: Record "NPR Register";
        POSStore: Record "NPR POS Store";
    begin
        if Register.Get(Rec."No.") then
            exit;
        if Rec."POS Store Code" = '' then
            exit;

        Register.Init;
        Register."Register No." := Rec."No.";
        Register.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnAfterPostPOSEntry', '', true, true)]
    local procedure OnAfterPOSPostEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;
        UpdatePostingStatusFromPOSEntry(POSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnCheckPostingRestrictions', '', true, true)]
    local procedure OnBeforePOSPostEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;
        CheckPostingStatusFromPOSEntry(POSEntry, true, false);
    end;
}

