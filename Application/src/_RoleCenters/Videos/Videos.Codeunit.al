codeunit 6059919 "NPR Videos"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(var sender: Codeunit Video)
    var
        VarModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(VarModuleInfo);
        POSIntroduction(sender, VarModuleInfo.Id);
        POSProcesses(sender, VarModuleInfo.Id);
        SalesCycle(sender, VarModuleInfo.Id);
        POSDiscountsFirstPart(sender, VarModuleInfo.Id);
        POSDiscountsSecondPart(sender, VarModuleInfo.Id);
        Vouchers(sender, VarModuleInfo.Id);
        EndOfDayBalancing(sender, VarModuleInfo.Id);
        POSStoreSetup(sender, VarModuleInfo.Id);
        POSUnitGeneralSettings(sender, VarModuleInfo.Id);
        POSProfilesOverview(sender, VarModuleInfo.Id);
        AuditProfile(sender, VarModuleInfo.Id);
        ViewProfile(sender, VarModuleInfo.Id);
        EndOfDayProfile(sender, VarModuleInfo.Id);
        InpuBoxProfile(sender, VarModuleInfo.Id);
        UnitReceiptTextProfile(sender, VarModuleInfo.Id);
        POSPaymentBinSetup(sender, VarModuleInfo.Id);
        ConfigurePOSPostingSetup(sender, VarModuleInfo.Id);
        POSPaymentMethods(sender, VarModuleInfo.Id);
        PrinterSetup(sender, VarModuleInfo.Id);
        UserSetup(sender, VarModuleInfo.Id);
        CustomerSetup(sender, VarModuleInfo.Id);
        MultiplePriceDiscount(sender, VarModuleInfo.Id);
        MixDiscountGeneralSettings(sender, VarModuleInfo.Id);
        MixDiscountConditionsAndMixDiscountLines(sender, VarModuleInfo.Id);
        EntertainmentTicketAdmission(sender, VarModuleInfo.Id);
        MixDiscountTypes(sender, VarModuleInfo.Id);
        CombinationMixDiscounts(sender, VarModuleInfo.Id);
        VarietySetup(sender, VarModuleInfo.Id);
        VarietyFieldsSetup(sender, VarModuleInfo.Id);
        VarietyAdministrativeSection(sender, VarModuleInfo.Id);
        VarietyTableAdministrativeSection(sender, VarModuleInfo.Id);
        VarietyValuesAdministrativeSection(sender, VarModuleInfo.Id);
        ConfigureVarietyGroups(sender, VarModuleInfo.Id);
        AssignVarietyToItem(sender, VarModuleInfo.Id);
        VarietyMatrixPopup(sender, VarModuleInfo.Id);
        PriceSetup(sender, VarModuleInfo.Id);
        SalesPriceListsAndWorksheets(sender, VarModuleInfo.Id);
        SetUpNPPayAndAydenTerminals(sender, VarModuleInfo.Id);
        SetUpMinorTomAndHardwareConnector(sender, VarModuleInfo.Id);
        RetailPrintTemplates(sender, VarModuleInfo.Id);
        FrontendEditor(sender, VarModuleInfo.Id);
        AddLogoOnReceipt(sender, VarModuleInfo.Id);
    end;

    local procedure POSIntroduction(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/hZ7-MGKY4tg', locked = true;
        TitleLbl: Label 'NP POS Academy 01: Introduction';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSProcesses(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/oQFDJ1WTdyk', locked = true;
        TitleLbl: Label 'NP POS Academy 02: POS Processes';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure SalesCycle(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/4Z8AVPVpihg', locked = true;
        TitleLbl: Label 'NP POS Academy 03: Sales cycle';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSDiscountsFirstPart(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/Pn2N0bcTDJ4', locked = true;
        TitleLbl: Label 'NP POS Academy 04: Discounts 1/2';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSDiscountsSecondPart(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/SC2BrmPshh8', locked = true;
        TitleLbl: Label 'NP POS Academy 05: Discounts 2/2';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure Vouchers(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/ZPpyT5wZDhc', locked = true;
        TitleLbl: Label 'NP POS Academy 06: Vouchers';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure EndOfDayBalancing(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/osYCSzngg-o', locked = true;
        TitleLbl: Label 'NP POS Academy 07: End of day balancing';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSStoreSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/AktQ3262OJ8', locked = true;
        TitleLbl: Label 'NP POS Academy 08: POS Store Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSUnitGeneralSettings(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/LLJWAW0QFOc', locked = true;
        TitleLbl: Label 'NP POS Academy 09: POS Unit General Settings';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSProfilesOverview(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/tbnKC-_cBGc', locked = true;
        TitleLbl: Label 'NP POS Academy 10: POS Profiles overview';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure AuditProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/JaqGl38lV-s', locked = true;
        TitleLbl: Label 'NP POS Academy 11: Audit profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure ViewProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/xmJ_q4eWDY4', locked = true;
        TitleLbl: Label 'NP POS Academy 12: View profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure EndOfDayProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/ox4sPv9T62Q', locked = true;
        TitleLbl: Label 'NP POS Academy 13: End-of-Day profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure InpuBoxProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/b93ucAw0W5I', locked = true;
        TitleLbl: Label 'NP POS Academy 14: Input box profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure UnitReceiptTextProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/OJ2V87aDmuA', locked = true;
        TitleLbl: Label 'NP POS Academy 15: Unit receipt text profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSPaymentBinSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/Lo2OjMXLJQg', locked = true;
        TitleLbl: Label 'NP POS Academy 16: POS Payment bin setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure ConfigurePOSPostingSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/NACqyx-5Jc4', locked = true;
        TitleLbl: Label 'NP POS Academy 17: Configure POS Posting Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSPaymentMethods(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/czGJ2OqvsNw', locked = true;
        TitleLbl: Label 'NP POS Academy 18: POS Payment methods';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure PrinterSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/VKI0MNWorPA', locked = true;
        TitleLbl: Label 'NP POS Academy 19: Printer Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure UserSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/kJ6cjtj56VE', locked = true;
        TitleLbl: Label 'NP POS Academy 20: User Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure CustomerSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/nyrOQE1To_I', locked = true;
        TitleLbl: Label 'NP POS Academy 21: Customer Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure MultiplePriceDiscount(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/TK8aiGYn810', locked = true;
        TitleLbl: Label 'NP POS Academy 22: Multiple Price Discount';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure MixDiscountGeneralSettings(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/GCjFBjm8jtU', locked = true;
        TitleLbl: Label 'NP POS Academy 23: Mix Discount 01 - General Settings';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure MixDiscountConditionsAndMixDiscountLines(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/xDJF8fIzZW0', locked = true;
        TitleLbl: Label 'NP POS Academy 24: Mix Discount 02 - Conditions and Mix Discount Lines';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure EntertainmentTicketAdmission(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://share.synthesia.io/embeds/videos/dddf3d9a-bac6-47e4-b784-4dd50b39cc62', locked = true;
        TitleLbl: Label 'NP POS Academy 25: Entertainment - Ticket Admission';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure MixDiscountTypes(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/GdFKN5v223g', locked = true;
        TitleLbl: Label 'NP POS Academy 26: Mix Discount Types';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure CombinationMixDiscounts(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/NynY_ZB-jxc', locked = true;
        TitleLbl: Label 'NP POS Academy 27: Combination Mix Discounts';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietySetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/pDZ9kzk3SIc', locked = true;
        TitleLbl: Label 'NP POS Academy 28: Variety Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietyFieldsSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/owAFstc4vds', locked = true;
        TitleLbl: Label 'NP POS Academy 29: Variety Fields Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietyAdministrativeSection(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/DWCgtBz6-2c', locked = true;
        TitleLbl: Label 'NP POS Academy 30: Variety Administrative Section';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietyTableAdministrativeSection(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/ZhXcEmrrknk', locked = true;
        TitleLbl: Label 'NP POS Academy 31: Variety Table Administrative Section';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietyValuesAdministrativeSection(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/ksacX2zt9Uw', locked = true;
        TitleLbl: Label 'NP POS Academy 32: Variety Values Administrative Section';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure ConfigureVarietyGroups(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/7BQ8XESFc0I', locked = true;
        TitleLbl: Label 'NP POS Academy 33: Configure Variety Groups';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure AssignVarietyToItem(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/Xe4AwlA5DmE', locked = true;
        TitleLbl: Label 'NP POS Academy 34: Assign a Variety to an Item';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure VarietyMatrixPopup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/P63eJyhAMzg', locked = true;
        TitleLbl: Label 'NP POS Academy 35: Variety Matrix Pop up';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure PriceSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/-dDaY9iLQHE?si=xQv_QW6wg9XbyKvL', locked = true;
        TitleLbl: Label 'NP POS Academy 36: Price Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure SalesPriceListsAndWorksheets(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/DZFlAhoDlvI?si=LQXLZtV8zqXK4oit', locked = true;
        TitleLbl: Label 'NP POS Academy 37: Sales Price Lists and Worksheets';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure SetUpNPPayAndAydenTerminals(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/lYpd0Pe4X6E', locked = true;
        TitleLbl: Label 'NP POS Academy 38: Setting up NP Pay to use Ayden terminals';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure SetUpMinorTomAndHardwareConnector(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/oJW4ECnU10g', locked = true;
        TitleLbl: Label 'NP POS Academy 39: How to set up the Minor Tom and Hardware Connector';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure RetailPrintTemplates(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/d_UHXC1cILQ', locked = true;
        TitleLbl: Label 'NP POS Academy 40: Retail Print Templates';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure FrontendEditor(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/TOnYujxa7wc', locked = true;
        TitleLbl: Label 'NP POS Academy 41: The Frontend Editor';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure AddLogoOnReceipt(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://www.youtube.com/embed/M6naAmEB7fo', locked = true;
        TitleLbl: Label 'NP POS Academy 42: How to add a logo on a receipt';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;
}