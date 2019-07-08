codeunit 6014600 "Security Protocol Switcher"
{
    // NPR5.40/MMV /20171031 CASE 293106 Created object.
    // 
    // This codeunit exists because NAV 2016/17 is running on .NET 4.5.2 where ServicePointManager.SecurityProtocol for the .NET process (NST Service)
    // is not set to attempt tls1.2 or tls1.1 by default.
    // This means that all webservice requests made via classes like HttpClient, HttpWebRequest, WebClient etc. will not attempt using tls1.2 or tls1.1 at all even though
    // both are actually supported in .NET 4.5.2.
    // In some cases, if consuming external APIs that are strict about allowed protocols, not changing this behaviour means that no connection can be established at all.
    // 
    // This codeunit hooks to OnAfterCompanyOpen and switches the property so that tls1.2 & tls1.1 is attempted as well - this is a GLOBAL setting for the entire NST process!
    // Changing this can also be accomplished via manual server registry key edits but this approach is deemed less intrusive.
    // This codeunit is specifically made so that it only enables new protocols on-top of what is already allowed so that nothing stops working for existing
    // web service integrations.
    // 
    // If/when a time comes where tls1.1 or tls1.2 is considered unsafe or the NAV NST runs on .NET 4.6 or later where this is enabled by default, delete or refactor this codeunit.
    // 
    // NOTE: MS released an out-of-band hotfix for NAV2016/17 addressing this officially: https://blogs.msdn.microsoft.com/nav/2018/01/23/connecting-dynamics-nav-2016-2017-dynamics-365-for-sales-version-9/
    // If this fix has been applied this codeunit is obsolete.
    // 
    // NPR5.40.02/MMV /20180418 CASE 311401 Temporarily disabled - MobilePay endpoint cannot gracefully handshake with clients supporting newer than tls1.0
    // NPR5.41/MMV /20180430 CASE 311962 Re-enabled now that MobilePay endpoint supports TLS1.2
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/MHA /20190424  CASE 352870 Added explicit support for TLS1.0 as it is no longer default on newer versions


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', false, false)]
    local procedure OnAfterCompanyOpen()
    var
        ServicePointManager: DotNet ServicePointManager;
        SecurityProtocolType: DotNet SecurityProtocolType;
        NewSecurityProtocol: DotNet SecurityProtocolType;
    begin
        //-NPR5.41 [311962]
        //-NPR5.40.02 [311401]
        //EXIT;
        //+NPR5.40.02 [311401]
        //+NPR5.41 [311962]

        //-NPR5.50 [352870]
        // IF ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls12) AND ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls11) THEN
        //  EXIT;
        if ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls12)
          and ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls11)
          and ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls)
        then
          exit;
        //+NPR5.50 [352870]

        //In C# we would just do |= onto the existing flags, but we need a little more help in C/AL..
        NewSecurityProtocol := BitwiseOR(ServicePointManager.SecurityProtocol, SecurityProtocolType.Tls12);
        NewSecurityProtocol := BitwiseOR(NewSecurityProtocol, SecurityProtocolType.Tls11);
        //-NPR5.50 [352870]
        NewSecurityProtocol := BitwiseOR(NewSecurityProtocol, SecurityProtocolType.Tls);
        //+NPR5.50 [352870]
        ServicePointManager.SecurityProtocol := NewSecurityProtocol;
    end;

    local procedure BitwiseOR(A: Integer;B: Integer): Integer
    var
        Result: Integer;
        BitMask: Integer;
        BitIndex: Integer;
        MaxBitIndex: Integer;
    begin
        if (A < 0) or (B < 0) then
          Error('Negative value. This is a programming error.');

        BitMask := 1;
        Result := 0;
        MaxBitIndex := 31; // 1st bit is ignored as it is always equals to 0 for positive Int32 numbers
        for BitIndex := 1 to MaxBitIndex do begin
          if ((A mod 2) = 1) or ((B mod 2) = 1) then
            Result += BitMask;
          A := A div 2;
          B := B div 2;
          if BitIndex < MaxBitIndex then
            BitMask += BitMask;
        end;
        exit(Result);
    end;
}

