codeunit 6014437 "NPR Phone Lookup"
{
    var
        IComm: Record "NPR I-Comm";
        Initialized: Boolean;


    procedure RunPhoneLookup(PhoneNo: Text[30]; var TempPhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary): Boolean
    begin
        if not TempPhoneLookupBuffer.IsTemporary() then
            exit(false);

        if not GuiAllowed then
            exit(false);

        if not InitIComm() then
            exit;

        Clear(TempPhoneLookupBuffer);
        TempPhoneLookupBuffer."Phone No." := PhoneNo;

        CODEUNIT.Run(IComm."Number Info Codeunit ID", TempPhoneLookupBuffer);

        case TempPhoneLookupBuffer.Count() of
            0:
                exit(false);
            1:
                begin
                    TempPhoneLookupBuffer.FindFirst();
                    exit(true);
                end;
        end;

        exit(PAGE.RunModal(PAGE::"NPR Phone Number Lookup", TempPhoneLookupBuffer) = ACTION::LookupOK);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure ContactOnValidateNo(var Rec: Record Contact; var xRec: Record Contact; CurrFieldNo: Integer)
    var
        Cont: Record Contact;
        TempPhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Cont.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", TempPhoneLookupBuffer) then
            UpdateCont(Rec, TempPhoneLookupBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure CustomerOnValidateNo(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        Cust: Record Customer;
        TempPhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Cust.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", TempPhoneLookupBuffer) then
            UpdateCust(Rec, TempPhoneLookupBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', true, true)]
    local procedure CustomerOnAfterModify(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today();
        Rec.Modify(false);
    end;


    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure VendorOnValidateNo(var Rec: Record Vendor; var xRec: Record Vendor; CurrFieldNo: Integer)
    var
        TempPhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
        Vend: Record Vendor;
    begin
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Vend.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", TempPhoneLookupBuffer) then
            UpdateVend(Rec, TempPhoneLookupBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterModifyEvent', '', true, true)]
    local procedure VendorOnAfterModify(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today();
        Rec.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Info Capture", 'OnAfterValidateEvent', 'Phone No.', true, true)]
    local procedure MemberInfoCapOnValidatePhone(var Rec: Record "NPR MM Member Info Capture"; var xRec: Record "NPR MM Member Info Capture"; CurrFieldNo: Integer)
    var
        TempPhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        if (Rec."Phone No." = '') then
            exit;

        if Rec."Membership Entry No." > 0 then
            exit;

        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."Phone No.", TempPhoneLookupBuffer) then
            UpdateMemberInfoCapture(Rec, TempPhoneLookupBuffer);
    end;

    procedure UpdateCont(var Cont: Record Contact; TempPhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        Cont.Validate(Name, CopyStr(TempPhoneLookupBuf.Name, 1, MaxStrLen(Cont.Name)));
        Cont."Name 2" := CopyStr(TempPhoneLookupBuf.Name, MaxStrLen(Cont.Name) + 1, MaxStrLen(Cont."Name 2"));
        Cont.Address := CopyStr(TempPhoneLookupBuf.Address, 1, MaxStrLen(Cont.Address));
        Cont."Address 2" := CopyStr(TempPhoneLookupBuf.Address, MaxStrLen(Cont.Address) + 1, MaxStrLen(Cont."Address 2"));
        Cont."Post Code" := CopyStr(TempPhoneLookupBuf."Post Code", 1, MaxStrLen(Cont."Post Code"));
        Cont.City := CopyStr(TempPhoneLookupBuf.City, 1, MaxStrLen(Cont.City));
        if (Cont."Post Code" <> '') and (Cont.City = '') then
            Cont.Validate("Post Code");
        if (Cont."Post Code" = '') and (Cont.City <> '') then
            Cont.Validate(City);
        Cont."E-Mail" := CopyStr(TempPhoneLookupBuf."E-Mail", 1, MaxStrLen(Cont."E-Mail"));
        Cont."Home Page" := CopyStr(TempPhoneLookupBuf."Home Page", 1, MaxStrLen(Cont."Home Page"));
        Cont."Phone No." := CopyStr(TempPhoneLookupBuf."Phone No.", 1, MaxStrLen(Cont."Phone No."));
        Cont."VAT Registration No." := TempPhoneLookupBuf."VAT Registration No.";
        Cont."Mobile Phone No." := TempPhoneLookupBuf."Mobile Phone No.";
    end;

    procedure UpdateCust(var Cust: Record Customer; TempPhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        Cust.Validate(Name, CopyStr(TempPhoneLookupBuf.Name, 1, MaxStrLen(Cust.Name)));
        Cust."Name 2" := CopyStr(TempPhoneLookupBuf.Name, MaxStrLen(Cust.Name) + 1, MaxStrLen(Cust."Name 2"));
        Cust.Address := CopyStr(TempPhoneLookupBuf.Address, 1, MaxStrLen(Cust.Address));
        Cust."Address 2" := CopyStr(TempPhoneLookupBuf.Address, MaxStrLen(Cust.Address) + 1, MaxStrLen(Cust."Address 2"));
        Cust."Post Code" := CopyStr(TempPhoneLookupBuf."Post Code", 1, MaxStrLen(Cust."Post Code"));
        Cust.City := CopyStr(TempPhoneLookupBuf.City, 1, MaxStrLen(Cust.City));
        if (Cust."Post Code" <> '') and (Cust.City = '') then
            Cust.Validate("Post Code");
        if (Cust."Post Code" = '') and (Cust.City <> '') then
            Cust.Validate(City);
        Cust."E-Mail" := CopyStr(TempPhoneLookupBuf."E-Mail", 1, MaxStrLen(Cust."E-Mail"));
        Cust."Home Page" := CopyStr(TempPhoneLookupBuf."Home Page", 1, MaxStrLen(Cust."Home Page"));
        Cust."Phone No." := CopyStr(TempPhoneLookupBuf."Phone No.", 1, MaxStrLen(Cust."Phone No."));
        Cust."VAT Registration No." := TempPhoneLookupBuf."VAT Registration No.";
    end;

    procedure UpdateVend(var Vend: Record Vendor; TempPhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        Vend.Validate(Name, CopyStr(TempPhoneLookupBuf.Name, 1, MaxStrLen(Vend.Name)));
        Vend."Name 2" := CopyStr(TempPhoneLookupBuf.Name, MaxStrLen(Vend.Name) + 1, MaxStrLen(Vend."Name 2"));
        Vend.Address := CopyStr(TempPhoneLookupBuf.Address, 1, MaxStrLen(Vend.Address));
        Vend."Address 2" := CopyStr(TempPhoneLookupBuf.Address, MaxStrLen(Vend.Address) + 1, MaxStrLen(Vend."Address 2"));
        Vend."Post Code" := CopyStr(TempPhoneLookupBuf."Post Code", 1, MaxStrLen(Vend."Post Code"));
        Vend.City := CopyStr(TempPhoneLookupBuf.City, 1, MaxStrLen(Vend.City));
        if (Vend."Post Code" <> '') and (Vend.City = '') then
            Vend.Validate("Post Code");
        if (Vend."Post Code" = '') and (Vend.City <> '') then
            Vend.Validate(City);
        Vend."E-Mail" := CopyStr(TempPhoneLookupBuf."E-Mail", 1, MaxStrLen(Vend."E-Mail"));
        Vend."Home Page" := CopyStr(TempPhoneLookupBuf."Home Page", 1, MaxStrLen(Vend."Home Page"));
        Vend."Phone No." := CopyStr(TempPhoneLookupBuf."Phone No.", 1, MaxStrLen(Vend."Phone No."));
        Vend."VAT Registration No." := TempPhoneLookupBuf."VAT Registration No.";
    end;

    procedure UpdateMemberInfoCapture(var MMMemberInfoCapture: Record "NPR MM Member Info Capture"; TempPhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        MMMemberInfoCapture.Validate("First Name", TempPhoneLookupBuf."First Name");
        MMMemberInfoCapture.Validate("Last Name", TempPhoneLookupBuf."Last Name");
        MMMemberInfoCapture.Address := CopyStr(TempPhoneLookupBuf.Address, 1, MaxStrLen(MMMemberInfoCapture.Address));
        MMMemberInfoCapture."Post Code Code" := CopyStr(TempPhoneLookupBuf."Post Code", 1, MaxStrLen(MMMemberInfoCapture."Post Code Code"));
        MMMemberInfoCapture.City := CopyStr(TempPhoneLookupBuf.City, 1, MaxStrLen(MMMemberInfoCapture.City));
        MMMemberInfoCapture."E-Mail Address" := CopyStr(TempPhoneLookupBuf."E-Mail", 1, MaxStrLen(MMMemberInfoCapture."E-Mail Address"));
    end;

    procedure Creation(var TempTDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    begin
        if TempTDCNamesNumbersBuffer."Create Vendor" then
            CreateVendor(TempTDCNamesNumbersBuffer);

        if TempTDCNamesNumbersBuffer."Create Contact" then
            CreateContact(TempTDCNamesNumbersBuffer);

        if TempTDCNamesNumbersBuffer."Create Customer" then
            CreateCustomer(TempTDCNamesNumbersBuffer);

        if TempTDCNamesNumbersBuffer."Create Contact" and TempTDCNamesNumbersBuffer."Create Customer" then
            CreateContactBusinessRel(TempTDCNamesNumbersBuffer, "Contact Business Relation Link To Table"::Customer);

        if TempTDCNamesNumbersBuffer."Create Contact" and TempTDCNamesNumbersBuffer."Create Vendor" then
            CreateContactBusinessRel(TempTDCNamesNumbersBuffer, "Contact Business Relation Link To Table"::Vendor);
    end;

    local procedure CreateCustomer(var TempTDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(TempTDCNamesNumbersBuffer."Phone No.") then
            exit;
        Customer.Init();
        Customer."No." := CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Customer."No."));
        Customer.Insert();
        Customer.Validate(Name, CopyStr(TempTDCNamesNumbersBuffer.Name, 1, MaxStrLen(Customer.Name)));
        Customer.Validate("Name 2", CopyStr(TempTDCNamesNumbersBuffer.Name, MaxStrLen(Customer.Name) + 1, MaxStrLen(Customer."Name 2")));
        Customer.Validate(Address, CopyStr(TempTDCNamesNumbersBuffer.Address, 1, MaxStrLen(Customer.Address)));
        Customer.Validate("Address 2", CopyStr(TempTDCNamesNumbersBuffer.Address, MaxStrLen(Customer.Address) + 1, MaxStrLen(Customer."Address 2")));
        Customer.Validate("Post Code", CopyStr(TempTDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Customer."Post Code")));
        Customer.Validate(City, CopyStr(TempTDCNamesNumbersBuffer.City, 1, MaxStrLen(Customer.City)));
        Customer.Validate("E-Mail", CopyStr(TempTDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Customer."E-Mail")));
        Customer.Validate("Home Page", CopyStr(TempTDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Customer."Home Page")));
        Customer.Validate("Phone No.", CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Customer."Phone No.")));
        Customer.Modify();
        Commit();

        Customer.SetRecFilter();
        if PAGE.RunModal(PAGE::"Customer Card", Customer) = ACTION::LookupOK then;
    end;

    local procedure CreateContact(TempTDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        Contact: Record Contact;
    begin
        if Contact.Get(TempTDCNamesNumbersBuffer."Phone No.") then
            exit;

        Contact.Init();
        Contact."No." := CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Contact."No."));
        Contact.Insert(true);
        Contact.Validate(Name, CopyStr(TempTDCNamesNumbersBuffer.Name, 1, MaxStrLen(Contact.Name)));
        Contact.Validate("Name 2", CopyStr(TempTDCNamesNumbersBuffer.Name, MaxStrLen(Contact.Name) + 1, MaxStrLen(Contact."Name 2")));
        Contact.Validate(Address, CopyStr(TempTDCNamesNumbersBuffer.Address, 1, MaxStrLen(Contact.Address)));
        Contact.Validate("Address 2", CopyStr(TempTDCNamesNumbersBuffer.Address, MaxStrLen(Contact.Address) + 1, MaxStrLen(Contact."Address 2")));
        Contact.Validate("Post Code", CopyStr(TempTDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Contact."Post Code")));
        Contact.Validate(City, CopyStr(TempTDCNamesNumbersBuffer.City, 1, MaxStrLen(Contact.City)));
        Contact.Validate("E-Mail", CopyStr(TempTDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Contact."E-Mail")));
        Contact.Validate("Home Page", CopyStr(TempTDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Contact."Home Page")));
        Contact.Validate("Phone No.", CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Contact."Phone No.")));
        Contact.Modify();
        Commit();

        if (TempTDCNamesNumbersBuffer."Create Contact") and (not TempTDCNamesNumbersBuffer."Create Customer") then begin
            Contact.SetRecFilter();
            if (PAGE.RunModal(PAGE::"Contact Card", Contact) = ACTION::OK) then;
        end;
    end;

    local procedure CreateContactBusinessRel(TempTDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary; LinkToTable: Enum "Contact Business Relation Link To Table")
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactBusinessRelation.Get(TempTDCNamesNumbersBuffer."Phone No.", '') then
            exit;

        ContactBusinessRelation.Init();
        ContactBusinessRelation."Contact No." := TempTDCNamesNumbersBuffer."Phone No.";
        ContactBusinessRelation."Business Relation Code" := '';
        ContactBusinessRelation."Link to Table" := LinkToTable;
        ContactBusinessRelation.Insert();
    end;

    local procedure CreateVendor(TempTDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(TempTDCNamesNumbersBuffer."Phone No.") then
            exit;

        Vendor.Init();
        Vendor."No." := CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Vendor."No."));
        Vendor.Insert(true);
        Vendor.Validate(Name, CopyStr(TempTDCNamesNumbersBuffer.Name, 1, MaxStrLen(Vendor.Name)));
        Vendor.Validate("Name 2", CopyStr(TempTDCNamesNumbersBuffer.Name, MaxStrLen(Vendor.Name) + 1, MaxStrLen(Vendor."Name 2")));
        Vendor.Validate(Address, CopyStr(TempTDCNamesNumbersBuffer.Address, 1, MaxStrLen(Vendor.Address)));
        Vendor.Validate("Address 2", CopyStr(TempTDCNamesNumbersBuffer.Address, MaxStrLen(Vendor.Address) + 1, MaxStrLen(Vendor."Address 2")));
        Vendor."Post Code" := CopyStr(TempTDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Vendor."Post Code"));
        Vendor.City := CopyStr(TempTDCNamesNumbersBuffer.City, 1, MaxStrLen(Vendor.City));
        Vendor.Validate("E-Mail", CopyStr(TempTDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Vendor."E-Mail")));
        Vendor.Validate("Home Page", CopyStr(TempTDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Vendor."Home Page")));
        Vendor.Validate("Phone No.", CopyStr(TempTDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Vendor."Phone No.")));
        Vendor.Modify();
        Commit();


        Vendor.SetRecFilter();
        if (PAGE.RunModal(PAGE::"Vendor Card", Vendor) = ACTION::OK) then;
    end;

    local procedure InitIComm(): Boolean
    begin
        if not Initialized then begin
            Initialized := true;
            if not IComm.Get() then
                exit(false);
        end;

        if not IComm."Use Auto. Cust. Lookup" then
            exit(false);
        if IComm."Number Info Codeunit ID" = 0 then
            exit(false);

        exit(true);
    end;
}