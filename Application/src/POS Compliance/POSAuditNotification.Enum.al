enum 6014658 "NPR POS Audit Notification"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; NPRRSFiscal) { }
    value(1; NPRCROFiscal) { }
    value(2; NPRSIFiscal) { }
    value(3; NPRBGSISFiscal) { }
    value(4; NPRITFiscal) { }
    value(5; NPRSEFiscal) { }
    value(6; NPRBEFiscal) { }
    value(7; NPRDKFiscal) { }
    value(8; NPRHUMSInvoice) { }
    value(9; NPRFRFiscal) { }
    value(10; NPRNOFiscal) { }
}