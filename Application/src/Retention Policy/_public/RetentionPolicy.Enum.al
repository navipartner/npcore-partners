#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enum 6059962 "NPR Retention Policy" implements "NPR IRetention Policy"
{
    Extensible = true;
    DefaultImplementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Undefined";

    value(0; UNDEFINED)
    {
        Caption = '<Undefined>';
    }
    value(1; "NPR Retention Policy Log Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Log Entry RetPol";
    }
    value(2; "NPR Data Log Record")
    {
        // Also serves as retention policy for "NPR Data Log Field"
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Data Log Record";
    }
    value(3; "NPR EFT Receipt")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: EFT Receipt";
    }
    value(4; "NPR EFT Transaction Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: EFT Transc. Log";
    }
    value(5; "NPR EFT Transaction Request")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: EFT Transc. Req.";
    }
    value(6; "NPR Exchange Label")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Exchange Label";
    }
    value(7; "NPR HL Webhook Request")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: HL Webhook Req.";
    }
    value(8; "NPR M2 Record Change Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: M2 RecChangeLog";
    }
    value(9; "NPR MM Admis. Service Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: MMAdmisServEntry";
    }
    value(10; "NPR Nc Import Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Nc Import Entry";
    }
    value(11; "NPR Nc Task")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Nc Task";
    }
    value(12; "NPR NpCs Arch. Document")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NpCs Arch. Doc.";
    }
    value(13; "NPR NpGp Export Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NpGp Export Log";
    }
    value(14; "NPR NpGp POS Sales Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NpGpPOSSalesEntr";
    }
    value(15; "NPR NPRE Kitchen Order")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPRE KitchenOrd.";
    }
    value(16; "NPR NPRE Waiter Pad")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPRE Waiter Pad";
    }
    value(17; "NPR NPRE W.Pad Prnt LogEntry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPREWPadPrntLogE";
    }
    value(18; "NPR POS Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPR POS Entry";
    }
    value(19; "NPR POS Balancing Line")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POS Balanc. Line";
    }
    value(20; "NPR POS Entry Output Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSEntryOutptLog";
    }
    value(21; "NPR POS Entry Payment Line")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSEntryPmtLine";
    }
    value(22; "NPR POS Entry Sales Line")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSEntrSalesLine";
    }
    value(23; "NPR POS Entry Tax Line")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSEntryTaxLine";
    }
    value(24; "NPR POS Layout Archive")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POS Layout Archv";
    }
    value(25; "NPR POS Period Register")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSPeriodRegstr";
    }
    value(26; "NPR POS Posting Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POS Posting Log";
    }
    value(27; "NPR POS Saved Sale Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: POSSavedSaleEntr";
    }
    value(28; "NPR Replication Error Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Repl. Error Log";
    }
    value(29; "NPR BTF EndPoint Error Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: BTFEndPntErrLog";
    }
    value(30; "NPR Sales Price Maint. Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: SalesPrcMntLog";
    }
    value(31; "NPR Tax Free Voucher")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Tax Free Voucher";
    }
    value(32; "NPR Spfy App Request")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPR Spfy App Req";
    }
    value(33; "NPR Spfy Log")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: NPR Spfy Log";
    }
    value(34; "NPR Spfy Webhook Notification")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: SpfyWebhookNotif";
    }
}
#endif