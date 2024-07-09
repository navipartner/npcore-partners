codeunit 6150653 "NPR POS Action: Send Receipt" implements "NPR IPOS Workflow"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::SEND_RECEIPT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for sending a receipt in an E-mail for the current or selected transaction.';
        OptionSetting: Label 'Last Receipt,Choose Receipt', Locked = true;
        CaptionSetting: Label 'Settings';
        DescSetting: Label 'Settings for print.';
        OptionCptSetting: Label 'Last Receipt,Choose Receipt';
        OptionReceiptListFilter: Label 'None,Current POS Store,Current POS Unit,Current Salesperson', locked = true;
        CaptionReceiptListFilter: Label 'Receipt List Filter';
        DescReceiptListFilter: Label 'Filter for receipts.';
        OptionCptReceiptListFilter: Label 'None,Current POS Store,Current POS Unit,Current Salesperson';
        CaptionReceiptListView: Label 'Receipt List View';
        DescReceiptListView: Label 'View of the receipt list.';
        OptionSelectionDialogType: Label 'TextField,List', locked = true;
        CaptionSelectionDialogType: Label 'Selection Dialog Type';
        DescSelectionDialogType: Label 'Type of the selection dialog.';
        OptionCptSelectionDialogType: Label 'TextField,List';
        OptionObfuscationMethod: Label 'None,MI', locked = true;
        CaptionObfuscationMethod: Label 'Obfuscation Method';
        DescObfuscationMethod: Label 'Type of the obfuscation method';
        OptionCptObfuscationMethod: Label 'None,MI';
        EnterReceiptNoLbl: Label 'Enter Receipt Number';
        EmailTemplateCodeCptLbl: Label 'Set E-mail Template';
        EmailTemplateCodeDescLbl: Label 'Choose E-mail Template';
        SelectReceiptToSend_CptLbl: Label 'Select Receipt To Send';
        SelectReceiptToSend_DescLbl: Label 'Choose which receipt you want to send';
        SelectReceiptToSend_OptLbl: Label 'Normal Receipt,Digital Receipt';
        EmailAddCptLbl: Label 'E-mail:';
        EmailAddTitLbl: Label 'Please enter the E-mail address';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('Setting',
                                        OptionSetting,
#pragma warning disable AA0139
                                        SelectStr(1, OptionSetting),
#pragma warning restore 
                                        CaptionSetting,
                                        DescSetting,
                                        OptionCptSetting);
        WorkflowConfig.AddOptionParameter('ReceiptListFilter',
                                        OptionReceiptListFilter,
#pragma warning disable AA0139
                                        SelectStr(3, OptionReceiptListFilter),
#pragma warning restore 
                                        CaptionReceiptListFilter,
                                        DescReceiptListFilter,
                                        OptionCptReceiptListFilter);
        WorkflowConfig.AddTextParameter('ReceiptListView', '', CaptionReceiptListView, DescReceiptListView);
        WorkflowConfig.AddOptionParameter('SelectionDialogType',
                                        OptionSelectionDialogType,
#pragma warning disable AA0139
                                        SelectStr(2, OptionSelectionDialogType),
#pragma warning restore 
                                        CaptionSelectionDialogType,
                                        DescSelectionDialogType,
                                        OptionCptSelectionDialogType);
        WorkflowConfig.AddOptionParameter('ObfuscationMethod',
                                        OptionObfuscationMethod,
#pragma warning disable AA0139
                                          SelectStr(1, OptionObfuscationMethod),
#pragma warning restore
                                          CaptionObfuscationMethod,
                                        DescObfuscationMethod,
                                        OptionCptObfuscationMethod);
        WorkflowConfig.AddTextParameter('EmailTemplate', '', EmailTemplateCodeCptLbl, EmailTemplateCodeDescLbl);
        WorkflowConfig.AddLabel('EnterReceiptNoLbl', EnterReceiptNoLbl);
        WorkflowConfig.AddLabel('EmailTitle', EmailAddTitLbl);
        WorkflowConfig.AddLabel('EmailCpt', EmailAddCptLbl);
        WorkflowConfig.AddOptionParameter('SelectReceiptToSend',
                                           SelectReceiptToSend_OptLbl,
#pragma warning disable AA0139
                                           SelectStr(1, SelectReceiptToSend_OptLbl),
#pragma warning restore 
                                           SelectReceiptToSend_CptLbl,
                                           SelectReceiptToSend_DescLbl,
                                           SelectReceiptToSend_OptLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSendRcpt.js###
'let main=async({workflow:t,popup:i,parameters:e,captions:l,context:n})=>{if(!e.EmailTemplate){i.error("Please set an E-mail Template before sending.");return}if(e.SelectionDialogType==e.SelectionDialogType.TextField&&(e.Setting==e.Setting["Choose Receipt"]||e.Setting==e.Setting["Choose Receipt Large"])){var a=await i.input({title:l.Title,caption:l.EnterReceiptNoLbl,value:""});if(a==null)return" "}await t.respond("setReceipt",{ManualReceiptNo:a}),t.context.receiptAddress=await i.input({caption:l.EmailCpt,title:l.EmailTitle,value:n.defaultEmail}),!(t.context.receiptAddress===null||t.context.receiptAddress==="")&&(await t.respond("sendReceiptNo"),n.status?i.error(n.status):i.message("E-mail has been successfully sent."))};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'setReceipt':
                FrontEnd.WorkflowResponse(GetReceipt(Context));
            'sendReceiptNo':
                SendEmail(Context);
        end;

    end;

    local procedure SendEmail(Context: Codeunit "NPR POS JSON Helper")
    var
        NPOSActionSendRcptB: Codeunit "NPR POS Action: Send Rcpt.-B";
        EmailTemplateCode: Code[20];
        ReceiptEmail: Text[80];
        EntryNo: Integer;
        SelectReceiptToSendParam: Integer;
    begin
        ValidateEmailAddress(Context);

        EntryNo := Context.GetInteger('entryNo');

#pragma warning disable AA0139
        EmailTemplateCode := Context.GetStringParameter('EmailTemplate');
        ReceiptEmail := Context.GetString('receiptAddress');
#pragma warning restore 
        SelectReceiptToSendParam := Context.GetIntegerParameter('SelectReceiptToSend');
        Context.SetContext('status', NPOSActionSendRcptB.SendReceipt(EmailTemplateCode, ReceiptEmail, EntryNo, SelectReceiptToSendParam));
    end;

    local procedure GetReceipt(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Send Rcpt.-B";
        SettingOption: Option "Last Receipt","Choose Receipt";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
        POSEntry: Record "NPR POS Entry";
        Customer: Record Customer;
    begin
        SettingOption := Context.GetIntegerParameter('Setting');
        ReceiptListFilterOption := Context.GetIntegerParameter('ReceiptListFilter');
        PresetTableView := Context.GetStringParameter('ReceiptListView');
        SelectionDialogType := Context.GetIntegerParameter('SelectionDialogType');
        if ((SelectionDialogType = SelectionDialogType::TextField) and
           ((SettingOption = SettingOption::"Choose Receipt"))) then
            //   (SettingOption = SettingOption::"Choose Receipt Large"))) then
#pragma warning disable AA0139
            ManualReceiptNo := Context.GetString('ManualReceiptNo');
#pragma warning restore
        ObfuscationMethod := Context.GetIntegerParameter('ObfuscationMethod');
        BusinessLogicRun.SetReceipt(POSEntry, SettingOption,
                                    ReceiptListFilterOption,
                                    PresetTableView,
                                    SelectionDialogType,
                                    ManualReceiptNo,
                                    ObfuscationMethod);
        Context.SetContext('entryNo', POSEntry."Entry No.");
        if POSEntry."Customer No." <> '' then
            Customer.Get(POSEntry."Customer No.");

        Context.SetContext('defaultEmail', Customer."E-Mail");
    end;

    local procedure ValidateEmailAddress(Context: Codeunit "NPR POS JSON Helper")
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.CheckValidEmailAddresses(Context.GetString('receiptAddress'));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        PosEntry: Record "NPR POS Entry";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ReceiptListView':
                begin
                    FilterPageBuilder.AddRecord(PosEntry.TableCaption, PosEntry);
                    if POSParameterValue.Value <> '' then begin
                        PosEntry.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(PosEntry.TableCaption, PosEntry.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(PosEntry.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PosEntry: Record "NPR POS Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ReceiptListView':
                begin
                    if POSParameterValue.Value <> '' then
                        PosEntry.SetView(POSParameterValue.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupEmailTemplateParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'EmailTemplate' then
            exit;
        Handled := true;

        if Page.RunModal(0, EmailTemplateHeader) = Action::LookupOK then
            POSParameterValue.Value := EmailTemplateHeader.Code;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateEmailTemplateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        TypeErr: Label 'E-mail Tempalte can be only 20 characters.';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'EmailTemplate' then
            exit;
        if POSParameterValue.Value = '' then
            exit;
        if StrLen(POSParameterValue.Value) > 20 then
            Error(TypeErr);

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not EmailTemplateHeader.Get(POSParameterValue.Value) then begin
            EmailTemplateHeader.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if EmailTemplateHeader.FindFirst() then
                POSParameterValue.Value := EmailTemplateHeader.Code;
        end;

        EmailTemplateHeader.Get(POSParameterValue.Value);
    end;
}
