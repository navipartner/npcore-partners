codeunit 6150697 "NPR RetailDataModel AR Upgr."
{
    //this codeunit is changed to Upgrade to handle Obsolete fields and it needs to be called from Powershell when upgrade from older databases is runned
    Subtype = Upgrade;

    Permissions = TableData "NPR Audit Roll" = rimd;

    trigger OnRun()
    begin
        UpgradeAuditRollStep1();
        OnActivatePosEntryPosting();
    end;

    var
        TmpAuditRollBuffer: Record "NPR Audit Roll" temporary;
        ProgressDialog: Dialog;
        EstNoOfEntries: Integer;
        Progress: Integer;
        NextProgress: Integer;
        NoOfPOSEntriesCreated: Integer;
        StartDateTime: DateTime;
        Counter: Integer;
        CHECKPOINT_PROGRESS: Label 'Creating checkpoints for: %1 %2\\@1@@@@@@@@';
        ALL_REGISTERS_MUST_BE_BALANCED: Label 'Not all %1 have %2 %3! Only %1 with %2 %3 will have their balance transfered. Do you want to continue anyway?';
        NOT_ALL_CR_HAVE_POS_UNIT: Label 'All %1 must have a %2 when activating POS Entry posting. %1 %3 is missing its %2.';

    procedure UpgradeAuditRollStep1()
    var
        AuditRoll: Record "NPR Audit Roll";
        xAuditRoll: Record "NPR Audit Roll";
        LastAuditRoll: Record "NPR Audit Roll";
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSUnit: Record "NPR POS Unit";
        POSLedgerRegister: Record "NPR POS Period Register";
        VATAmountLine: Record "VAT Amount Line";
        HasOpenPOSLedgerRegister: Boolean;
    begin
        //Use "Audit Roll to POS Entry Link" to determine how far the Migration has come, and if new Datamodel have been disabled and therefore
        //needs to be rolled up to date again.
        if not AuditRolltoPOSEntryLink.IsEmpty and GuiAllowed then
            if Confirm('Do you want to rebuild the POS Entries from the Audit Roll?') then
                AuditRolltoPOSEntryLink.DeleteAll();  //Remove this after test!

        AuditRoll.SetCurrentKey("Clustered Key");
        AuditRolltoPOSEntryLink.LockTable();
        if AuditRolltoPOSEntryLink.FindLast() then
            AuditRoll.SetFilter("Clustered Key", '>%1', AuditRolltoPOSEntryLink."Link Entry No.")
        else
            InitDatamodel();

        StartDateTime := CurrentDateTime;
        if AuditRoll.FindSet() then begin
            if GuiAllowed then
                ProgressDialog.Open('Upgrade Step 1\' +
                                    'Processing Audit Roll entries @1@@@@@@@@\' +
                                    'Estimated no of AR entries #2########\' +
                                    'No of POS Entries created #3########\' +
                                    'Elapsed time #4########');
            LastAuditRoll.SetCurrentKey("Clustered Key");
            LastAuditRoll.LockTable();
            LastAuditRoll.FindLast();
            EstNoOfEntries := LastAuditRoll."Clustered Key" - AuditRoll."Clustered Key";
            if GuiAllowed then
                ProgressDialog.Update(2, EstNoOfEntries);
            repeat
                if GuiAllowed then begin
                    Progress := Round(9999 * (1 - (LastAuditRoll."Clustered Key" - AuditRoll."Clustered Key") / EstNoOfEntries), 1);
                    if Progress >= NextProgress then begin
                        ProgressDialog.Update(1, Progress);
                        ProgressDialog.Update(3, NoOfPOSEntriesCreated);
                        ProgressDialog.Update(4, Format(CurrentDateTime - StartDateTime));
                        NextProgress := Round(Progress, 100, '>');
                    end;
                end;
                if AuditRoll."Sales Ticket No." = '' then
                    AuditRoll."Sales Ticket No." := AuditRoll."Offline receipt no.";

                if (AuditRoll."Register No." <> xAuditRoll."Register No.") or
                   (AuditRoll."Sales Ticket No." <> xAuditRoll."Sales Ticket No.") or
                   ((AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment) and (AuditRoll.Type = AuditRoll.Type::"Open/Close")) then begin
                    if NoOfPOSEntriesCreated > 0 then begin
                        FinalizePOSEntry(POSEntry);
                        CalcVATAmountLines(POSEntry, VATAmountLine, POSSalesLine);
                        PersistVATAmountLines(POSEntry, VATAmountLine);
                    end;

                    if POSUnit."No." <> AuditRoll."Register No." then
                        if POSUnit.Get(AuditRoll."Register No.") then;

                    POSEntry.Init();
                    POSEntry."Entry No." := 0; //Auto Incr.
                    POSEntry."POS Store Code" := POSUnit."POS Store Code";
                    POSEntry."POS Unit No." := AuditRoll."Register No.";
                    POSEntry."Document No." := AuditRoll."Sales Ticket No.";
                    POSEntry."Entry Type" := POSEntry."Entry Type"::Comment; //Default, until possible lines changes this.
                    POSEntry."Entry Date" := AuditRoll."Sale Date";
                    POSEntry."Posting Date" := POSEntry."Entry Date";
                    POSEntry."Document Date" := POSEntry."Entry Date";
                    POSEntry."POS Sale ID" := AuditRoll."POS Sale ID";
                    POSEntry.Insert();

                    if (POSEntry."POS Unit No." <> POSLedgerRegister."POS Unit No.") or
                       (POSLedgerRegister.Status <> POSLedgerRegister.Status::OPEN) then begin
                        POSLedgerRegister.SetCurrentKey("POS Unit No.");
                        POSLedgerRegister.SetRange("POS Unit No.", POSEntry."POS Unit No.");
                        if POSLedgerRegister.FindLast() then
                            HasOpenPOSLedgerRegister := (POSLedgerRegister.Status = POSLedgerRegister.Status::OPEN)
                        else
                            HasOpenPOSLedgerRegister := false;
                        if not HasOpenPOSLedgerRegister then begin
                            POSLedgerRegister.Init();
                            POSLedgerRegister."No." := 0; //Auto Increment;
                            POSLedgerRegister."POS Store Code" := POSEntry."POS Store Code";
                            POSLedgerRegister."POS Unit No." := POSEntry."POS Unit No.";
                            POSLedgerRegister."Opening Entry No." := POSEntry."Entry No.";
                            POSLedgerRegister.Status := POSLedgerRegister.Status::OPEN;
                            POSLedgerRegister.Insert();
                        end;
                    end;
                    POSEntry."POS Period Register No." := POSLedgerRegister."No.";

                    AuditRolltoPOSEntryLink.Init();
                    AuditRolltoPOSEntryLink."Link Entry No." := 0; //Auto Increment
                    AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
                    AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                    AuditRolltoPOSEntryLink."Upgrade Step" := 1;
                    AuditRolltoPOSEntryLink.Insert();
                    NoOfPOSEntriesCreated += 1;
                end;

                case AuditRoll."Sale Type" of
                    AuditRoll."Sale Type"::Sale,
                  AuditRoll."Sale Type"::"Out payment",
                  AuditRoll."Sale Type"::"Debit Sale",
                  AuditRoll."Sale Type"::Deposit:
                        InsertPOSSaleLine(AuditRoll, POSEntry, POSSalesLine);
                    AuditRoll."Sale Type"::Comment:
                        if (AuditRoll.Type = AuditRoll.Type::"Open/Close") and AuditRoll.Balancing then
                            InsertPOSBalancingLine(AuditRoll, POSEntry, POSLedgerRegister, POSBalancingLine)
                        else
                            POSEntry.Description := CopyStr(AuditRoll.Description, 1, MaxStrLen(POSEntry.Description));//InsertPOSSaleLine(AuditRoll,POSEntry,POSSalesLine);
                    AuditRoll."Sale Type"::Payment:
                        InsertPOSPaymentLine(AuditRoll, POSEntry, POSPaymentLine);
                    else
                        Error('Sales Line Sale Type %1 not implemented in migration (%2 %3 %4)', AuditRoll."Sale Type", AuditRoll.TableName, AuditRoll.FieldName("Clustered Key"), AuditRoll."Clustered Key");
                end;
                UpdatePOSEntry(POSEntry, AuditRoll);
                xAuditRoll := AuditRoll;
            until AuditRoll.Next() = 0;
            if NoOfPOSEntriesCreated > 0 then begin
                FinalizePOSEntry(POSEntry);
                CalcVATAmountLines(POSEntry, VATAmountLine, POSSalesLine);
                PersistVATAmountLines(POSEntry, VATAmountLine);
            end;
            if GuiAllowed then
                ProgressDialog.Close();
        end;
    end;

    procedure UpgradeAuditRoll(Step: Integer)
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
        RunningDuration: Duration;
        PreviousEntryNo: Integer;
    begin
        if Step < 2 then
            Error('UpgradeAuditRoll function is only allowed to be run for step 2 or more');

        if GuiAllowed then
            ProgressDialog.Open(StrSubstNo('Upgrade Step %1\', Step) +
                                'Processing Audit Roll Link entries @1@@@@@@@@\' +
                                'Estimated no of AR Link entries #2########\' +
                                'Elapsed time #4########\' +
                                'Estimated time left #5#######');
        AuditRolltoPOSEntryLink.SetCurrentKey("POS Entry No.", "Line Type", "Line No.");
        AuditRolltoPOSEntryLink.SetRange("Link Source", AuditRolltoPOSEntryLink."Link Source"::"Data Model Upgrade");
        EstNoOfEntries := AuditRolltoPOSEntryLink.Count();
        StartDateTime := CurrentDateTime;
        if EstNoOfEntries = 0 then
            Error('No Entries to upgrade');
        if GuiAllowed then
            ProgressDialog.Update(2, EstNoOfEntries);
        Counter := 0;
        if AuditRolltoPOSEntryLink.FindSet() then
            repeat
                if GuiAllowed then begin
                    Counter := Counter + 1;
                    Progress := Round((Counter / EstNoOfEntries) * 10000, 1);
                    if Progress >= NextProgress then begin
                        ProgressDialog.Update(1, Progress);
                        RunningDuration := CurrentDateTime - StartDateTime;
                        ProgressDialog.Update(4, Format(RunningDuration));
                        ProgressDialog.Update(5, Format(Round(((RunningDuration * 1) * ((EstNoOfEntries - Counter) / Counter)) / (1000 * 60))) + ' minutes');
                        NextProgress := Round(Progress, 10, '>');
                    end;
                end;
                if AuditRolltoPOSEntryLink."Upgrade Step" = Step - 1 then begin
                    if PreviousEntryNo <> AuditRolltoPOSEntryLink."POS Entry No." then begin
                        if POSEntry.Get(AuditRolltoPOSEntryLink."POS Entry No.") then begin
                            case Step of
                                2:
                                    RecalulatePOSEntry(POSEntry);
                                else
                                    Error('Not Implemented');
                            end;
                        end;
                    end;
                end;
                PreviousEntryNo := AuditRolltoPOSEntryLink."POS Entry No.";
                AuditRolltoPOSEntryLink."Upgrade Step" := Step;
                AuditRolltoPOSEntryLink.Modify();
            until AuditRolltoPOSEntryLink.Next() = 0;
        if GuiAllowed then
            ProgressDialog.Close();
    end;

    local procedure InsertPOSSaleLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        IUoM: Record "Item Unit of Measure";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        AuditRollComment: Record "NPR Audit Roll";
    begin
        POSSalesLine.Init();
        POSSalesLine."POS Entry No." := POSEntry."Entry No.";
        POSSalesLine."Line No." := AuditRoll."Line No.";
        POSSalesLine."POS Store Code" := POSEntry."POS Store Code";
        POSSalesLine."POS Unit No." := AuditRoll."Register No.";
        POSSalesLine."Document No." := AuditRoll."Sales Ticket No.";
        POSSalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSSalesLine."Customer No." := AuditRoll."Customer No.";
        POSSalesLine."Salesperson Code" := AuditRoll."Salesperson Code";

        case AuditRoll.Type of
            AuditRoll.Type::Item:
                POSSalesLine.Type := POSSalesLine.Type::Item;
            AuditRoll.Type::"G/L":
                POSSalesLine.Type := POSSalesLine.Type::"G/L Account";
            AuditRoll.Type::Comment:
                POSSalesLine.Type := POSSalesLine.Type::Comment;
            AuditRoll.Type::Customer:
                POSSalesLine.Type := POSSalesLine.Type::Customer;
            AuditRoll.Type::"Debit Sale":
                begin
                    POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
                    POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
                    POSEntry.Description := 'Debit sale';
                    case AuditRoll."Customer Type" of
                        AuditRoll."Customer Type"::"Ord.":
                            POSEntry."Customer No." := AuditRoll."Customer No.";
                        AuditRoll."Customer Type"::Cash:
                            POSEntry."Contact No." := AuditRoll."Customer No.";
                    end;
                end;
            else
                Error('Sales Line Type %1 not implemented in migration (%2 %3 %4)', AuditRoll.Type, AuditRoll.TableName, AuditRoll.FieldName("Clustered Key"), AuditRoll."Clustered Key");
        end;
        POSSalesLine."Exclude from Posting" := ExcludeFromPosting(AuditRoll);
        POSSalesLine."No." := AuditRoll."No.";
        POSSalesLine."Variant Code" := AuditRoll."Variant Code";
        POSSalesLine."Location Code" := AuditRoll.Lokationskode;
        POSSalesLine."Posting Group" := AuditRoll."Posting Group";
        POSSalesLine.Description := AuditRoll.Description;

        //Description 2?

        if POSSalesLine.Type = POSSalesLine.Type::"G/L Account" then
            if GLAccount.Get(POSSalesLine."No.") then
                POSSalesLine."Gen. Posting Type" := GLAccount."Gen. Posting Type";
        POSSalesLine."Gen. Bus. Posting Group" := AuditRoll."Gen. Bus. Posting Group";
        POSSalesLine."VAT Bus. Posting Group" := AuditRoll."VAT Bus. Posting Group";
        POSSalesLine."Gen. Prod. Posting Group" := AuditRoll."Gen. Prod. Posting Group";
        POSSalesLine."VAT Prod. Posting Group" := AuditRoll."VAT Prod. Posting Group";
        POSSalesLine."Tax Area Code" := AuditRoll."Tax Area Code";
        POSSalesLine."Tax Liable" := AuditRoll."Tax Liable";
        POSSalesLine."Tax Group Code" := AuditRoll."Tax Group Code";
        POSSalesLine."Use Tax" := AuditRoll."Use Tax";
        if VATPostingSetup.Get(POSSalesLine."VAT Bus. Posting Group", POSSalesLine."VAT Prod. Posting Group") then begin
            POSSalesLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
            POSSalesLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
        end;
        POSSalesLine."Unit of Measure Code" := AuditRoll."Unit of Measure Code";
        POSSalesLine.Quantity := AuditRoll.Quantity;
        if (POSSalesLine.Type = POSSalesLine.Type::Item) then begin
            if Item.Get(POSSalesLine."No.") then begin
                POSSalesLine."Item Category Code" := Item."Item Category Code";
            end;
            if IUoM.Get(POSSalesLine."No.", POSSalesLine."Unit of Measure Code") then
                POSSalesLine."Qty. per Unit of Measure" := IUoM."Qty. per Unit of Measure";
        end;
        if POSSalesLine."Qty. per Unit of Measure" = 0 then
            POSSalesLine."Qty. per Unit of Measure" := 1;
        POSSalesLine."Quantity (Base)" := Round(POSSalesLine."Qty. per Unit of Measure" * POSSalesLine.Quantity, 0.00001);
        POSSalesLine."Unit Price" := AuditRoll."Unit Price";
        POSSalesLine."Unit Cost (LCY)" := AuditRoll."Unit Cost (LCY)";
        POSSalesLine."VAT %" := AuditRoll."VAT %";
        POSSalesLine."Discount Type" := POSSalesLine."Discount Type";
        POSSalesLine."Discount Code" := POSSalesLine."Discount Code";
        POSSalesLine."Discount Authorised by" := POSSalesLine."Discount Authorised by";
        POSSalesLine."Reason Code" := POSSalesLine."Reason Code";
        POSSalesLine."Line Discount Amount Excl. VAT" := Round(AuditRoll."Line Discount Amount" / (1 + AuditRoll."VAT %" / 100)); //Assuming Line Disc. Amount was alwas incl. VAYT
        POSSalesLine."Line Discount Amount Incl. VAT" := AuditRoll."Line Discount Amount";
        POSSalesLine."Amount Excl. VAT" := AuditRoll.Amount;
        POSSalesLine."Amount Incl. VAT" := AuditRoll."Amount Including VAT";
        POSSalesLine."VAT Base Amount" := AuditRoll."VAT Base Amount";

        //Special handling of Outpayments
        if AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Out payment" then begin
            if (POSSalesLine."Amount Incl. VAT" <> 0) and (POSSalesLine."Amount Excl. VAT" = 0) then
                POSSalesLine."Amount Excl. VAT" := POSSalesLine."Amount Incl. VAT"; //Probably payment roundings
            POSSalesLine."Unit Price" := -POSSalesLine."Unit Price";
            POSSalesLine."Amount Excl. VAT" := -POSSalesLine."Amount Excl. VAT";
            POSSalesLine."Amount Incl. VAT" := -POSSalesLine."Amount Incl. VAT";
        end;

        //LCY amounts are copied directly since old auditroll was always in LCY
        POSSalesLine."Amount Excl. VAT (LCY)" := POSSalesLine."Amount Excl. VAT";
        POSSalesLine."Amount Incl. VAT (LCY)" := POSSalesLine."Amount Incl. VAT";
        POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := POSSalesLine."Line Discount Amount Excl. VAT";
        POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := POSSalesLine."Line Discount Amount Incl. VAT";

        POSSalesLine."Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
        POSSalesLine."Orig. POS Line No." := AuditRoll."Orig. POS Line No.";

        //TODO: Implement these and consider Item Group
        //POSSalesLine."Item Category Code" :=
        //POSSalesLine.Nonstock :=
        //POSSalesLine."BOM Item No." :=
        POSSalesLine."Serial No." := AuditRoll."Serial No.";
        POSSalesLine."Return Reason Code" := AuditRoll."Return Reason Code";

        POSSalesLine."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
        POSSalesLine."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        POSSalesLine."Dimension Set ID" := AuditRoll."Dimension Set ID";

        //INSERT;
        if not POSSalesLine.Insert() then begin
            POSSalesLine."Line No." := POSSalesLine."Line No." + 1000000; //Fix error with duplicate Line No.'s in migration
            POSSalesLine.Insert();
        end;
        AuditRolltoPOSEntryLink.Init();
        AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
        AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
        AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
        AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Sale;
        AuditRolltoPOSEntryLink."Line No." := POSSalesLine."Line No.";
        AuditRolltoPOSEntryLink.Insert();

        //Update POS Entry
        case AuditRoll."Sale Type" of
            AuditRoll."Sale Type"::"Debit Sale":
                begin
                    POSEntry."Entry Type" := POSEntry."Entry Type"::"Credit Sale";
                    AuditRollComment.Reset();
                    AuditRollComment.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
                    AuditRollComment.SetRange(Type, AuditRollComment.Type::Comment);
                    if AuditRollComment.FindFirst() then
                        POSEntry.Description := AuditRollComment.Description;
                end;
            AuditRoll."Sale Type"::Sale:
                begin
                    POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
                    POSEntry.Description := 'Sales Ticket ' + Format(AuditRoll."Sales Ticket No.");
                end;
            AuditRoll."Sale Type"::Deposit, AuditRoll."Sale Type"::"Out payment":
                begin
                    POSEntry.Description := AuditRoll.Description;
                end;
        end;

        if POSEntry."Dimension Set ID" = 0 then begin
            POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
            POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        end;
        if AuditRoll."Item Entry Posted" then
            POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::Posted;
        if AuditRoll."Salgspris inkl. moms" then
            POSEntry."Prices Including VAT" := true;
        //Update measures
        if POSSalesLine.Type = POSSalesLine.Type::Item then begin
            POSEntry."Item Sales (LCY)" += POSSalesLine."Amount Incl. VAT";
            POSEntry."Discount Amount" += POSSalesLine."Line Discount Amount Excl. VAT";
            if POSSalesLine.Quantity < 0 then
                POSEntry."Return Sales Quantity" -= POSSalesLine.Quantity
            else
                POSEntry."Sales Quantity" += POSSalesLine.Quantity;
        end;
        POSEntry."Amount Excl. Tax" += POSSalesLine."Amount Excl. VAT";
        POSEntry."Tax Amount" += POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT";
        POSEntry."Amount Incl. Tax" += POSSalesLine."Amount Incl. VAT";
    end;

    local procedure InsertPOSPaymentLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
    begin
        POSPaymentLine.Init();
        POSPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSPaymentLine."Line No." := AuditRoll."Line No.";
        POSPaymentLine."POS Store Code" := POSEntry."POS Store Code";
        POSPaymentLine."POS Unit No." := AuditRoll."Register No.";
        POSPaymentLine."Document No." := AuditRoll."Sales Ticket No.";
        POSPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        case AuditRoll.Type of
            AuditRoll.Type::Payment:
#pragma warning disable AA0139
                POSPaymentLine."POS Payment Method Code" := AuditRoll."No.";
#pragma warning restore
            else
                Error('Payment Line Type %1 not implemented in migration (%2 %3 %4)', AuditRoll.Type, AuditRoll.TableName, AuditRoll.FieldName("Clustered Key"), AuditRoll."Clustered Key");
        end;
        POSPaymentLine."POS Payment Bin Code" := POSPaymentLine."POS Unit No."; //POS Unit = POS Payment Bin default for now
        POSPaymentLine.Description := AuditRoll.Description;
        POSPaymentLine.Amount := AuditRoll."Amount Including VAT";
        POSPaymentLine."Payment Amount" := AuditRoll."Amount Including VAT";
        POSPaymentLine."Amount (LCY)" := AuditRoll."Amount Including VAT";
        POSPaymentLine."Amount (Sales Currency)" := AuditRoll."Amount Including VAT";

        POSPaymentLine."Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
        POSPaymentLine."Orig. POS Line No." := AuditRoll."Orig. POS Line No.";
        POSPaymentLine.EFT := AuditRoll."Cash Terminal Approved";

        POSPaymentLine."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
        POSPaymentLine."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        POSPaymentLine."Dimension Set ID" := AuditRoll."Dimension Set ID";

        POSPaymentLine.Insert();
        AuditRolltoPOSEntryLink.Init();
        AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
        AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
        AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
        AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Payment;
        AuditRolltoPOSEntryLink."Line No." := POSPaymentLine."Line No.";
        AuditRolltoPOSEntryLink.Insert();

        //Update POS Entry
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale"; //If any payment line its a Sale
        if (AuditRoll."Dimension Set ID" <> 0) and (POSEntry."Dimension Set ID" <> AuditRoll."Dimension Set ID") then begin //Favor payment line dims over sales lines for the header
            POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
            POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        end;
    end;

    local procedure InsertPOSBalancingLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSLedgerRegister: Record "NPR POS Period Register"; var POSBalancingLine: Record "NPR POS Balancing Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        CashRegister: Record "NPR Register";
        CashRegPeriod: Record "NPR Period";
    begin
        POSBalancingLine.Init();
        POSBalancingLine."POS Entry No." := POSEntry."Entry No.";
        POSBalancingLine."Line No." := AuditRoll."Line No.";
        POSBalancingLine."POS Store Code" := POSEntry."POS Store Code";
        POSBalancingLine."POS Unit No." := AuditRoll."Register No.";
        POSBalancingLine."Document No." := AuditRoll."Sales Ticket No.";
        POSBalancingLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSBalancingLine."POS Payment Bin Code" := POSBalancingLine."POS Unit No.";  //POS Unit = POS Payment Bin default for now

        if CashRegister.Get(AuditRoll."Register No.") then
            POSBalancingLine."POS Payment Method Code" := CashRegister."Primary Payment Type";

        POSBalancingLine.Description := CopyStr(AuditRoll.Description, 1, MaxStrLen(POSBalancingLine.Description));

        CashRegPeriod.SetRange("Register No.", AuditRoll."Register No.");
        CashRegPeriod.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        if CashRegPeriod.FindLast() then begin
            POSBalancingLine."Calculated Amount" := CashRegPeriod."Balanced Cash Amount" + CashRegPeriod.Difference;
            POSBalancingLine."Balanced Amount" := CashRegPeriod."Balanced Cash Amount";
            POSBalancingLine."Balanced Diff. Amount" := CashRegPeriod.Difference;
            POSBalancingLine."New Float Amount" := CashRegPeriod."Closing Cash";
            POSBalancingLine."Deposit-To Bin Amount" := CashRegPeriod."Deposit in Bank";
        end else begin //Fall back to Audit Roll values
            POSBalancingLine."Calculated Amount" := AuditRoll."Closing Cash" + AuditRoll."Transferred to Balance Account" + AuditRoll.Difference;
            POSBalancingLine."Balanced Amount" := AuditRoll."Closing Cash" + AuditRoll."Transferred to Balance Account";
            POSBalancingLine."Balanced Diff. Amount" := AuditRoll.Difference;
            POSBalancingLine."New Float Amount" := AuditRoll."Closing Cash";
            POSBalancingLine."Deposit-To Bin Amount" := AuditRoll."Transferred to Balance Account";
        end;

        POSBalancingLine."Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
        POSBalancingLine."Orig. POS Line No." := AuditRoll."Orig. POS Line No.";

        POSBalancingLine."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
        POSBalancingLine."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        POSBalancingLine."Dimension Set ID" := AuditRoll."Dimension Set ID";

        POSBalancingLine.Insert();
        AuditRolltoPOSEntryLink.Init();
        AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
        AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
        AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
        AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Balancing;
        AuditRolltoPOSEntryLink."Line No." := POSBalancingLine."Line No.";
        AuditRolltoPOSEntryLink.Insert();
        POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
        POSEntry.Description := AuditRoll.Description;
        if POSEntry."Dimension Set ID" = 0 then begin
            POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
            POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
        end;

        //Close the current POS Ledger Register
        POSLedgerRegister."Document No." := AuditRoll."Posted Doc. No.";
        POSLedgerRegister."Closing Entry No." := POSBalancingLine."POS Entry No.";
        POSLedgerRegister.Status := POSLedgerRegister.Status::CLOSED;
        POSLedgerRegister.Modify();
    end;

    local procedure InitDatamodel()
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSLedgerRegister: Record "NPR POS Period Register";
        POSEntryCommentLine: Record "NPR POS Entry Comm. Line";
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        if (not POSEntry.IsEmpty) or
           (not POSSalesLine.IsEmpty) or
           (not POSPaymentLine.IsEmpty) or
           (not POSBalancingLine.IsEmpty) or
           (not POSLedgerRegister.IsEmpty) or
           (not POSEntryCommentLine.IsEmpty) then begin
            if Confirm('It seems that this is the inital Poseidon activation, but data exits in data tables. Do you want to delete all data in these tables to proceed?', false) then begin
                POSEntry.DeleteAll();
                POSSalesLine.DeleteAll();
                POSPaymentLine.DeleteAll();
                POSBalancingLine.DeleteAll();
                POSLedgerRegister.DeleteAll();
                POSEntryCommentLine.DeleteAll();
                POSTaxAmountLine.DeleteAll();
            end else
                Error('Can not initialize Poseidon Datamodel.');
        end;
    end;

    procedure BufferAuditRollLink(var AuditRoll: Record "NPR Audit Roll")
    begin
        TmpAuditRollBuffer.Init();
        TmpAuditRollBuffer := AuditRoll;
        TmpAuditRollBuffer.Insert();
    end;

    local procedure UpdatePOSEntry(var POSEntry: Record "NPR POS Entry"; var AuditRoll: Record "NPR Audit Roll")
    begin
        if (POSEntry."Starting Time" = 0T) or (POSEntry."Starting Time" > AuditRoll."Starting Time") then
            POSEntry."Starting Time" := AuditRoll."Starting Time";
        if (POSEntry."Ending Time" = 0T) or (POSEntry."Ending Time" < AuditRoll."Closing Time") then
            POSEntry."Ending Time" := AuditRoll."Closing Time";

        if POSEntry."Salesperson Code" = '' then
            POSEntry."Salesperson Code" := AuditRoll."Salesperson Code";

        case AuditRoll."Customer Type" of
            AuditRoll."Customer Type"::"Ord.":
                if POSEntry."Customer No." = '' then
                    POSEntry."Customer No." := AuditRoll."Customer No.";
            AuditRoll."Customer Type"::Cash:
                if POSEntry."Contact No." = '' then
                    POSEntry."Contact No." := AuditRoll."Customer No.";
        end;

        if POSEntry."No. Printed" < AuditRoll."No. Printed" then
            POSEntry."No. Printed" := AuditRoll."No. Printed";

        if AuditRoll.Posted then begin
            if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Debit Sale") then
                POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted"
            else
                if POSEntry."Post Entry Status" <> POSEntry."Post Entry Status"::"Not To Be Posted" then
                    POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::Posted;
        end;
    end;

    local procedure FinalizePOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
        if POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Unposted then
            POSEntry."Post Item Entry Status" := POSEntry."Post Entry Status";
        POSEntry."Amount Incl. Tax & Round" := POSEntry."Amount Incl. Tax" + POSEntry."Rounding Amount (LCY)";
        POSEntry.Modify();
    end;

    local procedure RecalulatePOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        SavedPostingStatus: Integer;
        WasModified: Boolean;
    begin
        SavedPostingStatus := POSEntry."Post Entry Status";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::Unposted;
        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);
        POSEntry."Post Entry Status" := SavedPostingStatus;
        if WasModified then
            POSEntry.Modify(true);
    end;

    procedure DuplicateAuditRollTicketToPosEntry(SalesTicketNo: Code[20])
    var
        AuditRoll: Record "NPR Audit Roll";
        xAuditRoll: Record "NPR Audit Roll";
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSUnit: Record "NPR POS Unit";
        POSLedgerRegister: Record "NPR POS Period Register";
        HasOpenPOSLedgerRegister: Boolean;
    begin
        if (SalesTicketNo = '') then
            exit;

        AuditRoll.SetFilter("Sales Ticket No.", '=%1', SalesTicketNo);
        if (AuditRoll.IsEmpty()) then
            exit;

        repeat
            if (AuditRoll."Register No." <> xAuditRoll."Register No.") or
                (AuditRoll."Sales Ticket No." <> xAuditRoll."Sales Ticket No.") or
                ((AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment) and (AuditRoll.Type = AuditRoll.Type::"Open/Close")) then begin
                if NoOfPOSEntriesCreated > 0 then
                    FinalizePOSEntry(POSEntry);

                if POSUnit."No." <> AuditRoll."Register No." then
                    if POSUnit.Get(AuditRoll."Register No.") then;

                POSEntry.Init();
                POSEntry."Entry No." := 0; //Auto Incr.
                POSEntry."POS Store Code" := POSUnit."POS Store Code";
                POSEntry."POS Unit No." := AuditRoll."Register No.";
                POSEntry."Document No." := AuditRoll."Sales Ticket No.";
                POSEntry."Entry Type" := POSEntry."Entry Type"::Comment; //Default, until possible lines changes this.
                POSEntry."Entry Date" := AuditRoll."Sale Date";
                POSEntry."Posting Date" := POSEntry."Entry Date";
                POSEntry."Document Date" := POSEntry."Entry Date";
                POSEntry."POS Sale ID" := AuditRoll."POS Sale ID";
                POSEntry.Insert();

                if (POSEntry."POS Unit No." <> POSLedgerRegister."POS Unit No.") or
                    (POSLedgerRegister.Status <> POSLedgerRegister.Status::OPEN) then begin
                    POSLedgerRegister.SetCurrentKey("POS Unit No.");
                    POSLedgerRegister.SetRange("POS Unit No.", POSEntry."POS Unit No.");
                    if POSLedgerRegister.FindLast() then
                        HasOpenPOSLedgerRegister := (POSLedgerRegister.Status = POSLedgerRegister.Status::OPEN)
                    else
                        HasOpenPOSLedgerRegister := false;
                    if not HasOpenPOSLedgerRegister then begin
                        POSLedgerRegister.Init();
                        POSLedgerRegister."No." := 0; //Auto Increment;
                        POSLedgerRegister."POS Store Code" := POSEntry."POS Store Code";
                        POSLedgerRegister."POS Unit No." := POSEntry."POS Unit No.";
                        POSLedgerRegister."Opening Entry No." := POSEntry."Entry No.";
                        POSLedgerRegister.Status := POSLedgerRegister.Status::OPEN;
                        POSLedgerRegister.Insert();
                    end;
                end;
                POSEntry."POS Period Register No." := POSLedgerRegister."No.";

                AuditRolltoPOSEntryLink.Init();
                AuditRolltoPOSEntryLink."Link Entry No." := 0; //Auto Increment
                AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
                AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                AuditRolltoPOSEntryLink."Upgrade Step" := 1;
                AuditRolltoPOSEntryLink.Insert();
                NoOfPOSEntriesCreated += 1;
                case AuditRoll."Sale Type" of
                    AuditRoll."Sale Type"::Sale,
                  AuditRoll."Sale Type"::"Out payment",
                  AuditRoll."Sale Type"::"Debit Sale",
                  AuditRoll."Sale Type"::Deposit:
                        InsertPOSSaleLine(AuditRoll, POSEntry, POSSalesLine);
                    AuditRoll."Sale Type"::Comment:
                        if (AuditRoll.Type = AuditRoll.Type::"Open/Close") and AuditRoll.Balancing then
                            InsertPOSBalancingLine(AuditRoll, POSEntry, POSLedgerRegister, POSBalancingLine)
                        else
                            POSEntry.Description := CopyStr(AuditRoll.Description, 1, MaxStrLen(POSEntry.Description));//InsertPOSSaleLine(AuditRoll,POSEntry,POSSalesLine);
                    AuditRoll."Sale Type"::Payment:
                        InsertPOSPaymentLine(AuditRoll, POSEntry, POSPaymentLine);
                    else
                        Error('Sales Line Sale Type %1 not implemented in migration (%2 %3 %4)', AuditRoll."Sale Type", AuditRoll.TableName, AuditRoll.FieldName("Clustered Key"), AuditRoll."Clustered Key");
                end;
                UpdatePOSEntry(POSEntry, AuditRoll);
                xAuditRoll := AuditRoll;
            end;
        until AuditRoll.Next() = 0;

        if NoOfPOSEntriesCreated > 0 then
            FinalizePOSEntry(POSEntry);
    end;

    procedure UpgradeSetupsBalancingV3()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentMethodCheck: Record "NPR POS Payment Method";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSUnit: Record "NPR POS Unit";
        POSUnitCheck: Record "NPR POS Unit";
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinCheck: Record "NPR POS Payment Bin";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPostingSetupCheck: Record "NPR POS Posting Setup";
        Register: Record "NPR Register";
        POSStore: Record "NPR POS Store";
        POSUnitBinRelation: Record "NPR POS Unit to Bin Relation";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if GuiAllowed then
            ProgressDialog.Open('Upgrade Setups for BalancingV3 \' +
                                 'Estimated Payment Type @1@@@@@@@@\' +
                                 'Populate POS Payment Bin #2########\' +
                                 'Set POS Posting Setup #3########');
        Register.Reset();
        POSUnit.Reset();
        if Register.FindSet() then begin
            repeat
                if POSUnitCheck.Get(Register."Register No.") then begin
                    POSUnit := POSUnitCheck;
                    POSUnit.Name := Register.Description;
                    POSUnit.Modify();
                end;
            until Register.Next() = 0;
        end;
        //1. Populate POS Payment Method
        POSPaymentMethod.Reset();  // Target
        POSPaymentMethodCheck.Reset();
        PaymentTypePOS.Reset();   //  Source
        Register.Reset();

        PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active); //Check for Active Status
        if PaymentTypePOS.FindSet() then
            repeat
                if GuiAllowed then
                    ProgressDialog.Update(1, PaymentTypePOS.Count());
                POSPaymentMethodCheck.Reset();
                POSPaymentMethod.Reset();
                if not POSPaymentMethodCheck.Get(PaymentTypePOS."No.") then begin
                    POSPaymentMethod.Init();
                    POSPaymentMethod.Code := PaymentTypePOS."No.";
                    case PaymentTypePOS."Processing Type" of

                        PaymentTypePOS."Processing Type"::Cash:
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CASH;

                        PaymentTypePOS."Processing Type"::EFT:
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                        PaymentTypePOS."Processing Type"::"Foreign Credit Voucher":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;

                        PaymentTypePOS."Processing Type"::"Foreign Gift Voucher":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;

                        PaymentTypePOS."Processing Type"::"Finance Agreement":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;

                        PaymentTypePOS."Processing Type"::Payout:
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::PAYOUT;

                        PaymentTypePOS."Processing Type"::"Foreign Currency":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CASH;

                        PaymentTypePOS."Processing Type"::"Gift Voucher":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;

                        PaymentTypePOS."Processing Type"::"Credit Voucher":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;

                        PaymentTypePOS."Processing Type"::"Terminal Card":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                        PaymentTypePOS."Processing Type"::"Manual Card":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                        PaymentTypePOS."Processing Type"::"Other Credit Cards":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                        PaymentTypePOS."Processing Type"::"Debit sale":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;

                        PaymentTypePOS."Processing Type"::Invoice:
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;

                        PaymentTypePOS."Processing Type"::DIBS:
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                        PaymentTypePOS."Processing Type"::"Point Card":
                            POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;

                    end;
                    if PaymentTypePOS."To be Balanced" then
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES
                    else
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::NO;

                    POSPaymentMethod."Post Condensed" := (PaymentTypePOS.Posting = PaymentTypePOS.Posting::Condensed);
                    if (POSPaymentMethod."Post Condensed") and (POSPaymentMethod."Condensed Posting Description" = '') then
                        POSPaymentMethod."Condensed Posting Description" := 'Dagens bevægelser %6 %3 kasse %1';
                    POSPaymentMethod."Rounding Type" := POSPaymentMethod."Rounding Type"::Nearest;
                    POSPaymentMethod."Rounding Precision" := PaymentTypePOS."Rounding Precision";
                    if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CASH then
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;

                    if POSPostingProfile.FindFirst() then begin
                        POSPaymentMethod."Rounding Gains Account" := POSPostingProfile."POS Sales Rounding Account";
                        POSPaymentMethod."Rounding Losses Account" := POSPostingProfile."POS Sales Rounding Account";
                    end;
                    POSPaymentMethod.Insert(true);
                end;
            until PaymentTypePOS.Next() = 0;

        //2. POS Payment Bin
        POSPaymentBin.Reset();
        POSPaymentBinCheck.Reset();
        POSUnit.Reset();
        if POSUnit.FindSet() then
            repeat
                if GuiAllowed then
                    ProgressDialog.Update(2, POSUnit.Count());
                POSPaymentBinCheck.Reset();
                POSPaymentBin.Reset();
                if not POSPaymentBinCheck.Get(POSUnit."No.") then begin
                    POSPaymentBin.Init();
                    POSPaymentBin."No." := POSUnit."No.";
                    POSPaymentBin."POS Store Code" := POSUnit."POS Store Code";
                    POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
                    POSPaymentBin."Eject Method" := 'Printer';
                    POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::CASH_DRAWER;
                    POSPaymentBin.Description := 'Payment Bin' + ' ' + POSPaymentBin."No.";
                    POSPaymentBin.Insert(true);
                end;
                //Default POS Payment Bin
                CreateDefaultBins();
            until POSUnit.Next() = 0;

        POSPostingSetupCheck.Reset();
        if POSPostingSetupCheck.Count() < 1 then begin
            //Global Setup
            POSPostingSetup.Reset();
            PaymentTypePOS.Reset();
            Register.Reset();
            POSPostingSetupCheck.Reset();  //POS Store Code,POS Payment Method Code,POS Payment Bin Code
            PaymentTypePOS.Reset();
            PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active); //Check for Active Status
            if PaymentTypePOS.FindSet() then
                repeat
                    if GuiAllowed then
                        ProgressDialog.Update(3, PaymentTypePOS.Count());
                    if CheckPaymentTypePOSAccount(PaymentTypePOS) then begin
                        POSPostingSetup.Reset();
                        POSPostingSetup.Init();
                        POSPostingSetup."POS Store Code" := '';
                        POSPostingSetup."POS Payment Method Code" := PaymentTypePOS."No.";
                        POSPostingSetup."POS Payment Bin Code" := '';
                        case PaymentTypePOS."Account Type" of
                            PaymentTypePOS."Account Type"::Bank:
                                begin
                                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"Bank Account";
                                    POSPostingSetup."Account No." := PaymentTypePOS."Bank Acc. No.";
                                end;
                            PaymentTypePOS."Account Type"::Customer:
                                begin
                                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::Customer;
                                    POSPostingSetup."Account No." := PaymentTypePOS."Customer No.";
                                end;
                            PaymentTypePOS."Account Type"::"G/L Account":
                                begin
                                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
                                    POSPostingSetup."Account No." := PaymentTypePOS."G/L Account No.";
                                end;
                        end;
                        POSPostingSetup."Difference Account Type" := POSPostingSetup."Difference Account Type"::"G/L Account";
                        if Register.FindFirst() then begin
                            POSPostingSetup."Difference Acc. No." := Register."Difference Account";
                            POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
                        end;
                        POSPostingSetup.Insert(true);
                    end;
                until PaymentTypePOS.Next() = 0;

            //Line Per POS Store
            POSPostingSetup.Reset();
            PaymentTypePOS.Reset();
            POSStore.Reset();
            Register.Reset();
            POSPaymentMethod.Reset();
            POSPostingSetupCheck.Reset();  //POS Store Code,POS Payment Method Code,POS Payment Bin Code
            if POSStore.FindSet() then
                repeat
                    POSPaymentMethod.Reset();
                    POSPaymentMethod.SetRange(POSPaymentMethod."Processing Type", POSPaymentMethod."Processing Type"::CASH);
                    if POSPaymentMethod.FindSet() then
                        repeat
                            if GuiAllowed then
                                ProgressDialog.Update(3, PaymentTypePOS.Count());
                            POSPostingSetup.Reset();
                            POSPostingSetup.Init();
                            POSPostingSetup."POS Store Code" := POSStore.Code;
                            POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
                            POSPostingSetup."POS Payment Bin Code" := 'BANK';
                            if Register.FindFirst() then begin
                                case Register."Balanced Type" of
                                    Register."Balanced Type"::Bank:
                                        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"Bank Account";

                                    Register."Balanced Type"::Finans:
                                        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
                                end;
                            end;
                            POSPostingSetup."Difference Account Type" := POSPostingSetup."Difference Account Type"::"G/L Account";
                            POSPostingSetup."Difference Acc. No." := Register."Difference Account";
                            POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
                            POSPostingSetup.Insert(true);
                        until POSPaymentMethod.Next() = 0;
                until POSStore.Next() = 0;
        end;

        //Create/Update POS Unit to Bin Relation

        POSUnit.Reset();
        if POSUnit.FindSet() then begin
            repeat
                POSUnitBinRelation.Reset();
                POSUnitBinRelation.SetRange("POS Unit No.", POSUnit."No.");
                if POSUnitBinRelation.FindFirst() then begin
                    if POSUnitBinRelation."POS Payment Bin No." = '' then
                        POSUnitBinRelation.Rename(POSUnitBinRelation."POS Unit No.", POSUnit."Default POS Payment Bin");
                end else begin
                    POSUnitBinRelation.Init();
                    POSUnitBinRelation."POS Unit No." := POSUnit."No.";
                    POSUnitBinRelation."POS Payment Bin No." := POSUnit."Default POS Payment Bin";
                    POSUnitBinRelation."POS Unit Status" := POSUnitBinRelation."POS Unit Status"::OPEN;
                    POSUnitBinRelation."POS Payment Bin Status" := POSUnitBinRelation."POS Payment Bin Status"::OPEN;
                    POSUnitBinRelation."POS Unit Name" := POSUnit.Name;
                    POSUnitBinRelation.Insert(true);
                end;
            until POSUnit.Next() = 0;
        end;

        if GuiAllowed then
            ProgressDialog.Close();
    end;

    procedure ExcludeFromPosting(AuditRoll: Record "NPR Audit Roll"): Boolean
    begin
        if AuditRoll.Type in [AuditRoll.Type::Comment] then
            exit(true);
        exit(AuditRoll."Sale Type" in [AuditRoll."Sale Type"::Comment, AuditRoll."Sale Type"::"Open/Close"]);//Remove "Sale Type"::"Debit Sale"
    end;

    local procedure CreateDefaultBins()
    var
        BinNoArray: array[3] of Code[10];
        BinDescArray: array[3] of Text[20];
        i: Integer;
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinCheck: Record "NPR POS Payment Bin";
    begin
        BinNoArray[1] := 'AUTO-BIN';
        BinNoArray[2] := 'BANK';
        BinNoArray[3] := 'SAFE';

        BinDescArray[1] := 'Auto Count Bin';
        BinDescArray[2] := 'Bank';
        BinDescArray[3] := 'Safe';

        for i := 1 to 3 do begin
            if not POSPaymentBinCheck.Get(BinNoArray[i]) then begin
                POSPaymentBin.Init();
                POSPaymentBin."No." := BinNoArray[i];
                POSPaymentBin."POS Store Code" := '';
                POSPaymentBin."Attached to POS Unit No." := '';
                POSPaymentBin."Eject Method" := '';
                POSPaymentBin.Description := BinDescArray[i];
                case i of
                    1:
                        POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::VIRTUAL; //'AUTO-BIN'
                    2:
                        POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::BANK; //'BANK'
                    3:
                        POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::SAFE; //'SAFE'
                end;
                POSPaymentBin.Insert(true);
            end;
        end;
    end;

    local procedure CheckPaymentTypePOSAccount(PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    begin
        case PaymentTypePOS."Account Type" of
            PaymentTypePOS."Account Type"::Bank:
                exit(PaymentTypePOS."Bank Acc. No." <> '');
            PaymentTypePOS."Account Type"::Customer:
                exit(PaymentTypePOS."Customer No." <> '');
            PaymentTypePOS."Account Type"::"G/L Account":
                exit(PaymentTypePOS."G/L Account No." <> '');
            else
                exit(false);
        end;
    end;

    local procedure DeleteDuplicatePOSStore()
    var
        POSStore: Record "NPR POS Store";
        POSStoreDuplicate: Record "NPR POS Store";
        POSStoreTemp: Record "NPR POS Store";
    begin
        Clear(POSStore);
        Clear(POSStoreTemp);
        Clear(POSStoreDuplicate);
        POSStore.SetCurrentKey(POSStore."Location Code", POSStore."Gen. Bus. Posting Group");
        if POSStore.FindSet() then begin
            repeat
                POSStoreTemp := POSStore;
                if (POSStore."Location Code" = POSStoreDuplicate."Location Code") and (POSStore."Gen. Bus. Posting Group" = POSStoreDuplicate."Gen. Bus. Posting Group") then
                    POSStore.Delete();
                POSStoreDuplicate := POSStoreTemp;
            until POSStore.Next() = 0;
        end;
    end;

    local procedure PersistVATAmountLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        PersistentPOSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        if VATAmountLine.FindSet() then
            repeat
                PersistentPOSTaxAmountLine.Init();
                PersistentPOSTaxAmountLine."VAT Identifier" := VATAmountLine."VAT Identifier";
                PersistentPOSTaxAmountLine."Tax Calculation Type" := VATAmountLine."VAT Calculation Type";
                PersistentPOSTaxAmountLine."Tax Group Code" := VATAmountLine."Tax Group Code";
                PersistentPOSTaxAmountLine."Use Tax" := VATAmountLine."Use Tax";
                PersistentPOSTaxAmountLine.Positive := VATAmountLine.Positive;
                PersistentPOSTaxAmountLine."Tax %" := VATAmountLine."VAT %";
                PersistentPOSTaxAmountLine."Tax Base Amount" := VATAmountLine."VAT Base";
                PersistentPOSTaxAmountLine."Tax Amount" := VATAmountLine."VAT Amount";
                PersistentPOSTaxAmountLine."Amount Including Tax" := VATAmountLine."Amount Including VAT";
                PersistentPOSTaxAmountLine."Line Amount" := VATAmountLine."Line Amount";
                PersistentPOSTaxAmountLine."Inv. Disc. Base Amount" := VATAmountLine."Inv. Disc. Base Amount";
                PersistentPOSTaxAmountLine."Invoice Discount Amount" := VATAmountLine."Invoice Discount Amount";
                PersistentPOSTaxAmountLine.Quantity := VATAmountLine.Quantity;
                PersistentPOSTaxAmountLine.Modified := VATAmountLine.Modified;
                PersistentPOSTaxAmountLine."Calculated Tax Amount" := VATAmountLine."Calculated VAT Amount";
                PersistentPOSTaxAmountLine."Tax Difference" := VATAmountLine."VAT Difference";
                PersistentPOSTaxAmountLine."POS Entry No." := POSEntryIn."Entry No.";
                PersistentPOSTaxAmountLine.Insert();
            until VATAmountLine.Next() = 0;
    end;

    procedure CalcVATAmountLines(POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line"; POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        POSEntry: Record "NPR POS Entry";
        TotalVATAmount: Decimal;
    begin
        POSEntry := POSEntryIn;
        VATAmountLine.DeleteAll();

        POSSalesLine.SetRange("POS Entry No.", POSEntryIn."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1', POSSalesLine.Type::Rounding);
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet() then
            repeat
                if ((POSSalesLine."Unit Price" <> 0) and (POSSalesLine.Quantity <> 0)) or (POSSalesLine."Amount Excl. VAT" <> 0) then begin
                    if (POSSalesLine."VAT Calculation Type" in
                       [POSSalesLine."VAT Calculation Type"::"Reverse Charge VAT", POSSalesLine."VAT Calculation Type"::"Sales Tax"])
                    then
                        POSSalesLine."VAT %" := 0;
                    if not VATAmountLine.Get(
                         POSSalesLine."VAT Identifier", POSSalesLine."VAT Calculation Type", POSSalesLine."Tax Group Code", false, POSSalesLine."Amount Excl. VAT" >= 0)
                    then begin
                        VATAmountLine.Init();
                        VATAmountLine."VAT Identifier" := POSSalesLine."VAT Identifier";
                        VATAmountLine."VAT Calculation Type" := POSSalesLine."VAT Calculation Type";
                        VATAmountLine."Tax Group Code" := POSSalesLine."Tax Group Code";
                        VATAmountLine."VAT %" := POSSalesLine."VAT %";
                        VATAmountLine.Modified := true;
                        VATAmountLine.Positive := POSSalesLine."Amount Excl. VAT" >= 0;
                        VATAmountLine.Insert();
                    end;
                    VATAmountLine.Quantity := VATAmountLine.Quantity + POSSalesLine."Quantity (Base)";
                    VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + POSSalesLine."Amount Excl. VAT";
                    VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + POSSalesLine."VAT Difference";
                    VATAmountLine."VAT Base" := VATAmountLine."VAT Base" + POSSalesLine."Amount Excl. VAT";
                    VATAmountLine."Amount Including VAT" := VATAmountLine."Amount Including VAT" + POSSalesLine."Amount Incl. VAT";
                    VATAmountLine."VAT Amount" := VATAmountLine."VAT Amount" + (POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT");
                    VATAmountLine.Modify();
                    TotalVATAmount := TotalVATAmount + POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT";
                end;
            until POSSalesLine.Next() = 0;
    end;

    #region **************** Upgrade from AuditRoll to POS Entry
    procedure OnActivatePosEntryPosting()
    begin

        ActivationValidationCheck();
        MigrateOpenBalance();

        CreatePOSSystemEntry('', UserId, 'POS Entry postings is activated.');
    end;

    procedure OnDeactivatePosEntryPosting()
    begin

        CreatePOSSystemEntry('', UserId, 'POS Entry postings is deactivated.');
    end;

    local procedure ActivationValidationCheck()
    var
        CacheRegister: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
    begin

        CacheRegister.SetFilter(Status, '<>%1', CacheRegister.Status::Afsluttet);
        if (not CacheRegister.IsEmpty()) then
            if (not Confirm(ALL_REGISTERS_MUST_BE_BALANCED, false, CacheRegister.TableCaption, CacheRegister.FieldCaption(Status), Format(CacheRegister.Status::Afsluttet))) then
                Error('POS Entry posting is not activated.');

        CacheRegister.Reset();
        if (CacheRegister.FindSet()) then begin
            repeat
                if (not POSUnit.Get(CacheRegister."Register No.")) then
                    Error(NOT_ALL_CR_HAVE_POS_UNIT, CacheRegister.TableCaption(), POSUnit.TableCaption, CacheRegister."Register No.");
            until (CacheRegister.Next() = 0);
        end;
    end;

    local procedure MigrateOpenBalance()
    var
        POSUnit: Record "NPR POS Unit";
        CashRegister: Record "NPR Register";
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        OpeningEntryNo: Integer;
    begin

        if (POSUnit.FindSet()) then begin
            repeat

                POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."No."); // make sure pos period register is correct
                POSOpenPOSUnit.OpenPOSUnit(POSUnit);
                OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", CopyStr(UserId, 1, 20));
                POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);

                CreateFirstCheckpointForUnit(POSUnit."No.", 'POS Entry Activation - Checkpoint.');
                CreatePOSSystemEntry(POSUnit."No.", UserId, 'Initial Workshift Checkpoint Created.');

            until (POSUnit.Next() = 0);
        end;

        CashRegister.ModifyAll(Status, CashRegister.Status::Ekspedition);

    end;

    local procedure CreatePOSSystemEntry(POSUnitNo: Code[10]; SalespersonCode: Code[10]; Description: Text[80]): Integer
    var
        POSEntry: Record "NPR POS Entry";
    begin

        POSEntry.Init();

        POSEntry."Entry No." := 0;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
        POSEntry."System Entry" := true;

        POSEntry."POS Period Register No." := 0;
        POSEntry."POS Store Code" := '';
        POSEntry."POS Unit No." := POSUnitNo;

        POSEntry."Entry Date" := Today();
        POSEntry."Starting Time" := Time;
        POSEntry."Ending Time" := Time;
        POSEntry."Salesperson Code" := SalespersonCode;

        POSEntry.Description := Description;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";

        POSEntry.Insert();

        exit(POSEntry."Entry No.");
    end;

    procedure CreateFirstCheckpointForUnit(POSUnitNo: Code[10]; Comment: Text[50])
    var
        BinEntry: Record "NPR POS Bin Entry";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        CashRegister: Record "NPR Register";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Window: Dialog;
        CurrentCurrent: Integer;
        MaxCount: Integer;
        ClosingEntryNo: Integer;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin

        if (not POSEntry.FindLast()) then
            exit;

        POSUnit.Get(POSUnitNo);

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint.Insert();

        if (CashRegister.Get(POSUnitNo)) then begin

            if (GuiAllowed) then
                Window.Open(StrSubstNo(CHECKPOINT_PROGRESS, POSUnit.TableCaption, POSUnitNo));
            MaxCount := POSPaymentMethod.Count();

            POSCreateEntry.InsertUnitCloseBeginEntry(POSUnitNo, UserId);

            POSPaymentMethod.FindSet();
            repeat

                BinEntry.Init();
                BinEntry."Entry No." := 0;
                BinEntry."Created At" := CurrentDateTime();

                BinEntry.Type := BinEntry.Type::CHECKPOINT;
                BinEntry."Payment Bin No." := POSUnit."Default POS Payment Bin";

                BinEntry."Transaction Date" := Today();
                BinEntry."Transaction Time" := Time;
                BinEntry.Comment := Comment;

                BinEntry."Register No." := POSUnitNo;
                BinEntry."POS Unit No." := POSUnitNo;
                BinEntry."POS Store Code" := POSUnit."POS Store Code";

                BinEntry."Payment Type Code" := POSPaymentMethod.Code;
                BinEntry."Payment Method Code" := POSPaymentMethod.Code;

                BinEntry.Insert();

                PaymentBinCheckpoint.Init();
                PaymentBinCheckpoint."Entry No." := 0;
                PaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
                PaymentBinCheckpoint."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
                PaymentBinCheckpoint.Status := PaymentBinCheckpoint.Status::TRANSFERED;
                PaymentBinCheckpoint.Type := PaymentBinCheckpoint.Type::ZREPORT;

                PaymentBinCheckpoint."Created On" := CurrentDateTime();
                PaymentBinCheckpoint."Checkpoint Date" := Today();
                PaymentBinCheckpoint."Checkpoint Time" := Time;
                PaymentBinCheckpoint.Comment := BinEntry.Comment;

                PaymentBinCheckpoint."Payment Type No." := BinEntry."Payment Type Code";
                PaymentBinCheckpoint."Payment Method No." := BinEntry."Payment Method Code";
                PaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
                PaymentBinCheckpoint."Payment Bin No." := POSUnit."Default POS Payment Bin";
                PaymentBinCheckpoint."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;

                PaymentBinCheckpoint.Description := POSPaymentMethod.Code;
                PaymentTypePOS.SetFilter("No.", '=%1', POSPaymentMethod.Code);
                if (PaymentTypePOS.FindFirst()) then
                    PaymentBinCheckpoint.Description := PaymentTypePOS.Description;

                if (CashRegister."Primary Payment Type" = PaymentTypePOS."No.") and (CashRegister.Status = CashRegister.Status::Afsluttet) then begin
                    PaymentBinCheckpoint."Calculated Amount Incl. Float" := CashRegister."Closing Cash";
                    PaymentBinCheckpoint."New Float Amount" := CashRegister."Closing Cash";
                end;

                PaymentBinCheckpoint.Insert();

                // Update checkpoint and make total balance on bin entry zero
                PaymentBinCheckpoint.CalcFields("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
                BinEntry."Transaction Amount" := -1 * PaymentBinCheckpoint."Payment Bin Entry Amount";
                BinEntry."Transaction Amount (LCY)" := -1 * PaymentBinCheckpoint."Payment Bin Entry Amount (LCY)";
                BinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
                BinEntry.Modify();

                // Create the required bin entry for float
                BinEntry."Entry No." := 0;
                BinEntry."Payment Type Code" := PaymentBinCheckpoint."Payment Type No.";
                BinEntry."Transaction Amount" := 0;
                BinEntry."Transaction Amount (LCY)" := 0;

                if (CashRegister."Primary Payment Type" = PaymentTypePOS."No.") and (CashRegister.Status = CashRegister.Status::Afsluttet) then begin
                    BinEntry."Transaction Amount" := CashRegister."Closing Cash";
                    BinEntry."Transaction Amount (LCY)" := CashRegister."Closing Cash";
                end;

                BinEntry.Type := BinEntry.Type::FLOAT;
                BinEntry.Insert();

                if (GuiAllowed) then
                    Window.Update(1, Round(CurrentCurrent / MaxCount * 10000, 1));

                CurrentCurrent += 1;

            until (POSPaymentMethod.Next() = 0);

            ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitNo, UserId);
            POSManagePOSUnit.ClosePOSUnitNo(POSUnitNo, ClosingEntryNo);

            if (GuiAllowed) then
                Window.Close();

        end;
    end;



    #endregion    

}