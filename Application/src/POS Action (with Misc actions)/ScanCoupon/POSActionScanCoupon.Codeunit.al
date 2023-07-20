codeunit 6150934 "NPR POS Action: Scan Coupon" implements "NPR IPOS Workflow"
{
    Access = Internal;


    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles Scan Discount Coupon.';
        ParamReferenceNo_CptLbl: Label 'Reference Number';
        ParamReferenceNo_DescLbl: Label 'Reference No. of a Coupon.';
        ScanCouponPrompt_Lbl: Label 'Scan Coupon';
        CouponTitle_Lbl: Label 'Discount Coupon';
        ParamSelectSerialNo_CaptionLbl: Label 'Select Serial No.';
        ParamSelectSerialNo_DescLbl: Label 'Enable/Disable select Serial No. from the list';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ScanCouponPrompt', ScanCouponPrompt_Lbl);
        WorkflowConfig.AddLabel('CouponTitle', CouponTitle_Lbl);
        WorkflowConfig.AddTextParameter('ReferenceNo', '', ParamReferenceNo_CptLbl, ParamReferenceNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('SelectSerialNo', false, ParamSelectSerialNo_CaptionLbl, ParamSelectSerialNo_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'ScanCoupon':
                FrontEnd.WorkflowResponse(ScanCoupon(Context, Sale, SaleLine));
        end;
    end;

    local procedure ScanCoupon(Context: codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line") Response: JsonObject
    var
        CouponReferenceNo: Text;
        RequireSerialNo: Boolean;
        POSActScanCouponB: Codeunit "NPR POS Action: Scan Coupon B";
    begin
        CouponReferenceNo := Context.GetString('CouponCode');
        POSActScanCouponB.ScanCoupon(CouponReferenceNo, Sale, SaleLine, RequireSerialNo);

        Response.Add('RequireSerialNo', RequireSerialNo);
    end;
    #region Ean Box Event Handling
    local procedure ActionCode(): Code[20]
    begin
        exit(FORMAT("NPR POS Workflow"::SCAN_COUPON));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        Text002: Label 'Discount Coupon';

    begin
        if not EanBoxEvent.Get(EventCodeRefNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeRefNo();
            EanBoxEvent."Module Name" := Text002;
            EanBoxEvent.Description := CopyStr(NpDcCoupon.FieldCaption("Reference No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeRefNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceNo', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeRefNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeRefNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(NpDcCoupon."Reference No.") then
            exit;

        NpDcCoupon.SetRange("Reference No.", EanBoxValue);
        if not NpDcCoupon.IsEmpty() then
            InScope := true;
    end;

    local procedure EventCodeRefNo(): Code[20]
    begin
        exit('DISCOUNT_COUPON');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Coupon Mgt.");
    end;

    #endregion Ean Box Event Handling

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionScanCoupon.js###
'let main=async({parameters:o,captions:n,popup:i,context:e})=>{if(o.ReferenceNo)e.CouponCode=o.ReferenceNo;else if(e.CouponCode=await i.input({caption:n.ScanCouponPrompt,title:n.CouponTitle}),!e.CouponCode)return;const{RequireSerialNo:a}=await workflow.respond("ScanCoupon");a&&await workflow.run("ASSIGN_SERIAL_NO",{parameters:{SelectSerialNo:o.SelectSerialNo}})};'
        )
    end;
}
