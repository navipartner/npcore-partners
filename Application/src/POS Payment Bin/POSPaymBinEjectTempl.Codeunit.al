﻿codeunit 6150646 "NPR POS Paym.Bin Eject: Templ."
{
    Access = Internal;
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

    local procedure InvokeParameterName(): Text
    begin
        exit('print_template');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        RPTemplateHeader: Record "NPR RP Template Header";
        Template: Text[20];
        DefaultPrintTemplateCode: Code[20];
        RecordVariant: Variant;
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        SelectDefaultPrintTemplate(POSPaymentBin, DefaultPrintTemplateCode);

        RPTemplateHeader.Get(DefaultPrintTemplateCode);

        Template := CopyStr(POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", InvokeParameterName(), DefaultPrintTemplateCode), 1, 20);

        POSPaymentBin.SetRecFilter();
        RecordVariant := POSPaymentBin;
        RPTemplateMgt.PrintTemplate(Template, RecordVariant, 0);

        Ejected := true;
    end;

    local procedure SelectDefaultPrintTemplate(POSPaymentBin: Record "NPR POS Payment Bin"; var DefaultPrintTemplateCode: Code[20])
    var
        IsHandled: Boolean;
        POSPaymBinEjectPublic: Codeunit "NPR POS Paym. Bin Eject Public";
        PrintTemplateCodeLbl: Label 'EPSON_CASH_DRAWER', Locked = true;
    begin
        POSPaymBinEjectPublic.OnSelectDefaultPrintTemplate(DefaultPrintTemplateCode, InvokeParameterName(), POSPaymentBin, IsHandled);

        if IsHandled then
            exit;

        DefaultPrintTemplateCode := PrintTemplateCodeLbl;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(InvokeMethodCode(), 1, 246);
        tmpRetailList.Value := CopyStr(InvokeMethodCode(), 1, 250);
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnShowInvokeParameters', '', false, false)]
    local procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", InvokeParameterName(), '');
        POSPaymentBinInvokeMgt.ShowGenericParameters(POSPaymentBin);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            InvokeParameterName():
                Caption := CaptionTemplate;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            InvokeParameterName():
                Caption := DescriptionTemplate;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnAfterValidateEvent', 'Value', false, false)]
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
            InvokeParameterName():
                begin
                    if Rec.Value <> '' then
                        RPTemplateHeader.Get(Rec.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnLookupParameter', '', false, false)]
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
            InvokeParameterName():
                begin
                    RPTemplateHeader.SetRange("Table ID", DATABASE::"NPR POS Payment Bin");
                    if PAGE.RunModal(0, RPTemplateHeader) = ACTION::LookupOK then
                        POSPaymentBinEjectParam.Value := RPTemplateHeader.Code;
                end;
        end;
    end;
}