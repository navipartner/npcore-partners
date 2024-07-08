codeunit 6184789 "NPR POS Audit Profile Notifier"
{
    Access = Internal;


    #region Audit Handler Validation Subscriber
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profile", 'OnAfterValidateEvent', 'Audit Handler', false, false)]
    local procedure OnAfterValidateAuditHandler(var Rec: Record "NPR POS Audit Profile"; var xRec: Record "NPR POS Audit Profile")
    begin
        if Rec."Audit Handler" = xRec."Audit Handler" then
            exit;

        ShowNotification(Rec);
    end;
    #endregion Audit Handler Validation Subscriber

    #region Notification Display    
    local procedure ShowNotification(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        POSAuditNotification: Enum "NPR POS Audit Notification";
    begin
        case true of
            ISRSAuditEnabled(POSAuditProfile) and RSCheckIfAssistedSetupNotCompleted():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRRSFiscal);
            IsCROAuditEnabled(POSAuditProfile) and CROCheckIfAssistedSetupNotCompleted():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRCROFiscal);
            IsSIAuditEnabled(POSAuditProfile) and SICheckIfAssistedSetupNotCompleted():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRSIFiscal);
            IsBGSISAuditEnabled(POSAuditProfile) and BGSISCheckIfAssistedSetupNotCompleted():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRBGSISFiscal);
            IsITAuditEnabled(POSAuditProfile) and ITCheckIfAssistedSetupCompleted():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRITFiscal);
            IsSECCAuditEnabled(POSAuditProfile) and SECheckIfCleanCashNotSetup():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRSEFiscal);
            IsBEAuditEnabled(POSAuditProfile) and BECheckForPrintTemplate():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRBEFiscal);
            IsDKAuditEnabled(POSAuditProfile) and DKCheckIfFiscalizationNotSetup():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRDKFiscal);
            IsHUMSAuditEnabled(POSAuditProfile) and HUMSCheckIfPaymentMethMappingExists():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRHUMSInvoice);
            IsFRAuditEnabled(POSAuditProfile) and FRCheckIfFiscalizationNotSetup():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRFRFiscal);
            IsNOAuditEnabled(POSAuditProfile) and NOCheckIfFiscalizationNotSetup():
                ShowAuditHandlerSetupNotification(POSAuditNotification::NPRNOFiscal);
        end;
    end;

    local procedure ShowAuditHandlerSetupNotification(POSAuditNotification: Enum "NPR POS Audit Notification")
    var
        AuditHandlerSetupNotification: Notification;
        LearnMoreActionLbl: Label 'Learn more';
    begin
        AuditHandlerSetupNotification.Id := GetNotificationId();
        AuditHandlerSetupNotification.SetData(POSAuditHandlerLbl, Format(POSAuditNotification));
        case POSAuditNotification of
            POSAuditNotification::NPRRSFiscal,
            POSAuditNotification::NPRCROFiscal,
            POSAuditNotification::NPRSIFiscal,
            POSAuditNotification::NPRBGSISFiscal,
            POSAuditNotification::NPRITFiscal:
                AddAssistedSetupNotificationMsgAction(AuditHandlerSetupNotification);
            POSAuditNotification::NPRSEFiscal:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, CleanCashSetup.TableCaption);
            POSAuditNotification::NPRBEFiscal:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, ObjectOutputSelection.TableCaption);
            POSAuditNotification::NPRDKFiscal:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, DKFiscalizationSetup.TableCaption);
            POSAuditNotification::NPRHUMSInvoice:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, HUMSPaymentMethodMap.TableCaption);
            POSAuditNotification::NPRFRFiscal:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, FRAuditSetup.TableCaption);
            POSAuditNotification::NPRNOFiscal:
                AddSetupNotificationMsgAction(AuditHandlerSetupNotification, NOFiscalizationSetup.TableCaption);
        end;
        AuditHandlerSetupNotification.AddAction(LearnMoreActionLbl, Codeunit::"NPR POS Audit Profile Notifier", 'OnActionLearnMore');
        AuditHandlerSetupNotification.Send();
    end;

    procedure OnActionShowSetup(Notification: Notification)
    var
        AssistedSetupGroup: Enum "Assisted Setup Group";
        POSAuditNotification: Enum "NPR POS Audit Notification";
        POSAuditHandlerData: Text;
    begin
        POSAuditHandlerData := Notification.GetData(POSAuditHandlerLbl);
        case POSAuditHandlerData of
            Format(POSAuditNotification::NPRRSFiscal):
                OpenAssistedSetupPage(AssistedSetupGroup::NPRRSFiscal);
            Format(POSAuditNotification::NPRCROFiscal):
                OpenAssistedSetupPage(AssistedSetupGroup::NPRCROFiscal);
            Format(POSAuditNotification::NPRSIFiscal):
                OpenAssistedSetupPage(AssistedSetupGroup::NPRSIFiscal);
            Format(POSAuditNotification::NPRBGSISFiscal):
                OpenAssistedSetupPage(AssistedSetupGroup::NPRBGSISFiscal);
            Format(POSAuditNotification::NPRITFiscal):
                OpenAssistedSetupPage(AssistedSetupGroup::NPRITFiscal);
            Format(POSAuditNotification::NPRSEFiscal):
                OpenSetupPage(Page::"NPR CleanCash Setup List");
            Format(POSAuditNotification::NPRBEFiscal):
                OpenSetupPage(Page::"NPR Object Output Selection");
            Format(POSAuditNotification::NPRDKFiscal):
                OpenSetupPage(Page::"NPR DK Fiscalization Setup");
            Format(POSAuditNotification::NPRHUMSInvoice):
                OpenSetupPage(Page::"NPR HU MS Payment Method Map.");
            Format(POSAuditNotification::NPRFRFiscal):
                OpenSetupPage(Page::"NPR FR Audit Setup");
            Format(POSAuditNotification::NPRNOFiscal):
                OpenSetupPage(Page::"NPR NO Fiscalization Setup");
        end;
    end;

    procedure OnActionLearnMore(Notification: Notification)
    var
        POSAuditNotification: Enum "NPR POS Audit Notification";
        POSAuditHandlerData: Text;
        RSLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/serbia/how-to/setup', Locked = true;
        CROLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/croatia/how-to/setup', Locked = true;
        SILearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/slovenia/how-to/setup', Locked = true;
        BGSISLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/bulgaria/how-to/setup', Locked = true;
        SECCLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/sweden/how-to/setup', Locked = true;
        BELearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/belgium/how-to/setup', Locked = true;
        DKLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/denmark/how-to/setup', Locked = true;
        HUMSLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/hungary/how-to/setup', Locked = true;
        FRLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/france/how-to/setup', Locked = true;
        NOLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/norway/how-to/setup', Locked = true;
        ITLearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/italy/how-to/setup/', Locked = true;
    begin
        POSAuditHandlerData := Notification.GetData(POSAuditHandlerLbl);
        case POSAuditHandlerData of
            Format(POSAuditNotification::NPRRSFiscal):
                Hyperlink(RSLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRCROFiscal):
                Hyperlink(CROLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRSIFiscal):
                Hyperlink(SILearnMoreLinkLbl);
            Format(POSAuditNotification::NPRBGSISFiscal):
                Hyperlink(BGSISLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRITFiscal):
                Hyperlink(ITLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRSEFiscal):
                Hyperlink(SECCLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRBEFiscal):
                Hyperlink(BELearnMoreLinkLbl);
            Format(POSAuditNotification::NPRDKFiscal):
                Hyperlink(DKLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRHUMSInvoice):
                Hyperlink(HUMSLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRFRFiscal):
                Hyperlink(FRLearnMoreLinkLbl);
            Format(POSAuditNotification::NPRNOFiscal):
                Hyperlink(NOLearnMoreLinkLbl);
        end;
    end;
    #endregion Notification Display

    #region Check Audit Handler
    local procedure IsRSAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = RSAuditMgt.HandlerCode());
    end;

    local procedure IsCROAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = CROAuditMgt.HandlerCode());
    end;

    local procedure IsSIAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = SIAuditMgt.HandlerCode());
    end;

    local procedure IsBGSISAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        BGSISAuditMgt: Codeunit "NPR BG SIS Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = BGSISAuditMgt.HandlerCode());
    end;

    local procedure IsITAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        ITAuditMgt: Codeunit "NPR IT Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = ITAuditMgt.HandlerCode());
    end;

    local procedure IsSECCAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
    begin
        exit(POSAuditProfile."Audit Handler" = CleanCashXCCSPProtocol.HandlerCode().ToUpper());
    end;

    local procedure IsBEAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        BEAuditMgt: Codeunit "NPR BE Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = BEAuditMgt.HandlerCode());
    end;

    local procedure IsDKAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = DKAuditMgt.HandlerCode());
    end;

    local procedure IsHUMSAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        HUMSAuditMgt: Codeunit "NPR HU MS Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = HUMSAuditMgt.HandlerCode());
    end;

    local procedure IsFRAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = FRAuditMgt.HandlerCode());
    end;

    local procedure IsNOAuditEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        NOAuditMgt: Codeunit "NPR NO Audit Mgt.";
    begin
        exit(POSAuditProfile."Audit Handler" = NOAuditMgt.HandlerCode());
    end;
    #endregion Check Audit Handler

    #region Check Setups

