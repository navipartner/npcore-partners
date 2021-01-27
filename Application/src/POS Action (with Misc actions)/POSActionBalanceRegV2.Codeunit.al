codeunit 6150832 "NPR POS Action: BalanceReg V2"
{
    // 
    // NOTES:
    // Balancing requires a valid salesesperson and therefor must be done after a login
    // We are therefor in a current sales transaction and should not start a new one.

    Permissions = TableData "NPR Audit Roll" = rimd;

    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        RegisterAlreadyClosedErr: Label 'Register already closed!';
        DeleteAllLinesBeforeBalancingErr: Label 'Delete all sales lines before balancing the register';
        CloseSalesWindowMsg: Label 'You must close sales window on register no. %1', Comment = '%1=Register."Register No."';
        txtCannotSendSMSWB: Label 'Could not send SMS with todays sales.';
        NotCompleted: Label 'The End-of-Day did not complete since the Payment Bins has not been counted.';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('ValidateRequirements', 'respond()');
            Sender.RegisterWorkflowStep('NotifySubscribers', 'respond()');
            Sender.RegisterWorkflowStep('Eft_EndOfDayReport', 'respond()');
            Sender.RegisterWorkflowStep('Eft_Print', 'respond();');
            Sender.RegisterWorkflowStep('BalanceRegister', 'respond()');
            Sender.RegisterWorkflowStep('EndOfWorkflow', 'respond()');

            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR Sale POS";
        Register: Record "NPR Register";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EftHandled: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSetup.GetRegisterRecord(Register);

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
            'ValidateRequirements':
                begin
                    if (not (ValidateRequirements(SalePOS."Register No.", SalePOS."Sales Ticket No."))) then
                        FrontEnd.ContinueAtStep('EndOfWorkflow');
                    POSCreateEntry.InsertUnitCloseBeginEntry(SalePOS."Register No.", SalePOS."Salesperson Code");
                end;
            'NotifySubscribers':
                OnBeforeBalancing(SalePOS, Register);
            'BalanceRegister':
                begin
                    BalanceRegister(SalePOS."Register No.", SalePOS."Sales Ticket No.");
                    POSCreateEntry.InsertUnitCloseEndEntry(SalePOS."Register No.", SalePOS."Salesperson Code");
                end;
            'EndOfWorkflow':
                begin
                    POSSession.ChangeViewLogin();
                end;
        end;

        case NextWorkflowStep of
            NextWorkflowStep::JUMP_BALANCE_REGISTER:
                FrontEnd.ContinueAtStep('BalanceRegister');
        end;
    end;

    local procedure ActionCode(): Text
    begin
        exit('BALANCE_V2');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    procedure ValidateRequirements(RegisterNo: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "NPR Retail Setup";
        "Audit Roll Check": Record "NPR Audit Roll";
        Register: Record "NPR Register";
        "Payment Type - Detailed": Record "NPR Payment Type - Detailed";
        SalePOS: Record "NPR Sale POS";
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
        Action1: Action;
        closingType: Option Cancel,Normal,Saved;
    begin
        RetailSetup.Get();

        Register.Get(RegisterNo);
        if (Register.Status = Register.Status::Afsluttet) then
            Error(RegisterAlreadyClosedErr);

        SalePOS.Get(RegisterNo, SalesTicketNo);
        if (RetailSalesLineCode.LineExists(SalePOS)) then
            Error(DeleteAllLinesBeforeBalancingErr);

        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
            Error('');

        "Audit Roll Check".SetRange("Register No.", RegisterNo);
        if ("Audit Roll Check".FindLast()) then begin
            if ("Audit Roll Check"."Sales Ticket No." > SalesTicketNo) then
                SalePOS.Rename(RegisterNo, RetailFormCode.FetchSalesTicketNumber(RegisterNo));
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
            if (Register.FindSet()) then
                repeat
                    if (Register."Register No." <> RegisterNo) then begin
                        Message(CloseSalesWindowMsg, Register."Register No.");
                        exit(false);
                    end;
                until Register.Next() = 0;
        end;

        SalePOS."Last Sale" := true;
        SalePOS.Modify;

        exit(true);
    end;

    procedure BalanceRegister(RegisterNo: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "NPR Retail Setup";
        pagePOSWorkshiftCheckpoint: Page "NPR POS Workshift Checkp. Card";
        "Audit Roll Check": Record "NPR Audit Roll";
        Register: Record "NPR Register";
        "Payment Type - Detailed": Record "NPR Payment Type - Detailed";
        SalePOS: Record "NPR Sale POS";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PageAction: Action;
        closingType: Option Cancel,Normal,Saved;
        CheckpointEntryNo: Integer;
    begin
        //BalanceRegister
        NPRetailSetup.Get();
        if (NPRetailSetup."Advanced Posting Activated") then
            Error('This balancing function should not be used when %1 is turned on.', NPRetailSetup."Advanced Posting Activated");

        RetailSetup.Get();
        Register.Get(RegisterNo);
        SalePOS.Get(RegisterNo, SalesTicketNo);

        CheckpointEntryNo := POSCheckpointMgr.CreateEndWorkshiftCheckpoint_AuditRoll(RegisterNo);
        Commit();

        POSWorkshiftCheckpoint.Get(CheckpointEntryNo);
        pagePOSWorkshiftCheckpoint.SetRecord(POSWorkshiftCheckpoint);

        pagePOSWorkshiftCheckpoint.SetCheckpointMode(1); // Final
        pagePOSWorkshiftCheckpoint.LookupMode(true);
        PageAction := pagePOSWorkshiftCheckpoint.RunModal();

        case PageAction of
            ACTION::LookupOK:
                begin
                    POSPaymentBinCheckpoint.Reset();
                    POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
                    POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
                    if (POSPaymentBinCheckpoint.FindFirst()) then begin
                        if (NPRetailSetup."Advanced POS Entries Activated") then
                            POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, false, CheckpointEntryNo);

                        POSCheckpointMgr.CopyCheckpointToPeriode_AR(CheckpointEntryNo, SalePOS, Today, Time, true);

                        "Payment Type - Detailed".SetRange("Register No.", RegisterNo);
                        "Payment Type - Detailed".DeleteAll(true);

                        if (not AdaptedFormBalanceRegister(SalePOS, Today())) then begin
                            SalePOS."Last Sale" := false;
                            SalePOS.Modify();
                            exit(false);
                        end;

                        if (not CODEUNIT.Run(CODEUNIT::"NPR Send Register Balance", SalePOS)) then
                            Message(txtCannotSendSMSWB);
                    end else begin
                        Error(NotCompleted);
                    end;
                end;
            else begin
                    SalePOS."Last Sale" := false;
                    SalePOS.Modify();
                    exit(false);
                end;
        end;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBalancing(SalePOS: Record "NPR Sale POS"; Register: Record "NPR Register")
    begin
    end;

    procedure AdaptedFormBalanceRegister(var SalePOS: Record "NPR Sale POS"; RegisterEndDate: Date) ret: Boolean
    var
        Register2: Record "NPR Register";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Register: Record "NPR Register";
        AuditRoll: Record "NPR Audit Roll";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Period: Record "NPR Period";
        RetailSetup: Record "NPR Retail Setup";
        RetailSetupGlobal: Record "NPR Retail Setup";
        PostAuditRoll: Codeunit "NPR Post audit roll";
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
        RetailFormCodeCu: Codeunit "NPR Retail Form Code";
        POSSale: Codeunit "NPR POS Sale";
        EndSalesTicketNo: Code[10];
        EndRegisterNo: Code[10];
        PostingRegisterNo: Code[20];
        Separator: Text[1];
        RegisterFilter: Text[30];
        RegisterBalancedByLbl: Label 'Register balanced by %1 with %2', Comment = '%1=Salesperson.Name;%2=Register."Closing Cash';
        RegisterBalancedMsg: Label 'Register %1 is balanced!', Comment = '%1=RegisterFilter';
        PostingFailedMsg: Label 'The register %1 is balanced but the posting of the audit roll failed. Try to post it by push F11 on the Audit roll', Comment = '%1=Register."Register No."';
        LukVindueFejl: Label 'You have to close the POS window on Register %1';
        PrintRegisterFailedMsg: Label 'An error occurred printing the register report. Do it manually from the Audit roll form!';
        NotEqualBalancingMsg: Label 'Error occured! \The receipt number on the balancing [%1] is not the same as on the current sale [%2]. \The balancing is saved for a retry.', Comment = '%1=Period."Sales Ticket No.";%2=SalePOS."Sales Ticket No."';
    begin
        // This is a mildly refactored version of the CU6014435.FormBalanceRegister

        //FormAfslutKasse()
        SalePOS."Last Sale" := true;
        SalePOS.Modify();

        // ** OBSOLETE CallTerminalIntegration.FlushFile("Register No.");
        ret := true;

        Period.Reset;
        Period.SetRange("Register No.", SalePOS."Register No.");
        Period.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Period.Find('+');

        if Period."Sales Ticket No." <> SalePOS."Sales Ticket No." then begin
            Message(NotEqualBalancingMsg, Period."Sales Ticket No.", SalePOS."Sales Ticket No.");
            exit(false);
        end;

        Clear(RegisterFilter);
        RetailSetupGlobal.Get();
        case RetailSetupGlobal."Balancing Posting Type" of
            RetailSetupGlobal."Balancing Posting Type"::TOTAL:
                begin
                    if Register.Find('-') then
                        repeat
                            RegisterFilter += Separator + Format(Register."Register No.");
                            if (Register."Register No." <> RetailFormCodeCu.FetchRegisterNumber) then
                                Error(LukVindueFejl, Register."Register No.");
                            Separator := '|';
                        until Register.Next = 0;
                end;
            RetailSetupGlobal."Balancing Posting Type"::"PER REGISTER":
                begin
                    RegisterFilter := Format(SalePOS."Register No.");
                end;
        end;

        Register.Find('-');
        PostingRegisterNo := Register."Register No.";

        Clear(AuditRoll);

        Register.SetFilter("Register No.", RegisterFilter);
        if Register.Find('-') then
            repeat
                Register.Validate(Status, Register.Status::Afsluttet);
                Register."Status Set By Sales Ticket" := SalePOS."Sales Ticket No.";
                Register."Closing Cash" := Period."Closing Cash";
                Register."Change Register" := Period."Change Register";
                Register.TestField(Account);
                Register.TestField("Gift Voucher Account");
                Register.TestField("Credit Voucher Account");
                Register.TestField("Difference Account");
                Register.TestField("Difference Account - Neg.");
                Register.TestField("Balance Account");

                AuditRoll.Init;
                AuditRoll."Register No." := Register."Register No.";
                AuditRoll."No." := Register."Register No.";
                AuditRoll.Lokationskode := Register."Location Code";
                AuditRoll."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
                AuditRoll."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
                AuditRoll."Dimension Set ID" := SalePOS."Dimension Set ID";
                AuditRoll."Salesperson Code" := SalePOS."Salesperson Code";
                AuditRoll.Type := AuditRoll.Type::"Open/Close";
                AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
                AuditRoll."Starting Time" := SalePOS."Start Time";
                AuditRoll."Closing Time" := Time();
                AuditRoll."Sale Date" := Today();

                AuditRoll.Balancing := true;
                AuditRoll."Sales Ticket No." := SalePOS."Sales Ticket No.";

                if SalespersonPurchaser.Get(SalePOS."Salesperson Code") then
                    AuditRoll.Description := CopyStr(StrSubstNo(RegisterBalancedByLbl, SalespersonPurchaser.Name, Register."Closing Cash"), 1, MaxStrLen(AuditRoll.Description));
                AuditRoll."Closing Cash" := Period."Closing Cash";
                AuditRoll."Transferred to Balance Account" := Period."Deposit in Bank";
                AuditRoll.Difference := Period.Difference;
                AuditRoll.EuroDifference := Period."Euro Difference";
                AuditRoll."Balance Amount" := Period."Balance Per Denomination";
                AuditRoll."Balance Sundries" := Period."Balanced Sec. Currency";
                AuditRoll."Balance amount euro" := Period."Balanced Euro";
                AuditRoll."Change Register" := Period."Change Register";

                if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo = Register."Register No.") then begin
                    EndSalesTicketNo := AuditRoll."Sales Ticket No.";
                    EndRegisterNo := AuditRoll."Register No.";
                    AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                    AuditRoll."On Register No." := EndRegisterNo;
                end;

                if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo <> Register."Register No.") then begin
                    AuditRoll."Closing Cash" := 0;
                    AuditRoll."Transferred to Balance Account" := 0;
                    AuditRoll.Difference := 0;
                    AuditRoll."Balance Amount" := '';
                    AuditRoll."Balance Sundries" := '';
                    AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                    AuditRoll."On Register No." := EndRegisterNo;
                end;
                AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
                AuditRoll."Money bag no." := Period."Money bag no.";
                AuditRoll.Balancing := true; //ohm
                if not RetailSetupGlobal."Create POS Entries Only" then begin
                    AuditRoll.Insert(true);                          //formAfslutKasse
                    RetailFormCodeCu.MoveSaleDim2AuditRoll(SalePOS, AuditRoll);
                end;
                Register."Opened Date" := 0D;
                Register.Modify;

            //Sender SMS med bruttooms�tning
            //  Flyttet til efter commit af opg�relsen.
            until Register.Next = 0;

        Commit();

        if not RetailSalesLineCode.Run(SalePOS) then
            Message(PrintRegisterFailedMsg);

        /* Code for running Credit Card dataport and delete file */

        Commit();

        Message(RegisterBalancedMsg, ConvertStr(RegisterFilter, '|', '+'));

        if RetailSetupGlobal."Posting Audit Roll" = RetailSetupGlobal."Posting Audit Roll"::Automatic then begin
            PostAuditRoll.ShowProgress(CurrentClientType = CLIENTTYPE::Windows);
            case RetailSetupGlobal."Posting When Balancing" of
                RetailSetupGlobal."Posting When Balancing"::"Per Register":
                    begin
                        AuditRoll.Reset;
                        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
                        if not PostAuditRoll.Run(AuditRoll) then
                            Message(PostingFailedMsg, Register."Register No.");
                    end;
                RetailSetupGlobal."Posting When Balancing"::Total:
                    begin
                        Register2.Reset;
                        Register2.SetCurrentKey(Status);
                        Register2.SetFilter(Status, '<>%1', Register2.Status::Afsluttet);
                        Clear(AuditRoll);
                        if not Register2.Find('-') then
                            if not PostAuditRoll.Run(AuditRoll) then
                                Message(PostingFailedMsg, Register."Register No.");
                    end;
            end;
        end;

        Commit();

        Clear(AuditRoll);
        Clear(ReportSelectionRetail);
        Commit();

        exit(true);
    end;
}
