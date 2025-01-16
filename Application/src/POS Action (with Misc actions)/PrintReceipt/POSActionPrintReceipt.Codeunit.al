codeunit 6150787 "NPR POS Action: Print Receipt" implements "NPR IPOS Workflow"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PRINT_RECEIPT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for printing a receipt for the current or selected transaction.';
        OptionSetting: Label 'Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large,Last Balance,Last Balance Large', Locked = true;
        CaptionSetting: Label 'Settings';
        DescSetting: Label 'Settings for print.';
        OptionCptSetting: Label 'Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large,Last Balance,Last Balance Large';
        CaptionPrintTickets: Label 'Print Tickets';
        DescPrintTickets: Label 'Parameter print tickets.';
        CaptionPrintMemberships: Label 'Print Memberships';
        DescPrintMemberships: Label 'Parameter print memberships.';
        CaptionPrintTerminalReceipt: Label 'Print Terminal Receipt';
        DescPrintTerminalReceipt: Label 'Parameter print terminal receipt.';
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
        CaptionPrintTaxFreeVoucher: Label 'Print Tax Free Voucher';
        DescPrintTaxFreeVoucher: Label 'Printing of the tax free voucher';
        CaptionPrintRetailVoucher: Label 'Print Retail Voucher';
        DescPrintRetailVoucher: Label 'Printing of the retail voucher';
        CaptionIssueDigitalReceipt: Label 'Issue Digital Receipts';
        DescIssueDigitalReceipts: Label 'Issuing of the digital receipts';
        CaptionPrintPhysicalReceipts: Label 'Print Physical Receipts';
        DescPrintPhysicalReceipts: Label 'Printing of the physical receipts';
        EnterReceiptNoLbl: Label 'Enter Receipt Number';
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
        WorkflowConfig.AddBooleanParameter('Print Physical Receipts', true, CaptionPrintPhysicalReceipts, DescPrintPhysicalReceipts);
        WorkflowConfig.AddBooleanParameter('Print Tickets', false, CaptionPrintTickets, DescPrintTickets);
        WorkflowConfig.AddBooleanParameter('Print Memberships', false, CaptionPrintMemberships, DescPrintMemberships);
        WorkflowConfig.AddBooleanParameter('Print Terminal Receipt', false, CaptionPrintTerminalReceipt, DescPrintTerminalReceipt);
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
        WorkflowConfig.AddBooleanParameter('Print Tax Free Voucher', false, CaptionPrintTaxFreeVoucher, DescPrintTaxFreeVoucher);
        WorkflowConfig.AddBooleanParameter('Print Retail Voucher', false, CaptionPrintRetailVoucher, DescPrintRetailVoucher);
        WorkflowConfig.AddBooleanParameter('Issue Digital Receipts', false, CaptionIssueDigitalReceipt, DescIssueDigitalReceipts);
        WorkflowConfig.AddLabel('EnterReceiptNoLbl', EnterReceiptNoLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionPrintRcpt.js###
'let main=async({workflow:i,popup:l,parameters:e,captions:t})=>{debugger;if(!(e["Issue Digital Receipts"]||e["Print Physical Receipts"]))return;if(e.SelectionDialogType==e.SelectionDialogType.TextField&&(e.Setting==e.Setting["Choose Receipt"]||e.Setting==e.Setting["Choose Receipt Large"])){var n=await l.input({title:t.Title,caption:t.EnterReceiptNoLbl,value:""});if(n==null)return" "}const{qrCodeLink:o,footerText:c}=await i.respond("ManualReceiptNo",{ManualReceiptNo:n});o&&await i.run("VIEW_DIG_RCPT_QRCODE",{parameters:{qrCodeLink:o,footerText:c}})};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Print Rcpt.-B";
        POSUnit: Record "NPR POS Unit";
        SettingOption: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large","Last Balance","Last Balance Large";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        SalesTicketNo: Code[20];
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
        PrintPhysicalReceipts: Boolean;
        PrintTickets: Boolean;
        PrintMemberships: Boolean;
        PrintRetailVoucher: Boolean;
        PrintTerminalReceipt: Boolean;
        PrintTaxFreeVoucher: Boolean;
        IssueDigitalReceipts: Boolean;
    begin
        SettingOption := Context.GetIntegerParameter('Setting');
        ReceiptListFilterOption := Context.GetIntegerParameter('ReceiptListFilter');
        PresetTableView := Context.GetStringParameter('ReceiptListView');
        SelectionDialogType := Context.GetIntegerParameter('SelectionDialogType');
        if ((SelectionDialogType = SelectionDialogType::TextField) and
           ((SettingOption = SettingOption::"Choose Receipt") or
           (SettingOption = SettingOption::"Choose Receipt Large"))) then
#pragma warning disable AA0139
            ManualReceiptNo := Context.GetString('ManualReceiptNo');
#pragma warning restore
        ObfuscationMethod := Context.GetIntegerParameter('ObfuscationMethod');
        PrintPhysicalReceipts := Context.GetBooleanParameter('Print Physical Receipts');
        PrintTickets := Context.GetBooleanParameter('Print Tickets');
        PrintMemberships := Context.GetBooleanParameter('Print Memberships');
        PrintRetailVoucher := Context.GetBooleanParameter('Print Retail Voucher');
        PrintTerminalReceipt := Context.GetBooleanParameter('Print Terminal Receipt');
        PrintTaxFreeVoucher := Context.GetBooleanParameter('Print Tax Free Voucher');
        IssueDigitalReceipts := Context.GetBooleanParameter('Issue Digital Receipts');

        if not (PrintPhysicalReceipts or IssueDigitalReceipts) then
            exit;

        Setup.GetPOSUnit(POSUnit);
        SalesTicketNo := BusinessLogicRun.GetSalesTicketNoAndPrintReceipt(Setup,
                                                           POSUnit,
                                                           SettingOption,
                                                           ReceiptListFilterOption,
                                                           PresetTableView,
                                                           SelectionDialogType,
                                                           ManualReceiptNo,
                                                           ObfuscationMethod,
                                                           PrintPhysicalReceipts,
                                                           PrintTickets,
                                                           PrintMemberships,
                                                           PrintRetailVoucher,
                                                           PrintTerminalReceipt,
                                                           PrintTaxFreeVoucher);

        FrontEnd.WorkflowResponse(PrepareDigitalReceiptWorkflow(IssueDigitalReceipts, SalesTicketNo));
    end;

    local procedure PrepareDigitalReceiptWorkflow(IssueDigitalReceipts: Boolean; SalesTicketNo: Code[20]) DigitalReceiptParameters: JsonObject
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Print Rcpt.-B";
        FooterTextMgt: Codeunit "NPR POS Action: IssueDigRcpt B";
        QrCodeLink: Text;
        FooterText: Text;
    begin
        if IssueDigitalReceipts then begin
            QrCodeLink := BusinessLogicRun.GetDigitalReceiptQRCodeLink(SalesTicketNo);
            FooterText := FooterTextMgt.SetFooterText();
        end;
        DigitalReceiptParameters.Add('qrCodeLink', QrCodeLink);
        DigitalReceiptParameters.Add('footerText', FooterText)
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
}
