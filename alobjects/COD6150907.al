codeunit 6150907 "HC Customer Management"
{
    // NPR5.38/BR  /20171128 CASE 297946 HQ Connector Created Object
    // NPR5.44/MHA /20180702 CASE 321096 Added prices "Prices Including VAT"
    // NPR5.45/MHA /20180702 CASE 321096 Added missing prices "Prices Including VAT" in InsertCustomer()

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet XmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          CustomerAction(XmlDoc);
    end;

    var
        NcSetup: Record "Nc Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Initialized: Boolean;
        Text001: Label 'Audit Roll %1 - %2 - %3 - %4 - %5 - %6 allready exists.';

    local procedure CustomerAction(XmlDoc: DotNet XmlDocument)
    var
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
          exit;

        XmlElement := XmlDoc.DocumentElement;

        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'customerimport',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'customeraction',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'updatecustomerinfo',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'customerinfo',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          UpdateCustomer(XmlElement)
        end;
    end;

    local procedure UpdateCustomer(ItemXmlElement: DotNet XmlElement) Imported: Boolean
    var
        Customer: Record Customer;
        ChildXmlElement: DotNet XmlElement;
    begin
        if IsNull(ItemXmlElement) then
          exit(false);

        InsertCustomer(ItemXmlElement,Customer);

        Commit;
        exit(true);
    end;

    local procedure PreprocessCustomer(var Customer: Record Customer)
    begin
        with Customer do begin

        end;
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertCustomer(XmlElement: DotNet XmlElement;var Customer: Record Customer)
    var
        TempCustomer: Record Customer temporary;
        OStream: OutStream;
    begin
        Evaluate(TempCustomer."No.",NpXmlDomMgt.GetXmlText(XmlElement,'no',0,false),9);
        Evaluate(TempCustomer.Name,NpXmlDomMgt.GetXmlText(XmlElement,'name',0,false),9);
        Evaluate(TempCustomer."Search Name",NpXmlDomMgt.GetXmlText(XmlElement,'searchname',0,false),9);
        Evaluate(TempCustomer."Name 2",NpXmlDomMgt.GetXmlText(XmlElement,'name2',0,false),9);
        Evaluate(TempCustomer.Address,NpXmlDomMgt.GetXmlText(XmlElement,'address',0,false),9);
        Evaluate(TempCustomer."Address 2",NpXmlDomMgt.GetXmlText(XmlElement,'address2',0,false),9);
        Evaluate(TempCustomer.City,NpXmlDomMgt.GetXmlText(XmlElement,'city',0,false),9);
        Evaluate(TempCustomer.Contact,NpXmlDomMgt.GetXmlText(XmlElement,'contact',0,false),9);
        Evaluate(TempCustomer."Phone No.",NpXmlDomMgt.GetXmlText(XmlElement,'phoneno',0,false),9);
        Evaluate(TempCustomer."Our Account No.",NpXmlDomMgt.GetXmlText(XmlElement,'ouraccountno',0,false),9);
        Evaluate(TempCustomer."Global Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'globaldimension1',0,false),9);
        Evaluate(TempCustomer."Global Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'globaldimension2',0,false),9);
        Evaluate(TempCustomer."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        Evaluate(TempCustomer."Customer Price Group",NpXmlDomMgt.GetXmlText(XmlElement,'customerpricegroup',0,false),9);
        Evaluate(TempCustomer."Language Code",NpXmlDomMgt.GetXmlText(XmlElement,'languagecode',0,false),9);
        Evaluate(TempCustomer."Salesperson Code",NpXmlDomMgt.GetXmlText(XmlElement,'salespersoncode',0,false),9);
        Evaluate(TempCustomer."Customer Disc. Group",NpXmlDomMgt.GetXmlText(XmlElement,'customerdiscgroup',0,false),9);
        Evaluate(TempCustomer."Country/Region Code",NpXmlDomMgt.GetXmlText(XmlElement,'countryregion',0,false),9);
        Evaluate(TempCustomer."Bill-to Customer No.",NpXmlDomMgt.GetXmlText(XmlElement,'billtocustomer',0,false),9);
        Evaluate(TempCustomer."Payment Method Code",NpXmlDomMgt.GetXmlText(XmlElement,'paymentmethod',0,false),9);
        Evaluate(TempCustomer."Location Code",NpXmlDomMgt.GetXmlText(XmlElement,'locationcode',0,false),9);
        Evaluate(TempCustomer."VAT Registration No.",NpXmlDomMgt.GetXmlText(XmlElement,'vatregistration',0,false),9);
        Evaluate(TempCustomer."Post Code",NpXmlDomMgt.GetXmlText(XmlElement,'postcode',0,false),9);
        Evaluate(TempCustomer.County,NpXmlDomMgt.GetXmlText(XmlElement,'county',0,false),9);
        Evaluate(TempCustomer."E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',0,false),9);
        Evaluate(TempCustomer."VAT Bus. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'vatbuspostinggroup',0,false),9);
        Evaluate(TempCustomer."Responsibility Center",NpXmlDomMgt.GetXmlText(XmlElement,'responsibilitycenter',0,false),9);
        //-NPR5.44 [321096]
        if Evaluate(TempCustomer."Prices Including VAT",NpXmlDomMgt.GetXmlAttributeText(XmlElement,'pricesIncludesVat',false),9) then;
        //+NPR5.44 [321096]

        PreprocessCustomer(TempCustomer);

        //Record insert
        if not Customer.Get(TempCustomer."No.") then begin
          Customer.Init;
          Customer."No." := TempCustomer."No.";
          Customer.Insert(true);
        end;
        Customer.Validate("No.",TempCustomer."No.");
        Customer.Validate(Name,TempCustomer.Name);
        Customer.Validate("Search Name",TempCustomer."Search Name");
        Customer.Validate("Name 2",TempCustomer."Name 2");
        Customer.Validate(Address,TempCustomer.Address);
        Customer.Validate("Address 2",TempCustomer."Address 2");
        Customer.Validate(City,TempCustomer.City);
        Customer.Validate(Contact,TempCustomer.Contact);
        Customer.Validate("Phone No.",TempCustomer."Phone No.");
        Customer.Validate("Our Account No.",TempCustomer."Our Account No.");
        Customer.Validate("Global Dimension 1 Code",TempCustomer."Global Dimension 1 Code");
        Customer.Validate("Global Dimension 2 Code",TempCustomer."Global Dimension 2 Code");
        Customer.Validate("Currency Code",TempCustomer."Currency Code");
        Customer.Validate("Customer Price Group",TempCustomer."Customer Price Group");
        Customer.Validate("Language Code",TempCustomer."Language Code");
        Customer.Validate("Salesperson Code",TempCustomer."Salesperson Code");
        Customer.Validate("Customer Disc. Group",TempCustomer."Customer Disc. Group");
        Customer.Validate("Country/Region Code",TempCustomer."Country/Region Code");
        Customer.Validate("Bill-to Customer No.",TempCustomer."Bill-to Customer No.");
        Customer.Validate("Payment Method Code",TempCustomer."Payment Method Code");
        Customer.Validate("Location Code",TempCustomer."Location Code");
        Customer."VAT Registration No." := TempCustomer."VAT Registration No.";
        Customer.Validate("Post Code",TempCustomer."Post Code");
        Customer.Validate(County,TempCustomer.County);
        Customer.Validate("E-Mail",TempCustomer."E-Mail");
        Customer.Validate("VAT Bus. Posting Group",TempCustomer."VAT Bus. Posting Group");
        Customer.Validate("Responsibility Center",TempCustomer."Responsibility Center");
        //-NPR5.45 [321096]
        Customer.Validate("Prices Including VAT",TempCustomer."Prices Including VAT");
        //+NPR5.45 [321096]

        Customer.Modify(true);
    end;
}

