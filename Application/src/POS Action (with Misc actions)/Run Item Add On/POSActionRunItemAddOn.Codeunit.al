codeunit 6151128 "NPR POS Action: Run Item AddOn" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ApplyToSaleLine: Option Main,Current,Auto,Ask;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This built-in action inserts Item AddOns for a selected POS Sale Line', MaxLength = 250;
        ParamApplyTo_Options: Label 'Main,Current,Auto,Ask', MaxLength = 250, Locked = true;
        ParamApplyTo_OptionCptLbl: Label 'Main line,Current line,Auto,Ask';
        ParamApplyTo_CptLbl: Label 'Apply To';
        ParamApplyTo_DescLbl: Label 'Specify the line of the POS sale to which the Item AddOn will be applied when it is unclear.';
        ParamItemAddOn_CptLbl: Label 'Item AddOn No';
        ParamItemAddOn_DescLbl: Label 'Specifies Item AddOn No. This value will override Item AddOn selected on Item Cards';
        ParamSkipItemAvailbCheck_CptLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvailbCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
        SelectLineCpt: Label 'Please select the line to apply the Item AddOn to';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('ItemAddOnNo', '', ParamItemAddOn_CptLbl, ParamItemAddOn_DescLbl);
        WorkflowConfig.AddOptionParameter('ApplyTo', ParamApplyTo_Options, CopyStr(SelectStr(1, ParamApplyTo_Options), 1, 250), ParamApplyTo_CptLbl, ParamApplyTo_DescLbl, ParamApplyTo_OptionCptLbl);
        WorkflowConfig.AddBooleanParameter('SkipItemAvailabilityCheck', false, ParamSkipItemAvailbCheck_CptLbl, ParamSkipItemAvailbCheck_DescLbl);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
        WorkflowConfig.AddLabel('SelectLine', SelectLineCpt);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'DefineBaseLineNo':
                FrontEnd.WorkflowResponse(DefineBaseLineNo(Context, SaleLine));
            'GetSalesLineAddonConfigJson':
                FrontEnd.WorkflowResponse(GenerateItemAddonConfig(Context, Sale, SaleLine));
            'SetItemAddons':
                FrontEnd.WorkflowResponse(OnActionRunAddOns(Context));
            'CancelTicketItemLine':
                CancelTicketItemLine(Context);
        end;
    end;

    local procedure CancelTicketItemLine(Context: Codeunit "NPR POS JSON Helper")
    var
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        POSActionDeleteLine: Codeunit "NPR POSAction: Delete POS Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSActionDeleteLine.SetPositionForPOSSaleLine(Context, POSSaleLine);
        POSActionDeleteLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeletePOSLineB.DeleteSaleLine(POSSaleLine);
    end;

    local procedure DefineBaseLineNo(Context: Codeunit "NPR POS JSON Helper"; POSSaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS_Main: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ApplyToDialogOptions: JsonArray;
        AddOnNo_Param: Code[20];
        ApplyTo: Integer;
    begin
        If GetBaseLineNoFromContext(Context, false) <> 0 then begin
            FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
            exit;
        end;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if not IsChildItemAddOnLine(SaleLinePOS, SaleLinePOSAddOn) then begin
            Context.SetContext('BaseLineNo', FindAppliesToLineNo(SaleLinePOS));
            FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
            exit;
        end;

        If not Context.GetIntegerParameter('ApplyTo', ApplyTo) then
            ApplyTo := _ApplyToSaleLine::Main;
        SaleLinePOS_Main.Get(
            SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Date", SaleLinePOS."Sale Type", SaleLinePOSAddOn."Applies-to Line No.");

        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"BOM List"]) or (ApplyTo = _ApplyToSaleLine::Main) then begin
            if ApplyTo = _ApplyToSaleLine::Current then
                SaleLinePOS.FieldError("Line Type");
            Context.SetContext('BaseLineNo', FindAppliesToLineNo(SaleLinePOS_Main));
            FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
            exit;
        end;

        if ApplyTo = _ApplyToSaleLine::Current then begin
            Context.SetContext('BaseLineNo', FindAppliesToLineNo(SaleLinePOS));
            FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
            exit;
        end;

        AddOnNo_Param := GetItemAddOnNoParam(Context);
        if ApplyTo = _ApplyToSaleLine::Auto then begin
            if AddOnNo_Param <> '' then begin
                SaleLinePOS.TestField("No.");
                Item.Get(SaleLinePOS."No.");
                if AddOnNo_Param = Item."NPR Item AddOn No." then begin
                    Context.SetContext('BaseLineNo', FindAppliesToLineNo(SaleLinePOS));
                    FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
                    exit;
                end;
            end;
            Context.SetContext('BaseLineNo', FindAppliesToLineNo(SaleLinePOS_Main));
            FinishApplyToLineResponse(false, ApplyToDialogOptions, Response);
            exit;
        end;
        AddApplyToLineDialogOption(SaleLinePOS_Main, _ApplyToSaleLine::Main, ApplyToDialogOptions);
        AddApplyToLineDialogOption(SaleLinePOS, _ApplyToSaleLine::Current, ApplyToDialogOptions);
        FinishApplyToLineResponse(true, ApplyToDialogOptions, Response);
    end;

    local procedure FinishApplyToLineResponse(AskForApplyToLine: Boolean; ApplyToDialogOptions: JsonArray; var Response: JsonObject)
    begin
        Response.Add('AskForApplyToLine', AskForApplyToLine);
        Response.Add('ApplyToDialogOptions', ApplyToDialogOptions);
    end;

    local procedure AddApplyToLineDialogOption(SaleLinePOS: Record "NPR POS Sale Line"; "Type": Integer; var ApplyToDialogOptions: JsonArray)
    var
        ApplyToDialogOption: JsonObject;
        LineTypesLbl: Label 'main line,current line';
    begin
        ApplyToDialogOption.Add('caption', StrSubstNo('%1<br><i>(%2)</i>', SaleLinePOS.Description, SelectStr("Type" + 1, LineTypesLbl)));
        ApplyToDialogOption.Add('id', SaleLinePOS."Line No.");
        ApplyToDialogOptions.Add(ApplyToDialogOption);
    end;

    local procedure GenerateItemAddonConfig(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        AddOnNo: Code[20];
        ItemAddonConfigAsString: Text;
        AppliesToLineNo: Integer;
        CompulsoryAddOn: Boolean;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        AppliesToLineNo := GetBaseLineNoFromContext(Context, true);
        if AppliesToLineNo <> SaleLinePOS."Line No." then
            SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"BOM List"]) then
            SaleLinePOS.FieldError("Line Type");

        AddOnNo := GetItemAddOnNoParam(Context);
        if AddOnNo = '' then begin
            Item.Get(SaleLinePOS."No.");
            AddOnNo := Item."NPR Item Addon No.";
            CompulsoryAddOn := not ItemAddOnMgt.AttachedIteamAddonLinesExist(SaleLinePOS);
            Response.Add('CompulsoryAddOn', CompulsoryAddOn);
        end;
        if AddOnNo = '' then
            if not LookupItemAddOn(AddOnNo) then
                Error('');

        ItemAddOn.Get(AddOnNo);
        ItemAddOn.TestField(Enabled);
        Response.Add('ApplyItemAddOnNo', AddOnNo);

        if not ItemAddOnMgt.UserInterfaceIsRequired(ItemAddOn, CompulsoryAddOn) then begin
            Response.Add('UserSelectionRequired', false);
            Response.Add('ItemAddonConfigAsString', '');
            exit;
        end;

        Response.Add('UserSelectionRequired', true);
        POSSale.GetCurrentSale(SalePOS);
        ItemAddOnMgt.GenerateItemAddOnConfigJson(SalePOS, SaleLinePOS, ItemAddOn).WriteTo(ItemAddonConfigAsString);
        Response.Add('ItemAddonConfigAsString', ItemAddonConfigAsString);
    end;

    local procedure FindAppliesToLineNo(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    begin
        if SaleLinePOS.Accessory then
            exit(SaleLinePOS."Main Line No.");

        exit(SaleLinePOS."Line No.");
    end;

    local procedure IsChildItemAddOnLine(SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn"): Boolean
    var
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '<>%1', 0);
        exit(SaleLinePOSAddOn.FindFirst());
    end;

    local procedure OnActionRunAddOns(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSActRunItemAddOnB: Codeunit "NPR POS Action: RunItemAddOn B";
        POSSession: Codeunit "NPR POS Session";
        UserSelectionJToken: JsonToken;
        ApplyItemAddOnNo: Code[20];
        CompulsoryAddOn: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        UserSelectionRequired: Boolean;
    begin
        ApplyItemAddOnNo := CopyStr(Context.GetString('ApplyItemAddOnNo'), 1, MaxStrLen(ApplyItemAddOnNo));
        if not Context.GetBoolean('CompulsoryAddOn', CompulsoryAddOn) then
            CompulsoryAddOn := false;
        if not Context.GetBooleanParameter('SkipItemAvailabilityCheck', SkipItemAvailabilityCheck) then
            SkipItemAvailabilityCheck := false;
        if not Context.GetBoolean('UserSelectionRequired', UserSelectionRequired) then
            UserSelectionRequired := false;
        if UserSelectionRequired then
            UserSelectionJToken := Context.GetJToken('UserSelectedAddons');

        if POSActRunItemAddOnB.RunItemAddOns(GetBaseLineNoFromContext(Context, true), ApplyItemAddOnNo, CompulsoryAddOn, SkipItemAvailabilityCheck, UserSelectionRequired, UserSelectionJToken) then
            POSSession.RequestFullRefresh();

        exit(GetTicketTokens(Context));
    end;

    local procedure GetTicketTokens(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
        Sale: Codeunit "NPR POS Sale";
        POSSale: Record "NPR POS Sale";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        Token: Text[100];
        TicketTokens: JsonArray;
        RequiredAdmissionHasTimeSlots, AllAdmissionsRequired : Boolean;
    begin
        if (not TicketRetailManager.UseFrontEndScheduleUX()) then
            exit;

        POSSession.GetSale(Sale);
        Sale.GetCurrentSale(POSSale);
        SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
        SaleLinePOSAddOn.SetFilter("Register No.", '=%1', POSSale."Register No.");
        SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', POSSale."Sales Ticket No.");
        SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', POSSale.Date);
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '=%1', GetBaseLineNoFromContext(Context, true));
        if (SaleLinePOSAddOn.FindSet()) then begin
            repeat
                if (TicketRequestManager.GetTokenFromReceipt(SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Line No.", Token)) then begin
                    TicketReservationRequest.Reset();
                    TicketReservationRequest.SetCurrentKey("Session Token ID");
                    TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
                    TicketReservationRequest.SetRange("Admission Inclusion", TicketReservationRequest."Admission Inclusion"::REQUIRED);
                    RequiredAdmissionHasTimeSlots := TicketReservationRequest.IsEmpty();

                    TicketReservationRequest.SetRange("External Adm. Sch. Entry No.");
                    TicketReservationRequest.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
                    AllAdmissionsRequired := TicketReservationRequest.IsEmpty();

                    if not (RequiredAdmissionHasTimeSlots and AllAdmissionsRequired) then
                        TicketTokens.Add(Token);
                end;
            until (SaleLinePOSAddOn.Next() = 0);
        end;

        Response.Add('TicketTokens', TicketTokens);
    end;

    local procedure GetBaseLineNoFromContext(Context: Codeunit "NPR POS JSON Helper"; Mandatory: Boolean) Result: Integer
    begin
        if Mandatory then
            Result := Context.GetInteger('BaseLineNo')
        else
            If not Context.GetInteger('BaseLineNo', Result) then
                exit(0);
        exit(Result);
    end;

    local procedure GetItemAddOnNoParam(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    var
        AddOnNoTxt: Text;
    begin
        if not Context.GetStringParameter('ItemAddOnNo', AddOnNoTxt) then
            exit('');
        exit(CopyStr(AddOnNoTxt, 1, 20));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        AddOnNo: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ItemAddOnNo':
                begin
                    AddOnNo := CopyStr(POSParameterValue.Value, 1, MaxStrLen(AddOnNo));
                    if LookupItemAddOn(AddOnNo) then
                        POSParameterValue.Value := AddOnNo;
                end;
        end;
    end;

    local procedure LookupItemAddOn(var AddOnNo: Code[20]): Boolean
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        ItemAddOn.FilterGroup(2);
        ItemAddOn.SetRange(Enabled, true);
        ItemAddOn.FilterGroup(0);
        if AddOnNo <> '' then begin
            ItemAddOn."No." := AddOnNo;
            if ItemAddOn.find('=><') then;
        end;
        if Page.RunModal(0, ItemAddOn) = Action::LookupOK then begin
            AddOnNo := ItemAddOn."No.";
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLbl: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ItemAddOnNo':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    ItemAddOn.SetRange(Enabled, true);
                    ItemAddOn."No." := CopyStr(POSParameterValue.Value, 1, MaxStrLen(ItemAddOn."No."));
                    if not ItemAddOn.Find() then begin
                        ItemAddOn.SetFilter("No.", CopyStr(StrSubstNo(ItemAddOnLbl, POSParameterValue.Value), 1, MaxStrLen(ItemAddOn."No.")));
                        ItemAddOn.FindFirst();
                    end;
                    POSParameterValue.Value := ItemAddOn."No.";
                end;
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::RUN_ITEM_ADDONS));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRunItemAddOn.js###
'const main=async({workflow:e,popup:i,context:a,captions:l})=>{const{AskForApplyToLine:r,ApplyToDialogOptions:A}=await e.respond("DefineBaseLineNo");if(r){const n=await i.optionsMenu({title:l.SelectLine,oneTouch:!0,options:A});if(!n)return;a.BaseLineNo=n.id}const{ApplyItemAddOnNo:s,CompulsoryAddOn:d,UserSelectionRequired:o,ItemAddonConfigAsString:p}=await e.respond("GetSalesLineAddonConfigJson");let t={};if(o){const n=JSON.parse(p),c=await i.configuration(n);t=await e.respond("SetItemAddons",{ApplyItemAddOnNo:s,CompulsoryAddOn:d,UserSelectionRequired:o,UserSelectedAddons:c})}else t=await e.respond("SetItemAddons",{ApplyItemAddOnNo:s,CompulsoryAddOn:d,UserSelectionRequired:o});if(t.TicketTokens&&t.TicketTokens.length>0){for(const n of t.TicketTokens)if((await e.run("TM_SCHEDULE_SELECT",{context:{TicketToken:n,EditSchedule:!0}})).cancel){await e.respond("CancelTicketItemLine");return}}};'
        );
    end;
}
