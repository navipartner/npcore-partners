codeunit 85525 "NPR Test Spfy Link Observer"
{
    // Manually bound observer of Shopify store-customer link modifies, shaped like a customer extension that reads the
    // customer back when one of its store links changes. It records the customer e-mail it finds on disk at that moment.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _LinkModifySeen: Boolean;
        _CustomerEmailOnDisk: Text;

    procedure LinkModifySeen(): Boolean
    begin
        exit(_LinkModifySeen);
    end;

    procedure CustomerEmailOnDisk(): Text
    begin
        exit(_CustomerEmailOnDisk);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Store-Customer Link", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifyLink(var Rec: Record "NPR Spfy Store-Customer Link")
    var
        Customer: Record Customer;
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec.Type <> Rec.Type::Customer then
            exit;
        if not Customer.Get(Rec."No.") then
            exit;
        _LinkModifySeen := true;
        _CustomerEmailOnDisk := Customer."E-Mail";
    end;
}
