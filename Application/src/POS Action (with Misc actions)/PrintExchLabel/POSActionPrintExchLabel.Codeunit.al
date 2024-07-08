codeunit 6150788 "NPR POS Action: PrintExchLabel" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for printing exchange labels';
        ParamSetting_NameLbl: Label 'Setting';
        ParamSetting_OptLbl: Label 'Single,Line Quantity,All Lines,Selection,Package', Locked = true;
        ParamSetting_DescLbl: Label 'Defines setting for printing.';
        ParamSetting_OptDescLbl: Label 'Single,Line Quantity,All Lines,Selection,Package';
        ParamPreventNegativeQty_CptLbl: Label 'Prevent Negative Quantity';
        ParamPreventNegativeQty_DescLbl: Label 'Denies negative quantity.';
        CalendarCaptionLbl: Label 'Select a valid from date and the lines to include';
        TitleLbl: Label 'Print Exchange Label';
        ValidFromLbl: Label 'Valid From Date';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Setting',
                                          ParamSetting_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamSetting_OptLbl),
#pragma warning restore                                          
                                          ParamSetting_NameLbl,
                                          ParamSetting_DescLbl,
                                          ParamSetting_OptDescLbl);
        WorkflowConfig.AddBooleanParameter('PreventNegativeQty', false, ParamPreventNegativeQty_CptLbl, ParamPreventNegativeQty_DescLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('validfrom', ValidFromLbl);
        WorkflowConfig.AddLabel('calendar', CalendarCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        CASE Step OF
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'PrintExchangeLabels':
                PrintExchangeLabels(Context, POSSession);
            'GetPrintLineKeys':
                FrontEnd.WorkflowResponse(GetPrintLinesKeyAsJsonArray(POSSession));
            'PrintExchangeLabelPerQty':
                PrintExchangeLabelPerQty(Context, POSSession);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        POSSetup: Codeunit "NPR POS Setup";
        DefaultValidFromDate: Date;
    begin
        POSSession.GetSetup(POSSetup);
        if not (Evaluate(DefaultValidFromDate, POSSetup.ExchangeLabelDefaultDate()) and (StrLen(POSSetup.ExchangeLabelDefaultDate()) > 0)) then
            DefaultValidFromDate := Today();

        Context.SetContext('defaultdate', Format(DefaultValidFromDate, 0, 9));
    end;

    local procedure PrintExchangeLabels(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        PrintLines: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";

        POSSaleLine: Codeunit "NPR POS Sale Line";
        UserSelectionJToken: JsonToken;
        UserSelectionJObject: JsonObject;
        RowKeys: List of [Text];
        RowKey: Text;
        RowPosition: Text;
        ValidFromDate: Date;
        Setting: Option Single,"Line Quantity","All Lines",Selection,Package;
        PreventNegativeQty: Boolean;
        POSActionPrintExchLblB: Codeunit "NPR POS Action: PrintExchLbl-B";
    begin
        if not Context.GetBooleanParameter('PreventNegativeQty', PreventNegativeQty) then
            PreventNegativeQty := false;
        if PreventNegativeQty then
            POSActionPrintExchLblB.CheckPreventNegativeQty(POSSession);

        Context.SetScopeRoot();
        Setting := Context.GetIntegerParameter('Setting');
        UserSelectionJToken := Context.GetJToken('UserSelection');
        case Setting of
            Setting::Single,
            Setting::"Line Quantity",
            Setting::"All Lines":
                begin
                    ValidFromDate := DT2Date(UserSelectionJToken.AsValue().AsDateTime());
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    PrintLines := SaleLinePOS;
                    PrintLines.SetRecFilter();
                end;
            Setting::Selection,
            Setting::Package:
                begin
                    UserSelectionJObject := UserSelectionJToken.AsObject();
                    UserSelectionJObject.Get('date', UserSelectionJToken);
                    ValidFromDate := DT2Date(UserSelectionJToken.AsValue().AsDateTime());

                    UserSelectionJObject.Get('rows', UserSelectionJToken);
                    UserSelectionJObject := UserSelectionJToken.AsObject();
                    RowKeys := UserSelectionJObject.Keys();
                    foreach RowKey in RowKeys do
                        if RowKey <> 'count' then begin
                            UserSelectionJObject.Get(RowKey, UserSelectionJToken);
                            RowPosition := UserSelectionJToken.AsValue().AsText();
                            PrintLines.SetPosition(RowPosition);
                            PrintLines.Mark(true);
                        end;
                    PrintLines.MarkedOnly(true);
                end;
        end;
        POSActionPrintExchLblB.PrintLabelsFromPOS(Setting, PrintLines, ValidFromDate);
    end;

    local procedure PrintExchangeLabelPerQty(Context: Codeunit "NPR POS JSON Helper";
                                             POSSession: Codeunit "NPR POS Session")
    var
        PrintLines: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        UserSelectionJToken: JsonToken;
        PrintLineKeyJsonObject: JsonObject;
        PrintLineKeyJsonToken: JsonToken;
        PrintLineKeyText: Text;
        ValidFromDate: Date;
        Setting: Option Single,"Line Quantity","All Lines",Selection,Package;
        PreventNegativeQty: Boolean;
        POSActionPrintExchLblB: Codeunit "NPR POS Action: PrintExchLbl-B";
    begin
        if Context.HasProperty('printLineKey') then begin
            Clear(PrintLineKeyJsonObject);
            PrintLineKeyJsonObject := Context.GetJsonObject('printLineKey');

            Clear(PrintLineKeyJsonToken);
            PrintLineKeyJsonObject.Get('key', PrintLineKeyJsonToken);
            PrintLineKeyText := PrintLineKeyJsonToken.AsValue().AsText();

            SaleLinePOS.GetBySystemId(PrintLineKeyText);
        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        end;

        if not Context.GetBooleanParameter('PreventNegativeQty', PreventNegativeQty) then
            PreventNegativeQty := false;

        if PreventNegativeQty then
            POSActionPrintExchLblB.CheckPreventNegativeQty(SaleLinePOS);

        Setting := Setting::"Line Quantity";
        UserSelectionJToken := Context.GetJToken('UserSelection');

        ValidFromDate := DT2Date(UserSelectionJToken.AsValue().AsDateTime());
        PrintLines := SaleLinePOS;
        PrintLines.SetRecFilter();

        POSActionPrintExchLblB.PrintLabelsFromPOS(Setting, PrintLines, ValidFromDate);
    end;

    local procedure GetPrintLinesKeyAsJsonArray(POSSession: Codeunit "NPR POS Session") ResponseJsonObject: JsonObject
    var
        PrintLines: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PrintLinesKeyJsonArray: JsonArray;
        PrintLineJsonObject: JsonObject;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        PrintLines := SaleLinePOS;
        PrintLines.SetRecFilter();
        PrintLines.SetRange("Line No.");
        PrintLines.SetLoadFields("Line No.");

        if PrintLines.findset(false) then
            repeat
                Clear(PrintLineJsonObject);
                PrintLineJsonObject.Add('key', Format(PrintLines.SystemId));
                PrintLinesKeyJsonArray.add(PrintLineJsonObject);
            until PrintLines.next() = 0;

        ResponseJsonObject.Add('printLineKeys', PrintLinesKeyJsonArray);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPrintExchLabel.js###
'let main=async({workflow:t,parameters:e,captions:i,popup:l,context:d})=>{debugger;if(await t.respond("AddPresetValuesToContext"),e.Setting==e.Setting.Package||e.Setting==e.Setting.Selection)var n=await l.calendarPlusLines({title:i.title,caption:i.calendar,date:d.defaultdate,dataSource:"BUILTIN_SALELINE",filter:g=>g.fields[5]==1&&parseFloat(g.fields[12])>0});else var n=await l.datepad({title:i.title,caption:i.validfrom,required:!0,value:d.defaultdate});if(n!==null)if(e.Setting!=e.Setting["All Lines"])await t.respond("PrintExchangeLabels",{UserSelection:n});else for(var r=await t.respond("GetPrintLineKeys"),a=0;a<r.printLineKeys.length;a++)t.context.printLineKey=r.printLineKeys[a],await t.respond("PrintExchangeLabelPerQty",{UserSelection:n})};'
        )
    end;
}
