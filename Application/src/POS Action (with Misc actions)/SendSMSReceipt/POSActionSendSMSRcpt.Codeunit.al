codeunit 6184926 "NPR POS Action: Send SMS Rcpt" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for sending a receipt in SMS for the current or selected transaction.';
        OptionSetting: Label 'Last Receipt,Choose Receipt', Locked = true;
        CaptionSetting: Label 'Settings';
        DescSetting: Label 'Settings for SMS.';
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
        EnterReceiptNoLbl: Label 'Enter Receipt Number';
        SMSTemplateCodeCptLbl: Label 'Set SMS Template';
        SMSTemplateCodeDescLbl: Label 'Choose SMS Template';
        PhoneNoAddCptLbl: Label 'Mobile Phone No.:';
        PhoneNoAddTitLbl: Label 'Please enter the mobile phone No.';
        SMSTemplateErrLbl: Label 'Please set a SMS Template before sending.';
        SMSSentLbl: Label 'SMS has been successfully sent.';
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
        WorkflowConfig.AddTextParameter('SMSTemplate', '', SMSTemplateCodeCptLbl, SMSTemplateCodeDescLbl);
        WorkflowConfig.AddLabel('EnterReceiptNoLbl', EnterReceiptNoLbl);
        WorkflowConfig.AddLabel('SMSTitle', PhoneNoAddTitLbl);
        WorkflowConfig.AddLabel('SMSCpt', PhoneNoAddCptLbl);
        WorkflowConfig.AddLabel('SMSTemplateErr', SMSTemplateErrLbl);
        WorkflowConfig.AddLabel('SMSSent', SMSSentLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'setReceipt':
                FrontEnd.WorkflowResponse(GetReceipt(Context));
            'sendSMS':
                SendSMS(Context);
        end;
    end;

    local procedure GetReceipt(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSActionSendSMSRcptB: Codeunit "NPR POS Action: Send SMS RcptB";
        SettingOption: Option "Last Receipt","Choose Receipt";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        POSEntry: Record "NPR POS Entry";
        Customer: Record Customer;
    begin
        SettingOption := Context.GetIntegerParameter('Setting');
        ReceiptListFilterOption := Context.GetIntegerParameter('ReceiptListFilter');
        PresetTableView := Context.GetStringParameter('ReceiptListView');
        SelectionDialogType := Context.GetIntegerParameter('SelectionDialogType');
        if ((SelectionDialogType = SelectionDialogType::TextField) and
           ((SettingOption = SettingOption::"Choose Receipt"))) then
#pragma warning disable AA0139
            ManualReceiptNo := Context.GetString('ManualReceiptNo');
#pragma warning restore
        POSActionSendSMSRcptB.SetReceipt(POSEntry, SettingOption,
                                    ReceiptListFilterOption,
                                    PresetTableView,
                                    SelectionDialogType,
                                    ManualReceiptNo);
        Context.SetContext('entryNo', POSEntry."Entry No.");
        if POSEntry."Customer No." <> '' then
            Customer.Get(POSEntry."Customer No.");

        Context.SetContext('defaultPhoneNo', Customer."Mobile Phone No.");
    end;

    local procedure SendSMS(Context: Codeunit "NPR POS JSON Helper")
    var
        SMSTemplateCode: Code[20];
        ReceiptPhoneNo: Text[80];
        EntryNo: Integer;
        POSActionSendSMSRcptB: Codeunit "NPR POS Action: Send SMS RcptB";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := Context.GetInteger('entryNo');
        POSEntry.Get(EntryNo);

#pragma warning disable AA0139
        SMSTemplateCode := Context.GetStringParameter('SMSTemplate');
        ReceiptPhoneNo := Context.GetString('receiptPhoneNo');
#pragma warning restore
        POSActionSendSMSRcptB.SendReceipt(SMSTemplateCode, ReceiptPhoneNo, EntryNo);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSendSMSRcpt.js###
'let main=async({workflow:i,popup:n,parameters:e,captions:t,context:S})=>{if(!e.SMSTemplate){n.error(t.SMSTemplateErr);return}if(e.SelectionDialogType==e.SelectionDialogType.TextField&&(e.Setting==e.Setting["Choose Receipt"]||e.Setting==e.Setting["Choose Receipt Large"])){var l=await n.input({title:t.Title,caption:t.EnterReceiptNoLbl,value:""});if(l==null)return" "}await i.respond("setReceipt",{ManualReceiptNo:l}),i.context.receiptPhoneNo=await n.input({caption:t.SMSCpt,title:t.SMSTitle,value:S.defaultPhoneNo}),!(i.context.receiptPhoneNo===null||i.context.receiptPhoneNo==="")&&(await i.respond("sendSMS"),S.status?n.error(S.status):n.message(t.SMSSent))};'
        );
    end;
}
