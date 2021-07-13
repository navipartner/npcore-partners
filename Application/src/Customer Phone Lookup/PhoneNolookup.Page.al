page 6014412 "NPR Phone No lookup"
{
    Caption = 'Phone No lookup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Phone Lookup Buffer";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PhoneNo; PhoneNo)
                {

                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the PhoneNo field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.DeleteAll();
                        CheckifExist();
                    end;
                }
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Home Page"; Rec."Home Page")
                {

                    ToolTip = 'Specifies the value of the Home Page field';
                    ApplicationArea = NPRRetail;
                }
                field(NewContact; NewContact)
                {

                    Caption = 'Create Contact';
                    ToolTip = 'Specifies the value of the Create Contact field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        if Contact.Get(PhoneNo) then
                            PAGE.RunModal(PAGE::"Contact Card", Contact);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist();
                    end;
                }
                field(NewCust; NewCust)
                {

                    Caption = 'Create Customer';
                    ToolTip = 'Specifies the value of the Create Customer field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        if Customer.Get(PhoneNo) then
                            PAGE.RunModal(PAGE::"Customer Card", Customer);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist();
                    end;
                }
                field(NewVendor; NewVendor)
                {

                    Caption = 'Create Vendor';
                    ToolTip = 'Specifies the value of the Create Vendor field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        if Vendor.Get(PhoneNo) then
                            PAGE.RunModal(PAGE::"Vendor Card", Vendor);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Lookup Phone")
            {
                Caption = 'Lookup Phone';
                Image = GetEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F6';

                ToolTip = 'Executes the Lookup Phone action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    LookupPhone();
                end;
            }
            action(Create)
            {
                Caption = 'Create';
                Image = New;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F3';

                ToolTip = 'Executes the Create action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    CreateDetails();
                end;
            }
        }
    }

    var
        PhoneNo: Text[100];
        NewCust: Boolean;
        NewVendor: Boolean;
        NewContact: Boolean;
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Icomm: Record "NPR I-Comm";
        NameandNumberslookup: Codeunit "NPR Phone Lookup";

    local procedure Initialize()
    var
        LookupLbl: Label 'LOOKUPPHONE', Locked = true;
    begin
        Rec.DeleteAll();
        Rec."Phone No." := PhoneNo;
        Rec."No. Info Functions" := LookupLbl;
    end;

    local procedure LookupPhone()
    begin
        Initialize();
        RunCodeunit();
    end;

    local procedure CreateDetails()
    var
        CreateLbl: Label 'CREATE', Locked = true;
    begin
        Rec."Create Contact" := NewContact;
        Rec."Create Customer" := NewCust;
        Rec."Create Vendor" := NewVendor;
        Rec."No. Info Functions" := CreateLbl;

        NameandNumberslookup.Creation(Rec);
    end;

    local procedure RunCodeunit()
    begin
        Icomm.Get();
        CODEUNIT.Run(Icomm."Number Info Codeunit ID", Rec);
    end;

    local procedure CheckifExist()
    var
        ContactExistMsg: Label 'Contact already exists.';
        VendorExistMsg: Label 'Vendor already exists.';
        CustomerExistMsg: Label 'Customer already exists.';
    begin
        if NewContact then begin
            if Contact.Get(PhoneNo) then begin
                NewContact := false;
                Message(ContactExistMsg);
            end;
        end;

        if NewCust then begin
            if Customer.Get(PhoneNo) then begin
                NewCust := false;
                Message(CustomerExistMsg);
            end;
        end;

        if NewVendor then begin
            if Vendor.Get(PhoneNo) then begin
                NewVendor := false;
                Message(VendorExistMsg);
            end;
        end;
        CurrPage.Update();
    end;

    procedure Getrec(var "TDC Names & Numbers Buffer": Record "NPR Phone Lookup Buffer")
    begin
        "TDC Names & Numbers Buffer" := Rec;
    end;

    procedure Setrec(var "TDC Names & Numbers Buffer": Record "NPR Phone Lookup Buffer")
    begin
        Rec := "TDC Names & Numbers Buffer";

        NewContact := Rec."Create Contact";
        NewCust := Rec."Create Customer";
        NewVendor := Rec."Create Vendor";
    end;
}

