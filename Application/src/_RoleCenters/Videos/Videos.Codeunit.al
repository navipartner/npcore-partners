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
}