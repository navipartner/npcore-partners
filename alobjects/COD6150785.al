codeunit 6150785 "PoC: CUST_DEBITSALE"
{

    trigger OnRun()
    begin
    end;

    var
        ActionCode: Label 'CUST_DEBITSALE';
        ActionDescription: Label 'Customer - Debit Sale (Proof of Concept)';
        ActionVersion: Label '1.0';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('CUST_SELECT',
              'if (!context.CustSpecified) { if (!model.EanBox) input("customer lookup not yet supported","enter custoner number in manually.").store("CustomerNo"); else store("CustomerNo", model.EanBox); }; respond(); model.EanBox = "";');
            RegisterWorkflowStep('SET_REFERENCE','if (context.RefMandatory) input("now set reference").store("ReferenceNo"); respond();');
            RegisterWorkflowStep('SET_EXTDOCNO','if (context.ExtDocMandatory) input("now setting mandatory").store("ExternalDocNo"); respond();');
            RegisterWorkflowStep('COMPLETE','respond();');
            RegisterWorkflow(true);

            RegisterOptionParameter('Posting','None,Ship,Invoice,Both','None');
            RegisterBooleanParameter('Printing',false);
            RegisterBooleanParameter('AuditRoll',true);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Context.SetContext('CustSpecified',false);   // Set the variable based on actual state in the transaction
        Context.SetContext('RefMandatory',true);    // The same here
        Context.SetContext('ExtDocMandatory',true); // Same here
        FrontEnd.SetActionContext(ActionCode,Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        case WorkflowStep of
          'CUST_SELECT':    AfterStep_SelectCustomer(Context,POSSession,FrontEnd);
          'SET_REFERENCE':  AfterStep_SetReference(Context,POSSession,FrontEnd);
          'SET_EXTDOCNO':   AfterStep_SetExtDocNo(Context,POSSession,FrontEnd);
          'COMPLETE':       AfterStep_Complete(Context,POSSession,FrontEnd);
          else
            FrontEnd.ReportBug(StrSubstNo('Unknown step in action %1: %2',Action.Code,WorkflowStep)); // TODO: probably something different here
        end;

        Handled := true;
    end;

    local procedure AfterStep_SelectCustomer(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
    begin
    end;

    local procedure AfterStep_SetReference(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    local procedure AfterStep_SetExtDocNo(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    local procedure AfterStep_Complete(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        Posting: Option "None",Ship,Invoice,Both;
        Printing: Boolean;
        AuditRoll: Boolean;
        CustNo: Code[20];
        ReferenceNo: Text;
        ExtDocNo: Text[20];
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        CustNo := JSON.GetString('CustomerNo',false);
        ReferenceNo := JSON.GetString('ReferenceNo',false);
        ExtDocNo := JSON.GetString('ExternalDocNo',false);

        JSON.SetScope('parameters',true);
        Posting := JSON.GetInteger('Posting',true);
        Printing := JSON.GetBoolean('Printing',true);
        AuditRoll := JSON.GetBoolean('AuditRoll',true);

        // Do the final business logic here - all context is known and available

        Message('Completing workflow with:\\Posting: %1\Printing: %2\Audit Roll: %3\\Customer No.: %4\Reference No.: %5\External Doc. No.: %6',
          Posting,
          Printing,
          AuditRoll,
          CustNo,
          ReferenceNo,
          ExtDocNo);
    end;
}

