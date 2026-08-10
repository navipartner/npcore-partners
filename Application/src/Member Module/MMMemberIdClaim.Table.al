table 6059978 "NPR MM MemberIdClaim"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; IdentityHash; Code[64])
        {
            Caption = 'Identity Hash';
            DataClassification = CustomerContent;
        }

        field(10; BusinessCentralSessionId; Integer)
        {
            Caption = 'Business Central Session ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; IdentityHash)
        {
            Clustered = true;
        }
    }

    internal procedure Acquire(Token: Text; BCSessionId: Integer): Boolean
    begin
        exit(Acquire(Token, BCSessionId, ClaimTtlMs()));
    end;

    internal procedure Acquire(Token: Text; BCSessionId: Integer; TtlMs: Integer): Boolean
    var
        Claim, CleanClaim, DirtyClaim : Record "NPR MM MemberIdClaim";
        ClaimKey: Code[64];
    begin
        ClaimKey := EncodeSHA256(Token);

        Claim.IdentityHash := ClaimKey;
        Claim.BusinessCentralSessionId := BCSessionId;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        DirtyClaim.ReadIsolation(IsolationLevel::ReadUncommitted);
        CleanClaim.ReadIsolation(IsolationLevel::ReadCommitted);
#endif

        if (DirtyClaim.Get(ClaimKey)) then begin
            if (DirtyClaim.BusinessCentralSessionId = BCSessionId) then
                exit(true);

            if ((CurrentDateTime() - DirtyClaim.SystemCreatedAt) < TtlMs) then
                exit(false);
        end;

        if (Claim.Insert()) then
            exit(true);

        if (CleanClaim.Get(ClaimKey)) then begin
            if (CleanClaim.BusinessCentralSessionId = BCSessionId) then
                exit(true);

            if ((CurrentDateTime() - CleanClaim.SystemCreatedAt) < TtlMs) then
                exit(false);

            if (not CleanClaim.Delete()) then
                exit(false);
        end;

        exit(Claim.Insert());
    end;

    internal procedure Release(Token: Text): Boolean
    var
        Claim: Record "NPR MM MemberIdClaim";
    begin
        if (not Claim.Get(EncodeSHA256(Token))) then
            exit(false);

        exit(Claim.Delete());
    end;

    local procedure EncodeSHA256(Plain: Text): Code[64]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
# pragma warning disable AA0139
        exit(CryptographyManagement.GenerateHash(Plain, HashAlgorithmType::SHA256));
# pragma warning restore AA0139
    end;

    local procedure ClaimTtlMs(): Integer
    begin
        // Stale-claim threshold: a claim older than this can be stolen by a new acquirer.
        exit(10 * 1000); // 10 seconds
    end;
}
