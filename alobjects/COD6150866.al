codeunit 6150866 "POS Action - Contact Select"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
    // NPR5.55/ALPO/20200813 CASE 419139 Front-end was not refreshed properly after multiple contact selection/removal runs


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Attach or remove Contact from POS sale.';
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        CAPTION_OPERATION: Label 'Operation';
        CAPTION_TABLEVIEW: Label 'Contact Table View';
        CAPTION_CONTACTPAGE: Label 'Contact Lookup Page';
        DESC_OPERATION: Label 'Operation to perform';
        DESC_TABLEVIEW: Label 'Pre-filtered Contact list';
        DESC_CONTACTPAGE: Label 'Custom Contact lookup page';
        OPTION_OPERATION: Label 'Attach,Remove';

    local procedure ActionCode(): Text
    begin
        exit ('CONTACT_SELECT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('Select','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('Operation', 'Attach,Remove', 'Attach');
            RegisterTextParameter('ContactTableView', '');
            RegisterIntegerParameter('ContactLookupPage', 0);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Operation: Option Attach,Remove;
        JSON: Codeunit "POS JSON Management";
        ContactTableView: Text;
        ContactLookupPage: Integer;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        ContactTableView := JSON.GetStringParameter('ContactTableView', true);
        ContactLookupPage := JSON.GetIntegerParameter('ContactLookupPage', true);
        Operation := JSON.GetIntegerParameter('Operation', true);
        case Operation of
          Operation::Attach : AttachContact(POSSession, ContactTableView, ContactLookupPage);
          Operation::Remove : RemoveContact(POSSession);
        end;

        POSSession.RequestRefreshData();
    end;

    procedure AttachContact(var POSSession: Codeunit "POS Session";ContactTableView: Text;ContactLookupPage: Integer)
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Contact: Record Contact;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if ContactTableView <> '' then
          Contact.SetView(ContactTableView);

        if PAGE.RunModal(ContactLookupPage, Contact) <> ACTION::LookupOK then
          exit;

        SalePOS."Customer Type" := SalePOS."Customer Type"::Cash;
        SalePOS.Validate("Customer No.", Contact."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSale.SetModified();  //NPR5.55 [419139]
    end;

    local procedure RemoveContact(var POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSale.SetModified();  //NPR5.55 [419139]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := CAPTION_OPERATION;
          'ContactLookupPage' : Caption := CAPTION_CONTACTPAGE;
          'ContactTableView' : Caption := CAPTION_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := DESC_OPERATION;
          'ContactLookupPage' : Caption := DESC_CONTACTPAGE;
          'ContactTableView' : Caption := DESC_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := OPTION_OPERATION;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        Contact: Record Contact;
        AllObj: Record AllObj;
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'ContactTableView' :
            begin
              FilterPageBuilder.AddRecord(Contact.TableCaption, Contact);
              if POSParameterValue.Value <> '' then begin
                Contact.SetView(POSParameterValue.Value);
                FilterPageBuilder.SetView(Contact.TableCaption, Contact.GetView(false));
              end;
              if FilterPageBuilder.RunModal() then
                POSParameterValue.Value := FilterPageBuilder.GetView(Contact.TableCaption, false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "POS Parameter Value")
    var
        PageMetadata: Record "Page Metadata";
        PageId: Integer;
        Contact: Record Contact;
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'ContactLookupPage' :
            begin
              if POSParameterValue.Value = '' then
                exit;
              Evaluate(PageId, POSParameterValue.Value);
              PageMetadata.SetRange(ID, PageId);
              PageMetadata.SetRange(SourceTable, DATABASE::Contact);
              PageMetadata.FindFirst;
            end;
          'ContactTableView' :
            begin
              if POSParameterValue.Value <> '' then
                Contact.SetView(POSParameterValue.Value);
            end;
        end;
    end;
}

