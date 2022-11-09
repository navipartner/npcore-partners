codeunit 6151005 "NPR POS Action: LoadPOSSvSl" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::LOAD_FROM_POS_QUOTE));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParamPreviewBeforeLoad_CptLbl: Label 'Preview Before Load';
        ParamPreviewBeforeLoad_DescLbl: Label 'Enable/Disable Preview parked sale before load';
        ParamScanSalesTicketNo_CptLbl: Label 'Scan Sales Ticket No.';
        ParamScanSalesTicketNo_DescLbl: Label 'Predefined Sales Ticket No.';
        ParamFilterOptionsLbl: Label 'All,Register,Salesperson,Register+Salesperson', Locked = true;
        ParamFilterOptions_CptLbl: Label 'All,Register,Salesperson,Register and Salesperson';
        ParamFilter_CptLbl: Label 'Filter';
        ParamFilter_DescLbl: Label 'Defines filter on POS Saved Sales';
        ParamQuoteInputTypeOptionsLbl: Label 'IntPad,List,Input', Locked = true;
        ParamQuoteInputTypeOptions_CptLbl: Label 'Numeric input,List,Text Input';
        ParamQuoteInputType_CptLbl: Label 'Quote Input Type';
        ParamQuoteInputType_DescLbl: Label 'Defines quote input type';
        POSEntry: Record "NPR POS Entry";
        ActionDescription: Label 'Load POS Sale from POS saved Sale';

    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('PreviewBeforeLoad', true, ParamPreviewBeforeLoad_CptLbl, ParamPreviewBeforeLoad_DescLbl);
        WorkflowConfig.AddTextParameter('ScanSalesTicketNo', '', ParamScanSalesTicketNo_CptLbl, ParamScanSalesTicketNo_DescLbl);
        WorkflowConfig.AddOptionParameter('Filter',
                                          ParamFilterOptionsLbl,
                                          SelectStr(2, ParamFilterOptionsLbl),
                                          ParamFilter_CptLbl,
                                          ParamFilter_DescLbl,
                                          ParamFilterOptions_CptLbl
                                          );
        WorkflowConfig.AddOptionParameter('QuoteInputType',
                                          ParamQuoteInputTypeOptionsLbl,
                                          SelectStr(1, ParamQuoteInputTypeOptionsLbl),
                                          ParamQuoteInputType_CptLbl,
                                          ParamQuoteInputType_DescLbl,
                                          ParamQuoteInputTypeOptions_CptLbl
                                          );
        WorkflowConfig.AddLabel('SalesTicketNo', POSEntry.FieldCaption("Document No."));
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'select_quote':
                FrontEnd.WorkflowResponse(SelectQuote(Context));
            'preview':
                FrontEnd.WorkflowResponse(Preview(Context));
            'load_from_quote':
                LoadFromQuote(Context);
        end;
    end;

    local procedure SelectQuote(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalesTicketNo: Code[20];
        "Filter": Integer;
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Filter := Context.GetIntegerParameter('Filter');
        POSQuoteMgt.SetSalePOSFilter(SalePOS, POSQuoteEntry, Filter);

        SalesTicketNo := CopyStr(Context.GetStringParameter('ScanSalesTicketNo'), 1, MaxStrLen(SalesTicketNo));
        if SalesTicketNo = '' then begin
            if PAGE.RunModal(0, POSQuoteEntry) <> ACTION::LookupOK then
                exit;
        end else begin
            POSQuoteEntry.SetRange("Sales Ticket No.", SalesTicketNo);
            POSQuoteEntry.FindFirst();
        end;

        Response.Add('quote_entry_no', POSQuoteEntry."Entry No.");

    end;

    local procedure Preview(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := Context.GetInteger('quote_entry_no');
        if QuoteEntryNo = 0 then
            exit;

        if not POSQuoteEntry.Get(QuoteEntryNo) then
            exit;

        POSQuoteEntry.FilterGroup(2);
        POSQuoteEntry.SetRecFilter();
        POSQuoteEntry.FilterGroup(0);
        IF Page.RunModal(Page::"NPR POS Saved Sale Card", POSQuoteEntry) <> Action::LookupOK then
            Response.Add('quote_entry_no', '');

    end;

    local procedure LoadFromQuote(Context: Codeunit "NPR POS JSON Helper")
    var
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSSale: Codeunit "NPR POS Sale";
        QuoteEntryNo: BigInteger;
        POSSession: Codeunit "NPR POS Session";
        CannotLoad: Label 'The POS Saved Sale is missing essential data and cannot be loaded.';
        POSActionLoadPOSSvSlB: Codeunit "NPR POS Action: LoadPOSSvSl B";

    begin
        QuoteEntryNo := Context.GetInteger('quote_entry_no');
        POSQuoteEntry.Get(QuoteEntryNo);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        if POSActionLoadPOSSvSlB.LoadFromQuote(POSQuoteEntry, SalePOS) then
            POSActionLoadPOSSvSlB.InsertParkedSale(POSQuoteEntry, SalePOS)
        else
            Error(CannotLoad);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        Text002: Label 'Parked Sales Ticket No.';
    begin
        if not EanBoxEvent.Get(EventCodeParkedSale()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeParkedSale();
            EanBoxEvent."Module Name" := Text002;
            EanBoxEvent.Description := CopyStr(POSQuoteEntry.FieldCaption("Sales Ticket No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := Codeunit::"NPR POS Action: LoadPOSSvSl";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeParkedSale():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ScanSalesTicketNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'QuoteInputType', false, 'List');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Filter', false, 'All');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeSalesTicketNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin

        if (EanBoxSetupEvent."Event Code" <> EventCodeParkedSale()) then
            exit;

        POSQuoteEntry.SetRange("Sales Ticket No.", EanBoxValue);
        if not POSQuoteEntry.IsEmpty() then
            InScope := true;

    end;

    local procedure EventCodeParkedSale(): Code[20]
    begin
        exit('PARKED_SALE');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionLoadPOSSvSl.js###
'let main=async({parameters:a,captions:t})=>{let e=a.ScanSalesTicketNo;switch(""+a.QuoteInputType){case"0":e=await popup.numpad({title:t.SalesTicketNo,caption:t.SalesTicketNo});break;case"2":e=await popup.input({title:t.SalesTicketNo,caption:t.SalesTicketNo});break;default:e=await workflow.respond("select_quote")}Object.keys(e).length!==0&&(a.PreviewBeforeLoad&&await workflow.respond("preview",e),await workflow.respond("load_from_quote",e))};'
        );
    end;
}
