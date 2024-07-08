codeunit 6150866 "NPR POS Action: Contact Select" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::CONTACT_SELECT));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action to attach or remove contact from POS sale.';
        ParameterContactLookupPage_NameCaptionLbl: Label 'Contact Lookup Page';
        ParameterContactLookupPage_NameDescriptionLbl: Label 'Custom Contact lookup page';
        ParameterContactTableView_NameCaptionLbl: Label 'Contact Table View';
        ParameterOperation_NameCaptionLbl: Label 'Operation';
        ParameterOperation_NameDescriptionLbl: Label 'Operation to perform';
        ParameterOperation_OptionCaptionsLbl: Label 'Attach,Remove';
        ParameterOperation_OptionsLbl: Label 'Attach,Remove', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            ParameterOperation_Name(),
            ParameterOperation_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterOperation_OptionsLbl),
#pragma warning restore 
            ParameterOperation_NameCaptionLbl,
            ParameterOperation_NameDescriptionLbl,
            ParameterOperation_OptionCaptionsLbl);
        WorkflowConfig.AddTextParameter(ParameterContactTableView_Name(), '', ParameterContactTableView_NameCaptionLbl, ParameterOperation_NameDescriptionLbl);
        WorkflowConfig.AddIntegerParameter(ParameterContactLookupPage_Name(), 0, ParameterContactLookupPage_NameCaptionLbl, ParameterContactLookupPage_NameDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        PosActionBusinessLogic: Codeunit "NPR POS Action: Cont. Select-B";
        Operation: Option Attach,Remove;
        ContactTableView: Text;
        ContactLookupPage: Integer;
    begin
        Operation := Context.GetIntegerParameter(ParameterOperation_Name());
        ContactTableView := Context.GetStringParameter(ParameterContactTableView_Name());
        ContactLookupPage := Context.GetIntegerParameter(ParameterContactLookupPage_Name());

        Sale.GetCurrentSale(SalePOS);
        case Operation of
            Operation::Attach:
                PosActionBusinessLogic.AttachContact(SalePOS, ContactTableView, ContactLookupPage);
            Operation::Remove:
                PosActionBusinessLogic.RemoveContact(SalePOS);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionContactSelect.js###
'let main=async({})=>await workflow.respond();'
        );
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
            ParameterContactTableView_Name():
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
            ParameterContactLookupPage_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Evaluate(PageId, POSParameterValue.Value);
                    PageMetadata.SetRange(ID, PageId);
                    PageMetadata.SetRange(SourceTable, DATABASE::Contact);
                    PageMetadata.FindFirst();
                end;
            ParameterContactTableView_Name():
                begin
                    if POSParameterValue.Value <> '' then
                        Contact.SetView(POSParameterValue.Value);
                end;
        end;
    end;

    local procedure ParameterOperation_Name(): Text[30]
    begin
        exit('Operation');
    end;

    local procedure ParameterContactTableView_Name(): Text[30]
    begin
        exit('ContactTableView');
    end;

    local procedure ParameterContactLookupPage_Name(): Text[30]
    begin
        exit('ContactLookupPage');
    end;
}
