codeunit 6150646 "NPR POS Paym.Bin Eject: Templ."
{
    // NPR5.50/MMV /20190417 CASE 350812 Created object


    trigger OnRun()
    begin
    end;

    var
        CaptionTemplate: Label 'Template';
        DescriptionTemplate: Label 'Retail print template to invoke for drawer opening';

    local procedure InvokeMethodCode(): Text
    begin
        exit('TEMPLATE');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        Template: Text;
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        RecordVariant: Variant;
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        Template := POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'print_template', '');

        POSPaymentBin.SetRecFilter();
        RecordVariant := POSPaymentBin;
        RPTemplateMgt.PrintTemplate(Template, RecordVariant, 0);

        Ejected := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := InvokeMethodCode;
        tmpRetailList.Value := InvokeMethodCode;
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnShowInvokeParameters', '', false, false)]
    local procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'print_template', '');
        POSPaymentBinInvokeMgt.ShowGenericParameters(POSPaymentBin);
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'print_template':
                Caption := CaptionTemplate;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'print_template':
                Caption := DescriptionTemplate;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnAfterValidateEvent', 'Value', false, false)]
    local procedure OnValidateParameter(var Rec: Record "NPR POS Paym. Bin Eject Param."; var xRec: Record "NPR POS Paym. Bin Eject Param."; CurrFieldNo: Integer)
    var
        PaymentBin: Record "NPR POS Payment Bin";
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if not PaymentBin.Get(Rec."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case Rec.Name of
            'print_template':
                begin
                    if Rec.Value <> '' then
                        RPTemplateHeader.Get(Rec.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnLookupParameter', '', false, false)]
    local procedure OnLookupParameter(var POSPaymentBinEjectParam: Record "NPR POS Paym. Bin Eject Param.")
    var
        PaymentBin: Record "NPR POS Payment Bin";
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if not PaymentBin.Get(POSPaymentBinEjectParam."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case POSPaymentBinEjectParam.Name of
            'print_template':
                begin
                    RPTemplateHeader.SetRange("Table ID", DATABASE::"NPR POS Payment Bin");
                    if PAGE.RunModal(0, RPTemplateHeader) = ACTION::LookupOK then
                        POSPaymentBinEjectParam.Value := RPTemplateHeader.Code;
                end;
        end;
    end;
}

