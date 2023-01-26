codeunit 6059951 "NPR POSAction: Ins. Customer-B"
{
    Access = Internal;

    [Obsolete('Not Used.')]
    procedure OnActionCreateContact(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Contact: Record Contact;
    begin

    end;

    procedure OnActionCreateCustomer(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
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