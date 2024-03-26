codeunit 6060089 "NPR BG VISION Local. Subs"
{
    Access = Internal;

    var
        BGVISIONLocalisationMgt: Codeunit "NPR BG VISION Local. Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnAfterPostPOSEntry', '', false, false)]
    local procedure POSPostEntriesOnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;

        BGVISIONLocalisationMgt.ModifySalesProtocolTVB(POSEntry);

        VATEntry.Reset();
        VATEntry.SetRange("Document No.", POSEntry."Document No.");
        VATEntry.SetRange("Posting Date", POSEntry."Posting Date");
        BGVISIONLocalisationMgt.ModifyVATSubjectTVB(VATEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR BG SIS Communication Mgt.", 'OnGetCustomerIdentificationNo', '', false, false)]
    local procedure BGSISCommunicationMgtOnGetCustomerIdentificationNo(Customer: Record Customer; var IdentificationNo: Text; var Handled: Boolean)
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGVISIONLocalisationMgt.GetCustomerIdentificationNoTVB(Customer, IdentificationNo, Handled);
    end;
}
