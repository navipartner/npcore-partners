enum 6014504 "NPR Scanner Provider" implements "NPR IScanner Provider"
{
    Extensible = true;

    value(0; Zebra)
    {
        Caption = 'Zebra', Locked = true, MaxLength = 20;
        Implementation = "NPR IScanner Provider" = "NPR Zebra Scanner Mgt";
    }
    value(1; CipherLab)
    {
        Caption = 'Cipher Lab', Locked = true, MaxLength = 20;
        Implementation = "NPR IScanner Provider" = "NPR Cipher Lab Scanner Mgt";
    }
}