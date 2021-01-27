codeunit 6150697 "NPR RetailDataModel AR Upgr."
{
    // URNPR5.33/AP  /20170426 CASE 262628 "Extention" to CU 6150699 to be able to migrate Audit Roll data without using RecRef and FieldRef
    // NPR5.36/AP  /20170426 CASE 262628 "Extention" to CU 6150699 to be able to migrate Audit Roll data without using RecRef and FieldRef
    // NPR5.36/BR  /20170919 CASE 279551 Added functions to split control posting and creation
    // NPR5.37/BR  /20171024 CASE 294219 Fix check
    // NPR5.37/NPKNAV/20171030  CASE 292364 Transport NPR5.37 - 27 October 2017
    // NPR5.38/TSA /20171124 CASE 297087 Added function DuplicateAuditRollTicketToPosEntry() to copy balancing lines to new pos entry
    // NPR5.38/BR  /20180110 CASE 301600 Fix Error on Balancing, added link to positing
    // NPR5.38/BR  /20180112 CASE 301600 Check that Automatic posting of Audit Roll is switched OFF when activating POS Entry Posting
    // NPR5.39/MMV /20180207 CASE 304835 Added MAXSTRLEN check.
    // NPR5.39/BR  /20180219 CASE 305590 Allow in PROD
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.44/MHA /20180705 CASE 321231 Added Discount Fields added to InsertPOSSaleLine()
    // NPR5.48/LS  /20181121 CASE 334335 When Upgrading Audit Roll, added migration of Setups
    // NPR5.48/TSA /20181126 CASE 336921 Adding on code on ActivatePoseidonPosting() and DeActivatePoseidonPosting(). Removing commented code
    // NPR5.48/TJ  /20190102 CASE 340615 Commented out usage of field Item."Product Group Code"
    // NPR5.51/MHA /20190718 CASE 362329 Added "Exclude from Posting" on POS Sales Lines in InsertPOSSaleLine()
    // NPR5.51/LS  /20190826 CASE 334335 Modified function UpgradeSetupsBalancingV3()
    // NPR5.52/SARA/20191011 CASE 371142 Enhancement on conversion tool for POS Entry, function UpgradeSetupsBalancingV3
    // NPR5.53/SARA/20191119 CASE 375828 Modify mapping for fields 'Rounding Gain Account' and 'Rounding Losses Account' for POS Paymeny Method
    // NPR5.53/SARA/20191206 CASE 381094 Correction Description for in POS Payment Bin for 'Bank' and 'Safe'
    // NPR5.55/SARA/20200305 CASE 394811 Added CheckPaymentTypePOSAccount to check payment types not having an account number
    // NPR5.55/SARA/20200310 CASE 395030 Update POS Unit 'Name' with Register 'Description'
    // NPR5.55/SARA/20200525 CASE 404019 Create Tax Amount Line when convert Audit roll to POS Entry
    // NPR5.55/SARA/20200608 CASE 407687 Update "Condensed Posting Description" in POS Payment Method

    Permissions = TableData "NPR Audit Roll" = rimd;

    trigger OnRun()
    begin
        UpgradeAuditRollStep1;
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

    procedure UpgradeAuditRollStep1()
    var
        AuditRoll: Record "NPR Audit Roll";
        xAuditRoll: Record "NPR Audit Roll";
        LastAuditRoll: Record "NPR Audit Roll";
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
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
                AuditRolltoPOSEntryLink.DeleteAll;  //Remove this after test!

        AuditRoll.SetCurrentKey("Clustered Key");
        AuditRolltoPOSEntryLink.LockTable;
        if AuditRolltoPOSEntryLink.FindLast then
            AuditRoll.SetFilter("Clustered Key", '>%1', AuditRolltoPOSEntryLink."Link Entry No.")
        else
            InitDatamodel;

        StartDateTime := CurrentDateTime;
        if AuditRoll.FindSet then begin
            if GuiAllowed then
                ProgressDialog.Open('Upgrade Step 1\' +
                                    'Processing Audit Roll entries @1@@@@@@@@\' +
                                    'Estimated no of AR entries #2########\' +
                                    'No of POS Entries created #3########\' +
                                    'Elapsed time #4########');
            LastAuditRoll.SetCurrentKey("Clustered Key");
            LastAuditRoll.LockTable;
            LastAuditRoll.FindLast;
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
                        FinalizePOSEntry(POSEntry, AuditRoll);
                        //-NPR5.55 [404019]
                        CalcVATAmountLines(POSEntry, VATAmountLine, POSSalesLine);
                        PersistVATAmountLines(POSEntry, VATAmountLine);
                        //+NPR5.55 [404019]
                    end;

                    if POSUnit."No." <> AuditRoll."Register No." then
                        if POSUnit.Get(AuditRoll."Register No.") then;

                    POSEntry.Init;
                    POSEntry."Entry No." := 0; //Auto Incr.
                    POSEntry."POS Store Code" := POSUnit."POS Store Code";
                    POSEntry."POS Unit No." := AuditRoll."Register No.";
                    POSEntry."Document No." := AuditRoll."Sales Ticket No.";
                    POSEntry."Entry Type" := POSEntry."Entry Type"::Comment; //Default, until possible lines changes this.
                    POSEntry."Entry Date" := AuditRoll."Sale Date";
                    POSEntry."Posting Date" := POSEntry."Entry Date";
                    POSEntry."Document Date" := POSEntry."Entry Date";
                    POSEntry."POS Sale ID" := AuditRoll."POS Sale ID";
                    POSEntry.Insert;

                    if (POSEntry."POS Unit No." <> POSLedgerRegister."POS Unit No.") or
                       (POSLedgerRegister.Status <> POSLedgerRegister.Status::OPEN) then begin
                        POSLedgerRegister.SetCurrentKey("POS Unit No.");
                        POSLedgerRegister.SetRange("POS Unit No.", POSEntry."POS Unit No.");
                        if POSLedgerRegister.FindLast then
                            HasOpenPOSLedgerRegister := (POSLedgerRegister.Status = POSLedgerRegister.Status::OPEN)
                        else
                            HasOpenPOSLedgerRegister := false;
                        if not HasOpenPOSLedgerRegister then begin
                            POSLedgerRegister.Init;
                            POSLedgerRegister."No." := 0; //Auto Increment;
                            POSLedgerRegister."POS Store Code" := POSEntry."POS Store Code";
                            POSLedgerRegister."POS Unit No." := POSEntry."POS Unit No.";
                            POSLedgerRegister."Opening Entry No." := POSEntry."Entry No.";
                            POSLedgerRegister.Status := POSLedgerRegister.Status::OPEN;
                            POSLedgerRegister.Insert;
                        end;
                    end;
                    POSEntry."POS Period Register No." := POSLedgerRegister."No.";

                    AuditRolltoPOSEntryLink.Init;
                    AuditRolltoPOSEntryLink."Link Entry No." := 0; //Auto Increment
                    AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
                    AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                    AuditRolltoPOSEntryLink."Upgrade Step" := 1;
                    AuditRolltoPOSEntryLink.Insert;
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
            until AuditRoll.Next = 0;
            if NoOfPOSEntriesCreated > 0 then begin
                FinalizePOSEntry(POSEntry, AuditRoll);
                //-NPR5.55 [404019]
                CalcVATAmountLines(POSEntry, VATAmountLine, POSSalesLine);
                PersistVATAmountLines(POSEntry, VATAmountLine);
                //+NPR5.55 [404019]
            end;
            if GuiAllowed then
                ProgressDialog.Close;
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
        EstNoOfEntries := AuditRolltoPOSEntryLink.Count;
        StartDateTime := CurrentDateTime;
        if EstNoOfEntries = 0 then
            Error('No Entries to upgrade');
        if GuiAllowed then
            ProgressDialog.Update(2, EstNoOfEntries);
        Counter := 0;
        if AuditRolltoPOSEntryLink.FindSet then
            repeat
                if GuiAllowed then begin
                    Counter := Counter + 1;
                    Progress := Round((Counter / EstNoOfEntries) * 10000, 1);
                    if Progress >= NextProgress then begin
                        ProgressDialog.Update(1, Progress);
                        RunningDuration := CurrentDateTime - StartDateTime;
                        ProgressDialog.Update(4, Format(RunningDuration));
                        ProgressDialog.Update(5, Format(Round(((RunningDuration * 1) * ((EstNoOfEntries - Counter) / Counter)) / (1000 * 60))) + ' minutes');
                        //ProgressDialog.UPDATE(5,FORMAT(ROUND(RunningDuration*1),1));
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
                AuditRolltoPOSEntryLink.Modify;
            until AuditRolltoPOSEntryLink.Next = 0;
        if GuiAllowed then
            ProgressDialog.Close;
    end;

    procedure ActivatePoseidonPOSEntries()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        NPRetailSetup.Get;
        NPRetailSetup.TestField("Advanced POS Entries Activated", false);
        if not Confirm('This will trigger Step 1 in the Upgrade to POS Entries. Do you wish to continue?') then
            Error('');
        UpgradeAuditRollStep1;
    end;

    procedure DeactivatePoseidonPOSEntries()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        NPRetailSetup.Get;
        NPRetailSetup.TestField("Advanced POS Entries Activated");
        //-NPR5.37 [294219]
        NPRetailSetup.TestField("Advanced Posting Activated", false);
        //+NPR5.37 [294219]
        //-NPR5.36 [279551]
        //ERROR('You cannot change this setting')
        //+NPR5.36 [279551]
    end;

    procedure ActivatePoseidonPosting()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        RetailSetup: Record "NPR Retail Setup";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin

        NPRetailSetup.Get;
        NPRetailSetup.TestField("Advanced POS Entries Activated");
        NPRetailSetup.TestField("Advanced Posting Activated", false);

        RetailSetup.Get;
        RetailSetup.TestField("Posting Audit Roll", RetailSetup."Posting Audit Roll"::Manual);

        //-NPR5.48 [336921]
        POSWorkshiftCheckpoint.OnActivatePosEntryPosting();
        //+NPR5.48 [336921]
    end;

    procedure DeactivatePoseidonPosting()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin

        NPRetailSetup.Get;
        NPRetailSetup.TestField("Advanced Posting Activated");

        //-NPR5.48 [336921]
        POSWorkshiftCheckpoint.OnDeactivatePosEntryPosting();
        //+NPR5.48 [336921]
    end;

    local procedure InsertPOSSaleLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        IUoM: Record "Item Unit of Measure";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        AuditRollComment: Record "NPR Audit Roll";
    begin
        with POSSalesLine do begin
            Init;
            "POS Entry No." := POSEntry."Entry No.";
            "Line No." := AuditRoll."Line No.";
            "POS Store Code" := POSEntry."POS Store Code";
            "POS Unit No." := AuditRoll."Register No.";
            "Document No." := AuditRoll."Sales Ticket No.";
            "POS Period Register No." := POSEntry."POS Period Register No.";
            "Customer No." := AuditRoll."Customer No.";
            "Salesperson Code" := AuditRoll."Salesperson Code";

            case AuditRoll.Type of
                AuditRoll.Type::Item:
                    Type := Type::Item;
                AuditRoll.Type::"G/L":
                    Type := Type::"G/L Account";
                AuditRoll.Type::Comment:
                    //AuditRoll.Type::Cancelled,
                    //AuditRoll.Type::"Open/Close",
                    Type := Type::Comment;
                AuditRoll.Type::Customer:
                    Type := Type::Customer;
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
            //-NPR5.51 [362329]
            "Exclude from Posting" := ExcludeFromPosting(AuditRoll);
            //+NPR5.51 [362329]
            "No." := AuditRoll."No.";
            "Variant Code" := AuditRoll."Variant Code";
            "Location Code" := AuditRoll.Lokationskode;
            "Posting Group" := AuditRoll."Posting Group";
            Description := AuditRoll.Description;

            //Description 2?

            if Type = Type::"G/L Account" then
                if GLAccount.Get("No.") then
                    "Gen. Posting Type" := GLAccount."Gen. Posting Type";
            "Gen. Bus. Posting Group" := AuditRoll."Gen. Bus. Posting Group";
            "VAT Bus. Posting Group" := AuditRoll."VAT Bus. Posting Group";
            "Gen. Prod. Posting Group" := AuditRoll."Gen. Prod. Posting Group";
            "VAT Prod. Posting Group" := AuditRoll."VAT Prod. Posting Group";
            "Tax Area Code" := AuditRoll."Tax Area Code";
            "Tax Liable" := AuditRoll."Tax Liable";
            "Tax Group Code" := AuditRoll."Tax Group Code";
            "Use Tax" := AuditRoll."Use Tax";
            //-NPR5.55 [404019]
            if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then begin
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
            end;
            //+NPR5.55 [404019]
            "Unit of Measure Code" := AuditRoll."Unit of Measure Code";
            Quantity := AuditRoll.Quantity;
            if (Type = Type::Item) then begin
                if Item.Get("No.") then begin
                    "Item Category Code" := Item."Item Category Code";
                    //-NPR5.48 [340615]
                    //"Product Group Code" := Item."Product Group Code";
                    //+NPR5.48 [340615]
                end;
                if IUoM.Get("No.", "Unit of Measure Code") then
                    "Qty. per Unit of Measure" := IUoM."Qty. per Unit of Measure";
            end;
            if "Qty. per Unit of Measure" = 0 then
                "Qty. per Unit of Measure" := 1;
            "Quantity (Base)" := Round("Qty. per Unit of Measure" * Quantity, 0.00001);
            "Unit Price" := AuditRoll."Unit Price";
            "Unit Cost (LCY)" := AuditRoll."Unit Cost (LCY)";
            "VAT %" := AuditRoll."VAT %";
            //-NPR5.44 [321231]
            "Discount Type" := "Discount Type";
            "Discount Code" := "Discount Code";
            "Discount Authorised by" := "Discount Authorised by";
            "Reason Code" := "Reason Code";
            //+NPR5.44 [321231]
            "Line Discount Amount Excl. VAT" := Round(AuditRoll."Line Discount Amount" / (1 + AuditRoll."VAT %" / 100)); //Assuming Line Disc. Amount was alwas incl. VAYT
            "Line Discount Amount Incl. VAT" := AuditRoll."Line Discount Amount";
            "Amount Excl. VAT" := AuditRoll.Amount;
            "Amount Incl. VAT" := AuditRoll."Amount Including VAT";
            "VAT Base Amount" := AuditRoll."VAT Base Amount";

            //Special handling of Outpayments
            if AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Out payment" then begin
                if ("Amount Incl. VAT" <> 0) and ("Amount Excl. VAT" = 0) then
                    "Amount Excl. VAT" := "Amount Incl. VAT"; //Probably payment roundings
                "Unit Price" := -"Unit Price";
                "Amount Excl. VAT" := -"Amount Excl. VAT";
                "Amount Incl. VAT" := -"Amount Incl. VAT";
            end;

            //LCY amounts are copied directly since old auditroll was always in LCY
            "Amount Excl. VAT (LCY)" := "Amount Excl. VAT";
            "Amount Incl. VAT (LCY)" := "Amount Incl. VAT";
            "Line Dsc. Amt. Excl. VAT (LCY)" := "Line Discount Amount Excl. VAT";
            "Line Dsc. Amt. Incl. VAT (LCY)" := "Line Discount Amount Incl. VAT";

            "Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
            "Orig. POS Line No." := AuditRoll."Orig. POS Line No.";

            //TODO: Implement these and consider Item Group
            //POSSalesLine."Item Category Code" :=
            //POSSalesLine.Nonstock :=
            //POSSalesLine."BOM Item No." :=
            "Serial No." := AuditRoll."Serial No.";
            "Return Reason Code" := AuditRoll."Return Reason Code";

            "Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            "Dimension Set ID" := AuditRoll."Dimension Set ID";

            //INSERT;
            if not Insert then begin
                "Line No." := "Line No." + 1000000; //Fix error with duplicate Line No.'s in migration
                Insert;
            end;
            AuditRolltoPOSEntryLink.Init;
            AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
            AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
            AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
            AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Sale;
            AuditRolltoPOSEntryLink."Line No." := "Line No.";
            AuditRolltoPOSEntryLink.Insert;

            //Update POS Entry
            //-NPR5.55 [404019]
            //IF Type <> Type::Comment THEN //any line not being comment should change type to sale
            //POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
            case AuditRoll."Sale Type" of
                AuditRoll."Sale Type"::"Debit Sale":
                    begin
                        POSEntry."Entry Type" := POSEntry."Entry Type"::"Credit Sale";
                        AuditRollComment.Reset;
                        AuditRollComment.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
                        AuditRollComment.SetRange(Type, AuditRollComment.Type::Comment);
                        if AuditRollComment.FindFirst then
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
            //+NPR5.55 [404019]

            if POSEntry."Dimension Set ID" = 0 then begin
                POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
                POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
                POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            end;
            if AuditRoll."Item Entry Posted" then
                //POSEntry."Item Entries Posted" := TRUE;
                POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::Posted;
            if AuditRoll."Salgspris inkl. moms" then
                POSEntry."Prices Including VAT" := true;
            //Update measures
            if Type = Type::Item then begin
                POSEntry."Item Sales (LCY)" += "Amount Incl. VAT";
                //-NPR5.55 [404019]
                //POSEntry."Discount Amount" += "Line Discount Amount Incl. VAT";
                POSEntry."Discount Amount" += "Line Discount Amount Excl. VAT";
                //+NPR5.55 [404019]
                if Quantity < 0 then
                    POSEntry."Return Sales Quantity" -= Quantity
                else
                    POSEntry."Sales Quantity" += Quantity;
            end;
            POSEntry."Amount Excl. Tax" += "Amount Excl. VAT";
            //-NPR5.55 [404019]
            //POSEntry."Tax Amount" += "Amount Incl. VAT";
            //POSEntry."Amount Incl. Tax" += "Amount Incl. VAT"-"Amount Excl. VAT";
            POSEntry."Tax Amount" += "Amount Incl. VAT" - "Amount Excl. VAT";
            POSEntry."Amount Incl. Tax" += "Amount Incl. VAT";
            //-NPR5.55 [404019]
        end;
    end;

    local procedure InsertPOSPaymentLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Payment Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
    begin
        with POSPaymentLine do begin
            Init;
            "POS Entry No." := POSEntry."Entry No.";
            "Line No." := AuditRoll."Line No.";
            "POS Store Code" := POSEntry."POS Store Code";
            "POS Unit No." := AuditRoll."Register No.";
            "Document No." := AuditRoll."Sales Ticket No.";
            "POS Period Register No." := POSEntry."POS Period Register No.";
            case AuditRoll.Type of
                AuditRoll.Type::Payment:
                    "POS Payment Method Code" := AuditRoll."No.";
                else
                    Error('Payment Line Type %1 not implemented in migration (%2 %3 %4)', AuditRoll.Type, AuditRoll.TableName, AuditRoll.FieldName("Clustered Key"), AuditRoll."Clustered Key");
            end;
            "POS Payment Bin Code" := "POS Unit No."; //POS Unit = POS Payment Bin default for now
            Description := AuditRoll.Description;
            Amount := AuditRoll."Amount Including VAT";
            "Payment Amount" := AuditRoll."Amount Including VAT";
            "Amount (LCY)" := AuditRoll."Amount Including VAT";
            "Amount (Sales Currency)" := AuditRoll."Amount Including VAT";

            "Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
            "Orig. POS Line No." := AuditRoll."Orig. POS Line No.";
            EFT := AuditRoll."Cash Terminal Approved";

            "Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            "Dimension Set ID" := AuditRoll."Dimension Set ID";

            Insert;
            AuditRolltoPOSEntryLink.Init;
            AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
            AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
            AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
            AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Payment;
            AuditRolltoPOSEntryLink."Line No." := "Line No.";
            AuditRolltoPOSEntryLink.Insert;

            //Update POS Entry
            POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale"; //If any payment line its a Sale
            if (AuditRoll."Dimension Set ID" <> 0) and (POSEntry."Dimension Set ID" <> AuditRoll."Dimension Set ID") then begin //Favor payment line dims over sales lines for the header
                POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
                POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
                POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            end;

        end;
    end;

    local procedure InsertPOSBalancingLine(var AuditRoll: Record "NPR Audit Roll"; var POSEntry: Record "NPR POS Entry"; var POSLedgerRegister: Record "NPR POS Period Register"; var POSBalancingLine: Record "NPR POS Balancing Line")
    var
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        CashRegister: Record "NPR Register";
        CashRegPeriod: Record "NPR Period";
        POSPostingControl: Codeunit "NPR POS Posting Control";
    begin
        with POSBalancingLine do begin
            Init;
            "POS Entry No." := POSEntry."Entry No.";
            "Line No." := AuditRoll."Line No.";
            "POS Store Code" := POSEntry."POS Store Code";
            "POS Unit No." := AuditRoll."Register No.";
            "Document No." := AuditRoll."Sales Ticket No.";
            "POS Period Register No." := POSEntry."POS Period Register No.";
            "POS Payment Bin Code" := "POS Unit No.";  //POS Unit = POS Payment Bin default for now

            if CashRegister.Get(AuditRoll."Register No.") then
                "POS Payment Method Code" := CashRegister."Primary Payment Type";

            //-NPR5.39 [304835]
            //Description := AuditRoll.Description;
            Description := CopyStr(AuditRoll.Description, 1, MaxStrLen(Description));
            //+NPR5.39 [304835]

            CashRegPeriod.SetRange("Register No.", AuditRoll."Register No.");
            CashRegPeriod.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
            if CashRegPeriod.FindLast then begin
                "Calculated Amount" := CashRegPeriod."Balanced Cash Amount" + CashRegPeriod.Difference;
                "Balanced Amount" := CashRegPeriod."Balanced Cash Amount";
                "Balanced Diff. Amount" := CashRegPeriod.Difference;
                "New Float Amount" := CashRegPeriod."Closing Cash";
                "Deposit-To Bin Amount" := CashRegPeriod."Deposit in Bank";
            end else begin //Fall back to Audit Roll values
                "Calculated Amount" := AuditRoll."Closing Cash" + AuditRoll."Transferred to Balance Account" + AuditRoll.Difference;
                "Balanced Amount" := AuditRoll."Closing Cash" + AuditRoll."Transferred to Balance Account";
                "Balanced Diff. Amount" := AuditRoll.Difference;
                "New Float Amount" := AuditRoll."Closing Cash";
                "Deposit-To Bin Amount" := AuditRoll."Transferred to Balance Account";
            end;

            "Orig. POS Sale ID" := AuditRoll."Orig. POS Sale ID";
            "Orig. POS Line No." := AuditRoll."Orig. POS Line No.";

            "Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            "Dimension Set ID" := AuditRoll."Dimension Set ID";

            Insert;
            AuditRolltoPOSEntryLink.Init;
            AuditRolltoPOSEntryLink."Link Entry No." := 0; //AutoIncr.
            AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
            AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
            AuditRolltoPOSEntryLink."Line Type" := AuditRolltoPOSEntryLink."Line Type"::Balancing;
            AuditRolltoPOSEntryLink."Line No." := "Line No.";
            AuditRolltoPOSEntryLink.Insert;

            //Update POS Entry
            //-NPR5.38 [297087]
            //POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
            POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
            //+NPR5.38 [297087]

            POSEntry.Description := AuditRoll.Description;
            if POSEntry."Dimension Set ID" = 0 then begin
                POSEntry."Dimension Set ID" := AuditRoll."Dimension Set ID";
                POSEntry."Shortcut Dimension 1 Code" := AuditRoll."Shortcut Dimension 1 Code";
                POSEntry."Shortcut Dimension 2 Code" := AuditRoll."Shortcut Dimension 2 Code";
            end;

            //Close the current POS Ledger Register
            POSLedgerRegister."Document No." := AuditRoll."Posted Doc. No.";
            POSLedgerRegister."Closing Entry No." := "POS Entry No.";
            POSLedgerRegister.Status := POSLedgerRegister.Status::CLOSED;
            POSLedgerRegister.Modify;
            //-NPR5.38 [301600]
            POSPostingControl.AutomaticPostPeriodRegister(POSLedgerRegister);
            //+NPR5.38 [301600]

        end;
    end;

    local procedure InitDatamodel()
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSLedgerRegister: Record "NPR POS Period Register";
        POSEntryCommentLine: Record "NPR POS Entry Comm. Line";
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
    begin
        if (not POSEntry.IsEmpty) or
           (not POSSalesLine.IsEmpty) or
           (not POSPaymentLine.IsEmpty) or
           (not POSBalancingLine.IsEmpty) or
           (not POSLedgerRegister.IsEmpty) or
           (not POSEntryCommentLine.IsEmpty) then begin
            if Confirm('It seems that this is the inital Poseidon activation, but data exits in data tables. Do you want to delete all data in these tables to proceed?', false) then begin
                POSEntry.DeleteAll;
                POSSalesLine.DeleteAll;
                POSPaymentLine.DeleteAll;
                POSBalancingLine.DeleteAll;
                POSLedgerRegister.DeleteAll;
                POSEntryCommentLine.DeleteAll;
                //-NPR5.55 [404019]
                POSTaxAmountLine.DeleteAll;
                //+NPR5.55 [404019]
            end else
                Error('Can not initialize Poseidon Datamodel.');
        end;
    end;

    procedure BufferAuditRollLink(var AuditRoll: Record "NPR Audit Roll")
    begin
        TmpAuditRollBuffer.Init;
        TmpAuditRollBuffer := AuditRoll;
        TmpAuditRollBuffer.Insert;
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
            //POSEntry.Posted := TRUE;
            if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Debit Sale") then
                POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted"
            else
                if POSEntry."Post Entry Status" <> POSEntry."Post Entry Status"::"Not To Be Posted" then
                    POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::Posted;
        end;
    end;

    local procedure FinalizePOSEntry(var POSEntry: Record "NPR POS Entry"; var AuditRoll: Record "NPR Audit Roll")
    begin
        if POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Unposted then
            POSEntry."Post Item Entry Status" := POSEntry."Post Entry Status";
        //-NPR5.55 [404019]
        POSEntry."Amount Incl. Tax & Round" := POSEntry."Amount Incl. Tax" + POSEntry."Rounding Amount (LCY)";
        //+NPR5.55 [404019]
        POSEntry.Modify;
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
        LastAuditRoll: Record "NPR Audit Roll";
        AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSUnit: Record "NPR POS Unit";
        POSLedgerRegister: Record "NPR POS Period Register";
        HasOpenPOSLedgerRegister: Boolean;
    begin

        //-NPR5.38 [297087]
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
                    FinalizePOSEntry(POSEntry, AuditRoll);

                if POSUnit."No." <> AuditRoll."Register No." then
                    if POSUnit.Get(AuditRoll."Register No.") then;

                POSEntry.Init;
                POSEntry."Entry No." := 0; //Auto Incr.
                POSEntry."POS Store Code" := POSUnit."POS Store Code";
                POSEntry."POS Unit No." := AuditRoll."Register No.";
                POSEntry."Document No." := AuditRoll."Sales Ticket No.";
                POSEntry."Entry Type" := POSEntry."Entry Type"::Comment; //Default, until possible lines changes this.
                POSEntry."Entry Date" := AuditRoll."Sale Date";
                POSEntry."Posting Date" := POSEntry."Entry Date";
                POSEntry."Document Date" := POSEntry."Entry Date";
                POSEntry."POS Sale ID" := AuditRoll."POS Sale ID";
                POSEntry.Insert;

                if (POSEntry."POS Unit No." <> POSLedgerRegister."POS Unit No.") or
                    (POSLedgerRegister.Status <> POSLedgerRegister.Status::OPEN) then begin
                    POSLedgerRegister.SetCurrentKey("POS Unit No.");
                    POSLedgerRegister.SetRange("POS Unit No.", POSEntry."POS Unit No.");
                    if POSLedgerRegister.FindLast then
                        HasOpenPOSLedgerRegister := (POSLedgerRegister.Status = POSLedgerRegister.Status::OPEN)
                    else
                        HasOpenPOSLedgerRegister := false;
                    if not HasOpenPOSLedgerRegister then begin
                        POSLedgerRegister.Init;
                        POSLedgerRegister."No." := 0; //Auto Increment;
                        POSLedgerRegister."POS Store Code" := POSEntry."POS Store Code";
                        POSLedgerRegister."POS Unit No." := POSEntry."POS Unit No.";
                        POSLedgerRegister."Opening Entry No." := POSEntry."Entry No.";
                        POSLedgerRegister.Status := POSLedgerRegister.Status::OPEN;
                        POSLedgerRegister.Insert;
                    end;
                end;
                POSEntry."POS Period Register No." := POSLedgerRegister."No.";

                AuditRolltoPOSEntryLink.Init;
                AuditRolltoPOSEntryLink."Link Entry No." := 0; //Auto Increment
                AuditRolltoPOSEntryLink."Audit Roll Clustered Key" := AuditRoll."Clustered Key";
                AuditRolltoPOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                AuditRolltoPOSEntryLink."Upgrade Step" := 1;
                AuditRolltoPOSEntryLink.Insert;
                NoOfPOSEntriesCreated += 1;
                //-NPR5.38 [301600]
                //END;
                //+NPR5.38 [301600]

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
                //-NPR5.38 [301600]
            end;
        //+NPR5.38 [301600]
        until AuditRoll.Next = 0;

        if NoOfPOSEntriesCreated > 0 then
            FinalizePOSEntry(POSEntry, AuditRoll);

        //+NPR5.38 [297087]
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
        BlankPosStoreCode: Integer;
    begin
        //-NPR5.48 [334335]
        //-NPR5.51 [334335]
        if GuiAllowed then
            ProgressDialog.Open('Upgrade Setups for BalancingV3 \' +
                                 'Estimated Payment Type @1@@@@@@@@\' +
                                 'Populate POS Payment Bin #2########\' +
                                 'Set POS Posting Setup #3########');
        //+NPR5.51 [334335]
        //Upadte POS Unit Name with Register Decsription
        //-NPR5.55 [395030]
        Register.Reset;
        POSUnit.Reset;
        if Register.FindSet then begin
            repeat
                if POSUnitCheck.Get(Register."Register No.") then begin
                    POSUnit := POSUnitCheck;
                    POSUnit.Name := Register.Description;
                    POSUnit.Modify;
                end;
            until Register.Next = 0;
        end;
        //+NPR5.55 [395030]

        //1. Populate POS Payment Method
        POSPaymentMethod.Reset;  // Target
        POSPaymentMethodCheck.Reset;
        PaymentTypePOS.Reset;   //  Source
        Register.Reset;

        //-NPR5.52[371142]
        PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active); //Check for Active Status
        //+NPR5.52[371142]
        if PaymentTypePOS.FindSet then
            repeat
                //-NPR5.51 [334335]
                if GuiAllowed then
                    ProgressDialog.Update(1, PaymentTypePOS.Count);
                //+NPR5.51 [334335]
                POSPaymentMethodCheck.Reset;
                POSPaymentMethod.Reset;
                if not POSPaymentMethodCheck.Get(PaymentTypePOS."No.") then begin
                    POSPaymentMethod.Init;
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

                        //-NPR5.51 [334335]
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
                    //+NPR5.51 [334335]

                    end;
                    if PaymentTypePOS."To be Balanced" then
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES
                    else
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::NO;

                    POSPaymentMethod."Post Condensed" := (PaymentTypePOS.Posting = PaymentTypePOS.Posting::Condensed);
                    //-NPR5.55 [407687]
                    if (POSPaymentMethod."Post Condensed") and (POSPaymentMethod."Condensed Posting Description" = '') then
                        POSPaymentMethod."Condensed Posting Description" := 'Dagens bevægelser %6 %3 kasse %1';
                    //+NPR5.55 [407687]
                    POSPaymentMethod."Rounding Type" := POSPaymentMethod."Rounding Type"::Nearest;
                    POSPaymentMethod."Rounding Precision" := PaymentTypePOS."Rounding Precision";
                    //-NPR5.52[371142]
                    if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CASH then
                        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;

                    //-NPR5.53 [375828]
                    /*
                    IF Register.FINDFIRST THEN BEGIN
                      POSPaymentMethod."Rounding Gains Account" := Register.Rounding;
                      POSPaymentMethod."Rounding Losses Account" := Register.Rounding;
                    END;
                    */
                    if POSPostingProfile.FindFirst then begin
                        POSPaymentMethod."Rounding Gains Account" := POSPostingProfile."POS Sales Rounding Account";
                        POSPaymentMethod."Rounding Losses Account" := POSPostingProfile."POS Sales Rounding Account";
                    end;
                    //+NPR5.53 [375828]
                    //+NPR5.52[371142]
                    POSPaymentMethod.Insert(true);
                end;
            until PaymentTypePOS.Next = 0;

        //2. POS Payment Bin
        POSPaymentBin.Reset;
        POSPaymentBinCheck.Reset;
        POSUnit.Reset;
        if POSUnit.FindSet then
            repeat
                //-NPR5.51 [334335]
                if GuiAllowed then
                    ProgressDialog.Update(2, POSUnit.Count);
                //+NPR5.51 [334335]
                POSPaymentBinCheck.Reset;
                POSPaymentBin.Reset;
                if not POSPaymentBinCheck.Get(POSUnit."No.") then begin
                    POSPaymentBin.Init;
                    POSPaymentBin."No." := POSUnit."No.";
                    POSPaymentBin."POS Store Code" := POSUnit."POS Store Code";
                    POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
                    POSPaymentBin."Eject Method" := 'Printer';
                    POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::CASH_DRAWER;
                    //-NPR5.52[371142]
                    POSPaymentBin.Description := 'Payment Bin' + ' ' + POSPaymentBin."No.";
                    //+NPR5.52[371142]
                    POSPaymentBin.Insert(true);
                end;
                //-NPR5.52[371142]
                //Default POS Payment Bin
                CreateDefaultBins(POSUnit."No.");
            //+NPR5.52[371142]
            until POSUnit.Next = 0;

        //3. POS Posting Setup
        //-NPR5.52[371142]
        /*
        POSPostingSetup.RESET;
        POSPostingSetupCheck.RESET;
        PaymentTypePOS.RESET;
        Register.RESET;
        POSPostingSetupCheck.RESET;  //POS Store Code,POS Payment Method Code,POS Payment Bin Code
        IF POSPostingSetupCheck.COUNT < 1 THEN BEGIN
          IF Register.FINDSET THEN REPEAT
            BlankPosStoreCode := 1;
            PaymentTypePOS.RESET;
            IF PaymentTypePOS.FINDSET THEN REPEAT
              //-NPR5.51 [334335]
              IF GUIALLOWED THEN
                ProgressDialog.UPDATE(3,PaymentTypePOS.COUNT);
              //+NPR5.51 [334335]
              POSPostingSetup.RESET;
              POSPostingSetup.INIT;
              POSPostingSetup."POS Store Code" := Register."Register No.";
              POSPostingSetup."POS Payment Method Code" := PaymentTypePOS."No.";
              POSPostingSetup."POS Payment Bin Code" := Register."Register No.";
              POSPostingSetup."Account Type" := PaymentTypePOS."Account Type";
              POSPostingSetup."Account No." := PaymentTypePOS."G/L Account No.";
              POSPostingSetup."Difference Account Type" := POSPostingSetup."Difference Account Type"::"G/L Account";
              POSPostingSetup."Difference Acc. No." := Register."Difference Account";
              POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
              POSPostingSetup.INSERT(TRUE);
        
              BlankPosStoreCode +=1;
        
            UNTIL PaymentTypePOS.NEXT = 0;
          UNTIL Register.NEXT = 0;
        END;
        */

        POSPostingSetupCheck.Reset;
        if POSPostingSetupCheck.Count < 1 then begin
            //Global Setup
            POSPostingSetup.Reset;
            PaymentTypePOS.Reset;
            Register.Reset;
            POSPostingSetupCheck.Reset;  //POS Store Code,POS Payment Method Code,POS Payment Bin Code
            BlankPosStoreCode := 1;
            PaymentTypePOS.Reset;
            PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active); //Check for Active Status
            if PaymentTypePOS.FindSet then
                repeat
                    //-NPR5.51 [334335]
                    if GuiAllowed then
                        ProgressDialog.Update(3, PaymentTypePOS.Count);
                    //+NPR5.51 [334335]
                    //-NPR5.55 [394811]
                    if CheckPaymentTypePOSAccount(PaymentTypePOS) then begin
                        //+NPR5.55 [394811]
                        POSPostingSetup.Reset;
                        POSPostingSetup.Init;
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
                        if Register.FindFirst then begin
                            POSPostingSetup."Difference Acc. No." := Register."Difference Account";
                            POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
                        end;
                        POSPostingSetup.Insert(true);
                    end;
                until PaymentTypePOS.Next = 0;

            //Line Per POS Store
            POSPostingSetup.Reset;
            PaymentTypePOS.Reset;
            POSStore.Reset;
            Register.Reset;
            POSPaymentMethod.Reset;
            POSPostingSetupCheck.Reset;  //POS Store Code,POS Payment Method Code,POS Payment Bin Code
            if POSStore.FindSet then
                repeat
                    POSPaymentMethod.Reset;
                    POSPaymentMethod.SetRange(POSPaymentMethod."Processing Type", POSPaymentMethod."Processing Type"::CASH);
                    if POSPaymentMethod.FindSet then
                        repeat
                            //-NPR5.51 [334335]
                            if GuiAllowed then
                                ProgressDialog.Update(3, PaymentTypePOS.Count);
                            //+NPR5.51 [334335]
                            POSPostingSetup.Reset;
                            POSPostingSetup.Init;
                            POSPostingSetup."POS Store Code" := POSStore.Code;
                            POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
                            POSPostingSetup."POS Payment Bin Code" := 'BANK';
                            if Register.FindFirst then begin
                                case Register."Balanced Type" of
                                    Register."Balanced Type"::Bank:
                                        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"Bank Account";

                                    Register."Balanced Type"::Finans:
                                        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
                                end;
                                POSPostingSetup."Account No." := Register."Balance Account";
                            end;
                            POSPostingSetup."Difference Account Type" := POSPostingSetup."Difference Account Type"::"G/L Account";
                            POSPostingSetup."Difference Acc. No." := Register."Difference Account";
                            POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
                            POSPostingSetup.Insert(true);
                            BlankPosStoreCode += 1;
                        until POSPaymentMethod.Next = 0;
                until POSStore.Next = 0;
        end;

        //Create/Update POS Unit to Bin Relation

        POSUnit.Reset;
        if POSUnit.FindSet then begin
            repeat
                POSUnitBinRelation.Reset;
                POSUnitBinRelation.SetRange("POS Unit No.", POSUnit."No.");
                if POSUnitBinRelation.FindFirst then begin
                    if POSUnitBinRelation."POS Payment Bin No." = '' then
                        POSUnitBinRelation.Rename(POSUnitBinRelation."POS Unit No.", POSUnit."Default POS Payment Bin");
                end else begin
                    POSUnitBinRelation.Init;
                    POSUnitBinRelation."POS Unit No." := POSUnit."No.";
                    POSUnitBinRelation."POS Payment Bin No." := POSUnit."Default POS Payment Bin";
                    POSUnitBinRelation."POS Unit Status" := POSUnitBinRelation."POS Unit Status"::OPEN;
                    POSUnitBinRelation."POS Payment Bin Status" := POSUnitBinRelation."POS Payment Bin Status"::OPEN;
                    POSUnitBinRelation."POS Unit Name" := POSUnit.Name;
                    POSUnitBinRelation.Insert(true);
                end;
            until POSUnit.Next = 0;
        end;
        //+NPR5.52[371142]

        //-NPR5.51 [334335]
        if GuiAllowed then
            ProgressDialog.Close;
        //+NPR5.51 [334335]

        //+NPR5.48 [334335]

    end;

    procedure ExcludeFromPosting(AuditRoll: Record "NPR Audit Roll"): Boolean
    begin
        //-NPR5.51 [362329]
        if AuditRoll.Type in [AuditRoll.Type::Comment] then
            exit(true);

        //-NPR5.55 [404019]
        //EXIT(AuditRoll."Sale Type" IN [AuditRoll."Sale Type"::Comment,AuditRoll."Sale Type"::"Debit Sale",AuditRoll."Sale Type"::"Open/Close"]);
        exit(AuditRoll."Sale Type" in [AuditRoll."Sale Type"::Comment, AuditRoll."Sale Type"::"Open/Close"]);//Remove "Sale Type"::"Debit Sale"
        //+NPR5.55 [404019]
        //+NPR5.51 [362329]
    end;

    local procedure CreateDefaultBins(POSUnitNo: Code[10])
    var
        BinNoArray: array[3] of Code[10];
        BinDescArray: array[3] of Text[20];
        i: Integer;
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinCheck: Record "NPR POS Payment Bin";
    begin
        //-NPR5.52[371142]
        BinNoArray[1] := 'AUTO-BIN';
        BinNoArray[2] := 'BANK';
        BinNoArray[3] := 'SAFE';

        BinDescArray[1] := 'Auto Count Bin';
        //-NPR5.53 [381094]
        //BinDescArray[2] := 'Safe';
        //BinDescArray[3] := 'Bank';
        BinDescArray[2] := 'Bank';
        BinDescArray[3] := 'Safe';
        //+NPR5.53 [381094]

        for i := 1 to 3 do begin
            //POSPaymentBinCheck.RESET;
            //POSPaymentBinCheck.SETRANGE("No.",BinNoArray[i]);
            //POSPaymentBinCheck.SETRANGE("Attached to POS Unit No.",POSUnitNo);
            if not POSPaymentBinCheck.Get(BinNoArray[i]) then begin
                POSPaymentBin.Init;
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
        //+NPR5.52[371142]
    end;

    local procedure CheckPaymentTypePOSAccount(PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    begin
        //-NPR5.55 [394811]
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
        //+NPR5.55 [394811]
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
        if POSStore.FindSet then begin
            repeat
                POSStoreTemp := POSStore;
                if (POSStore."Location Code" = POSStoreDuplicate."Location Code") and (POSStore."Gen. Bus. Posting Group" = POSStoreDuplicate."Gen. Bus. Posting Group") then
                    POSStore.Delete;
                POSStoreDuplicate := POSStoreTemp;
            until POSStore.Next = 0;
        end;
    end;

    local procedure PersistVATAmountLines(var POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line")
    var
        PersistentPOSTaxAmountLine: Record "NPR POS Tax Amount Line";
    begin
        if VATAmountLine.FindSet then
            repeat
                PersistentPOSTaxAmountLine.Init;
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
                PersistentPOSTaxAmountLine.Insert;
            until VATAmountLine.Next = 0;
    end;

    procedure CalcVATAmountLines(POSEntryIn: Record "NPR POS Entry"; var VATAmountLine: Record "VAT Amount Line"; POSSalesLine: Record "NPR POS Sales Line")
    var
        PrevVatAmountLine: Record "VAT Amount Line";
        Currency: Record Currency;
        POSEntry: Record "NPR POS Entry";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalVATAmount: Decimal;
        QtyToHandle: Decimal;
        RoundingLineInserted: Boolean;
    begin
        POSEntry := POSEntryIn;
        /*
        Posted := POSEntry."Post Entry Status" >= POSEntry."Post Entry Status"::Posted;
        SetUpCurrency(POSEntry."Currency Code");
        IF POSEntry."Currency Code" <> '' THEN
          POSEntry.TESTFIELD("Currency Factor");
        IF POSEntry."Currency Factor" = 0 THEN
          ExchangeFactor := 1
        ELSE
          ExchangeFactor := POSEntry."Currency Factor";
        */
        VATAmountLine.DeleteAll;

        with POSSalesLine do begin
            SetRange("POS Entry No.", POSEntryIn."Entry No.");
            SetFilter(Type, '<>%1', Type::Rounding);
            SetRange("Exclude from Posting", false);
            if FindSet then
                repeat
                    if (("Unit Price" <> 0) and (Quantity <> 0)) or ("Amount Excl. VAT" <> 0) then begin
                        if ("VAT Calculation Type" in
                           ["VAT Calculation Type"::"Reverse Charge VAT", "VAT Calculation Type"::"Sales Tax"])
                        then
                            "VAT %" := 0;
                        if not VATAmountLine.Get(
                             "VAT Identifier", "VAT Calculation Type", "Tax Group Code", false, "Amount Excl. VAT" >= 0)
                        then begin
                            VATAmountLine.Init;
                            VATAmountLine."VAT Identifier" := "VAT Identifier";
                            VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            VATAmountLine."Tax Group Code" := "Tax Group Code";
                            VATAmountLine."VAT %" := "VAT %";
                            VATAmountLine.Modified := true;
                            VATAmountLine.Positive := "Amount Excl. VAT" >= 0;
                            VATAmountLine.Insert;
                        end;
                        VATAmountLine.Quantity := VATAmountLine.Quantity + "Quantity (Base)";
                        VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + "Amount Excl. VAT";
                        VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + "VAT Difference";
                        VATAmountLine."VAT Base" := VATAmountLine."VAT Base" + "Amount Excl. VAT";
                        VATAmountLine."Amount Including VAT" := VATAmountLine."Amount Including VAT" + "Amount Incl. VAT";
                        VATAmountLine."VAT Amount" := VATAmountLine."VAT Amount" + ("Amount Incl. VAT" - "Amount Excl. VAT");
                        VATAmountLine.Modify;
                        TotalVATAmount := TotalVATAmount + "Amount Incl. VAT" - "Amount Excl. VAT";
                    end;
                until Next = 0;
        end;
        /*
        WITH VATAmountLine DO
          IF FINDSET THEN
            REPEAT
              IF (PrevVatAmountLine."VAT Identifier" <> "VAT Identifier") OR
                 (PrevVatAmountLine."VAT Calculation Type" <> "VAT Calculation Type") OR
                 (PrevVatAmountLine."Tax Group Code" <> "Tax Group Code") OR
                 (PrevVatAmountLine."Use Tax" <> "Use Tax")
              THEN
                PrevVatAmountLine.INIT;
              //IF POSEntry."Prices Including VAT" THEN BEGIN
                CASE "VAT Calculation Type" OF
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    BEGIN
                      "VAT Base" := "Line Amount";
                      {
                        ROUND(
                          ("Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
                          Currency."Amount Rounding Precision") - "VAT Difference";
                      }
                      "VAT Amount" := POSSalesLine.va
                        "VAT Difference" +
                        ROUND(
                          PrevVatAmountLine."VAT Amount" +
                          ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference"),
                          Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "VAT Base" + "VAT Amount";
                      IF Positive THEN
                        PrevVatAmountLine.INIT
                      ELSE BEGIN
                        PrevVatAmountLine := VATAmountLine;
                        PrevVatAmountLine."VAT Amount" :=
                          ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference");
                        PrevVatAmountLine."VAT Amount" :=
                          PrevVatAmountLine."VAT Amount" -
                          ROUND(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      END;
                    END;
                  "VAT Calculation Type"::"Full VAT":
                    BEGIN
                      "VAT Base" := 0;
                      "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                      "Amount Including VAT" := "VAT Amount";
                    END;
                  "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                      "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Base" :=
                        ROUND(
                          SalesTaxCalculate.ReverseCalculateTax(
                            POSEntry."Tax Area Code","Tax Group Code",POSSalesLine."Tax Liable",
                            POSEntry."Posting Date","Amount Including VAT",Quantity,POSEntry."Currency Factor"),
                          Currency."Amount Rounding Precision");
                      "VAT Amount" := "VAT Difference" + "Amount Including VAT" - "VAT Base";
                      IF "VAT Base" = 0 THEN
                        "VAT %" := 0
                      ELSE
                        "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base",0.00001);
                    END;
                END;
              //END ELSE
              {
                CASE "VAT Calculation Type" OF
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    BEGIN
                      "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Amount" :=
                        "VAT Difference" +
                        ROUND(
                          PrevVatAmountLine."VAT Amount" +
                          "VAT Base" * "VAT %" / 100,
                          Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount" + "VAT Amount";
                      IF Positive THEN
                        PrevVatAmountLine.INIT
                      ELSE
                        IF NOT "Includes Prepayment" THEN BEGIN
                          PrevVatAmountLine := VATAmountLine;
                          PrevVatAmountLine."VAT Amount" :=
                            "VAT Base" * "VAT %" / 100;
                          PrevVatAmountLine."VAT Amount" :=
                            PrevVatAmountLine."VAT Amount" -
                            ROUND(PrevVatAmountLine."VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                        END;
                    END;
                  "VAT Calculation Type"::"Full VAT":
                    BEGIN
                      "VAT Base" := 0;
                      "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                      "Amount Including VAT" := "VAT Amount";
                    END;
                  "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                      "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                      "VAT Amount" :=
                        SalesTaxCalculate.CalculateTax(
                          POSEntry."Tax Area Code","Tax Group Code",POSSalesLine."Tax Liable",
                          POSEntry."Posting Date","VAT Base",Quantity,POSEntry."Currency Factor");
                      IF "VAT Base" = 0 THEN
                        "VAT %" := 0
                      ELSE
                        "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base",0.00001);
                      "VAT Amount" :=
                        "VAT Difference" +
                        ROUND("VAT Amount",Currency."Amount Rounding Precision",Currency.VATRoundingDirection);
                      "Amount Including VAT" := "VAT Base" + "VAT Amount";
                    END;
                    }
                //END;
        
              "Calculated VAT Amount" := "VAT Amount" - "VAT Difference";
              MODIFY;
            UNTIL NEXT = 0;
        */
        //+NPR5.48 [335967]

    end;
}

