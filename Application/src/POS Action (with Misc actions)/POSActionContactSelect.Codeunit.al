codeunit 6150866 "NPR POS Action: Contact Select"
{
    var
        ActionDescription: Label 'Attach or remove Contact from POS sale.';
        CAPTION_OPERATION: Label 'Operation';
        CAPTION_TABLEVIEW: Label 'Contact Table View';
        CAPTION_CONTACTPAGE: Label 'Contact Lookup Page';
        DESC_OPERATION: Label 'Operation to perform';
        DESC_TABLEVIEW: Label 'Pre-filtered Contact list';
        DESC_CONTACTPAGE: Label 'Custom Contact lookup page';
        OPTION_OPERATION: Label 'Attach,Remove';

    local procedure ActionCode(): Code[20]
    begin
        exit('CONTACT_SELECT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('Select', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('Operation', 'Attach,Remove', 'Attach');
            Sender.RegisterTextParameter('ContactTableView', '');
            Sender.RegisterIntegerParameter('ContactLookupPage', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Operation: Option Attach,Remove;
        JSON: Codeunit "NPR POS JSON Management";
        ContactTableView: Text;
        ContactLookupPage: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        ContactTableView := JSON.GetStringParameterOrFail('ContactTableView', ActionCode());
        ContactLookupPage := JSON.GetIntegerParameterOrFail('ContactLookupPage', ActionCode());
        Operation := JSON.GetIntegerParameterOrFail('Operation', ActionCode());
        case Operation of
            Operation::Attach:
                AttachContact(POSSession, ContactTableView, ContactLookupPage);
            Operation::Remove:
                RemoveContact(POSSession);
        end;

        POSSession.RequestRefreshData();
    end;

    procedure AttachContact(var POSSession: Codeunit "NPR POS Session"; ContactTableView: Text; ContactLookupPage: Integer)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        POSSale.SetModified();
    end;

    local procedure RemoveContact(var POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSale.SetModified();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := CAPTION_OPERATION;
            'ContactLookupPage':
                Caption := CAPTION_CONTACTPAGE;
            'ContactTableView':
                Caption := CAPTION_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := DESC_OPERATION;
            'ContactLookupPage':
                Caption := DESC_CONTACTPAGE;
            'ContactTableView':
                Caption := DESC_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := OPTION_OPERATION;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        Contact: Record Contact;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ContactTableView':
                begin
                    FilterPageBuilder.AddRecord(Contact.TableCaption, Contact);
                    if POSParameterValue.Value <> '' then begin
                        Contact.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(Contact.TableCaption, Contact.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(Contact.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PageMetadata: Record "Page Metadata";
        PageId: Integer;
        Contact: Record Contact;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ContactLookupPage':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Evaluate(PageId, POSParameterValue.Value);
                    PageMetadata.SetRange(ID, PageId);
                    PageMetadata.SetRange(SourceTable, DATABASE::Contact);
                    PageMetadata.FindFirst();
                end;
            'ContactTableView':
                begin
                    if POSParameterValue.Value <> '' then
                        Contact.SetView(POSParameterValue.Value);
                end;
        end;
    end;
}
