codeunit 6150722 "POS Action - Text Enter"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.36/TSA /20170804 CASE 285403 Added wrapper function ScanBarcode() - used to apply f.ex. a coupon using the dispenser mechanism
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for completing the TextEnter request passed from the front end (when user presses enter in a supported text box)';
        Text001: Label 'Control %1 has just sent an %2 event, but it appears that events for this control are not handled.';
        NotFound: Label 'The value %1 is not a valid value for EAN Box.';
        Text002: Label 'Ambigous input, please specify.';

    local procedure ActionCode(): Text
    begin
        exit ('TEXT_ENTER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::BackEnd,
          Sender."Subscriber Instances Allowed"::Single);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        EanBoxEventHandler: Codeunit "Ean Box Event Handler";
        ControlId: Text;
        Value: Text;
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        ControlId := JSON.GetString('id',true);
        Value := JSON.GetString('value',true);

        case ControlId of
          //-NPR5.45 [319706]
          //'EanBox': EanBox(Context, POSSession, FrontEnd, Value,DoNotClearTextBox);
          'EanBox':
            EanBoxEventHandler.InvokeEanBox(Value,Context,POSSession,FrontEnd);
          //+NPR5.45 [319706]
          else
            FrontEnd.ReportBug(StrSubstNo(Text001,ControlId,ActionCode));
        end;

        //-NPR5.45 [319706]
        // IF DoNotClearTextBox THEN
        //  FrontEnd.SetOption('doNotClearTextBox',TRUE);
        //+NPR5.45 [319706]

        Handled := true;
    end;
}

