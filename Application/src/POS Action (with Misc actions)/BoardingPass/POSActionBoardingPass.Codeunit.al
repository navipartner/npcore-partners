codeunit 6150837 "NPR POS Action: Boarding Pass" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'POS Action for boarding pass scan';
        ParametarBoardingPass_DescLbl: Label 'Specifies the boarding pass string';
        ParametarBoardingPass_CaptionLbl: Label 'Boarding Pass String';
        ParametarRequiredTravelToday_DescLbl: Label 'Specifies if the departure date is today.';
        ParametarRequiredTravelToday_CaptionLbl: Label 'Required Travel Today';
        ParametarRequiredLegAirPortCode_DescLbl: Label 'Specifies required LEG airport code';
        ParametarRequiredLegAirPortCode_CaptionLbl: Label 'Required LEG AirPort Code';
        ParametarShowTripMessage_DescLbl: Label 'Specifies if trip message will be shown';
        ParametarShowTripMessage_CaptionLbl: Label 'Show Trip Message';
        ParametarInfoCode_DescLbl: Label 'Specifies info code';
        ParametarInfoCode_CaptionLbl: Label 'Info Code';
        BoardingPassCaption: Label 'Boarding Pass';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('BoardingPassString', '', ParametarBoardingPass_CaptionLbl, ParametarBoardingPass_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequiredTravelToday', true, ParametarRequiredTravelToday_CaptionLbl, ParametarRequiredTravelToday_DescLbl);
        WorkflowConfig.AddTextParameter('RequiredLegAirPortCode', '', ParametarRequiredLegAirPortCode_CaptionLbl, ParametarRequiredLegAirPortCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowTripMessage', true, ParametarShowTripMessage_CaptionLbl, ParametarShowTripMessage_DescLbl);
        WorkflowConfig.AddTextParameter('InfoCode', '', ParametarInfoCode_CaptionLbl, ParametarInfoCode_DescLbl);
        WorkflowConfig.AddLabel('boardingpass', BoardingPassCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'InputBoardingPass':
                Frontend.WorkflowResponse(ProcessResult(Context, Sale, SaleLine));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupParameterPosInfo(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSInfo: Record "NPR POS Info";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'InfoCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        POSInfo.SetRange("Input Type", POSInfo."Input Type"::Text);
        POSInfo.SetRange(Type, POSInfo.Type::"Request Data");
        if PAGE.RunModal(0, POSInfo) = ACTION::LookupOK then
            POSParameterValue.Value := POSInfo.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateParameterPosInfo(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSInfo: Record "NPR POS Info";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'InfoCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not POSInfo.Get(POSParameterValue.Value) then begin
            POSInfo.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            POSInfo.SetRange("Input Type", POSInfo."Input Type"::Text);
            POSInfo.SetRange(Type, POSInfo.Type::"Request Data");
            if POSInfo.FindFirst() then
                POSParameterValue.Value := POSInfo.Code;
        end;
        POSInfo.Get(POSParameterValue.Value);
        POSInfo.TestField("Input Type", POSInfo."Input Type"::Text);
        POSInfo.TestField(Type, POSInfo.Type::"Request Data");
    end;

    local procedure ProcessResult(Context: Codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"): JsonObject
    var
        BoardingPassString: Text;
        RequiredTravelToday: Boolean;
        RequiredLegAirPortCode: Code[3];
        ShowTripMessage: Boolean;
        InfoCode: Text;
        POSActionBoardingPassB: Codeunit "NPR POS Action: Board. Pass B";
    begin

        BoardingPassString := Context.GetString('BoardingPass');
        RequiredTravelToday := Context.GetBooleanParameter('RequiredTravelToday');
        RequiredLegAirPortCode := CopyStr(Context.GetStringParameter('RequiredLegAirPortCode'), 1, MaxStrLen(RequiredLegAirPortCode));
        ShowTripMessage := Context.GetBooleanParameter('ShowTripMessage');
        InfoCode := Context.GetStringParameter('InfoCode');

        POSActionBoardingPassB.DecodeBoardingPassString(BoardingPassString,
                                                        InfoCode,
                                                        RequiredLegAirPortCode,
                                                        RequiredTravelToday,
                                                        ShowTripMessage,
                                                        Sale,
                                                        SaleLine);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Text000: Label 'Tax Free';
        Text001: Label 'Boarding Pass';
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := ActionCode();
            EanBoxEvent."Module Name" := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text001, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeBoardingPass(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;

        if BarCodeIsBoardingPass(EanBoxValue) then
            InScope := true;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::BOARDINGPASS));
    end;


    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Boarding Pass");
    end;

    procedure BarCodeIsBoardingPass(Barcode: Text): Boolean
    var
        IntBuffer: Integer;
    begin
        if StrLen(Barcode) < 60 then
            exit(false);

        if UpperCase(CopyStr(Barcode, 1, 1)) <> 'M' then
            exit(false);

        if not Evaluate(IntBuffer, CopyStr(Barcode, 2, 1)) then
            exit(false);

        exit(true);
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionBoardingPass.js###
'let main=async({workflow:a,captions:n,parameters:i})=>{if(i.BoardingPassString)await a.respond("InputBoardingPass",{BoardingPass:i.BoardingPassString});else{var s=await popup.input({title:n.boardingpass,caption:n.boardingpass});if(s==null)return" ";await a.respond("InputBoardingPass",{BoardingPass:s})}};'
        );
    end;
}

