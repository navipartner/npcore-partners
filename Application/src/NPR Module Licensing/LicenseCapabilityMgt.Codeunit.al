// SKU -> capability matrix (meeting 24. 8. 2026) and the per-user capability lookup. Only capabilities with a
// consumer exist. Enforcement guards live in "NPR License Mgt.".
codeunit 6151299 "NPR License Capability Mgt."
{
    Access = Internal;

    internal procedure GrantsCapability(Module: Enum "NPR License Module"; Capability: Enum "NPR License Capability"): Boolean
    begin
        case Capability of
            Capability::BackOffice:
                exit(Module in [Module::POS, Module::RetailWithoutPOS, Module::AttractionPOS, Module::AttractionWithoutPOS]);
            Capability::POSEndOfSale:
                exit(Module in [Module::POS, Module::AttractionPOS]);
            Capability::TicketManagement:
                exit(Module in [Module::AttractionPOS, Module::AttractionWithoutPOS]);
        end;
        exit(false);
    end;

    internal procedure UserHasCapability(UserSecID: Guid; Capability: Enum "NPR License Capability"): Boolean
    var
        LicenseUser: Record "NPR License User";
    begin
        LicenseUser.SetRange("User Security ID", UserSecID);
        LicenseUser.SetRange(Status, LicenseUser.Status::Active);
        LicenseUser.SetLoadFields(Module);
        if LicenseUser.FindSet() then
            repeat
                if GrantsCapability(LicenseUser.Module, Capability) then
                    exit(true);
            until LicenseUser.Next() = 0;
        exit(false);
    end;

    // The capability that unlocks an NP application-area tag (compared in upper case). First match wins: single-tag
    // exceptions (none today; a case before the prefixes), then prefix groups (#NPRTicket*), then Back Office.
    internal procedure CapabilityForTag(Tag: Text): Enum "NPR License Capability"
    var
        UpperTag: Text;
    begin
        UpperTag := UpperCase(Tag);
        if UpperTag.StartsWith('#NPRTICKET') then
            exit(Enum::"NPR License Capability"::TicketManagement);
        exit(Enum::"NPR License Capability"::BackOffice);
    end;

    // The modules that count for UI visibility: Active rows, and rows the portal sync auto-suspended (UI grace,
    // so a sync alone never blanks a user's back office; the POS check stays strict).
    internal procedure GetModulesCountingForUI(UserSecID: Guid; var Modules: List of [Enum "NPR License Module"])
    var
        LicenseUser: Record "NPR License User";
    begin
        Clear(Modules);
        LicenseUser.SetRange("User Security ID", UserSecID);
        LicenseUser.SetFilter(Status, '%1|%2', LicenseUser.Status::Active, LicenseUser.Status::SuspendedAutomatically);
        LicenseUser.SetLoadFields(Module);
        if LicenseUser.FindSet() then
            repeat
                Modules.Add(LicenseUser.Module);
            until LicenseUser.Next() = 0;
    end;

    // Seats add up; none can take away.
    internal procedure AnyModuleGrants(Modules: List of [Enum "NPR License Module"]; Capability: Enum "NPR License Capability"): Boolean
    var
        Module: Enum "NPR License Module";
    begin
        foreach Module in Modules do
            if GrantsCapability(Module, Capability) then
                exit(true);
        exit(false);
    end;
}
