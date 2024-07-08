codeunit 6150953 "NPR UPG Retail Logo"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Retail Logo Upgrade', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Retail Logo")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        RetailLogoUpgrade();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Retail Logo"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RetailLogoUpgrade()
    var
        RetailLogo: Record "NPR Retail Logo";
        IStream: InStream;
        OStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        LogoByte1: Byte;
        LogoByte2: Byte;
        LogoByte2Int: Integer;
    begin
        RetailLogo.SetAutoCalcFields(ESCPOSLogo);
        if not RetailLogo.FindSet(true) then
            exit;

        //find all 0xC2 and 0xC3 prefixed values between decimal 127 and 255 as per unicode standard and remove the padding.

        repeat
            if RetailLogo.ESCPOSLogo.HasValue then begin
                TempBlob.CreateOutStream(OStream);
                RetailLogo.ESCPOSLogo.CreateInStream(IStream);

                while (not IStream.EOS()) do begin
                    IStream.Read(LogoByte1, 1);
                    if (LogoByte1 = 194) or (LogoByte1 = 195) then begin
                        IStream.Read(LogoByte2);
                        if ((LogoByte2 > 127) and (LogoByte2 < 192)) then begin
                            if (LogoByte1 = 194) then begin
                                OStream.Write(LogoByte2, 1);
                            end else begin
                                LogoByte2Int := LogoByte2 + 64; //Values prefixed with 0xC3 must be shifted 7 positions, i.e. 64
                                LogoByte2 := LogoByte2Int;
                                OStream.Write(LogoByte2, 1);
                            end;
                        end else begin
                            OStream.Write(LogoByte1, 1);
                            OStream.Write(LogoByte2, 1);
                        end;
                    end else begin
                        OStream.Write(LogoByte1, 1);
                    end;
                end;

                Clear(OStream);
                Clear(IStream);

                TempBlob.CreateInStream(IStream);
                Clear(RetailLogo.ESCPOSLogo);
                RetailLogo.ESCPOSLogo.CreateOutStream(OStream);
                CopyStream(OStream, IStream);
                RetailLogo.Modify();
                Clear(TempBlob);
            end;
        until RetailLogo.Next() = 0;
    end;
}