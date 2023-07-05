codeunit 6059958 "NPR Manual Setup Upgrade"
{
    Access = Internal;
#IF NOT BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure GuidedExperienceOnRegisterManualSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertManualSetup('NPR POS Payment Method List', 'POS Payment Method List', 'Set up POS Payment methods.', 10,
                                            ObjectType::Page, Page::"NPR POS Payment Method List", Enum::"Manual Setup Category"::NPRetail, 'POS, Payment, Processing, Counting, Currency');

        GuidedExperience.InsertManualSetup('NPR POS Payment Bins', 'POS Payment Bins', 'Set up POS Payment Bins.', 5,
                                            ObjectType::Page, Page::"NPR POS Payment Bins", Enum::"Manual Setup Category"::NPRetail, 'POS, Payment, Bins');

        GuidedExperience.InsertManualSetup('NPR EFT Setup', 'EFT Setup', 'Set up Electronic Fund Transfer', 10,
                                            ObjectType::Page, Page::"NPR EFT Setup", Enum::"Manual Setup Category"::NPRetail, 'POS, EFT, Integration');

        GuidedExperience.InsertManualSetup('NPR NpDc Coupon Types', 'NpDc Coupon Types', 'Set up NpDc Coupon Types', 5,
                                            ObjectType::Page, Page::"NPR NpDc Coupon Types", Enum::"Manual Setup Category"::NPRetail, 'Coupon, Discount');

        GuidedExperience.InsertManualSetup('NPR NpRv Voucher Types ', 'NpRv Voucher Types ', 'Set up Retail Voucher Types', 5,
                                            ObjectType::Page, Page::"NPR NpRv Voucher Types", Enum::"Manual Setup Category"::NPRetail, 'Voucher');

        GuidedExperience.InsertManualSetup('NPR Retail Logo Setup', 'Retail Logo Setup', 'Import Retail Logo.', 2,
                                            ObjectType::Page, Page::"NPR Retail Logo Setup", Enum::"Manual Setup Category"::NPRetail, 'Retail, Logo');

        GuidedExperience.InsertManualSetup('NPR Exchange Label Setup', 'Exchange Label Setup', 'Set up Exchange Label', 3,
                                            ObjectType::Page, Page::"NPR Exchange Label Setup", Enum::"Manual Setup Category"::NPRetail, 'Exchange Label, EAN');

        GuidedExperience.InsertManualSetup('NPR MPOS Report Printers', 'MPOS Report Printers', 'Set up MPOS Report Printers', 5,
                                            ObjectType::Page, Page::"NPR MPOS Report Printers", Enum::"Manual Setup Category"::NPRetail, 'MPOS, Report, Printers');

        GuidedExperience.InsertManualSetup('NPR HWC Printers', 'HWC Printers', 'Set up Hardware Connector Report Printers', 5,
                                            ObjectType::Page, Page::"NPR HWC Printers", Enum::"Manual Setup Category"::NPRetail, 'HWC, Printers, Report, Paper');

        GuidedExperience.InsertManualSetup('NPR SMS Template List', 'SMS Template List', 'Set up SMS Templates', 10,
                                            ObjectType::Page, Page::"NPR SMS Template List", Enum::"Manual Setup Category"::NPRetail, 'SMS, Templates');
    end;
#ENDIF
}
