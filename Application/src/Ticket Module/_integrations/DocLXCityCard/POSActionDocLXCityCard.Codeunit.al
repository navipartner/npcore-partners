codeunit 6184834 "NPR POSAction DocLXCityCard" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action validates and redeems a DocLX City Card.';
        CityCodeCaption: Label 'City Code';
        CityCodeDescription: Label 'City Code is the City Card Solutions City Setup Code.';
        LocationCodeCaption: Label 'Location Code';
        LocationCodeDescription: Label 'Location Code is the alias for the City Card Solutions location id.';
        CityCardNumberPrompt: Label 'Enter the City Card number';
        WindowTitle: Label 'City Card Solutions';
        ValidatingStatus: Label 'Validating City Card...';
        RedeemingStatus: Label 'Redeeming City Card...';
        ApplyingCoupon: Label 'Applying City Card...';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('CityCode', '', CityCodeCaption, CityCodeDescription);
        WorkflowConfig.AddTextParameter('LocationCode', '', LocationCodeCaption, LocationCodeDescription);
        WorkflowConfig.AddLabel('WindowTitle', WindowTitle);
        WorkflowConfig.AddLabel('NumberInputPrompt', CityCardNumberPrompt);
        WorkflowConfig.AddLabel('ValidatingStatus', ValidatingStatus);
        WorkflowConfig.AddLabel('RedeemingStatus', RedeemingStatus);
        WorkflowConfig.AddLabel('ApplyingCoupon', ApplyingCoupon);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'Validate':
                FrontEnd.WorkflowResponse(DoValidate(Context, Setup.GetPOSUnitNo()));
            'Redeem':
                FrontEnd.WorkflowResponse(DoRedeem(Context));
            'AcquireCoupon':
                FrontEnd.WorkflowResponse(DoAcquireCoupon(Context, Sale));
            'CheckReservation':
                FrontEnd.WorkflowResponse(DoCheckReservation(Sale, SaleLine));

        end;
    end;

    local procedure DoValidate(Context: Codeunit "NPR POS JSON Helper"; PosUnitNo: Code[10]): JsonObject
    var
        CityCard: Codeunit "NPR DocLXCityCard";
        CardNumber: Code[20];
        LocationCode, CityCode : Code[10];
    begin
        GetParameters(Context, CardNumber, CityCode, LocationCode);
        exit(CityCard.ValidateCityCard(CardNumber, CityCode, LocationCode, PosUnitNo));
    end;

    local procedure DoRedeem(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        CityCard: Codeunit "NPR DocLXCityCard";
        CardNumber: Code[20];
        LocationCode, CityCode : Code[10];
    begin
        GetParameters(Context, CardNumber, CityCode, LocationCode);
        exit(CityCard.RedeemCityCard(CardNumber, CityCode, LocationCode));
    end;

    local procedure DoAcquireCoupon(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        CityCard: Codeunit "NPR DocLXCityCard";
        PosSale: Record "NPR POS Sale";
        CardNumber: Code[20];
        LocationCode, CityCode : Code[10];
    begin
        GetParameters(Context, CardNumber, CityCode, LocationCode);
        Sale.GetCurrentSale(PosSale);

        exit(CityCard.AcquireCoupon(CardNumber, CityCode, LocationCode, PosSale."Sales Ticket No."));
    end;

    local procedure DoCheckReservation(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        PosSale: Record "NPR POS Sale";
        PosSaleLine: Record "NPR POS Sale Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Response.ReadFrom('{"needsSchedule": false, "token": ""}');

        TicketSetup.Get();
        if (TicketSetup.UseFrontEndScheduleUX) then begin
            Sale.GetCurrentSale(PosSale);
            SaleLine.GetCurrentSaleLine(PosSaleLine);

            TicketRequest.SetCurrentKey("Receipt No.");
            TicketRequest.SetFilter("Receipt No.", '=%1', PosSale."Sales Ticket No.");
            TicketRequest.SetFilter("Line No.", '=%1', PosSaleLine."Line No.");
            TicketRequest.SetFilter("Admission Created", '=%1', false);
            if (TicketRequest.FindFirst()) then
                Response.ReadFrom(StrSubstNo('{"needsSchedule": true, "token": "%1"}', TicketRequest."Session Token ID"));
        end;
    end;

    local procedure GetParameters(Context: Codeunit "NPR POS JSON Helper"; var CardNumber: Code[20]; var CityCode: Code[10]; var LocationCode: Code[10])
    begin
        CardNumber := CopyStr(Context.GetString('cityCardNumber'), 1, MaxStrLen(CardNumber));
        CityCode := CopyStr(Context.GetStringParameter('CityCode'), 1, MaxStrLen(CityCode));
        LocationCode := CopyStr(Context.GetStringParameter('LocationCode'), 1, MaxStrLen(LocationCode));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDocLXCityCard.js### 
'let main=async({workflow:a,context:u,popup:r,parameters:l,captions:t})=>{const s=await r.input({caption:t.NumberInputPrompt,title:t.WindowTitle});if(s===null)return;let n=await r.simplePayment({showStatus:!0,title:t.WindowTitle,amount:" "}),e={cityCardNumber:s,validated:!1,redeemed:!1,coupon:!1};try{debugger;n&&n.updateStatus(t.ValidatingStatus);const o=await a.respond("Validate",e);if(e.validated=o.state.code===200,o.state.code===523){n&&n.updateStatus(t.ApplyingCoupon);const i=await a.respond("AcquireCoupon",e);e.coupon=i.state.code===200,e.coupon||await r.message({caption:"<center><font color=red size=72>&#x274C;</font><h3>"+i.state.message+"</h3></center>",title:t.WindowTitle});debugger;if(e.coupon){await a.run("SCAN_COUPON",{parameters:{ReferenceNo:i.coupon.reference_no}});const d=await a.respond("CheckReservation");d.needsSchedule&&(await r.entertainment.scheduleSelection({token:d.token})||await a.run("DELETE_POS_LINE",{parameters:{ConfirmDialog:!0}}))}return}e.validated||await r.message({caption:"<center><font color=red size=72>&#x274C;</font><h3>"+o.state.message+"</h3></center>",title:t.WindowTitle});debugger;if(e.validated){n&&n.updateStatus(t.RedeemingStatus);const i=await a.respond("Redeem",e);e.redeemed=i.state.code===200,e.redeemed||await r.message({caption:"<center><font color=red size=72>&#x274C;</font><h3>"+i.state.message+"</h3></center>",title:t.WindowTitle})}debugger;if(e.redeemed){n&&n.updateStatus(t.ApplyingCoupon);const i=await a.respond("AcquireCoupon",e);e.coupon=i.state.code===200,e.coupon||await r.message({caption:"<center><font color=red size=72>&#x274C;</font><h3>"+i.state.message+"</h3></center>",title:t.WindowTitle});debugger;if(e.coupon){await a.run("SCAN_COUPON",{parameters:{ReferenceNo:i.coupon.reference_no}});const d=await a.respond("CheckReservation");d.needsSchedule&&(await r.entertainment.scheduleSelection({token:d.token})||await a.run("DELETE_POS_LINE",{parameters:{ConfirmDialog:!0}}))}}}catch(o){console.error(o)}finally{n&&n.close()}};'
        )
    end;


}
