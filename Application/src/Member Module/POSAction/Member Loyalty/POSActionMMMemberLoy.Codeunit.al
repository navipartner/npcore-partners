codeunit 6060146 "NPR POS Action: MM Member Loy." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is capable of redeeming member points and applying them as a coupon.';
        ParamDefInput_CptLbl: Label 'Default Input Value';
        ParamDefInput_DescLbl: Label 'Specify Default Input Value.';
        ParamForeignCommunity_CptLbl: Label 'Foreign Community Code';
        ParamForeignCommunity_DescLbl: Label 'Specify Foreign Community Code.';
        ParamFunctionOption_CptLbl: Label 'Function';
        ParamFunctionOption_DescLbl: Label 'Specify function';
        FunctionOptionString: Label 'Select Membership,View Points,Redeem Points,Available Coupons,Select Membership (EAN Box)', Locked = true;
        FunctionOptionString_CptLbl: Label 'Select Membership,View Points,Redeem Points,Available Coupons,Select Membership (EAN Box)';
        LoyaltyWindowTitle: Label '%1 - Membership Loyalty.';
        MemberCardPrompt: Label 'Member Card No.';
        ToastMessageCaption: Label 'Toast Message Timer';
        ToastMessageDescription: Label 'Specifies the time in seconds the toast message is displayed.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Function',
                                        FunctionOptionString,
                                        CopyStr(SelectStr(1, FunctionOptionString), 1, 250),
                                        ParamFunctionOption_CptLbl,
                                        ParamFunctionOption_DescLbl,
                                        FunctionOptionString_CptLbl);
        WorkflowConfig.AddTextParameter('DefaultInputValue', '', ParamDefInput_CptLbl, ParamDefInput_DescLbl);
        WorkflowConfig.AddTextParameter('ForeignCommunityCode', '', ParamForeignCommunity_CptLbl, ParamForeignCommunity_DescLbl);
        WorkflowConfig.AddIntegerParameter('ToastMessageTimer', 15, ToastMessageCaption, ToastMessageDescription);
        WorkflowConfig.AddLabel('LoyaltyWindowTitle', LoyaltyWindowTitle);
        WorkflowConfig.AddLabel('MemberCardPrompt', MemberCardPrompt);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'OnBeforeWorkflow':
                begin
                    OnBeforePOSActionMMLoyalty(Context);
                end;
            'do_work':
                begin
                    FrontEnd.WorkflowResponse(OnPOSAction(Context, FrontEnd));
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMMMemberLoy.js###
'let main=async({workflow:i,context:o,parameters:n,popup:s,captions:r})=>{await i.respond("OnBeforeWorkflow");const l=["Select Membership","View Points","Redeem Points","Available Coupons","Select Membership (EAN Box)"];let t=n.Function.toInt();t<0&&(t=0),n.DefaultInputValue.length>0&&(o.show_dialog=!1);const d=r.LoyaltyWindowTitle.substitute(l[t]);let a="";if(o.show_dialog&&(a=await s.input({caption:r.MemberCardPrompt,title:d}),a===null))return;const e=await i.respond("do_work",{membercard_number:a}),m=n.ToastMessageTimer!==null&&n.ToastMessageTimer!==void 0&&n.ToastMessageTimer!==0?n.ToastMessageTimer:15;e.MemberScanned&&m>0&&toast.memberScanned({memberImg:e.MemberScanned.ImageDataUrl,memberName:e.MemberScanned.Name,validForAdmission:e.MemberScanned.Valid,hideAfter:m,memberExpiry:e.MemberScanned.ExpiryDate}),e.workflowName!==""&&await i.run(e.workflowName,{parameters:e.parameters})};'
        )
    end;

    local procedure OnBeforePOSActionMMLoyalty(Context: codeunit "NPR POS JSON Helper")
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        Context.SetContext('show_dialog', (SalePOS."Customer No." = ''));
    end;

    local procedure OnPOSAction(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management") Response: JsonObject
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
        SalePOS: Record "NPR POS Sale";
        BusinessLogic: Codeunit "NPR POSAction: MM Member Loy.B";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        MMMembershipEvents: Codeunit "NPR MM Membership Events";
        FunctionId: Integer;
        MemberCardNumber: Text[50];
        ForeignCommunityCode: Code[20];
        ActionContext: JsonObject;
    begin
        FunctionId := Context.GetIntegerParameter('Function');
        if (FunctionId < 0) then
            FunctionId := 0;

        MemberCardNumber := CopyStr(Context.GetStringParameter('DefaultInputValue'), 1, MaxStrLen(MemberCardNumber));
        ForeignCommunityCode := CopyStr(Context.GetStringParameter('ForeignCommunityCode'), 1, MaxStrLen(ForeignCommunityCode));

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::HEADER);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (POSSalesInfo.FindFirst()) then;

        if (MemberCardNumber = '') then
            MemberCardNumber := CopyStr(Context.GetString('membercard_number'), 1, MaxStrLen(MemberCardNumber));

        if (MemberCardNumber = '') then
            MemberCardNumber := CopyStr(POSSalesInfo."Scanned Card Data", 1, MaxStrLen(MemberCardNumber));
        MMMembershipEvents.OnAfterPOSActionMemberLoyReadMemberCardNumber(MemberCardNumber);
        case FunctionId of
            0:
                Response := BusinessLogic.SetCustomer(MemberCardNumber, ForeignCommunityCode);
            1:
                BusinessLogic.ViewPoints(MemberCardNumber, ForeignCommunityCode);
            2:
                BusinessLogic.RedeemPoints(Context, FrontEnd, MemberCardNumber, ForeignCommunityCode, ActionContext);
            3:
                BusinessLogic.SelectAvailableCoupon(Context, FrontEnd, MemberCardNumber, ForeignCommunityCode, ActionContext);
            4:
                Response := BusinessLogic.SetCustomer(MemberCardNumber, ForeignCommunityCode);

        end;
        HandleWorkflowResponse(Response, ActionContext);
        exit(Response);
    end;


    internal procedure HandleWorkflowResponse(var Response: JsonObject; ActionContextIn: JsonObject): Boolean
    var
        JObj: JsonObject;
        JToken: JsonToken;
    begin
        if not ActionContextIn.Get('name', JToken) then begin
            Response.Add('workflowName', '');
            exit(true);
        end;
        if JToken.AsValue().AsText() = '' then
            exit(true);

        Response.Add('workflowName', JToken.AsValue().AsText());

        ActionContextIn.Get('version', JToken);
        Response.Add('workflowVersion', JToken.AsValue().AsText());

        ActionContextIn.Get('parameters', JToken);
        JObj := JToken.AsObject();
        Response.Add('parameters', JObj);
    end;
}

