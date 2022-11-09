codeunit 6059951 "NPR POSAction: Ins. Customer-B"
{
    Access = Internal;
    procedure OnActionCreateContact(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Contact: Record Contact;
    begin
        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Cash) and (SalePOS."Customer No." <> '') then
            Contact.Get(SalePOS."Customer No.")
        else begin
            Contact.Init();
            Contact."No." := '';
            Contact.Insert(true);
            Commit();
        end;

        Contact.SetRecFilter();
        if CardPageId > 0 then
            PAGE.RunModal(CardPageId, Contact)
        else
            PageRunModalWithFieldFocus(Contact, Contact.FieldNo(Name));

        SalePOS."Customer Type" := SalePOS."Customer Type"::Cash;
        SalePOS.Validate("Customer No.", Contact."No.");
    end;

    procedure OnActionCreateCustomer(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Customer: Record Customer;
    begin
        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and (SalePOS."Customer No." <> '') then
            Customer.Get(SalePOS."Customer No.")
        else begin
            Customer.Init();
            Customer."No." := '';
            Customer.Insert(true);
            Commit();
        end;

        if CardPageId > 0 then
            PAGE.RunModal(CardPageId, Customer)
        else
            PageRunModalWithFieldFocus(Customer, Customer.FieldNo(Name));

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
    end;

    procedure PageRunModalWithFieldFocus(RecRelatedVariant: Variant; FieldNumber: Integer): Boolean
    var
        RecordRef: RecordRef;
        RecordRefVariant: Variant;
        PageID: Integer;
        PageMgt: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        if not GuiAllowed then
            exit(false);

        if not DataTypeManagement.GetRecordRef(RecRelatedVariant, RecordRef) then
            exit(false);

        PageID := PageMgt.GetPageID(RecordRef);

        if PageID <> 0 then begin
            RecordRefVariant := RecordRef;
            PAGE.RunModal(PageID, RecordRefVariant, FieldNumber);
            exit(true);
        end;

        exit(false);
    end;
}