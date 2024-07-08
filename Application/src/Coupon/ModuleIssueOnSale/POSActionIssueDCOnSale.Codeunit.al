codeunit 6151600 "NPR POSAction Issue DC OnSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action Issues Discount Coupons.';
        ParamCouponType_NameLbl: Label 'Coupon Type Code';
        ParamCouponType_DescLbl: Label 'Specifies Coupon Type Code';
        ParamQty_NameLbl: Label 'Quantity';
        ParamQty_DescLbl: Label 'Sepcifies quantity';
        ParamInstantIssue_NameLbl: Label 'Instant Issue';
        ParamInsantIssue_DescLbl: Label 'Specifies Instant Issue';
        IssueDiscCouponsCpt: Label 'Issue Discount Coupons';
        EnterQtyCpt: Label 'Enter Quantity';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('IssueCouponTitle', IssueDiscCouponsCpt);
        WorkflowConfig.AddLabel('Quantity', EnterQtyCpt);
        WorkflowConfig.AddTextParameter('CouponTypeCode', '', ParamCouponType_NameLbl, ParamCouponType_DescLbl);
        WorkflowConfig.AddIntegerParameter('Quantity', 0, ParamQty_NameLbl, ParamQty_DescLbl);
        WorkflowConfig.AddBooleanParameter('InstantIssue', false, ParamInstantIssue_NameLbl, ParamInsantIssue_DescLbl);

    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'coupon_type_input':
                FrontEnd.WorkflowResponse(OnActionCouponTypeInput());
            'issue_coupon':
                OnActionIssueCoupon(Context, Sale);
        end;
    end;

    local procedure OnActionCouponTypeInput() Response: JsonObject
    var
        CouponTypeCode: Text;
        NpDcModuleIssueOnSaleB: Codeunit "NPR POSAction Issue DC OnSaleB";
    begin
        if not NpDcModuleIssueOnSaleB.SelectCouponType(CouponTypeCode) then
            Error('');

        Response.Add('CouponTypeCode', CouponTypeCode);
    end;

    local procedure OnActionIssueCoupon(JSON: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale")
    var
        CouponTypeCode: Code[20];
        Quantity: Integer;
        NpDcModuleIssueOnSaleB: Codeunit "NPR POSAction Issue DC OnSaleB";
        InstantIssue: Boolean;
    begin
        CouponTypeCode := CopyStr(UpperCase(JSON.GetString('CouponTypeCode')), 1, MaxStrLen(CouponTypeCode));
        Quantity := JSON.GetInteger('Qty_input');
        InstantIssue := JSON.GetBooleanParameter('InstantIssue');

        NpDcModuleIssueOnSaleB.IssueCoupon(CouponTypeCode, Quantity, InstantIssue, POSSale);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    var
        Text006: Label 'Checks On-Sale Discount Coupons on Sale Line Insert';
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'AddNewOnSaleCoupons':
                begin
                    Rec.Description := Text006;
                    Rec."Sequence No." := 40;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        CouponType: Record "NPR NpDc Coupon Type";
        SelectedValue: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CouponTypeCode':
                begin
                    SelectedValue := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedValue));
                    if SelectedValue <> '' then begin
                        CouponType.Code := SelectedValue;
                        if CouponType.Find('=><') then;
                    end;
                    if Page.RunModal(0, CouponType) = Action::LookupOK then
                        POSParameterValue.Validate(Value, CouponType.Code);
                end;
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::ISSUE_COUPON));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionIssueDCOnSale.js###
'let main=async({workflow:o,captions:e,parameters:u,context:p})=>{debugger;let n;u.CouponTypeCode?p.CouponTypeCode=u.CouponTypeCode:n=await o.respond("coupon_type_input"),u.Quantity<=0?p.Qty_input=await popup.numpad({title:e.IssueCouponTitle,caption:e.Quantity,value:1}):p.Qty_input=u.Quantity,await o.respond("issue_coupon",n)};'
    )
    end;

    internal procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POSAction Issue DC OnSale");
    end;
}
