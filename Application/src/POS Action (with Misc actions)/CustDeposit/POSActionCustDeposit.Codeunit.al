codeunit 6150864 "NPR POS Action: Cust. Deposit" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(enum::"NPR POS Workflow"::CUSTOMER_DEPOSIT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Collect customer deposits, optionally applied directly to entries.';
        ParamDepositType_NameCptLbl: Label 'Deposit Type';
        ParamDepositType_OptLbl: Label 'ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt', Locked = true;
        ParamDepositType_OptCptLbl: Label 'Apply Customer Entries,Invoice No. Prompt,Amount Prompt,Match Amount To Customer Balance,Cr. Memo No. Prompt';
        ParamDepositType_OptDescLbl: Label 'Select how deposit is entered';
        ParamCustEntryView_NameCptLbl: Label 'Customer Entry View';
        ParamCustEntryView_DescLbl: Label 'Pre-filtered customer entry view';
        InvoiceNoPrompt_Cpt: Label 'Enter document no.';
        AmountPrompt_Cpt: Label 'Enter amount to deposit';
        EditDesc_titleLbl: Label 'Add or change description.';
        ParamEditDescription_CaptionLbl: Label 'Edit Description';
        ParamEditDescription_DescLbl: Label 'Enable/Disable Edit Description';
        ParamCopyDescToLedgerEntries_CaptionLbl: Label 'Copy Description';
        ParamCopyDescToLedgerEntries_DescLbl: Label 'Copy New Description to Ledger Entries';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('InvoiceNoPrompt', InvoiceNoPrompt_Cpt);
        WorkflowConfig.AddLabel('AmountPrompt', AmountPrompt_Cpt);
        WorkflowConfig.AddLabel('CrMemoNoPrompt', InvoiceNoPrompt_Cpt);
        WorkflowConfig.AddLabel('editDesc_title', EditDesc_titleLbl);
        WorkflowConfig.AddLabel('editDesc_lead', EditDesc_titleLbl);
        WorkflowConfig.AddOptionParameter(
            'DepositType',
            ParamDepositType_OptLbl,
#pragma warning disable AA0139
            SelectStr(1, ParamDepositType_OptLbl),
#pragma warning restore 
            ParamDepositType_NameCptLbl,
            ParamDepositType_OptDescLbl,
            ParamDepositType_OptCptLbl);
        WorkflowConfig.AddTextParameter('CustomerEntryView', '', ParamCustEntryView_NameCptLbl, ParamCustEntryView_DescLbl);
        WorkflowConfig.AddBooleanParameter('EditDescription', false, ParamEditDescription_CaptionLbl, ParamEditDescription_DescLbl);
        WorkflowConfig.AddBooleanParameter('CopyNewDescToLedgEntries', false, ParamCopyDescToLedgerEntries_CaptionLbl, ParamCopyDescToLedgerEntries_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        CopyDesc: Boolean;
    begin
        if Context.GetBooleanParameter('CopyNewDescToLedgEntries', CopyDesc) then;

        case Step of
            'CreateDeposit':
                CreateDeposit(Context, Sale, SaleLine, CopyDesc);
            'ChangeDesc':
                ChangeDesc(Context, SaleLine, CopyDesc)
        end;
    end;

    local procedure CreateDeposit(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; CopyDesc: Boolean)
    var
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Code[20];
        PromptAmt: Decimal;
        POSActionCustDepositB: Codeunit "NPR POS Action: Cust.Deposit B";
    begin
        DepositType := Context.GetIntegerParameter('DepositType');
        CustomerEntryView := Context.GetStringParameter('CustomerEntryView');

        if (DepositType = DepositType::InvoiceNoPrompt) or (DepositType = DepositType::CrMemoNoPrompt) then
            PromptValue := CopyStr(UpperCase(Context.GetString('PromptValue')), 1, MaxStrLen(PromptValue));
        if (DepositType = DepositType::AmountPrompt) then
            PromptAmt := Context.GetDecimal('PromptAmt');

        POSActionCustDepositB.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, CopyDesc);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerEntryView':
                begin
                    FilterPageBuilder.AddRecord(CustLedgerEntry.TableCaption, CustLedgerEntry);
                    if POSParameterValue.Value <> '' then begin
                        CustLedgerEntry.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(CustLedgerEntry.TableCaption, CustLedgerEntry.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(CustLedgerEntry.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerEntryView':
                begin
                    if POSParameterValue.Value <> '' then
                        CustLedgerEntry.SetView(POSParameterValue.Value);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCustDeposit.js###
'let main=async({workflow:i,parameters:n,popup:a,captions:e,context:t})=>{if(!(n.DepositType==1&&(t.PromptValue=await a.input({caption:e.InvoiceNoPrompt}),t.PromptValue===null))&&!(n.DepositType==2&&(t.PromptAmt=await a.numpad({caption:e.AmountPrompt}),t.PromptAmt===null))&&!(n.DepositType==4&&(t.PromptValue=await a.input({caption:e.CrMemoNoPrompt}),t.PromptValue===null))&&(await i.respond("CreateDeposit"),n.EditDescription)){debugger;if(i.context.Desc1=await a.input({title:e.editDesc_title,caption:e.editDesc_lead}),i.context.Desc1===null||i.context.Desc1==="")return;await i.respond("ChangeDesc")}};'
        );
    end;

    local procedure ChangeDesc(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"; CopyDesc: Boolean)
    var
        CustomDescription: Text[100];
        POSActionCustDepositB: Codeunit "NPR POS Action: Cust.Deposit B";
    begin
        CustomDescription := CopyStr(Context.GetString('Desc1'), 1, MaxStrLen(CustomDescription));
        POSActionCustDepositB.SetNewDesc(CustomDescription, SaleLine, CopyDesc);
    end;
}