#if BC17
    local procedure RSCheckIfAssistedSetupNotCompleted(): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        exit(not ((AssistedSetup.IsComplete(Page::"NPR Setup RS Fiscal"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup RS Payment Methods"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup RS POS Paym. Meth."))
            and (AssistedSetup.IsComplete(Page::"NPR Setup RS POS Unit"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup RS VAT Posting"))));
    end;

    local procedure CROCheckIfAssistedSetupNotCompleted(): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        exit(not ((AssistedSetup.IsComplete(Page::"NPR Setup CRO Fiscal"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup CRO Paym. Meth."))
            and (AssistedSetup.IsComplete(Page::"NPR Setup CRO POS Paym. Meth."))
            and (AssistedSetup.IsComplete(Page::"NPR Setup CRO Salespeople"))));
    end;

    local procedure SICheckIfAssistedSetupNotCompleted(): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        exit(not ((AssistedSetup.IsComplete(Page::"NPR Setup SI Fiscal"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup SI POS Store"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup SI Salespeople"))));
    end;

    local procedure BGSISCheckIfAssistedSetupNotCompleted(): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        exit(not ((AssistedSetup.IsComplete(Page::"NPR Setup BG SIS Fiscal"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup BG SIS POS Pay Meth"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup BG SIS POS Unit"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup BG SIS Return Reason"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup BG SIS VAT PostSetup"))));
    end;

    local procedure ITCheckIfAssistedSetupCompleted(): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        exit(not ((AssistedSetup.IsComplete(Page::"NPR Setup IT Fiscal"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup IT POS Paym. Meth."))
            and (AssistedSetup.IsComplete(Page::"NPR Setup IT POS Unit Mapping"))
            and (AssistedSetup.IsComplete(Page::"NPR Setup IT Audit Profile"))));
    end;
#else
    local procedure RSCheckIfAssistedSetupNotCompleted(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(not ((GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup RS Fiscal"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup RS Payment Methods"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup RS POS Paym. Meth."))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup RS POS Unit"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup RS VAT Posting"))));
    end;

    local procedure CROCheckIfAssistedSetupNotCompleted(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(not ((GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup CRO Fiscal"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup CRO Paym. Meth."))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup CRO POS Paym. Meth."))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup CRO Salespeople"))));
    end;

    local procedure SICheckIfAssistedSetupNotCompleted(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(not ((GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup SI Fiscal"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup SI POS Store"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup SI Salespeople"))));
    end;

    local procedure BGSISCheckIfAssistedSetupNotCompleted(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(not ((GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup BG SIS Fiscal"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup BG SIS POS Pay Meth"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup BG SIS POS Unit"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup BG SIS Return Reason"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup BG SIS VAT PostSetup"))));
    end;

    local procedure ITCheckIfAssistedSetupCompleted(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(not ((GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup IT Fiscal"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup IT POS Paym. Meth."))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup IT POS Unit Mapping"))
            and (GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"NPR Setup IT Audit Profile"))));
    end;
#endif
    local procedure SECheckIfCleanCashNotSetup(): Boolean
    begin
        if not CleanCashSetup.Get() then
            exit(true);
        exit(not ((CleanCashSetup."CleanCash No. Series" <> '')
            and (CleanCashSetup."CleanCash Register No." <> '')
            and (CleanCashSetup."Connection String" <> '')
            and (CleanCashSetup."Organization ID" <> '')
            and (CleanCashSetup.Register <> '')));
    end;

    local procedure BECheckForPrintTemplate(): Boolean
    begin
        ObjectOutputSelection.SetRange("Print Template", 'EPSON_RECEIPT_2');
        exit(ObjectOutputSelection.IsEmpty());
    end;

    local procedure DKCheckIfFiscalizationNotSetup(): Boolean
    begin
        if not DKFiscalizationSetup.Get() then
            exit(true);
        exit(not ((DKFiscalizationSetup."Enable DK Fiscal")
            and (DKFiscalizationSetup."Signing Certificate".HasValue())
            and (DKFiscalizationSetup."SAF-T Audit File Sender" <> '')
            and (DKFiscalizationSetup."SAF-T Contact No." <> '')));
    end;

    local procedure HUMSCheckIfPaymentMethMappingExists(): Boolean
    begin
        exit(HUMSPaymentMethodMap.IsEmpty());
    end;

    local procedure FRCheckIfFiscalizationNotSetup(): Boolean
    begin
        if not FRAuditSetup.Get() then
            exit(true);
        exit(not (FRAuditSetup."Signing Certificate".HasValue()));
    end;

    local procedure NOCheckIfFiscalizationNotSetup(): Boolean
    begin
        if not NOFiscalizationSetup.Get() then
            exit(true);
        exit(not ((NOFiscalizationSetup."Signing Certificate".HasValue())
            and (NOFiscalizationSetup."SAF-T Audit File Sender" <> '')
            and (NOFiscalizationSetup."SAF-T Contact No." <> '')));
    end;

    #endregion Check Setups

    #region Setup Page Opening

#if BC17
    local procedure OpenAssistedSetupPage(AssistedSetupGroup: Enum "Assisted Setup Group")
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Open(AssistedSetupGroup);
    end;
#else
    local procedure OpenAssistedSetupPage(AssistedSetupGroup: Enum "Assisted Setup Group")
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.OpenAssistedSetup(AssistedSetupGroup);
    end;
#endif

    local procedure OpenSetupPage(SetupPageID: Integer)
    begin
        Page.RunModal(SetupPageID);
    end;

    #endregion Setup Page Opening

    #region Helper Procedures
    local procedure GetNotificationId(): Guid
    begin
        exit(CreateGuid());
    end;

    local procedure AddSetupNotificationMsgAction(var Notification: Notification; TableCaption: Text)
    begin
        Notification.Message(FormatNotificationMessage(TableCaption));
        Notification.AddAction(FormatActionCaption(TableCaption), Codeunit::"NPR POS Audit Profile Notifier", 'OnActionShowSetup');
    end;

    local procedure AddAssistedSetupNotificationMsgAction(var Notification: Notification)
    var
        AssistedSetupNotificationActionLbl: Label 'Open Assisted Setup Wizard';
        AssistedSetupNotificationTxt: Label 'Selected Audit Handler requires you to go through Assisted Setup Wizard steps.';
    begin
        Notification.Message(AssistedSetupNotificationTxt);
        Notification.AddAction(AssistedSetupNotificationActionLbl, Codeunit::"NPR POS Audit Profile Notifier", 'OnActionShowSetup');
    end;

    local procedure FormatNotificationMessage(TableCaption: Text): Text
    var
        OnePageSetupNotificationTxt: Label 'Selected Audit Handler requires additional setup in %1', Comment = '%1 = Table Caption';
    begin
        exit(StrSubstNo(OnePageSetupNotificationTxt, TableCaption));
    end;

    local procedure FormatActionCaption(TableCaption: Text): Text
    var
        OnePageSetupNotificationActionLbl: Label 'Open %1', Comment = '%1 = Table Caption';
    begin
        exit(StrSubstNo(OnePageSetupNotificationActionLbl, TableCaption));
    end;

    #endregion Helper Procedures

    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        CleanCashSetup: Record "NPR CleanCash Setup";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        HUMSPaymentMethodMap: Record "NPR HU MS Payment Method Map.";
        FRAuditSetup: Record "NPR FR Audit Setup";
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
        POSAuditHandlerLbl: Label 'POSAuditHandler';
}