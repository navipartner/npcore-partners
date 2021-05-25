codeunit 85030 "NPR Library - Sales Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Sales", 'OnAfterCreateCustomer', '', false, false)]
    local procedure OnAfterCreateCustomer(var Customer: Record Customer)
    var
        Salesperson: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesperson(Salesperson);
        Customer."Salesperson Code" := Salesperson.Code;
        Customer.Modify();
    end;
}