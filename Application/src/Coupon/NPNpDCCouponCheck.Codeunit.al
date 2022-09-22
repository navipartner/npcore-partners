codeunit 6059889 "NPR NP NpDC Coupon Check"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit('CHECK_COUPON');
    end;

    local procedure ActionVersion(): Text[3]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'let result = await popup.input({title: $captions.title, caption: $captions.referencenoprompt, required: true});' +
              'if (result === null) {' +
              '    return;' +
              '}' +
              'workflow.respond("", { ReferenceNo: result });'
            );
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'voucherprompt', ReferenceNoPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        TooLongErr: Label '%1 cannot have more than %2 characters.';
        ReferenceNo: Text;
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcCouponCard: Page "NPR NpDc Coupon Card";
        NotFoundErr: Label '%1 with %2 %3 doesn''t exist.';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;
        ReferenceNo := Context.GetStringOrFail('ReferenceNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode(), 'ReferenceNo'));
        if StrLen(ReferenceNo) > 50 then
            Error(TooLongErr, 'ReferenceNo', 50);


        NpDcCoupon.SetRange("Reference No.", ReferenceNo);
        if not NpDcCoupon.FindFirst() then
            Error(NotFoundErr, NpDcCoupon.TableCaption, NpDcCoupon.FieldCaption("Reference No."), ReferenceNo);

        NpDcCouponCard.Editable(false);
        NpDcCouponCard.SetRecord(NpDcCoupon);
        NpDcCouponCard.RunModal();
    end;

    var
        ActionDescriptionLbl: Label 'This action handles Coupon Check.';
        Title: Label 'Coupon Check';
        ReferenceNoPrompt: Label 'Coupon Reference Number';
        ReadingErr: Label 'reading in %1 of %2 string %3';
}
