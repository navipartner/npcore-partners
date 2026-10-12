codeunit 6151530 "NPR Cust. Contact Update"
{
    // A code-driven Customer.Modify(true) hands Customer.OnModify an xRec that already carries the new values, so Microsoft's
    // IsContactUpdateNeeded sees no change and leaves the contact alone. Code that changes a customer compares with the row it
    // read instead, and updates the contact only when a field Microsoft copies to it changed, as a page edit would.
    Access = Internal;

    /// <summary>Updates the customer's contact when a field the contact takes from the customer differs from xCustomer.</summary>
    internal procedure UpdateContactIfChanged(var Customer: Record Customer; xCustomer: Record Customer)
    var
        CustContUpdate: Codeunit "CustCont-Update";
    begin
        if not ContactFieldsChanged(Customer, xCustomer) then
            exit;
        CustContUpdate.OnModify(Customer);
    end;

    // The fields Customer.IsContactUpdateNeeded compares.
    local procedure ContactFieldsChanged(Customer: Record Customer; xCustomer: Record Customer): Boolean
    begin
        exit(
            (Customer.Name <> xCustomer.Name) or
            (Customer."Search Name" <> xCustomer."Search Name") or
            (Customer."Name 2" <> xCustomer."Name 2") or
            (Customer.Address <> xCustomer.Address) or
            (Customer."Address 2" <> xCustomer."Address 2") or
            (Customer.City <> xCustomer.City) or
            (Customer."Phone No." <> xCustomer."Phone No.") or
            (Customer."Mobile Phone No." <> xCustomer."Mobile Phone No.") or
            (Customer."Telex No." <> xCustomer."Telex No.") or
            (Customer."Territory Code" <> xCustomer."Territory Code") or
            (Customer."Currency Code" <> xCustomer."Currency Code") or
            (Customer."Language Code" <> xCustomer."Language Code") or
            (Customer."Salesperson Code" <> xCustomer."Salesperson Code") or
            (Customer."Country/Region Code" <> xCustomer."Country/Region Code") or
            (Customer."Fax No." <> xCustomer."Fax No.") or
            (Customer."Telex Answer Back" <> xCustomer."Telex Answer Back") or
            (Customer."Registration Number" <> xCustomer."Registration Number") or
            (Customer."VAT Registration No." <> xCustomer."VAT Registration No.") or
            (Customer."Post Code" <> xCustomer."Post Code") or
            (Customer.County <> xCustomer.County) or
            (Customer."E-Mail" <> xCustomer."E-Mail") or
            (Customer."Home Page" <> xCustomer."Home Page") or
            (Customer.Contact <> xCustomer.Contact));
    end;
}
