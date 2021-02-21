codeunit 6150830 "NPR POS Action: ScanExchLabel"
{


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a build in function to handle exchange labels.';
        InpTitle: Label 'Exchange Label';
        InpLead: Label 'Enter Exchange Label Barcode';
        ErrNotExchLabel: Label '%1 ';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

                RegisterWorkflowStep('prompt', 'if (param.PromptForBarcode == true) { input(labels.InpTitle, labels.InpLead, labels.InpInstr, param.ExchLabelBarcode, true).respond().cancel() } else { respond() };');

                RegisterWorkflow(false);
                RegisterDataBinding();
                RegisterBooleanParameter('PromptForBarcode', false);
                RegisterTextParameter('ExchLabelBarcode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        ExchLabelBarcode: Text;
        InputExchLabelBarcode: Text;
        PromptForBarcode: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('/', true);
        PromptForBarcode := JSON.GetBooleanParameter('PromptForBarcode', true);

        if not PromptForBarcode then begin
            ExchLabelBarcode := JSON.GetStringParameter('ExchLabelBarcode', false);
            if ExchLabelBarcode = '' then begin
                Handled := true;
                exit;
            end;
        end else begin
            JSON.SetScope('$prompt', true);
            InputExchLabelBarcode := JSON.GetString('input', true);
            ExchLabelBarcode := InputExchLabelBarcode;
        end;

        HandleExchangeLabelBarcode(ExchLabelBarcode, POSSession);

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin

        Captions.AddActionCaption(ActionCode, 'InpTitle', InpTitle);
        Captions.AddActionCaption(ActionCode, 'InpLead', InpLead);
        Captions.AddActionCaption(ActionCode, 'InpInstr', '');
    end;

    local procedure ActionCode(): Text
    begin
        exit('EXCHANGELABEL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    local procedure "--"()
    begin
    end;

    local procedure HandleExchangeLabelBarcode(iBarcode: Text; var POSSession: Codeunit "NPR POS Session")
    var
        ExchangeLabelManagement: Codeunit "NPR Exchange Label Mgt.";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        CodeBarcode: Code[20];
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        CodeBarcode := CopyStr(iBarcode, 1, MaxStrLen(CodeBarcode));

        // IF NOT ExchangeLabelManagement.BarCodeIsExchangeLabel(CodeBarcode) THEN BEGIN
        //  ERROR(STRSUBSTNO(ErrNotExchLabel,iBarcode));
        // END;
        if not BarCodeIsExchangeLabel(CodeBarcode) then
            Error(StrSubstNo(ErrNotExchLabel, iBarcode));

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        //ExchangeLabelManagement.ScanExchangeLabel(SalePOS, CodeBarcode, CodeBarcode);
        if ExchangeLabelManagement.ScanExchangeLabel(SalePOS, CodeBarcode, CodeBarcode) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.SetFirst();
        end;
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if not EanBoxEvent.Get(EventCodeExchLabel()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeExchLabel;
            EanBoxEvent."Module Name" := InpTitle;
            //EanBoxEvent.Description := ExchangeLabel.FIELDCAPTION(Barcode);
            EanBoxEvent.Description := CopyStr(ExchangeLabel.FieldCaption(Barcode), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeExchLabel():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ExchLabelBarcode', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'PromptForBarcode', false, 'false');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeExchLabel(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeExchLabel() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(ExchangeLabel.Barcode) then
            exit;

        if BarCodeIsExchangeLabel(EanBoxValue) then
            InScope := true;
    end;

    local procedure EventCodeExchLabel(): Code[20]
    begin
        exit('EXCHLABEL');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: ScanExchLabel");
    end;

    procedure BarCodeIsExchangeLabel(Barcode: Text): Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        IComm: Record "NPR I-Comm";
        RetailConfiguration: Record "NPR Retail Setup";
        ExchangeLabelManagement: Codeunit "NPR Exchange Label Mgt.";
    begin
        //-NPR5.45 [319706]
        if StrLen(Barcode) > MaxStrLen(ExchangeLabel.Barcode) then
            exit(false);

        Barcode := UpperCase(Barcode);
        RetailConfiguration.Get;
        //-NPR5.53 [372948]
        //IF COPYSTR(Barcode,1,2) <> RetailConfiguration."EAN Prefix Exhange Label" THEN
        if not ExchangeLabelManagement.CheckPrefix(Barcode, RetailConfiguration."EAN Prefix Exhange Label") then
            //+NPR5.53 [372948]
            exit(false);

        ExchangeLabel.SetCurrentKey(Barcode);
        ExchangeLabel.SetRange(Barcode, Barcode);
        if ExchangeLabel.FindFirst then
            exit(true);

        if not RetailConfiguration."Use I-Comm" then
            exit(false);
        if not IComm.Get then
            exit(false);
        if IComm."Exchange Label Center Company" = '' then
            exit(false);
        if ExchangeLabel.ChangeCompany(IComm."Company - Clearing") then
            exit(false);

        ExchangeLabel.SetRange(Barcode, Barcode);
        exit(ExchangeLabel.FindFirst);
        //+NPR5.45 [319706]
    end;
}

