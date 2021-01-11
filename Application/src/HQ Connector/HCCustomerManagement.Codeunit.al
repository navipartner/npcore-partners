codeunit 6150907 "NPR HC Customer Management"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if LoadXmlDoc(Document) then
            CustomerAction(Document);
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    local procedure CustomerAction(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        Document.GetRoot(Element);

        if Element.IsEmpty then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'customerimport', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'customeraction', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'updatecustomerinfo', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'customerinfo', NodeList) then
            exit;

        foreach Node in NodeList do
            UpdateCustomer(Node.AsXmlElement());
    end;

    local procedure UpdateCustomer(ItemXmlElement: XmlElement) Imported: Boolean
    var
        Customer: Record Customer;
    begin
        if ItemXmlElement.IsEmpty then
            exit(false);

        InsertCustomer(ItemXmlElement, Customer);

        Commit;
        exit(true);
    end;

    local procedure InsertCustomer(Element: XmlElement; var Customer: Record Customer)
    var
        TempCustomer: Record Customer temporary;
        OStream: OutStream;
    begin
        Evaluate(TempCustomer."No.", NpXmlDomMgt.GetXmlText(Element, 'no', 0, false), 9);
        Evaluate(TempCustomer.Name, NpXmlDomMgt.GetXmlText(Element, 'name', 0, false), 9);
        Evaluate(TempCustomer."Search Name", NpXmlDomMgt.GetXmlText(Element, 'searchname', 0, false), 9);
        Evaluate(TempCustomer."Name 2", NpXmlDomMgt.GetXmlText(Element, 'name2', 0, false), 9);
        Evaluate(TempCustomer.Address, NpXmlDomMgt.GetXmlText(Element, 'address', 0, false), 9);
        Evaluate(TempCustomer."Address 2", NpXmlDomMgt.GetXmlText(Element, 'address2', 0, false), 9);
        Evaluate(TempCustomer.City, NpXmlDomMgt.GetXmlText(Element, 'city', 0, false), 9);
        Evaluate(TempCustomer.Contact, NpXmlDomMgt.GetXmlText(Element, 'contact', 0, false), 9);
        Evaluate(TempCustomer."Phone No.", NpXmlDomMgt.GetXmlText(Element, 'phoneno', 0, false), 9);
        Evaluate(TempCustomer."Our Account No.", NpXmlDomMgt.GetXmlText(Element, 'ouraccountno', 0, false), 9);
        Evaluate(TempCustomer."Global Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'globaldimension1', 0, false), 9);
        Evaluate(TempCustomer."Global Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'globaldimension2', 0, false), 9);
        Evaluate(TempCustomer."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        Evaluate(TempCustomer."Customer Price Group", NpXmlDomMgt.GetXmlText(Element, 'customerpricegroup', 0, false), 9);
        Evaluate(TempCustomer."Language Code", NpXmlDomMgt.GetXmlText(Element, 'languagecode', 0, false), 9);
        Evaluate(TempCustomer."Salesperson Code", NpXmlDomMgt.GetXmlText(Element, 'salespersoncode', 0, false), 9);
        Evaluate(TempCustomer."Customer Disc. Group", NpXmlDomMgt.GetXmlText(Element, 'customerdiscgroup', 0, false), 9);
        Evaluate(TempCustomer."Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'countryregion', 0, false), 9);
        Evaluate(TempCustomer."Bill-to Customer No.", NpXmlDomMgt.GetXmlText(Element, 'billtocustomer', 0, false), 9);
        Evaluate(TempCustomer."Payment Method Code", NpXmlDomMgt.GetXmlText(Element, 'paymentmethod', 0, false), 9);
        Evaluate(TempCustomer."Location Code", NpXmlDomMgt.GetXmlText(Element, 'locationcode', 0, false), 9);
        Evaluate(TempCustomer."VAT Registration No.", NpXmlDomMgt.GetXmlText(Element, 'vatregistration', 0, false), 9);
        Evaluate(TempCustomer."Post Code", NpXmlDomMgt.GetXmlText(Element, 'postcode', 0, false), 9);
        Evaluate(TempCustomer.County, NpXmlDomMgt.GetXmlText(Element, 'county', 0, false), 9);
        Evaluate(TempCustomer."E-Mail", NpXmlDomMgt.GetXmlText(Element, 'email', 0, false), 9);
        Evaluate(TempCustomer."VAT Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatbuspostinggroup', 0, false), 9);
        Evaluate(TempCustomer."Responsibility Center", NpXmlDomMgt.GetXmlText(Element, 'responsibilitycenter', 0, false), 9);
        if Evaluate(TempCustomer."Prices Including VAT", NpXmlDomMgt.GetXmlAttributeText(Element, 'pricesIncludesVat', false), 9) then;

        //Record insert
        if not Customer.Get(TempCustomer."No.") then begin
            Customer.Init;
            Customer."No." := TempCustomer."No.";
            Customer.Insert(true);
        end;
        Customer.Validate("No.", TempCustomer."No.");
        Customer.Validate(Name, TempCustomer.Name);
        Customer.Validate("Search Name", TempCustomer."Search Name");
        Customer.Validate("Name 2", TempCustomer."Name 2");
        Customer.Validate(Address, TempCustomer.Address);
        Customer.Validate("Address 2", TempCustomer."Address 2");
        Customer.Validate(City, TempCustomer.City);
        Customer.Validate(Contact, TempCustomer.Contact);
        Customer.Validate("Phone No.", TempCustomer."Phone No.");
        Customer.Validate("Our Account No.", TempCustomer."Our Account No.");
        Customer.Validate("Global Dimension 1 Code", TempCustomer."Global Dimension 1 Code");
        Customer.Validate("Global Dimension 2 Code", TempCustomer."Global Dimension 2 Code");
        Customer.Validate("Currency Code", TempCustomer."Currency Code");
        Customer.Validate("Customer Price Group", TempCustomer."Customer Price Group");
        Customer.Validate("Language Code", TempCustomer."Language Code");
        Customer.Validate("Salesperson Code", TempCustomer."Salesperson Code");
        Customer.Validate("Customer Disc. Group", TempCustomer."Customer Disc. Group");
        Customer.Validate("Country/Region Code", TempCustomer."Country/Region Code");
        Customer.Validate("Bill-to Customer No.", TempCustomer."Bill-to Customer No.");
        Customer.Validate("Payment Method Code", TempCustomer."Payment Method Code");
        Customer.Validate("Location Code", TempCustomer."Location Code");
        Customer."VAT Registration No." := TempCustomer."VAT Registration No.";
        Customer.Validate("Post Code", TempCustomer."Post Code");
        Customer.Validate(County, TempCustomer.County);
        Customer.Validate("E-Mail", TempCustomer."E-Mail");
        Customer.Validate("VAT Bus. Posting Group", TempCustomer."VAT Bus. Posting Group");
        Customer.Validate("Responsibility Center", TempCustomer."Responsibility Center");
        Customer.Validate("Prices Including VAT", TempCustomer."Prices Including VAT");

        Customer.Modify(true);
    end;
}

