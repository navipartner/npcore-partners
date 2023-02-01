codeunit 6059877 "NPR POS Action: Imp. Pstd. Inv" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Import and open standard NAV posted invoices to current POS sale';
        ParamSelectCust_CptLbl: Label 'Select Customer';
        ParamSelectCust_DescLbl: Label 'Enable/Disable customer selection';
        ParamSalesDocViewString_CptLbl: Label 'Posted Sales Invoice View String';
        ParamSalesDocViewString_DescLbl: Label 'Pre-filtered Posted Sales Invoice View';
        ParamLocationFrom_CptLbl: Label 'Location From';
        ParamLocationFrom_DescLbl: Label 'Pre-filtered location option';
        ParamLocationFrom_OptionsLbl: Label 'POS Store,Location Filter Parameter', Locked = true;
        ParamLocationFrom_OptionsCptLbl: Label 'POS Store, Location Filter Parameter';
        ParamLocation_CptLbl: Label 'Location Filter';
        ParamLocation_DescLbl: Label 'Pre-filtered location';
        ParamConfirmDiscAmt_CptLbl: Label 'Confirm Invoice Discount Amount';
        ParamConfirmDiscAmt_DescLbl: Label 'Enable/Disable Invoice Discount Amount confirmation';
        ParamEnableSalesPersonFromInv_CptLbl: Label 'SalesPerson From Invoice';
        ParamEnableSalesPersonFromInv_DescLbl: Label 'Enable/Disable SalesPerson From Invoice';
        ParamNegativeValues_CptLbl: Label 'Negative Values';
        ParamNegativeValues_DescLbl: Label 'Reverse values from Posted Sales Invoice';
        ParamCopyAppliesToInvoice_CptLbl: Label 'Copy Invoice No. to Imported from Invoice No.';
        ParamCopyAppliesToInvoice_DescLbl: Label 'Enable/Disable copy Invoice No. to Imported from Invoice No.';
        ParamShowMsg_CptLbl: Label 'Show Message';
        ParamShowMsg_DescLbl: Label 'Specifies if creation message will be shown';
        ParamTransferDim_CptLbl: Label 'Transfer Dimensions';
        ParamTransferDim_DescLbl: Label 'Transfer dimensions from imported document to sale.';
        ParamScanLabel_CptLbl: Label 'Scan Exchange Label';
        ParamScanLabel_DescLbl: Label 'Scan Exchange Label to find document';
        editScanLabel_title: Label 'Scan the Exchange Label';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, ParamSelectCust_CptLbl, ParamSelectCust_DescLbl);
        WorkflowConfig.AddTextParameter('SalesDocViewString', '', ParamSalesDocViewString_CptLbl, ParamSalesDocViewString_DescLbl);
        WorkflowConfig.AddOptionParameter('LocationFrom',
                                          ParamLocationFrom_OptionsLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamLocationFrom_OptionsLbl),
