codeunit 6150845 "POS Action - Quick Login"
{
    // NPR5.39/MHA /20180129  CASE 302237 Object created - Quick Login on current POS Sale
    // NPR5.43/MHA /20180607  CASE 313123 Renamed function from -Reasons- to -Salesperson- and added filter on "Locked-to Register No."


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Quick Login - change Salesperson on current POS Sale';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('FixedSalespersonCode','if (param.FixedSalespersonCode != "")  {respond()}');
            RegisterWorkflowStep('LookupSalespersonCode','if (param.LookupSalespersonCode)  {respond()}');

            RegisterTextParameter('FixedSalespersonCode','');
            RegisterBooleanParameter('LookupSalespersonCode',true);
            RegisterWorkflow(false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'FixedSalespersonCode':
            begin
              Handled := true;
              //-NPR5.43 [313123]
              //OnActionFixedReasonCode(JSON,POSSession);
              OnActionFixedSalespersonCode(JSON,POSSession);
              //+NPR5.43 [313123]
              exit;
            end;
          'LookupSalespersonCode':
            begin
              Handled := true;
              //-NPR5.43 [313123]
              //OnActionLookupReasonCode(JSON,POSSession);
              OnActionLookupSalespersonCode(JSON,POSSession);
              //+NPR5.43 [313123]
              exit;
            end;
        end;
    end;

    local procedure OnActionFixedSalespersonCode(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        SalespersonCode: Code[10];
    begin
        JSON.SetScope('parameters',true);
        SalespersonCode := JSON.GetString('FixedSalespersonCode',true);
        if SalespersonCode = '' then
          exit;

        ApplySalespersonCode(SalespersonCode,POSSession);

        POSSession.RequestRefreshData();
    end;

    local procedure OnActionLookupSalespersonCode(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;
        if SalespersonPurchaser.Get(SalePOS."Salesperson Code") then;
        //-NPR5.43 [313123]
        SalespersonPurchaser.FilterGroup(2);
        SalespersonPurchaser.SetFilter("Locked-to Register No.",'%1|%2','',SalePOS."Register No.");
        SalespersonPurchaser.FilterGroup(0);
        //+NPR5.43 [313123]
        if PAGE.RunModal(0,SalespersonPurchaser) <> ACTION::LookupOK then
          exit;

        ApplySalespersonCode(SalespersonPurchaser.Code,POSSession);
        POSSession.RequestRefreshData();
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure ApplySalespersonCode(SalespersonCode: Code[10];var POSSession: Codeunit "POS Session")
    var
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        SalePOS.Validate("Salesperson Code",SalespersonCode);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;

    local procedure ActionCode(): Text
    begin
        exit ('QUICK_LOGIN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;
}

