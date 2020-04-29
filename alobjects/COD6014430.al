codeunit 6014430 "Apply Salesperson to Document"
{
    // Manually bound event
    // 
    // NPR5.53/MMV /20200102 CASE Created object

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        SalespersonCode: Text;

    procedure SetCode(Value: Text)
    begin
        SalespersonCode := Value;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifySalesHeader(var Rec: Record "Sales Header";var xRec: Record "Sales Header";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not RunTrigger) then
          exit;

        if Rec."Salesperson Code" = SalespersonCode then
          exit;

        Rec.Validate("Salesperson Code", SalespersonCode);
        Rec.Modify;
    end;
}

