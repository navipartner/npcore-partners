codeunit 6151286 "NPR SS Action: Start SelfServ." implements "NPR IPOS Workflow"
{
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This built in actions starts the POS in SelfService mode';
        ParamSalesPerson_CaptLbl: Label 'Sales Person Code';
        ParamSalesPerson_DescLbl: Label 'Specifies Sales Person Code';
        ParamLanguageCode_CaptLbl: Label 'Language Code';
        ParamLanguageCode_DescLbl: Label 'Specifies Language Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddTextParameter('SalespersonCode', '', ParamSalesPerson_CaptLbl, ParamSalesPerson_DescLbl);
        WorkflowConfig.AddTextParameter('LanguageCode', '', ParamLanguageCode_CaptLbl, ParamLanguageCode_DescLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
       //###NPR_INJECT_FROM_FILE:POSActionPaymentCashSS.js###
       'let main=async({})=>{await workflow.respond()};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        SalespersonCode: Code[20];
        LanguageCode: Code[10];
    begin
        SalesPersonCode := CopyStr(Context.GetStringParameter('SalespersonCode'), 1, MaxStrLen(SalespersonCode));
        LanguageCode := CopyStr(Context.GetStringParameter('LanguageCode'), 1, MaxStrLen(LanguageCode));
        StartSelfService(POSSession, SalesPersonCode, LanguageCode);
    end;

    procedure StartSelfService(POSSession: Codeunit "NPR POS Session"; SalespersonCode: Code[20]; LanguageCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Language: Record Language;
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSUIManagement: Codeunit "NPR POS UI Management";
        OpeningEntryNo: Integer;
        InactivePosUnitLbl: Label 'POS Unit %1 is inactive. It can not be used to complete the action', Comment = '%1-POS Unit code';
    begin
        DATABASE.SelectLatestVersion();
        POSSession.GetSetup(POSSetup);

        POSSetup.Initialize();

        SalespersonPurchaser.Get(SalespersonCode);
        POSSetup.SetSalesperson(SalespersonPurchaser);

        POSSetup.GetPOSUnit(POSUnit);

        // possetup might have a stale version
        POSUnit.Get(POSUnit."No.");
        POSSetup.SetPOSUnit(POSUnit);

        case POSUnit.Status of
            POSUnit.Status::OPEN:
                ; // Default

            POSUnit.Status::CLOSED:
                begin
                    CreateFirstTimeCheckpoint(POSUnit."No.");
                    POSManagePOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
                    POSManagePOSUnit.OpenPOSUnit(POSUnit);
                    OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSManagePOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
                    POSSetup.SetPOSUnit(POSUnit);
                end;

            POSUnit.Status::EOD:
                Error('This unit is busy with another process right now. Please try again later. <br>Thank-you for your patience.');

            POSUnit.Status::INACTIVE:
                Error(InactivePosUnitLbl, POSUnit."No.");
        end;

        POSCreateEntry.InsertUnitLoginEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        if (Language.Get(LanguageCode)) then begin
            if (Language."Windows Language ID" > 0) then
                GlobalLanguage(Language."Windows Language ID");
            POSUIManagement.InitializeCaptions();
        end;

        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure CreateFirstTimeCheckpoint(UnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', UnitNo);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);

        if (POSWorkshiftCheckpoint.IsEmpty()) then begin
            POSWorkshiftCheckpoint."Entry No." := 0;
            POSWorkshiftCheckpoint."POS Unit No." := UnitNo;
            POSWorkshiftCheckpoint.Open := false;
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
            POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
            POSWorkshiftCheckpoint.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitializationComplete', '', false, false)]
    local procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //Invoke POSResume codeunit to check if last exists, with manually bound subscriber?
    end;
}

