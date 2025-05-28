codeunit 85065 "NPR Library RS Fiscal"
{
    EventSubscriberInstance = Manual;

    procedure CreateAuditProfileAndRSSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var VATPostingSetup: Record "VAT Posting Setup"; var POSUnit: Record "NPR POS Unit")
    var
        NoSeriesLine: Record "No. Series Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        PaymentMethod: Record "Payment Method";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
#ELSE
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
#ENDIF
        NoSeriesLine.Modify();
        POSAuditProfile.Insert();
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        RSPOSUnitMapping.Init();
        RSPOSUnitMapping."POS Unit Code" := POSUnit."No.";
        RSPOSUnitMapping."RS Sandbox Token" := '4e3f2b87-9353-41f9-b53a-4efe640280f2';
        RSPOSUnitMapping."RS Sandbox PIN" := 7766;
        RSPOSUnitMapping."RS Sandbox JID" := 'YJLQTEQR';
        RSPOSUnitMapping.Insert();

        VATPostingSetup."VAT %" := 9;
        VATPostingSetup.Modify();
        if not RSVATPostSetupMapping.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            RSVATPostSetupMapping.Init();
            RSVATPostSetupMapping."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            RSVATPostSetupMapping."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            RSVATPostSetupMapping."RS Tax Category Name" := 'VAT';
            RSVATPostSetupMapping."RS Tax Category Label" := 'A';
            RSVATPostSetupMapping.Insert();
        end;

        POSPaymentMethod.FindSet();
        repeat
            if not RSPOSPaymMethMapping.Get(POSPaymentMethod.Code) then begin
                RSPOSPaymMethMapping.Init();
                RSPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
                RSPOSPaymMethMapping."RS Payment Method" := RSPOSPaymMethMapping."RS Payment Method"::Other;
                RSPOSPaymMethMapping.Insert();
            end;
        until POSPaymentMethod.Next() = 0;

        PaymentMethod.FindSet();
        repeat
            if not RSPaymentMethodMapping.Get(PaymentMethod.Code) then begin
                RSPaymentMethodMapping.Init();
                RSPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
                RSPaymentMethodMapping."RS Payment Method" := RSPaymentMethodMapping."RS Payment Method"::Other;
                RSPaymentMethodMapping.Insert();
            end;
        until PaymentMethod.Next() = 0;

        RSFiscalizationSetup.DeleteAll();
        RSFiscalizationSetup.Init();
        RSFiscalizationSetup."Enable RS Fiscal" := true;
        RSFiscalizationSetup."Fiscal Proforma on Sales Doc." := true;
        RSFiscalizationSetup."Report E-Mail Selection" := RSFiscalizationSetup."Report E-Mail Selection"::Both;
        RSFiscalizationSetup."Sandbox URL" := 'http://devesdc.sandbox.suf.purs.gov.rs:8888';
        RSFiscalizationSetup."Configuration URL" := 'https://api.sandbox.suf.purs.gov.rs/';
        RSFiscalizationSetup.Insert();

        BindSubscription(LibraryRSFiscal);
        RSTaxCommunicationMgt.PullAndFillSUFConfiguration();
        RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
        UnbindSubscription(LibraryRSFiscal);

        POSStore.Get(POSUnit."POS Store Code");
        POSStore."Registration No." := 'Test';
        POSStore."Country/Region Code" := 'RS';
        POSStore.Modify();
    end;

    procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'RS_FISKALIZACIJA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForNormalSale', '', false, false)]
    local procedure OnBeforeSendHttpRequestForNormalSale(var Sender: Codeunit "NPR RS Tax Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; StartTime: DateTime; var IsHandled: Boolean);
    begin
        ResponseText :=
        '{' +
            '"requestedBy": "YJLQTEQR",' +
            '"sdcDateTime": "2023-06-06T13:21:15.504282+02:00",' +
            '"invoiceCounter": "8652/11389ПП",' +
            '"invoiceCounterExtension": "ПП",' +
            '"invoiceNumber": "YJLQTEQR-YJLQTEQR-11389",' +
            '"taxItems": [' +
            '    {' +
            '        "categoryType": 0,' +
            '        "label": "A",' +
            '        "amount": 5.6527,' +
            '        "rate": 9.00,' +
            '        "categoryName": "VAT"' +
            '    }' +
            '],' +
            '"verificationUrl": "https://sandbox.suf.purs.gov.rs/v/?vl=A1lKTFFURVFSWUpMUVRFUVJ9LAAAzCEAADhyCgAAAAAAAAABiJBwjfAAAApSUzM0NTY0NTY1vqWJsTpXAmKxkqBjWiSYY%2FHhR298NENpyuAAv3%2BjL%2BLkj6b44E9oJ7YUTude2YMM5xjhjcScSSGHwDkYRzhHyVERVgw97xpyEc%2Fz0UPLMMZzzzOu6MPtDqiWJU3G29XkJi9abLUV7tMkelE9eYDVDaUEMCzGb0zp7TXzJKZThiHQlzpSovx5N56Jfz6YLsJC%2FCyjgEiSoq1OSh2TP8wfFVkS61UWYXwaKHFdRh8viPen0JKHsCzm6hf50aLvKhiC9lZ87jlrrahg%2BAaAFMctgnB0ibPJy1uv8rNXGeXjYDj%2FwCUAWs6no6wgl5VjRs6M1AoBm%2F9Aao%2Fgg1VFacSJVaMmSLQYowuowR4MXq8Y2aNvEi9AHD9s%2BSgr4lfMPWqa1WyAYq%2FNHiAptMdgaKgFu9vgCIZD4ai9Yl8iH4CSMfrYOp1Q49ei3ei5dceP88G%2B6afEZDRkQ4BoP6dmuaisT0%2F46NqKHEsAvaUIqBn%2B3xb8%2FKsDh6aMos6Aksvowvfby3stbyNmtzUbJAl2J%2BiWVuu%2B4cMPMRQBcdpn36C5Vzam0Acvlt5hGAkdmCHXC2vyCPDUxn5WG00k%2FILiLpr3HczooRMiVEV2%2FTPh1lA6VSS9M9QH9hV4LythfSD0pA4WQk1ComGCA6mM4%2FSLeMgsc4VkRw7FJmzAGr0djhY6vEpapyCm4D9yN4O36GPXmkWZ",' +
            '"verificationQRCode": null,' +
            '"journal": "============ ФИСКАЛНИ РАЧУН ============\r\nRS111911206\r\nNAVIPARTNER\r\nNAVIPARTNER\r\nХЕРОЈА МИЛАНА ТЕПИЋА 13\r\nБеоград\r\nКасир:                         123456789\r\nИД купца:                     RS34564565\r\nОпционо поље купца:               567546\r\nЕСИР број:                   POS2017/998\r\nЕСИР време:          08.12.2020. 8:55:23\r\n-------------ПРОМЕТ ПРОДАЈА-------------\r\nАртикли\r\n========================================\r\nНазив   Цена         Кол.         Укупно\r\nSport-100 Helmet, Blue (A)              \r\n        34,23          2           68,46\r\n----------------------------------------\r\nУкупан износ:                      68,46\r\nГотовина:                          68,46\r\n========================================\r\nОзнака       Име      Стопа        Порез\r\nA             VAT    9,00%          5,65\r\n----------------------------------------\r\nУкупан износ пореза:                5,65\r\n========================================\r\nПФР време:          06.06.2023. 13:21:15\r\nПФР број рачуна: YJLQTEQR-YJLQTEQR-11389\r\nБројач рачуна:              8652/11389ПП\r\n========================================\r\n======== КРАЈ ФИСКАЛНОГ РАЧУНА =========\r\n",' +
            '"messages": "Success",' +
            '"signedBy": "YJLQTEQR",' +
            '"encryptedInternalData": "vqWJsTpXAmKxkqBjWiSYY/HhR298NENpyuAAv3+jL+Lkj6b44E9oJ7YUTude2YMM5xjhjcScSSGHwDkYRzhHyVERVgw97xpyEc/z0UPLMMZzzzOu6MPtDqiWJU3G29XkJi9abLUV7tMkelE9eYDVDaUEMCzGb0zp7TXzJKZThiHQlzpSovx5N56Jfz6YLsJC/CyjgEiSoq1OSh2TP8wfFVkS61UWYXwaKHFdRh8viPen0JKHsCzm6hf50aLvKhiC9lZ87jlrrahg+AaAFMctgnB0ibPJy1uv8rNXGeXjYDj/wCUAWs6no6wgl5VjRs6M1AoBm/9Aao/gg1VFacSJVQ==",' +
            '"signature": "oyZItBijC6jBHgxerxjZo28SL0AcP2z5KCviV8w9aprVbIBir80eICm0x2BoqAW72+AIhkPhqL1iXyIfgJIx+tg6nVDj16Ld6Ll1x4/zwb7pp8RkNGRDgGg/p2a5qKxPT/jo2oocSwC9pQioGf7fFvz8qwOHpoyizoCSy+jC99vLey1vI2a3NRskCXYn6JZW677hww8xFAFx2mffoLlXNqbQBy+W3mEYCR2YIdcLa/II8NTGflYbTST8guIumvcdzOihEyJURXb9M+HWUDpVJL0z1Af2FXgvK2F9IPSkDhZCTUKiYYIDqYzj9It4yCxzhWRHDsUmbMAavR2OFjq8Sg==",' +
            '"totalCounter": 11389,' +
            '"transactionTypeCounter": 8652,' +
            '"totalAmount": 68.46,' +
            '"taxGroupRevision": 5,' +
            '"businessName": "NAVIPARTNER",' +
            '"tin": "RS111911206",' +
            '"locationName": "NAVIPARTNER",' +
            '"address": "ХЕРОЈА МИЛАНА ТЕПИЋА 13",' +
            '"district": "Београд",' +
            '"mrc": "00-1002-YJLQTEQR"' +
        '}';
        Sender.TestFillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForProformaSale', '', false, false)]
    local procedure OnBeforeSendHttpRequestForProformaSale(sender: Codeunit "NPR RS Tax Communication Mgt."; var ResponseText: Text; var SalesHeader: Record "Sales Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
        ResponseText :=
        '{' +
            '"requestedBy":"YJLQTEQR",' +
            '"sdcDateTime":"2024-02-29T17:07:27.4551405+01:00",' +
            '"invoiceCounter":"25734/92455РП",' +
            '"invoiceCounterExtension":"РП",' +
            '"invoiceNumber":"YJLQTEQR-YJLQTEQR-92455",' +
            '"taxItems":[' +
                '{' +
                    '"categoryType":0,' +
                    '"label":"F",' +
                    '"amount":72.3423,' +
                    '"rate":11.00,' +
                    '"categoryName":"ECAL"' +
                '}' +
            '],' +
            '"verificationUrl":"https://sandbox.suf.purs.gov.rs/v/?vl=A1lKTFFURVFSWUpMUVRFUVInaQEAhmQAAKBjbwAAAAAAAAABjfWe498BAAAb18anZDcyY3Yzg5Q6B4i%2Bl%2F1RwuH3KC7LXOTDHGsDJ9b0GVJhnUmZdEGk3SpomTz3%2BCxBHYV3eEEIaJq7k1rEKzFI0ZBtQiaAb%2BAdG7DcQRSruOHKJYd%2FFidnT%2BtwyZlQf1ZX3lANsGrelzlkgqY6YXPGe%2Fk08W%2BtHP%2FH5KJqig1icvkeiY04D5S7WPDQenFAOv9ykoAa%2BOE7Go%2FhP3baoAS%2BU12r3FaOvLTVWXsppum0Xb0XOokPmT%2Bqs%2FhONQ%2FiO82pXyygB7xiZVHTsNdSbZy8mwnNUbi0VU21ENTFiPAaXCY7xDXB2swHpeNil%2FlqDsvzjzssQZWohUEr8vlIUjGtw2iBY8HwNhjT6ST0OLHj3FfvY7FQwx1ut2KPvZhnSQ2MLcD4oUewCTE72MhakxFKpPH8Gg5YZX85pJg4Z71sO3RLgJdyup7YGSlCDKbmpTvj5pYQPyrw6%2Bum97P1XyqgzN3b3K7hX2HfqvCFzkCQFKhdIrvf3rER%2Bnhf2JVmMLs%2BR9Xp5A%2Bwvgdou5LtOJekYm0sLeVGsUzEQnbl6KMyN8Z8%2FuGuAdOVjA1jV6vgLwIi4TccVVPKUWE%2FfS8nKh6ulrjCjLqMQBeLAET31NBwi8GToESeG3W0DwLPE5sUge2UvMoIEsPWd9yJWZTNW9OETLfgoDmhW9UYctRSiLSeKmRAAqt12JZUq4YkGtc%3D",' +
            '"verificationQRCode":null,' +
            '"journal":"======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН ======= \r\nRS111911206 \r\nNAVIPARTNER \r\nNAVIPARTNER \r\nХЕРОЈА МИЛАНА ТЕПИЋА 13 \r\nБеоград \r\nКасир: AAAA \r\nЕСИР број: 1230/1.0 \r\n-----------ПРЕДРАЧУН ПРОДАЈА------------ \r\nАртикли \r\n======================================== \r\nНазив Цена Кол. Укупно \r\nMilka,cizkejk (F) \r\n 730,00 1 730,00 \r\n---------------------------------------- \r\nУкупан износ: 730,00 \r\nДруго безготовинско плаћање: 0,00 \r\n======================================== \r\n ОВО НИЈЕ ФИСКАЛНИ РАЧУН \r\n======================================== \r\nОзнака Име Стопа Порез \r\nF ECAL 11,00% 72,34 \r\n---------------------------------------- \r\nУкупан износ пореза: 72,34 \r\n======================================== \r\nПФР време: 29.02.2024. 17:07:27 \r\nПФР број рачуна: YJLQTEQR-YJLQTEQR-92455 \r\nБројач рачуна: 25734/92455РП \r\n======================================== \r\n======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН ======= \r\n",' +
            '"messages":"Success",' +
            '"signedBy":"YJLQTEQR",' +
            '"encryptedInternalData":"G9fGp2Q3MmN2M4OUOgeIvpf9UcLh9yguy1zkwxxrAyfW9BlSYZ1JmXRBpN0qaJk89/gsQR2Fd3hBCGiau5NaxCsxSNGQbUImgG/gHRuw3EEUq7jhyiWHfxYnZ0/rcMmZUH9WV95QDbBq3pc5ZIKmOmFzxnv5NPFvrRz/x+SiaooNYnL5HomNOA+Uu1jw0HpxQDr/cpKAGvjhOxqP4T922qAEvlNdq9xWjry01Vl7KabptF29FzqJD5k/qrP4TjUP4jvNqV8soAe8YmVR07DXUm2cvJsJzVG4tFVNtRDUxYjwGlwmO8Q1wdrMB6XjYpf5ag7L8487LEGVqIVBK/L5SA==",' +
            '"signature":"UjGtw2iBY8HwNhjT6ST0OLHj3FfvY7FQwx1ut2KPvZhnSQ2MLcD4oUewCTE72MhakxFKpPH8Gg5YZX85pJg4Z71sO3RLgJdyup7YGSlCDKbmpTvj5pYQPyrw6+um97P1XyqgzN3b3K7hX2HfqvCFzkCQFKhdIrvf3rER+nhf2JVmMLs+R9Xp5A+wvgdou5LtOJekYm0sLeVGsUzEQnbl6KMyN8Z8/uGuAdOVjA1jV6vgLwIi4TccVVPKUWE/fS8nKh6ulrjCjLqMQBeLAET31NBwi8GToESeG3W0DwLPE5sUge2UvMoIEsPWd9yJWZTNW9OETLfgoDmhW9UYctRSiA==",' +
            '"totalCounter":92455,' +
            '"transactionTypeCounter":25734,' +
            '"totalAmount":730.0,' +
            '"taxGroupRevision":8,' +
            '"businessName":"NAVIPARTNER",' +
            '"tin":"RS111911206",' +
            '"locationName":"NAVIPARTNER",' +
            '"address":"ХЕРОЈА МИЛАНА ТЕПИЋА 13",' +
            '"district":"Београд",' +
            '"mrc":"00-1002-YJLQTEQR"' +
        '}';
        sender.TestFillRSAuditFromNormalSaleAndRefundResponse(SalesHeader, ResponseText, false, true, StartTime);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForPrepaymentSaleDocument', '', false, false)]
    local procedure OnBeforeSendHttpRequestForPrepaymentSaleDocument(sender: Codeunit "NPR RS Tax Communication Mgt."; var ResponseText: Text; var SalesInvoiceHeader: Record "Sales Invoice Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
        ResponseText :=
        '{' +
            '"requestedBy":"YJLQTEQR",' +
            '"sdcDateTime":"2024-02-29T17:07:27.4551405+01:00",' +
            '"invoiceCounter":"25734/92455РП",' +
            '"invoiceCounterExtension":"РП",' +
            '"invoiceNumber":"YJLQTEQR-YJLQTEQR-92455",' +
            '"taxItems":[' +
                '{' +
                    '"categoryType":0,' +
                    '"label":"F",' +
                    '"amount":72.3423,' +
                    '"rate":11.00,' +
                    '"categoryName":"ECAL"' +
                '}' +
            '],' +
            '"verificationUrl":"https://sandbox.suf.purs.gov.rs/v/?vl=A1lKTFFURVFSWUpMUVRFUVInaQEAhmQAAKBjbwAAAAAAAAABjfWe498BAAAb18anZDcyY3Yzg5Q6B4i%2Bl%2F1RwuH3KC7LXOTDHGsDJ9b0GVJhnUmZdEGk3SpomTz3%2BCxBHYV3eEEIaJq7k1rEKzFI0ZBtQiaAb%2BAdG7DcQRSruOHKJYd%2FFidnT%2BtwyZlQf1ZX3lANsGrelzlkgqY6YXPGe%2Fk08W%2BtHP%2FH5KJqig1icvkeiY04D5S7WPDQenFAOv9ykoAa%2BOE7Go%2FhP3baoAS%2BU12r3FaOvLTVWXsppum0Xb0XOokPmT%2Bqs%2FhONQ%2FiO82pXyygB7xiZVHTsNdSbZy8mwnNUbi0VU21ENTFiPAaXCY7xDXB2swHpeNil%2FlqDsvzjzssQZWohUEr8vlIUjGtw2iBY8HwNhjT6ST0OLHj3FfvY7FQwx1ut2KPvZhnSQ2MLcD4oUewCTE72MhakxFKpPH8Gg5YZX85pJg4Z71sO3RLgJdyup7YGSlCDKbmpTvj5pYQPyrw6%2Bum97P1XyqgzN3b3K7hX2HfqvCFzkCQFKhdIrvf3rER%2Bnhf2JVmMLs%2BR9Xp5A%2Bwvgdou5LtOJekYm0sLeVGsUzEQnbl6KMyN8Z8%2FuGuAdOVjA1jV6vgLwIi4TccVVPKUWE%2FfS8nKh6ulrjCjLqMQBeLAET31NBwi8GToESeG3W0DwLPE5sUge2UvMoIEsPWd9yJWZTNW9OETLfgoDmhW9UYctRSiLSeKmRAAqt12JZUq4YkGtc%3D",' +
            '"verificationQRCode":null,"journal":"======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН ======= \r\nRS111911206 \r\nNAVIPARTNER \r\nNAVIPARTNER \r\nХЕРОЈА МИЛАНА ТЕПИЋА 13 \r\nБеоград \r\nКасир: AAAA \r\nЕСИР број: 1230/1.0 \r\n-----------ПРЕДРАЧУН ПРОДАЈА------------ \r\nАртикли \r\n======================================== \r\nНазив Цена Кол. Укупно \r\nMilka,cizkejk (F) \r\n 730,00 1 730,00 \r\n---------------------------------------- \r\nУкупан износ: 730,00 \r\nДруго безготовинско плаћање: 0,00 \r\n======================================== \r\n ОВО НИЈЕ ФИСКАЛНИ РАЧУН \r\n======================================== \r\nОзнака Име Стопа Порез \r\nF ECAL 11,00% 72,34 \r\n---------------------------------------- \r\nУкупан износ пореза: 72,34 \r\n======================================== \r\nПФР време: 29.02.2024. 17:07:27 \r\nПФР број рачуна: YJLQTEQR-YJLQTEQR-92455 \r\nБројач рачуна: 25734/92455РП \r\n======================================== \r\n======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН ======= \r\n",' +
            '"messages":"Success",' +
            '"signedBy":"YJLQTEQR",' +
            '"encryptedInternalData":"G9fGp2Q3MmN2M4OUOgeIvpf9UcLh9yguy1zkwxxrAyfW9BlSYZ1JmXRBpN0qaJk89/gsQR2Fd3hBCGiau5NaxCsxSNGQbUImgG/gHRuw3EEUq7jhyiWHfxYnZ0/rcMmZUH9WV95QDbBq3pc5ZIKmOmFzxnv5NPFvrRz/x+SiaooNYnL5HomNOA+Uu1jw0HpxQDr/cpKAGvjhOxqP4T922qAEvlNdq9xWjry01Vl7KabptF29FzqJD5k/qrP4TjUP4jvNqV8soAe8YmVR07DXUm2cvJsJzVG4tFVNtRDUxYjwGlwmO8Q1wdrMB6XjYpf5ag7L8487LEGVqIVBK/L5SA==",' +
            '"signature":"UjGtw2iBY8HwNhjT6ST0OLHj3FfvY7FQwx1ut2KPvZhnSQ2MLcD4oUewCTE72MhakxFKpPH8Gg5YZX85pJg4Z71sO3RLgJdyup7YGSlCDKbmpTvj5pYQPyrw6+um97P1XyqgzN3b3K7hX2HfqvCFzkCQFKhdIrvf3rER+nhf2JVmMLs+R9Xp5A+wvgdou5LtOJekYm0sLeVGsUzEQnbl6KMyN8Z8/uGuAdOVjA1jV6vgLwIi4TccVVPKUWE/fS8nKh6ulrjCjLqMQBeLAET31NBwi8GToESeG3W0DwLPE5sUge2UvMoIEsPWd9yJWZTNW9OETLfgoDmhW9UYctRSiA==",' +
            '"totalCounter":92455,' +
            '"transactionTypeCounter":25734,' +
            '"totalAmount":730.0,' +
            '"taxGroupRevision":8,' +
            '"businessName":"NAVIPARTNER",' +
            '"tin":"RS111911206",' +
            '"locationName":"NAVIPARTNER",' +
            '"address":"ХЕРОЈА МИЛАНА ТЕПИЋА 13",' +
            '"district":"Београд",' +
            '"mrc":"00-1002-YJLQTEQR"' +
        '}';
        sender.TestFillRSAuditFromNormalSaleAndRefundResponse(SalesInvoiceHeader, ResponseText, StartTime);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForNormalRefund', '', false, false)]
    local procedure OnBeforeSendHttpRequestForNormalRefund(sender: Codeunit "NPR RS Tax Communication Mgt."; var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; var ResponseText: Text; StartTime: DateTime; var IsHandled: Boolean)
    begin
        ResponseText := '{' +
        '"requestedBy":"YJLQTEQR",' +
        '"sdcDateTime":"2024-03-01T12:50:46.6401271+01:00",' +
        '"invoiceCounter":"25659/92714ПР",' +
        '"invoiceCounterExtension":"ПР",' +
        '"invoiceNumber":"YJLQTEQR-YJLQTEQR-92714",' +
        '"taxItems":[' +
            '{' +
                '"categoryType":0,' +
                '"label":"F",' +
                '"amount":72.3423,' +
                '"rate":11.00,' +
                '"categoryName":"ECAL"' +
            '}' +
        '],' +
        '"verificationUrl":"https://sandbox.suf.purs.gov.rs/v/?vl=A1lKTFFURVFSWUpMUVRFUVIqagEAO2QAAKBjbwAAAAAAAAABjfnaQHAAAQBUMhGsOlJR4UKEBQXU6O5Eq395VCY%2FNWuM0RRv%2Fzlax26reAEGzpBI20glwBwBm8Cv1lSbtvHWJoXUJcEEfQJWA1CzN5gFy%2F3WkvqtDiTPH8cl0%2BjFEratYJU1jG3qy%2FQOyWy49TO0Ow10sizdY1SrFXB8Ag%2BBgnP1mnijDF53SlhT45cOIkDzfK%2FUxxmc4kpSPAArDBBerZUwyC%2FpOEWOxKmRwevcOy3oUHuxJU7sCcxKs4Uv1PUDef83iSa7V5iRpbAs5pEocmdlF1rXtuaHJVdf5IgFwfae5Xfx1WjPunJ6a1UUnZ8%2ByMPlU19jxAkU6tWLntMp0JwjNAJSacUkJvHMqncFt3uLQpNa8r4PGdkXRwtqrpCCkc35VrxnD4qkC6C8rrCjksCCL33ySFQ78zz30iiX%2Bolr2EzUwcVWo5O%2BfTpLhArnsbCowjrznzHskOxJDSe80II1HGlnIJo8%2B6XE%2BaQ971L%2FSeVO1OXTg6RPV7ar0JxiHcGOLI4EjgOgMnJq4kZKI9wspiOnl8B7mNAfNgL1eL0qW2v8UU7cwxdUiqmNSm4SSU9VzOoJuihLNnkecih0h57i8q30ofOQig3Bb3pJUvXzHSWexHucy7KSmOUS5cy9yeXJNkBm8KSYeymJ0GpE0%2BKK4CKgFzEowWz%2BN3Ig2Rxv2osyIVYdhpCmVFjkdCXdWhkSe7hzwRQ%3D",' +
        '"verificationQRCode":null,' +
        '"journal":"============ ФИСКАЛНИ РАЧУН ============ \r\nRS111911206 \r\nNAVIPARTNER \r\nNAVIPARTNER \r\nХЕРОЈА МИЛАНА ТЕПИЋА 13 \r\nБеоград \r\nКасир: GU00000120 \r\nЕСИР број: 1230/1.0 \r\nРеф. број: YJLQTEQR-YJLQTEQR-92713 \r\nРеф. време: 01.03.2024. 12:48:11 \r\n-----------ПРОМЕТ РЕФУНДАЦИЈА----------- \r\nАртикли \r\n======================================== \r\nНазив Цена Кол. Укупно \r\nMilka,cizkejk (F) \r\n 730,00 1 -730,00 \r\n---------------------------------------- \r\nУкупна рефундација: 730,00 \r\nГотовина: 730,00 \r\n======================================== \r\nОзнака Име Стопа Порез \r\nF ECAL 11,00% 72,34 \r\n---------------------------------------- \r\nУкупан износ пореза: 72,34 \r\n======================================== \r\nПФР време: 01.03.2024. 12:50:46 \r\nПФР број рачуна: YJLQTEQR-YJLQTEQR-92714 \r\nБројач рачуна: 25659/92714ПР \r\n======================================== \r\n======== КРАЈ ФИСКАЛНОГ РАЧУНА =========\r\n",' +
        '"messages":"Success",' +
        '"signedBy":"YJLQTEQR",' +
        '"encryptedInternalData":"VDIRrDpSUeFChAUF1OjuRKt/eVQmPzVrjNEUb/85Wsduq3gBBs6QSNtIJcAcAZvAr9ZUm7bx1iaF1CXBBH0CVgNQszeYBcv91pL6rQ4kzx/HJdPoxRK2rWCVNYxt6sv0DslsuPUztDsNdLIs3WNUqxVwfAIPgYJz9Zp4owxed0pYU+OXDiJA83yv1McZnOJKUjwAKwwQXq2VMMgv6ThFjsSpkcHr3Dst6FB7sSVO7AnMSrOFL9T1A3n/N4kmu1eYkaWwLOaRKHJnZRda17bmhyVXX+SIBcH2nuV38dVoz7pyemtVFJ2fPsjD5VNfY8QJFOrVi57TKdCcIzQCUmnFJA==",' +
        '"signature":"JvHMqncFt3uLQpNa8r4PGdkXRwtqrpCCkc35VrxnD4qkC6C8rrCjksCCL33ySFQ78zz30iiX+olr2EzUwcVWo5O+fTpLhArnsbCowjrznzHskOxJDSe80II1HGlnIJo8+6XE+aQ971L/SeVO1OXTg6RPV7ar0JxiHcGOLI4EjgOgMnJq4kZKI9wspiOnl8B7mNAfNgL1eL0qW2v8UU7cwxdUiqmNSm4SSU9VzOoJuihLNnkecih0h57i8q30ofOQig3Bb3pJUvXzHSWexHucy7KSmOUS5cy9yeXJNkBm8KSYeymJ0GpE0+KK4CKgFzEowWz+N3Ig2Rxv2osyIVYdhg==",' +
        '"totalCounter":92714,' +
        '"transactionTypeCounter":25659,' +
        '"totalAmount":730.0,' +
        '"taxGroupRevision":8,' +
        '"businessName":"NAVIPARTNER",' +
        '"tin":"RS111911206",' +
        '"locationName":"NAVIPARTNER",' +
        '"address":"ХЕРОЈА МИЛАНА ТЕПИЋА 13",' +
        '"district":"Београд",' +
        '"mrc":"00-1002-YJLQTEQR"' +
        '}';
        sender.TestFillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForVerifyPin', '', false, false)]
    local procedure OnBeforeSendHttpRequestForVerifyPin(RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean);
    var
        RSPinStatusResponse: Enum "NPR RS Pin Status Response";
    begin
        ResponseText := '"0100"';
        ResponseText := DelChr(ResponseText, '=', '"');
        Evaluate(RSPinStatusResponse, ResponseText);
        ResponseText := ResponseText + ' - ' + Format(RSPinStatusResponse);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForSUFConfiguration', '', false, false)]
    local procedure OnBeforeSendHttpRequestForSUFConfiguration(var Sender: Codeunit "NPR RS Tax Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean);
    begin
        ResponseText :=
            '{' +
            '    "organizationName": "Министарство финансија - Пореска управа - Централа",' +
            '    "serverTimeZone": "Central Europe Standard Time",' +
            '    "street": "Саве Машковића 3-5",' +
            '    "city": "Београд",' +
            '    "country": "RS",' +
            '    "endpoints": {' +
            '        "taxpayerAdminPortal": "https://tap.sandbox.suf.purs.gov.rs:443/",' +
            '        "taxCoreApi": "https://api.sandbox.suf.purs.gov.rs:443/",' +
            '        "vsdc": "https://vsdc.sandbox.suf.purs.gov.rs:443/",' +
            '        "root": "https://sandbox.suf.purs.gov.rs:443/v/?vl="' +
            '    },' +
            '    "environmentName": "СУФ Развој",' +
            '    "logo": "https://sandbox.suf.purs.gov.rs:443/DownloadContent/TAlogo.png",' +
            '    "ntpServer": "http://0.pool.ntp.org:80/",' +
            '    "supportedLanguages": [' +
            '        "sr-Cyrl-RS",' +
            '        "en-US"' +
            '    ]' +
            '}';
        Sender.TextFillSUFConfigurationSetup(ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Tax Communication Mgt.", 'OnBeforeSendHttpRequestForAllowedTaxRates', '', false, false)]
    local procedure OnBeforeSendHttpRequestForAllowedTaxRates(var Sender: Codeunit "NPR RS Tax Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean);
    begin
        ResponseText :=
            '{' +
                '"currentTaxRates": {' +
                    '"validFrom": "2021-12-19T23:00:00Z",' +
                    '"groupId": 5,' +
                    '"taxCategories": [' +
                        '{' +
                            '"name": "ECAL",' +
                            '"categoryType": 0,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 11.00,' +
                                    '"label": "F"' +
                                '}' +
                            '],' +
                            '"orderId": 1' +
                        '},' +
                        '{' +
                            '"name": "N-TAX",' +
                            '"categoryType": 0,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 0.00,' +
                                    '"label": "N"' +
                                '}' +
                            '],' +
                            '"orderId": 2' +
                        '},' +
                        '{' +
                            '"name": "PBL",' +
                            '"categoryType": 2,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 0.50,' +
                                    '"label": "P"' +
                                '}' +
                            '],' +
                            '"orderId": 3' +
                        '},' +
                        '{' +
                            '"name": "STT",' +
                            '"categoryType": 0,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 6.00,' +
                                    '"label": "E"' +
                                '}' +
                            '],' +
                            '"orderId": 4' +
                        '},' +
                        '{' +
                            '"name": "TOTL",' +
                            '"categoryType": 1,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 2.00,' +
                                    '"label": "T"' +
                                '}' +
                            '],' +
                            '"orderId": 5' +
                        '},' +
                        '{' +
                            '"name": "VAT",' +
                            '"categoryType": 0,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 9.00,' +
                                    '"label": "A"' +
                                '},' +
                                '{' +
                                    '"rate": 0.00,' +
                                    '"label": "B"' +
                                '},' +
                                '{' +
                                    '"rate": 19.00,' +
                                    '"label": "Ж"' +
                                '}' +
                            '],' +
                            '"orderId": 6' +
                        '},' +
                        '{' +
                            '"name": "VAT-EXCL",' +
                            '"categoryType": 0,' +
                            '"taxRates": [' +
                                '{' +
                                    '"rate": 0.00,' +
                                    '"label": "C"' +
                                '}' +
                            '],' +
                            '"orderId": 7' +
                        '}' +
                    ']' +
                '},' +
                '"allTaxRates": [' +
                    '{' +
                        '"validFrom": "2021-12-19T23:00:00Z",' +
                        '"groupId": 5,' +
                        '"taxCategories": [' +
                            '{' +
                                '"name": "ECAL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 11.00,' +
                                        '"label": "F"' +
                                    '}' +
                                '],' +
                                '"orderId": 1' +
                            '},' +
                            '{' +
                                '"name": "N-TAX",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "N"' +
                                    '}' +
                                '],' +
                                '"orderId": 2' +
                            '},' +
                            '{' +
                                '"name": "PBL",' +
                                '"categoryType": 2,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.50,' +
                                        '"label": "P"' +
                                    '}' +
                                '],' +
                                '"orderId": 3' +
                            '},' +
                            '{' +
                                '"name": "STT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 6.00,' +
                                        '"label": "E"' +
                                    '}' +
                                '],' +
                                '"orderId": 4' +
                            '},' +
                            '{' +
                                '"name": "TOTL",' +
                                '"categoryType": 1,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 2.00,' +
                                        '"label": "T"' +
                                    '}' +
                                '],' +
                                '"orderId": 5' +
                            '},' +
                            '{' +
                                '"name": "VAT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 9.00,' +
                                        '"label": "A"' +
                                    '},' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "B"' +
                                    '},' +
                                    '{' +
                                        '"rate": 19.00,' +
                                        '"label": "Ж"' +
                                    '}' +
                                '],' +
                                '"orderId": 6' +
                            '},' +
                            '{' +
                                '"name": "VAT-EXCL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "C"' +
                                    '}' +
                                '],' +
                                '"orderId": 7' +
                            '}' +
                        ']' +
                    '},' +
                    '{' +
                        '"validFrom": "2021-07-22T09:55:24Z",' +
                        '"groupId": 2,' +
                        '"taxCategories": [' +
                            '{' +
                                '"name": "ECAL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 11.00,' +
                                        '"label": "F"' +
                                    '}' +
                                '],' +
                                '"orderId": 1' +
                            '},' +
                            '{' +
                                '"name": "N-TAX",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "N"' +
                                    '}' +
                                '],' +
                                '"orderId": 2' +
                            '},' +
                            '{' +
                                '"name": "PBL",' +
                                '"categoryType": 2,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.50,' +
                                        '"label": "P"' +
                                    '}' +
                                '],' +
                                '"orderId": 3' +
                            '},' +
                            '{' +
                                '"name": "STT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 6.00,' +
                                        '"label": "E"' +
                                    '}' +
                                '],' +
                                '"orderId": 4' +
                            '},' +
                            '{' +
                                '"name": "TOTL",' +
                                '"categoryType": 1,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 2.00,' +
                                        '"label": "T"' +
                                    '}' +
                                '],' +
                                '"orderId": 5' +
                            '},' +
                            '{' +
                                '"name": "VAT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 9.00,' +
                                        '"label": "A"' +
                                    '},' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "B"' +
                                    '}' +
                                '],' +
                                '"orderId": 6' +
                            '},' +
                            '{' +
                                '"name": "VAT-EXCL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "C"' +
                                    '}' +
                                '],' +
                                '"orderId": 7' +
                            '}' +
                        ']' +
                    '},' +
                    '{' +
                        '"validFrom": "2021-07-15T23:08:09Z",' +
                        '"groupId": 1,' +
                        '"taxCategories": [' +
                            '{' +
                                '"name": "ECAL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 10.00,' +
                                        '"label": "F"' +
                                    '}' +
                                '],' +
                                '"orderId": 1' +
                            '},' +
                            '{' +
                                '"name": "N-TAX",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "N"' +
                                    '}' +
                                '],' +
                                '"orderId": 2' +
                            '},' +
                            '{' +
                                '"name": "PBL",' +
                                '"categoryType": 2,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.50,' +
                                        '"label": "P"' +
                                    '}' +
                                '],' +
                                '"orderId": 3' +
                            '},' +
                            '{' +
                                '"name": "STT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 6.00,' +
                                        '"label": "E"' +
                                    '}' +
                                '],' +
                                '"orderId": 4' +
                            '},' +
                            '{' +
                                '"name": "TOTL",' +
                                '"categoryType": 1,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 2.00,' +
                                        '"label": "T"' +
                                    '}' +
                                '],' +
                                '"orderId": 5' +
                            '},' +
                            '{' +
                                '"name": "VAT",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 9.00,' +
                                        '"label": "A"' +
                                    '},' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "B"' +
                                    '}' +
                                '],' +
                                '"orderId": 6' +
                            '},' +
                            '{' +
                                '"name": "VAT-EXCL",' +
                                '"categoryType": 0,' +
                                '"taxRates": [' +
                                    '{' +
                                        '"rate": 0.00,' +
                                        '"label": "C"' +
                                    '}' +
                                '],' +
                                '"orderId": 7' +
                            '}' +
                        ']' +
                    '}' +
                ']' +
            '}';
        Sender.TestFillAllowedTaxRates(ResponseText, false);
        IsHandled := true;
    end;

#if not BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Fiscal Preview Mgt.", 'OnBeforeGEnerateQRCodeAZOnAddCurrentReceipt', '', false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddCurrentReceipt(var Base64QRCodeImage: Text; var IsHandled: Boolean);
    begin
        Base64QRCodeImage := 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Fiscal Preview Mgt.", 'OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptCopyIfExists', '', false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptCopyIfExists(var Base64QRCodeImage: Text; var IsHandled: Boolean);
    begin
        Base64QRCodeImage := 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS Fiscal Preview Mgt.", 'OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptOriginal', '', false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptOriginal(var Base64QRCodeImage: Text; var IsHandled: Boolean);
    begin
        Base64QRCodeImage := 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
        IsHandled := true;
    end;
#endif
}