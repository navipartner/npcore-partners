codeunit 6150790 "NPR POS Action: Customer Loc."
{
    // NPR5.31/MMV /20170322 CASE 264112 Added support for new setting StampAndImport.
    //                                   Added explicit view switch on export.
    //                                   Upversioned action to 1.3.
    // NPR5.38/BR  /20180118 CASE 302761 Disable Audit Roll Creation for "Create POS Enties Only"
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // #381848/VB  /20200526 CASE 381848  Refactoring the LocationExport function (replacing FrontEnd.SetView call with FrontEnd.SaleView call)

    Permissions = TableData "NPR Audit Roll" = rimd;

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for moving sale lines to/from a customer location and starting related prints.';
        Caption_TransferSale: Label 'Transferred to location receipt';

    local procedure ActionCode(): Text
    begin
        exit('CUST_LOCATION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Button,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflow(false);
                //-NPR5.31 [264112]
                //RegisterOptionParameter('Setting','Import,Export,Print,List','Import');
                RegisterOptionParameter('Setting', 'Import,Export,Print,List,StampAndImport', 'Import');
                //+NPR5.31 [264112]
                RegisterTextParameter('Location No.', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        LocationNo: Code[20];
        JSON: Codeunit "NPR POS JSON Management";
        Setting: Option Import,Export,Print,List,StampAndImport;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        Setting := JSON.GetInteger('Setting', true);
        LocationNo := JSON.GetString('Location No.', false);

        case Setting of
            //-NPR5.31 [264112]
            //Setting::Export : LocationExport(LocationNo,POSSession);
            Setting::Export:
                LocationExport(LocationNo, POSSession, FrontEnd);
            Setting::StampAndImport:
                LocationStampAndImport(LocationNo, POSSession);
            //+NPR5.31 [264112]
            Setting::Import:
                LocationImport(LocationNo, POSSession);
            Setting::List:
                LocationList();
            Setting::Print:
                LocationPrint(LocationNo, POSSession);
        end;

        Handled := true;
    end;

    local procedure LocationExport(LocationNo: Code[20]; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSCustLocMgt: Codeunit "NPR POS Customer Location Mgt.";
        ViewType: DotNet NPRNetViewType0;
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if POSCustLocMgt.SaveSaleToLoc(LocationNo, SalePOS) then begin
            POSSession.StartTransaction();
            //-NPR5.31 [264112]
            POSSession.GetSetup(POSSetup);
            FrontEnd.SaleView(POSSetup);
            //+NPR5.31 [264112]
        end;
    end;

    local procedure LocationImport(LocationNo: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSCustLocMgt: Codeunit "NPR POS Customer Location Mgt.";
        LocSalePOS: Record "NPR Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if POSCustLocMgt.GetSaleFromLoc(LocationNo, SalePOS, LocSalePOS) then begin
            POSSale.LoadSavedSale(LocSalePOS);

            WriteAuditRollTrace(SalePOS, LocSalePOS);

            //-NPR5.38 [302761]
            WritePOSEntryTrace(SalePOS, LocSalePOS);
            //+NPR5.38 [302761]

            POSSession.RequestRefreshData;
        end;
    end;

    local procedure LocationList()
    var
        POSCustLocMgt: Codeunit "NPR POS Customer Location Mgt.";
    begin
        POSCustLocMgt.List(false, true);
    end;

    local procedure LocationPrint(LocationNo: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSCustLocMgt: Codeunit "NPR POS Customer Location Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSCustLocMgt.Print(0, SalePOS, LocationNo);
    end;

    local procedure LocationStampAndImport(LocationNo: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSCustLocMgt: Codeunit "NPR POS Customer Location Mgt.";
        LocSalePOS: Record "NPR Sale POS";
        Import: Boolean;
    begin
        //-NPR5.31 [264112]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Import := POSCustLocMgt.StampSaleAndGetFromLoc(LocationNo, SalePOS, LocSalePOS);
        POSSale.Refresh(SalePOS);

        if Import then begin
            POSSale.LoadSavedSale(LocSalePOS);
            WriteAuditRollTrace(SalePOS, LocSalePOS);
            POSSession.RequestRefreshData;
        end;
        //+NPR5.31 [264112]
    end;

    local procedure WriteAuditRollTrace(var NewSalePOS: Record "NPR Sale POS"; var OldSalePOS: Record "NPR Sale POS")
    var
        AuditRoll: Record "NPR Audit Roll";
        RetailSetup: Record "NPR Retail Setup";
        LineNo: Integer;
    begin
        //-NPR5.38 [302761]
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
            exit;
        //+NPR5.38 [302761]
        AuditRoll.SetCurrentKey("Sales Ticket No.", "Line No.");
        AuditRoll.SetRange("Sales Ticket No.", OldSalePOS."Sales Ticket No.");
        if AuditRoll.FindLast then;
        LineNo := AuditRoll."Line No." + 10000;

        AuditRoll.Init;
        AuditRoll."Register No." := OldSalePOS."Register No.";
        AuditRoll."Sales Ticket No." := OldSalePOS."Sales Ticket No.";
        AuditRoll."Line No." := LineNo;
        AuditRoll."Sale Date" := Today;
        AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
        AuditRoll.Type := AuditRoll.Type::Cancelled;
        AuditRoll."Salesperson Code" := OldSalePOS."Salesperson Code";
        AuditRoll."No." := '';
        AuditRoll.Description := StrSubstNo('%1 %2', Caption_TransferSale, NewSalePOS."Sales Ticket No.");
        AuditRoll."Starting Time" := Time;
        AuditRoll."Closing Time" := Time;
        AuditRoll.Posted := true;
        AuditRoll."Drawer Opened" := OldSalePOS."Drawer Opened";
        AuditRoll."Offline receipt no." := OldSalePOS."Sales Ticket No.";
        AuditRoll.Insert(true);
    end;

    local procedure WritePOSEntryTrace(var NewSalePOS: Record "NPR Sale POS"; var OldSalePOS: Record "NPR Sale POS")
    var
        POSEntry: Record "NPR POS Entry";
        RetailSetup: Record "NPR Retail Setup";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        //-NPR5.38 [302761]
        POSCreateEntry.InsertTransferLocation(OldSalePOS."Register No.", OldSalePOS."Salesperson Code", NewSalePOS."Sales Ticket No.", OldSalePOS."Sales Ticket No.");
        //+NPR5.38 [302761]
    end;
}

