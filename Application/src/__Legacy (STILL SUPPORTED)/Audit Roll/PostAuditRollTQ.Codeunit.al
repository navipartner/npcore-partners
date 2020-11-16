codeunit 6059912 "NPR Post Audit Roll TQ"
{
    // TQ1.28/MHA  /20151216  CASE 229609 Task Queue
    // NPR5.29/MHA /20170116  CASE 262116 Added Item Ledger Posting to auto post missing Item Entries
    // NPR5.30/JC  /20170213  CASE 265042 Option to create task for only posting Item ledgers

    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        SkipPostGLEntry: Boolean;
        SkipPostItemLedgerEntry: Boolean;
        OnlyItemLedgerPosting: Boolean;
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TestField("Valid After");
        TestField("Valid Until");

        AuditRoll.Reset;
        if not AuditRoll.SetCurrentKey(Posted, "Register No.", "Sale Date") then
            AuditRoll.SetCurrentKey("Register No.", Posted, "Sale Date");
        AuditRoll.SetRange(Posted, false);
        AuditRoll.SetFilter("Sale Date", '<>%1', 0D);

        //-NPR5.30 [265042]
        SkipPostGLEntry := false;
        SkipPostItemLedgerEntry := false;
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        if not TaskLineParam.IsEmpty then begin
            SkipPostGLEntry := GetParameterBool('SKIPPOSTGLENTRY');
            SkipPostItemLedgerEntry := GetParameterBool('SKIPPOSTILENTRY');
        end;
        OnlyItemLedgerPosting := SkipPostGLEntry and (not SkipPostItemLedgerEntry);
        //+NPR5.30

        if AuditRoll.FindFirst then
            repeat
                //will always post per register, per date
                AuditRoll.SetRange("Register No.", AuditRoll."Register No.");
                AuditRoll.SetRange("Sale Date", AuditRoll."Sale Date");
                AuditRoll.FindLast;
                //Post it
                AuditRoll2.Copy(AuditRoll);
                Clear(PostAuditRoll);
                PostAuditRoll.ShowProgress(false);
                //-NPR5.30 [265042]
                PostAuditRoll.SetPostingParameters(SkipPostGLEntry, SkipPostItemLedgerEntry);
                //-NPR5.30
                PostAuditRoll.Run(AuditRoll2);

                AddMessageLine2OutputLog(StrSubstNo(Text002, AuditRoll."Register No.", AuditRoll."Sale Date"));
                Commit;

                //remove the current sales date filter and register filter
                AuditRoll.SetRange("Register No.");
                AuditRoll.SetFilter("Sale Date", '<>%1', 0D);

                if not TimeSlotStillValid then begin
                    //Commit and throw an error if im out of time? (then the job fail, and normal TQ mail routine can be used to send error mail)
                    AddMessageLine2OutputLog(Text001);
                    Commit;
                    Error(Text001);
                    exit;
                end;
            until AuditRoll.Next = 0;

        //-NPR5.30 [265042]
        if not OnlyItemLedgerPosting then begin
            //-NPR5.30
            //-NPR5.29 [262116]
            AuditRoll.Reset;
            AuditRoll.SetRange(Posted, true);
            AuditRoll.SetRange("Item Entry Posted", false);
            AuditRoll.SetFilter("Sale Date", '<>%1', 0D);
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
            AuditRoll.SetRange(Type, AuditRoll.Type::Item);
            if AuditRoll.IsEmpty then
                exit;

            AuditRoll.FindSet;
            repeat
                AuditRoll2.Copy(AuditRoll);
                AuditRoll2.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
                Clear(PostAuditRoll);
                PostAuditRoll.ShowProgress(false);
                PostAuditRoll.RunCode(AuditRoll2);
            until AuditRoll.Next = 0;
            //+NPR5.29 [262116]
        end;
    end;

    var
        PostAuditRoll: Codeunit "NPR Post audit roll";
        AuditRoll: Record "NPR Audit Roll";
        AuditRoll2: Record "NPR Audit Roll";
        Text001: Label 'Stopped Audit Roll Posting, since the timeslot is Invalid';
        Text002: Label 'Audit Roll Posted for Register No %1 for Date %2';

    [EventSubscriber(ObjectType::Table, 6059902, 'OnAfterValidateEvent', 'Object No.', false, false)]
    local procedure Initialize(var Rec: Record "NPR Task Line"; var xRec: Record "NPR Task Line"; CurrFieldNo: Integer)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
        TaskWorkerGroup: Record "NPR Task Worker Group";
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
        FieldType: Option Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFilter;
    begin
        //-NPR5.30 [265042]
        with Rec do begin
            if (xRec."Object No." = 6059912) and ("Object No." <> 6059912) then begin
                TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
                TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
                TaskLineParam.SetRange("Journal Line No.", "Line No.");
                TaskLineParam.DeleteAll;
                "Call Object With Task Record" := false;
            end;

            if "Object No." <> 6059912 then
                exit;

            if GuiAllowed then
                if not Confirm(Text001) then
                    exit;

            TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
            TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
            TaskLineParam.SetRange("Journal Line No.", "Line No.");
            TaskLineParam.DeleteAll;

            InsertParameter('SKIPPOSTGLENTRY', FieldType::Boolean);
            InsertParameter('SKIPPOSTILENTRY', FieldType::Boolean);

            "Call Object With Task Record" := true;
        end;
        //+NPR5.30
    end;
}

