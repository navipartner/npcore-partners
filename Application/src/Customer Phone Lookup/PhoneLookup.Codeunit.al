codeunit 6014437 "NPR Phone Lookup"
{
    // NPR5.40/LS  /20180226  CASE 305526 Modified UpdateMemberInfoCapture() to allow saving of First Name and Last Name for membersNPR5.23/BHR /20160325  CASE 222711 Phone lookup
    // NPR5.23/TSA /20160505  CASE 222711 Changed how subscriber interprets blank phone no. and added check on the functionen enabbled field
    // NPR5.23/LS  /20160513  CASE 226819 Added functions ApplyConfigTemplate, UpdCustomerAfterInsert, UpdVendorAfterInsert. Commented function
    // NPR5.25/BHR /20160727  CASE 247278 TDC functionality for Vendors.
    // NPR5.26/MHA /20160921  CASE 252881 Subscriber funtions changed from Insert to OnValidateNo to avoid double invoke on Contact sync and Extended Lookup with Contact
    // NPR5.27/BHR /20162010  CASE 255864 Set functions '--- BufferToRec',UpdateCont(),UpdateCust(),UpdateVend() to Global variables
    // NPR5.27/LS  /20161025  CASE 251264 Separated TDC and Config Template, Modified ContactOnValidateNo,CustomerOnValidateNo,VendorOnValidateNo
    //                                    Added functions CustomerOnAfterInsert(),CustomerOnAfterModify(),ContactOnAfterInsert(),ContactOnAfterModify(), VendorOnAfterInsert(),VendorOnAfterModify()
    //                                    Modifed function ApplyConfigTemplate(), Replace param RecVariant by RecRef
    // NPR5.28/MHA /20161104  CASE 257461 Added GUIALLOWED check to ApplyConfigTemplate() and RunPhoneLookup()
    // NPR5.29/MHA /20170118  CASE 263883 Missing InitIcomm() added for when RunPhoneLookup is invoked Externally
    // NPR5.29/TJ  /20170125  CASE 263507 New subscribers moved from PhoneLookup actions on pages
    // NPR5.31/BHR /20170316  CASE 268879 Phone Lookup For members
    // NPR5.38/MHA /20180105  CASE 301053 Added missing ; in CreateCustomer() and CreateVendor()
    // NPR5.40/LS  /20180226  CASE 305526 Modified UpdateMemberInfoCapture() to allow saving of First Name and Last Name for members
    // NPR5.48/JC  /20181217 CASE 313549 added subcriber function CustomerOnValidatePhoneNo
    // NPR5.49/LS  /20190402  CASE 313549 Commented 5.48 codes due to wrong flow.


    trigger OnRun()
    begin
    end;

    var
        IComm: Record "NPR I-Comm";
        Initialized: Boolean;
        Text000: Label 'Do you wish to apply Config. Template %1?';
        Text001: Label 'Do you want to do TDC lookup?';

    local procedure "--- Phone Lookup"()
    begin
    end;

    procedure RunPhoneLookup(PhoneNo: Text[30]; var PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary): Boolean
    begin
        //-NPR5.26 [252881]
        if not PhoneLookupBuffer.IsTemporary then
            exit(false);

        //-NPR5.28 [257461]
        if not GuiAllowed then
            exit(false);
        //+NPR5.28 [257461]

        //-NPR5.29 [263883]
        if not InitIComm() then
            exit;
        //+NPR5.29 [263883]

        Clear(PhoneLookupBuffer);
        PhoneLookupBuffer."Phone No." := PhoneNo;

        CODEUNIT.Run(IComm."Number Info Codeunit ID", PhoneLookupBuffer);

        case PhoneLookupBuffer.Count of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    PhoneLookupBuffer.FindFirst;
                    exit(true);
                end;
        end;

        exit(PAGE.RunModal(PAGE::"NPR Phone Number Lookup", PhoneLookupBuffer) = ACTION::LookupOK);
        //+NPR5.26 [252881]
    end;

    local procedure "---- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5050, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure ContactOnValidateNo(var Rec: Record Contact; var xRec: Record Contact; CurrFieldNo: Integer)
    var
        Cont: Record Contact;
        ConfigTemplateHeader: Record "Config. Template Header";
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Cont.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", PhoneLookupBuffer) then
            UpdateCont(Rec, PhoneLookupBuffer);
    end;

    [EventSubscriber(ObjectType::Table, 5050, 'OnAfterInsertEvent', '', true, true)]
    local procedure ContactOnAfterInsert(var Rec: Record Contact; RunTrigger: Boolean)
    var
        Cont: Record Contact;
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        if not InitIComm() then
            exit;

        if IComm."Config Request (Contact)" = IComm."Config Request (Contact)"::None then
            exit;

        if not ConfigTemplateHeader.Get(IComm."Config. Template (Contact)") then
            exit;

        RecRef.GetTable(Rec);
        ApplyConfigTemplate(RecRef, ConfigTemplateHeader, IComm."Config Request (Contact)" = IComm."Config Request (Contact)"::Ask);
        RecRef.SetTable(Rec);
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Table, 5050, 'OnAfterModifyEvent', '', true, true)]
    local procedure ContactOnAfterModify(var Rec: Record Contact; RunTrigger: Boolean)
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today;
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Page, 5052, 'OnAfterActionEvent', 'NPR PhoneLookup', false, false)]
    local procedure ContactListOnAfterAction(var Rec: Record Contact)
    var
        PhoneNoLookup: Page "NPR Phone No lookup";
        TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.29 [263507]
        TDCNamesNumbersBuffer."Create Contact" := true;
        PhoneNoLookup.Setrec(TDCNamesNumbersBuffer);
        PhoneNoLookup.RunModal;
        //+NPR5.29 [263507]
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure CustomerOnValidateNo(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        Cust: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.26 [252881]
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Cust.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", PhoneLookupBuffer) then
            UpdateCust(Rec, PhoneLookupBuffer);
        //+NPR5.26 [252881]
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterValidateEvent', 'Phone No.', true, true)]
    local procedure CustomerOnValidatePhoneNo(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        Cust: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.49 [313549]
        //-NPR5.48 [313549]
        // IF (Rec."No." = '') THEN
        //  EXIT;
        // IF NOT InitIComm() THEN
        //  EXIT;
        //
        // IF GUIALLOWED THEN
        //  IF Rec."Phone No." <> '' THEN
        //    IF NOT CONFIRM(Text001) THEN
        //      EXIT;
        //
        // IF RunPhoneLookup(Rec."Phone No.",PhoneLookupBuffer) THEN
        //  UpdateCust(Rec,PhoneLookupBuffer);
        //+NPR5.48 [313549]
        //+NPR5.49 [313549]
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterInsertEvent', '', true, true)]
    local procedure CustomerOnAfterInsert(var Rec: Record Customer; RunTrigger: Boolean)
    var
        Cust: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        if not IComm.Get then
            exit;

        if IComm."Config Request (Customer)" = IComm."Config Request (Customer)"::None then
            exit;

        if not ConfigTemplateHeader.Get(IComm."Config. Template (Customer)") then
            exit;

        RecRef.GetTable(Rec);
        ApplyConfigTemplate(RecRef, ConfigTemplateHeader, IComm."Config Request (Customer)" = IComm."Config Request (Customer)"::Ask);
        RecRef.SetTable(Rec);
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterModifyEvent', '', true, true)]
    local procedure CustomerOnAfterModify(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today;
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'NPR PhoneLookup', false, false)]
    local procedure CustomerListOnAfterAction(var Rec: Record Customer)
    var
        PhoneNoLookup: Page "NPR Phone No lookup";
        TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.29 [263507]
        TDCNamesNumbersBuffer."Create Customer" := true;
        PhoneNoLookup.Setrec(TDCNamesNumbersBuffer);
        PhoneNoLookup.RunModal;
        //+NPR5.29 [263507]
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure VendorOnValidateNo(var Rec: Record Vendor; var xRec: Record Vendor; CurrFieldNo: Integer)
    var
        Vend: Record Vendor;
        ConfigTemplateHeader: Record "Config. Template Header";
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.26 [252881]
        if xRec."No." <> '' then
            exit;
        if (Rec."No." = '') then
            exit;
        if Vend.Get(Rec."No.") then
            exit;
        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."No.", PhoneLookupBuffer) then
            UpdateVend(Rec, PhoneLookupBuffer);
        //+NPR5.26 [252881]
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterInsertEvent', '', true, true)]
    local procedure VendorOnAfterInsert(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        Vend: Record Vendor;
        ConfigTemplateHeader: Record "Config. Template Header";
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
        RecRef: RecordRef;
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        if not IComm.Get then
            exit;

        if IComm."Config Request (Vendor)" = IComm."Config Request (Vendor)"::None then
            exit;

        if not ConfigTemplateHeader.Get(IComm."Config. Template (Vendor)") then
            exit;

        RecRef.GetTable(Rec);
        ApplyConfigTemplate(RecRef, ConfigTemplateHeader, IComm."Config Request (Vendor)" = IComm."Config Request (Vendor)"::Ask);
        RecRef.SetTable(Rec);
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterModifyEvent', '', true, true)]
    local procedure VendorOnAfterModify(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        //-NPR5.27 [251264]
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today;
        Rec.Modify(false);
        //+NPR5.27 [251264]
    end;

    [EventSubscriber(ObjectType::Page, 27, 'OnAfterActionEvent', 'NPR PhoneLookup', false, false)]
    local procedure VendorListOnAfterAction(var Rec: Record Vendor)
    var
        PhoneNoLookup: Page "NPR Phone No lookup";
        TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.29 [263507]
        TDCNamesNumbersBuffer."Create Vendor" := true;
        PhoneNoLookup.Setrec(TDCNamesNumbersBuffer);
        PhoneNoLookup.RunModal;
        //+NPR5.29 [263507]
    end;

    [EventSubscriber(ObjectType::Table, 6060134, 'OnAfterValidateEvent', 'Phone No.', true, true)]
    local procedure MemberInfoCapOnValidatePhone(var Rec: Record "NPR MM Member Info Capture"; var xRec: Record "NPR MM Member Info Capture"; CurrFieldNo: Integer)
    var
        PhoneLookupBuffer: Record "NPR Phone Lookup Buffer" temporary;
    begin
        //-NPR5.31 [268879]
        if (Rec."Phone No." = '') then
            exit;

        if Rec."Membership Entry No." > 0 then
            exit;

        if not InitIComm() then
            exit;

        if RunPhoneLookup(Rec."Phone No.", PhoneLookupBuffer) then
            UpdateMemberInfoCapture(Rec, PhoneLookupBuffer);
        //+NPR5.31 [268879]
    end;

    procedure "--- BufferToRec"()
    begin
    end;

    procedure UpdateCont(var Cont: Record Contact; PhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        //-NPR5.26 [252881]
        with Cont do begin
            Validate(Name, CopyStr(PhoneLookupBuf.Name, 1, MaxStrLen(Name)));
            "Name 2" := CopyStr(PhoneLookupBuf.Name, MaxStrLen(Name) + 1, MaxStrLen("Name 2"));
            Address := CopyStr(PhoneLookupBuf.Address, 1, MaxStrLen(Address));
            "Address 2" := CopyStr(PhoneLookupBuf.Address, MaxStrLen(Address) + 1, MaxStrLen("Address 2"));
            "Post Code" := CopyStr(PhoneLookupBuf."Post Code", 1, MaxStrLen("Post Code"));
            City := CopyStr(PhoneLookupBuf.City, 1, MaxStrLen(City));
            if ("Post Code" <> '') and (City = '') then
                Validate("Post Code");
            if ("Post Code" = '') and (City <> '') then
                Validate(City);
            "E-Mail" := CopyStr(PhoneLookupBuf."E-Mail", 1, MaxStrLen("E-Mail"));
            "Home Page" := CopyStr(PhoneLookupBuf."Home Page", 1, MaxStrLen("Home Page"));
            "Phone No." := CopyStr(PhoneLookupBuf."Phone No.", 1, MaxStrLen("Phone No."));
            "VAT Registration No." := PhoneLookupBuf."VAT Registration No.";
            "Mobile Phone No." := PhoneLookupBuf."Mobile Phone No.";
        end;
        //+NPR5.26 [252881]
    end;

    procedure UpdateCust(var Cust: Record Customer; PhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        //-NPR5.23
        with Cust do begin
            Validate(Name, CopyStr(PhoneLookupBuf.Name, 1, MaxStrLen(Name)));
            "Name 2" := CopyStr(PhoneLookupBuf.Name, MaxStrLen(Name) + 1, MaxStrLen("Name 2"));
            Address := CopyStr(PhoneLookupBuf.Address, 1, MaxStrLen(Address));
            "Address 2" := CopyStr(PhoneLookupBuf.Address, MaxStrLen(Address) + 1, MaxStrLen("Address 2"));
            "Post Code" := CopyStr(PhoneLookupBuf."Post Code", 1, MaxStrLen("Post Code"));
            City := CopyStr(PhoneLookupBuf.City, 1, MaxStrLen(City));
            //-NPR5.26 [252881]
            //IF ("Post Code" <> '') AND (City <> '') THEN
            //  VALIDATE(City);
            if ("Post Code" <> '') and (City = '') then
                Validate("Post Code");
            if ("Post Code" = '') and (City <> '') then
                Validate(City);
            //+NPR5.26 [252881]
            "E-Mail" := CopyStr(PhoneLookupBuf."E-Mail", 1, MaxStrLen("E-Mail"));
            "Home Page" := CopyStr(PhoneLookupBuf."Home Page", 1, MaxStrLen("Home Page"));
            "Phone No." := CopyStr(PhoneLookupBuf."Phone No.", 1, MaxStrLen("Phone No."));
            "VAT Registration No." := PhoneLookupBuf."VAT Registration No.";
        end;
        //+NPR5.23
    end;

    procedure UpdateVend(var Vend: Record Vendor; PhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        //-NPR5.25 [247278]
        with Vend do begin
            Validate(Name, CopyStr(PhoneLookupBuf.Name, 1, MaxStrLen(Name)));
            "Name 2" := CopyStr(PhoneLookupBuf.Name, MaxStrLen(Name) + 1, MaxStrLen("Name 2"));
            Address := CopyStr(PhoneLookupBuf.Address, 1, MaxStrLen(Address));
            "Address 2" := CopyStr(PhoneLookupBuf.Address, MaxStrLen(Address) + 1, MaxStrLen("Address 2"));
            "Post Code" := CopyStr(PhoneLookupBuf."Post Code", 1, MaxStrLen("Post Code"));
            City := CopyStr(PhoneLookupBuf.City, 1, MaxStrLen(City));
            //-NPR5.26 [252881]
            //IF ("Post Code" <> '') AND (City <> '') THEN
            //  VALIDATE(City);
            if ("Post Code" <> '') and (City = '') then
                Validate("Post Code");
            if ("Post Code" = '') and (City <> '') then
                Validate(City);
            //+NPR5.26 [252881]
            "E-Mail" := CopyStr(PhoneLookupBuf."E-Mail", 1, MaxStrLen("E-Mail"));
            "Home Page" := CopyStr(PhoneLookupBuf."Home Page", 1, MaxStrLen("Home Page"));
            "Phone No." := CopyStr(PhoneLookupBuf."Phone No.", 1, MaxStrLen("Phone No."));
            "VAT Registration No." := PhoneLookupBuf."VAT Registration No.";
        end;
        //+NPR5.25 [247278]
    end;

    procedure UpdateMemberInfoCapture(var MMMemberInfoCapture: Record "NPR MM Member Info Capture"; PhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    begin
        //-NPR5.31 [268879]
        with MMMemberInfoCapture do begin
            //-NPR5.40 [305526]
            //VALIDATE("First Name", COPYSTR(PhoneLookupBuf.Name, 1, MAXSTRLEN("First Name")));
            //"Last Name":= COPYSTR(PhoneLookupBuf.Name, MAXSTRLEN("First Name") + 1, MAXSTRLEN("Last Name"));
            Validate("First Name", PhoneLookupBuf."First Name");
            Validate("Last Name", PhoneLookupBuf."Last Name");
            //+NPR5.40 [305526]
            Address := CopyStr(PhoneLookupBuf.Address, 1, MaxStrLen(Address));
            "Post Code Code" := CopyStr(PhoneLookupBuf."Post Code", 1, MaxStrLen("Post Code Code"));
            City := CopyStr(PhoneLookupBuf.City, 1, MaxStrLen(City));
            "E-Mail Address" := CopyStr(PhoneLookupBuf."E-Mail", 1, MaxStrLen("E-Mail Address"));
            //"Phone No." := COPYSTR(PhoneLookupBuf."Phone No.", 1, MAXSTRLEN("Phone No."));
        end;
        //-NPR5.31 [268879]
    end;

    local procedure "--- Page Create"()
    begin
    end;

    procedure Creation(var TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    begin
        //-NPR5.23
        if TDCNamesNumbersBuffer."Create Vendor" then
            CreateVendor(TDCNamesNumbersBuffer);

        if TDCNamesNumbersBuffer."Create Contact" then
            CreateContact(TDCNamesNumbersBuffer);

        if TDCNamesNumbersBuffer."Create Customer" then
            CreateCustomer(TDCNamesNumbersBuffer);

        if TDCNamesNumbersBuffer."Create Contact" and TDCNamesNumbersBuffer."Create Customer" then
            CreateContactBusinessRel(TDCNamesNumbersBuffer, "Contact Business Relation Link To Table"::Customer);


        if TDCNamesNumbersBuffer."Create Contact" and TDCNamesNumbersBuffer."Create Vendor" then
            CreateContactBusinessRel(TDCNamesNumbersBuffer, "Contact Business Relation Link To Table"::Vendor);

        //+NPR5.23
    end;

    local procedure CreateCustomer(var TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        MarketingSetup: Record "Marketing Setup";
        Customer: Record Customer;
    begin
        //-NPR5.23

        if Customer.Get(TDCNamesNumbersBuffer."Phone No.") then
            exit;
        Customer.Init;
        Customer."No." := CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Customer."No."));
        Customer.Insert;
        Customer.Validate(Name, CopyStr(TDCNamesNumbersBuffer.Name, 1, MaxStrLen(Customer.Name)));
        Customer.Validate("Name 2", CopyStr(TDCNamesNumbersBuffer.Name, MaxStrLen(Customer.Name) + 1, MaxStrLen(Customer."Name 2")));
        Customer.Validate(Address, CopyStr(TDCNamesNumbersBuffer.Address, 1, MaxStrLen(Customer.Address)));
        Customer.Validate("Address 2", CopyStr(TDCNamesNumbersBuffer.Address, MaxStrLen(Customer.Address) + 1, MaxStrLen(Customer."Address 2")));
        Customer.Validate("Post Code", CopyStr(TDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Customer."Post Code")));
        Customer.Validate(City, CopyStr(TDCNamesNumbersBuffer.City, 1, MaxStrLen(Customer.City)));
        Customer.Validate("E-Mail", CopyStr(TDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Customer."E-Mail")));
        Customer.Validate("Home Page", CopyStr(TDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Customer."Home Page")));
        Customer.Validate("Phone No.", CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Customer."Phone No.")));
        Customer.Modify;
        Commit;


        Customer.SetRecFilter;
        //-NPR5.38 [301053]
        //IF PAGE.RUNMODAL( PAGE::"Customer Card", Customer ) = ACTION::LookupOK THEN
        if PAGE.RunModal(PAGE::"Customer Card", Customer) = ACTION::LookupOK then;
        //+NPR5.38 [301053]
        //+NPR5.23
    end;

    local procedure CreateContact(TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        Contact: Record Contact;
    begin
        //-NPR5.23

        if Contact.Get(TDCNamesNumbersBuffer."Phone No.") then
            exit;

        Contact.Init;
        Contact."No." := CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Contact."No."));
        Contact.Insert(true);
        Contact.Validate(Name, CopyStr(TDCNamesNumbersBuffer.Name, 1, MaxStrLen(Contact.Name)));
        Contact.Validate("Name 2", CopyStr(TDCNamesNumbersBuffer.Name, MaxStrLen(Contact.Name) + 1, MaxStrLen(Contact."Name 2")));
        Contact.Validate(Address, CopyStr(TDCNamesNumbersBuffer.Address, 1, MaxStrLen(Contact.Address)));
        Contact.Validate("Address 2", CopyStr(TDCNamesNumbersBuffer.Address, MaxStrLen(Contact.Address) + 1, MaxStrLen(Contact."Address 2")));
        Contact.Validate("Post Code", CopyStr(TDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Contact."Post Code")));
        Contact.Validate(City, CopyStr(TDCNamesNumbersBuffer.City, 1, MaxStrLen(Contact.City)));
        Contact.Validate("E-Mail", CopyStr(TDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Contact."E-Mail")));
        Contact.Validate("Home Page", CopyStr(TDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Contact."Home Page")));
        Contact.Validate("Phone No.", CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Contact."Phone No.")));
        Contact.Modify;
        Commit;

        if (TDCNamesNumbersBuffer."Create Contact") and (not TDCNamesNumbersBuffer."Create Customer") then begin
            Contact.SetRecFilter;
            if (PAGE.RunModal(PAGE::"Contact Card", Contact) = ACTION::OK) then;
        end;
        //+NPR5.23
    end;

    local procedure CreateContactBusinessRel(TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary; LinkToTable: Enum "Contact Business Relation Link To Table")
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
    begin
        //-NPR5.23

        if ContactBusinessRelation.Get(TDCNamesNumbersBuffer."Phone No.", '') then
            exit;

        ContactBusinessRelation.Init;
        ContactBusinessRelation."Contact No." := TDCNamesNumbersBuffer."Phone No.";
        ContactBusinessRelation."Business Relation Code" := '';
        ContactBusinessRelation."Link to Table" := LinkToTable;
        ContactBusinessRelation.Insert;
        //+NPR5.23
    end;

    local procedure CreateVendor(TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary)
    var
        Vendor: Record Vendor;
    begin
        //-NPR5.23

        if Vendor.Get(TDCNamesNumbersBuffer."Phone No.") then
            exit;

        Vendor.Init;
        Vendor."No." := CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Vendor."No."));
        Vendor.Insert(true);
        Vendor.Validate(Name, CopyStr(TDCNamesNumbersBuffer.Name, 1, MaxStrLen(Vendor.Name)));
        Vendor.Validate("Name 2", CopyStr(TDCNamesNumbersBuffer.Name, MaxStrLen(Vendor.Name) + 1, MaxStrLen(Vendor."Name 2")));
        Vendor.Validate(Address, CopyStr(TDCNamesNumbersBuffer.Address, 1, MaxStrLen(Vendor.Address)));
        Vendor.Validate("Address 2", CopyStr(TDCNamesNumbersBuffer.Address, MaxStrLen(Vendor.Address) + 1, MaxStrLen(Vendor."Address 2")));
        Vendor."Post Code" := CopyStr(TDCNamesNumbersBuffer."Post Code", 1, MaxStrLen(Vendor."Post Code"));
        Vendor.City := CopyStr(TDCNamesNumbersBuffer.City, 1, MaxStrLen(Vendor.City));
        Vendor.Validate("E-Mail", CopyStr(TDCNamesNumbersBuffer."E-Mail", 1, MaxStrLen(Vendor."E-Mail")));
        Vendor.Validate("Home Page", CopyStr(TDCNamesNumbersBuffer."Home Page", 1, MaxStrLen(Vendor."Home Page")));
        Vendor.Validate("Phone No.", CopyStr(TDCNamesNumbersBuffer."Phone No.", 1, MaxStrLen(Vendor."Phone No.")));
        Vendor.Modify;
        Commit;


        Vendor.SetRecFilter;
        //-NPR5.38 [301053]
        //IF (PAGE.RUNMODAL(PAGE::"Vendor Card", Vendor ) = ACTION::OK) THEN
        if (PAGE.RunModal(PAGE::"Vendor Card", Vendor) = ACTION::OK) then;
        //+NPR5.38 [301053]
        //+NPR5.23
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure ApplyConfigTemplate(var RecRef: RecordRef; ConfigTemplateHeader: Record "Config. Template Header"; QueryConfirm: Boolean)
    var
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        if ConfigTemplateHeader.Code = '' then
            exit;

        //-NPR5.28 [257461]
        if QueryConfirm and not GuiAllowed then
            exit;
        //+NPR5.28 [257461]

        if QueryConfirm then begin
            if not Confirm(Text000, false, ConfigTemplateHeader.Code) then
                exit;
        end;

        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
    end;

    local procedure InitIComm(): Boolean
    begin
        //-NPR5.26 [252881]
        if not Initialized then begin
            Initialized := true;
            if not IComm.Get then
                exit(false);
        end;

        if not IComm."Use Auto. Cust. Lookup" then
            exit(false);
        if IComm."Number Info Codeunit ID" = 0 then
            exit(false);

        exit(true);
        //+NPR5.26 [252881]
    end;
}

