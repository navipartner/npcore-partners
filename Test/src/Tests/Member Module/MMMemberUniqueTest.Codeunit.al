codeunit 85296 "NPR MM Member Unique Test"
{

    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_Email_EmitsOneKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] EMAIL identity -> exactly one lock key (the caller serializes on that one identity)
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL;
        Capture."E-Mail Address" := 'someone@example.com';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(1, Keys.Count(), 'EMAIL identity should emit exactly one lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_EmailOrPhone_BothPresent_EmitsTwoKeys()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] EMAIL_OR_PHONE is a disjunction: a collision on EITHER field must serialize, so it emits TWO
        // independent keys (this is the case that a single scraped filter string could never express).
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL_OR_PHONE;
        Capture."E-Mail Address" := 'someone@example.com';
        Capture."Phone No." := '+1 (212) 555-1234';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(2, Keys.Count(), 'EMAIL_OR_PHONE with both fields should emit two independent lock keys.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_None_EmitsNoKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] NONE = no uniqueness invariant -> no key -> caller takes no lock
        Community."Member Unique Identity" := Community."Member Unique Identity"::NONE;

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(0, Keys.Count(), 'NONE identity should emit no lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_Email_KeyIsCaseInsensitive()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        CaptureUpper, CaptureLower : Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        KeysUpper, KeysLower : List of [Text];
    begin
        // [SCENARIO] The same e-mail in different casing must hash to the same key, or two requests for the same
        // address in different casing would not serialize against each other.
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL;
        CaptureUpper."E-Mail Address" := 'Someone@Example.COM';
        CaptureLower."E-Mail Address" := 'someone@example.com';

        MembershipMgt.SetMemberUniqueIdFilter(Community, CaptureUpper, MemberFilter, KeysUpper);
        Clear(MemberFilter);
        MembershipMgt.SetMemberUniqueIdFilter(Community, CaptureLower, MemberFilter, KeysLower);

        Assert.AreEqual(KeysLower.Get(1), KeysUpper.Get(1), 'The EMAIL key must be case-insensitive.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_Email_DifferentAddressesDifferentKeys()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        CaptureA, CaptureB : Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        KeysA, KeysB : List of [Text];
    begin
        // [SCENARIO] Distinct identities produce distinct keys - this is what preserves concurrency (only same-identity
        // creates serialize, everything else runs in parallel).
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL;
        CaptureA."E-Mail Address" := 'a@example.com';
        CaptureB."E-Mail Address" := 'b@example.com';

        MembershipMgt.SetMemberUniqueIdFilter(Community, CaptureA, MemberFilter, KeysA);
        Clear(MemberFilter);
        MembershipMgt.SetMemberUniqueIdFilter(Community, CaptureB, MemberFilter, KeysB);

        Assert.AreNotEqual(KeysA.Get(1), KeysB.Get(1), 'Different e-mails must produce different lock keys.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_PhoneNo_EmitsOneKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] PHONENO identity -> exactly one lock key. Guards against silently dropping the phone UniqueKeys.Add.
        Community."Member Unique Identity" := Community."Member Unique Identity"::PHONENO;
        Capture."Phone No." := '+1 (212) 555-1234';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(1, Keys.Count(), 'PHONENO identity should emit exactly one lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_Ssn_EmitsOneKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] SSN identity -> exactly one lock key. Guards against silently dropping the SSN UniqueKeys.Add.
        Community."Member Unique Identity" := Community."Member Unique Identity"::SSN;
        Capture."Social Security No." := '123-45-6789';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(1, Keys.Count(), 'SSN identity should emit exactly one lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_EmailAndPhone_EmitsOneKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] EMAIL_AND_PHONE is a conjunction - the collision is the (email,phone) pair, so ONE composite key
        // (not two). Guards both that the composite is emitted and that it is not accidentally split into two.
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL_AND_PHONE;
        Capture."E-Mail Address" := 'someone@example.com';
        Capture."Phone No." := '+1 (212) 555-1234';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(1, Keys.Count(), 'EMAIL_AND_PHONE should emit exactly one composite lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UniqueIdFilter_EmailAndFirstName_EmitsOneKey()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        MemberFilter: Record "NPR MM Member";
        Assert: Codeunit Assert;
        Keys: List of [Text];
    begin
        // [SCENARIO] EMAIL_AND_FIRST_NAME is a conjunction -> ONE composite key.
        Community."Member Unique Identity" := Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME;
        Capture."E-Mail Address" := 'someone@example.com';
        Capture."First Name" := 'Alex';

        MembershipMgt.SetMemberUniqueIdFilter(Community, Capture, MemberFilter, Keys);

        Assert.AreEqual(1, Keys.Count(), 'EMAIL_AND_FIRST_NAME should emit exactly one composite lock key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClaimTokens_Foreign_EmitsExtNoToken()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        Assert: Codeunit Assert;
        Tokens: List of [Text];
    begin
        // [SCENARIO] FOREIGN context with an external member no -> serialize on that shared cross-instance identity.
        Community."Create Member UI Violation" := Community."Create Member UI Violation"::Error;
        Capture."Information Context" := Capture."Information Context"::FOREIGN;
        Capture."External Member No" := 'EXT-123';

        MembershipMgt.GetMemberIdClaimTokens(Community, Capture, Tokens);

        Assert.AreEqual(1, Tokens.Count(), 'FOREIGN with an external member no should emit exactly one lock token.');
        Assert.AreEqual('EXT-NO:EXT-123', Tokens.Get(1), 'FOREIGN token must be the EXT-NO-prefixed external member no.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClaimTokens_ForeignBlankExtNo_EmitsNoToken()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Community: Record "NPR MM Member Community";
        Capture: Record "NPR MM Member Info Capture";
        Assert: Codeunit Assert;
        Tokens: List of [Text];
    begin
        // [SCENARIO] Blank external no under FOREIGN means "mint a fresh local number" (a distinct member), not a shared
        // identity -> no token. Otherwise concurrent distinct foreign creates would falsely serialize on a constant 'EXT-NO:'.
        Community."Create Member UI Violation" := Community."Create Member UI Violation"::Error;
        Capture."Information Context" := Capture."Information Context"::FOREIGN;
        Capture."External Member No" := '';

        MembershipMgt.GetMemberIdClaimTokens(Community, Capture, Tokens);

        Assert.AreEqual(0, Tokens.Count(), 'FOREIGN with a blank external member no must emit no token.');
    end;

    // -------- NPR MM MemberIdClaim: acquire / reject-while-held / release --------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Claim_HeldTokenRejectsOtherSession_ReleaseFrees()
    var
        Claim: Record "NPR MM MemberIdClaim";
        Assert: Codeunit Assert;
        Token: Text;
        HolderSession, OtherSession : Integer;
    begin
        // [SCENARIO] A token held by one session rejects a DIFFERENT session's acquire (the real concurrent conflict),
        // and releasing it frees the identity. Same-session re-acquire is re-entrancy (see the next test), not a conflict.
        Token := 'UNIQ-TEST|' + Format(CreateGuid());
        HolderSession := 1001;
        OtherSession := 2002;

        Assert.IsTrue(Claim.Acquire(Token, HolderSession), 'First acquire should succeed.');
        Assert.IsFalse(Claim.Acquire(Token, OtherSession), 'A token held by another session should be rejected.');
        Assert.IsTrue(Claim.Release(Token), 'Releasing a held token should succeed.');
        Assert.IsTrue(Claim.Acquire(Token, OtherSession), 'After release the other session should be able to acquire.');

        Claim.Release(Token);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Claim_SameSessionReAcquireIsReentrant()
    var
        Claim: Record "NPR MM MemberIdClaim";
        Assert: Codeunit Assert;
        Token: Text;
        HolderSession: Integer;
    begin
        // [SCENARIO] The SAME session re-acquiring its own held token is re-entrancy, not a conflict - always allowed,
        // and it bypasses the TTL (re-entrancy is not a steal). This is what lets sequential same-identity work in one
        // session (shared member across memberships, reuse, merge) proceed instead of self-colliding on its own claim.
        Token := 'UNIQ-TEST|REENTRANT|' + Format(CreateGuid());
        HolderSession := 1001;

        Assert.IsTrue(Claim.Acquire(Token, HolderSession), 'First acquire should succeed.');
        Assert.IsTrue(Claim.Acquire(Token, HolderSession), 'Same session re-acquiring its own claim must be allowed (re-entrant).');
        Assert.IsTrue(Claim.Acquire(Token, HolderSession, 10 * 60 * 1000), 'Same session must ignore the TTL - re-entrancy is not a steal.');

        Claim.Release(Token);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Claim_DifferentTokensDoNotContend()
    var
        Claim: Record "NPR MM MemberIdClaim";
        Assert: Codeunit Assert;
        TokenA, TokenB : Text;
    begin
        // [SCENARIO] Different identities (tokens) never contend - both acquire.
        TokenA := 'UNIQ-TEST|A|' + Format(CreateGuid());
        TokenB := 'UNIQ-TEST|B|' + Format(CreateGuid());

        Assert.IsTrue(Claim.Acquire(TokenA, SessionId()), 'Acquire of token A should succeed.');
        Assert.IsTrue(Claim.Acquire(TokenB, SessionId()), 'Acquire of an unrelated token B should also succeed.');

        Claim.Release(TokenA);
        Claim.Release(TokenB);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Claim_ReleaseNotHeldTokenReturnsFalse()
    var
        Claim: Record "NPR MM MemberIdClaim";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Releasing a token that was never acquired is a no-op false, not an error.
        Assert.IsFalse(Claim.Release('UNIQ-TEST|NEVER|' + Format(CreateGuid())), 'Releasing a token that is not held should return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Claim_StaleLockStolenOnlyAcrossSessions()
    var
        Claim: Record "NPR MM MemberIdClaim";
        Assert: Codeunit Assert;
        Token: Text;
        HolderSession, OtherSession : Integer;
    begin
        // [SCENARIO] The TTL/steal is a CROSS-session mechanism - same-session bypasses it via re-entrancy, so it must
        // be exercised with two different session ids. A different session within the TTL is rejected (holder still
        // live); past the TTL it steals the stale orphan. SystemCreatedAt can't be aged (platform overwrites it on
        // write), so the TTL is injected: TtlMs = 10 min => still live => reject; TtlMs = 0 => stale => steal.
        Token := 'UNIQ-TEST|STALE|' + Format(CreateGuid());
        HolderSession := 1001;
        OtherSession := 2002;

        Assert.IsTrue(Claim.Acquire(Token, HolderSession), 'First acquire should succeed.');
        Assert.IsFalse(Claim.Acquire(Token, OtherSession, 10 * 60 * 1000), 'Another session within the TTL must be rejected, not stolen.');
        Assert.IsTrue(Claim.Acquire(Token, OtherSession, 0), 'Another session past the TTL must steal the stale lock.');

        Claim.Release(Token);
    end;
}