#pragma warning restore 
                                          ParamLocationFrom_CptLbl,
                                          ParamLocationFrom_DescLbl,
                                          ParamLocationFrom_OptionsCptLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocation_CptLbl, ParamLocation_DescLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, ParamConfirmDiscAmt_CptLbl, ParamConfirmDiscAmt_DescLbl);
        WorkflowConfig.AddBooleanParameter('SalesPersonFromInv', false, ParamEnableSalesPersonFromInv_CptLbl, ParamEnableSalesPersonFromInv_DescLbl);
        WorkflowConfig.AddBooleanParameter('NegativeValues', false, ParamNegativeValues_CptLbl, ParamNegativeValues_DescLbl);
        WorkflowConfig.AddBooleanParameter('CopyAppliesToInvoice', false, ParamCopyAppliesToInvoice_CptLbl, ParamCopyAppliesToInvoice_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowMessage', false, ParamShowMsg_CptLbl, ParamShowMsg_DescLbl);
        WorkflowConfig.AddBooleanParameter('TransferDimensions', false, ParamTransferDim_CptLbl, ParamTransferDim_DescLbl);
        WorkflowConfig.AddBooleanParameter('ScanExchangeLabel', false, ParamScanLabel_CptLbl, ParamScanLabel_DescLbl);
        WorkflowConfig.AddLabel('editScanLabel_title', editScanLabel_title);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'SelectInvoice':
                Step_SelectInvoice(Context);
            'ScanLabel':
                Step_ScanLabel(Context, Sale);
        end;
    end;

    local procedure Step_SelectInvoice(Context: Codeunit "NPR POS JSON Helper")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SelectCustomer: Boolean;
        ConfirmInvDiscAmt: Boolean;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SalesPersonFromInv: Boolean;
        NegativeValues: Boolean;
        AppliesToInvoice: Boolean;
        ShowMsg: Boolean;
        TransferDim: Boolean;
    begin
        SetParameters(Context, SelectCustomer, SalesDocViewString, LocationSource, LocationFilter, SalesPersonFromInv, ConfirmInvDiscAmt, NegativeValues, AppliesToInvoice, ShowMsg, TransferDim);

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not
            SelectDocument(
              POSSession,
              SalesInvHeader,
              SalesDocViewString,
              LocationSource,
              LocationFilter, '')
        then
            exit;

        if ConfirmInvDiscAmt then
            if not ConfirmDiscount(SalesInvHeader) then
                exit;
        AddSalesInvoiceToPOSLine(POSSale, SalesInvHeader, NegativeValues, ShowMsg, AppliesToInvoice, TransferDim, SalesPersonFromInv, false);
    end;

    local procedure AddSalesInvoiceToPOSLine(var POSSale: Codeunit "NPR POS Sale"; var SalesInvHeader: Record "Sales Invoice Header"; NegativeValues: Boolean; ShowMsg: Boolean; AppliesToInvoice: Boolean; TransferDim: Boolean; SalesPersonFromInv: Boolean; ChooseLines: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PostedSalesInvoiceLines: Page "Posted Sales Invoice Lines";
        RecRef: RecordRef;
        PostedSalesLineFilter: Text;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        if ChooseLines then begin
            SalesInvoiceLine.SetRange("Document No.", SalesInvHeader."No.");
            PostedSalesInvoiceLines.SetTableView(SalesInvoiceLine);
            PostedSalesInvoiceLines.LookupMode(true);
            if PostedSalesInvoiceLines.RunModal() = Action::LookupOK then begin
                PostedSalesInvoiceLines.SetSelectionFilter(SalesInvoiceLine);
                RecRef.GetTable(SalesInvoiceLine);
                PostedSalesLineFilter := SelectionFilterManagement.GetSelectionFilter(RecRef, SalesInvoiceLine.FieldNo("Line No."));
            end;
        end;
        POSSession.GetSale(POSSale);
        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, SalesInvHeader."Bill-to Customer No.");
        if TransferDim then
            POSActImpPstdInvB.SetPosSaleDimension(POSSale, SalesInvHeader);

        POSActImpPstdInvB.PostedInvToPOS(POSSession, SalesInvHeader, NegativeValues, ShowMsg, AppliesToInvoice, TransferDim, PostedSalesLineFilter);

        if SalesPersonFromInv then
            POSActImpPstdInvB.UpdateSalesPerson(POSSale, SalesInvHeader);
    end;

    local procedure Step_ScanLabel(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        Barcode: Code[13];
        SelectCustomer: Boolean;
        ConfirmInvDiscAmt: Boolean;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SalesPersonFromInv: Boolean;
        NegativeValues: Boolean;
        AppliesToInvoice: Boolean;
        ShowMsg: Boolean;
        TransferDim: Boolean;
        SalesInvHeader: Record "Sales Invoice Header";
        POSSession: Codeunit "NPR POS Session";
    begin
        SetParameters(Context, SelectCustomer, SalesDocViewString, LocationSource, LocationFilter, SalesPersonFromInv, ConfirmInvDiscAmt, NegativeValues, AppliesToInvoice, ShowMsg, TransferDim);
        Barcode := CopyStr(Context.GetString('Barcode'), 1, MaxStrLen(Barcode));

        if not
            SelectDocument(
            POSSession,
            SalesInvHeader,
            SalesDocViewString,
            LocationSource,
            LocationFilter, Barcode)
        then
            exit;

        if ConfirmInvDiscAmt then
            if not ConfirmDiscount(SalesInvHeader) then
                exit;

        AddSalesInvoiceToPOSLine(Sale, SalesInvHeader, NegativeValues, ShowMsg, AppliesToInvoice, TransferDim, SalesPersonFromInv, true);
    end;

    local procedure SetParameters(Context: Codeunit "NPR POS JSON Helper"; var SelectCustomer: Boolean; var SalesDocViewString: Text; var LocationSource: Option "POS Store","Location Filter Parameter"; var LocationFilter: Text; var SalesPersonFromInv: Boolean; var ConfirmInvDiscAmt: Boolean; var NegativeValues: Boolean; var AppliesToInvoice: Boolean; var ShowMsg: Boolean; var TransferDim: Boolean)
    var

    begin
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        SalesDocViewString := Context.GetStringParameter('SalesDocViewString');
        LocationSource := Context.GetIntegerParameter('LocationFrom');
        LocationFilter := Context.GetStringParameter('LocationFilter');
        SalesPersonFromInv := Context.GetBooleanParameter('SalesPersonFromInv');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        NegativeValues := Context.GetBooleanParameter('NegativeValues');
        AppliesToInvoice := Context.GetBooleanParameter('CopyAppliesToInvoice');
        ShowMsg := Context.GetBooleanParameter('ShowMessage');
        TransferDim := Context.GetBooleanParameter('TransferDimensions');
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";

    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, Customer."No.");
        Commit();
        exit(true);
    end;

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesInvHeader: Record "Sales Invoice Header"; SalesDocViewString: Text; LocationSource: Option "POS Store","Location Filter Parameter"; LocationFilter: Text; Barcode: Code[20]): Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        POSSale: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalesDocViewString <> '' then
            SalesInvHeader.SetView(SalesDocViewString);
        SalesInvHeader.FilterGroup(2);
        if SalePOS."Customer No." <> '' then
            SalesInvHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        case LocationSource of
            LocationSource::"POS Store":
                begin
                    POSStore.Get(SalePOS."POS Store Code");
                    LocationFilter := POSStore."Location Code";
                end;
        end;
        if LocationFilter <> '' then
            SalesInvHeader.SetFilter("Location Code", LocationFilter);
        if Barcode <> '' then begin
            ExchangeLabel.Reset();
            ExchangeLabel.SetCurrentKey(Barcode);
            ExchangeLabel.SetRange(Barcode, Barcode);
            if ExchangeLabel.FindFirst() then
                if ExchangeLabel."Table No." = Database::"Sales Line" then
                    SalesInvHeader.SetRange("Order No.", ExchangeLabel."Sales Header No.");
        end;
        SalesInvHeader.FilterGroup(0);
        if SalesInvHeader.FindFirst() then;
        exit(PAGE.RunModal(0, SalesInvHeader) = ACTION::LookupOK);
    end;


    local procedure ConfirmDiscount(SalesInvHeader: Record "Sales Invoice Header"): Boolean;
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetFilter("Inv. Discount Amount", '>%1', 0);
        SalesInvLine.CalcSums("Inv. Discount Amount");
        if SalesInvLine."Inv. Discount Amount" > 0 then
            exit(Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()));
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::IMPORT_POSTED_INV));
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        LocationList: Page "Location List";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                begin
                    FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
                    if POSParameterValue.Value <> '' then begin
                        SalesHeader.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(SalesHeader.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;

            'LocationFilter':
                begin
                    Clear(LocationList);
                    Location.SetRange("Use As In-Transit", false);
                    LocationList.SetTableView(Location);
                    LocationList.LookupMode(true);
                    if LocationList.RunModal() = ACTION::LookupOK then
                        POSParameterValue.Value := CopyStr(LocationList.GetSelectionFilter(), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                if POSParameterValue.Value <> '' then
                    SalesHeader.SetView(POSParameterValue.Value);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionImportPostedI.js###
'let main=async({workflow:e,context:a,captions:i,parameters:t})=>{if(t.ScanExchangeLabel)if(a.Barcode=await popup.input({title:i.editScanLabel_title,caption:i.editScanLabel_title}),a.Barcode)await e.respond("ScanLabel");else return" ";else await e.respond("SelectInvoice")};'
        )
    end;
}
