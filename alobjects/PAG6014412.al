page 6014412 "Phone No lookup"
{
    // NPR5.41/TS  /20180105 CASE 300893 Change Name of Action LookupPhone to Lookup Phone

    Caption = 'Phone No lookup';
    PageType = Card;
    SourceTable = "Phone Lookup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PhoneNo;PhoneNo)
                {
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        DeleteAll;
                        CheckifExist;
                    end;
                }
                field(ID;ID)
                {
                }
                field(Name;Name)
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field(Address;Address)
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("Home Page";"Home Page")
                {
                }
                field(NewContact;NewContact)
                {
                    Caption = 'Create Contact';

                    trigger OnDrillDown()
                    begin
                        if Contact.Get(PhoneNo) then
                         PAGE.RunModal(PAGE::"Contact Card", Contact);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist;
                    end;
                }
                field(NewCust;NewCust)
                {
                    Caption = 'Create Customer';

                    trigger OnDrillDown()
                    begin
                        if Customer.Get(PhoneNo) then
                         PAGE.RunModal(PAGE::"Customer Card", Customer);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist;
                    end;
                }
                field(NewVendor;NewVendor)
                {
                    Caption = 'Create Vendor';

                    trigger OnDrillDown()
                    begin
                        if Vendor.Get(PhoneNo) then
                         PAGE.RunModal(PAGE::"Vendor Card", Vendor);
                    end;

                    trigger OnValidate()
                    begin
                        CheckifExist;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F6';

                trigger OnAction()
                begin
                    LookupPhone;
                end;
            }
            action(Create)
            {
                Caption = 'Create';
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F3';

                trigger OnAction()
                begin
                    CreateDetails ;
                end;
            }
        }
    }

    var
        ID: Code[10];
        PhoneNo: Text[100];
        TDCNamesNumbersBuffer: Record "Phone Lookup Buffer" temporary;
        NewCust: Boolean;
        NewVendor: Boolean;
        NewContact: Boolean;
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Icomm: Record "I-Comm";
        NameandNumberslookup: Codeunit "Phone Lookup";

    local procedure Initialize()
    begin
        DeleteAll;
        "Phone No." := PhoneNo;
        "No. Info Functions" := 'LOOKUPPHONE';
    end;

    local procedure LookupPhone()
    begin
        Initialize;
        RunCodeunit;
    end;

    local procedure CreateDetails()
    begin
        "Create Contact" := NewContact;
        "Create Customer" := NewCust;
        "Create Vendor" :=  NewVendor ;
        "No. Info Functions" := 'CREATE';

        NameandNumberslookup.Creation(Rec);
    end;

    local procedure RunCodeunit()
    begin
        Icomm.Get;
        CODEUNIT.Run(Icomm."Number Info Codeunit ID",Rec);
    end;

    local procedure CheckifExist()
    var
        Text000: Label 'Contact already exists.';
        Text001: Label 'Vendor already exists.';
        Text002: Label 'Customer already exists.';
    begin
        if NewContact then begin
          if Contact.Get(PhoneNo) then begin
            NewContact:= false;
            Message(Text000);
          end;
        end;

        if NewCust then begin
         if Customer.Get(PhoneNo) then begin
          NewCust := false;
          Message(Text002);
          end;
        end;

        if NewVendor then begin
         if Vendor.Get(PhoneNo) then begin
          NewVendor := false;
          Message(Text001);
          end;
        end;
        CurrPage.Update;
    end;

    procedure Getrec(var "TDC Names & Numbers Buffer": Record "Phone Lookup Buffer")
    begin
        "TDC Names & Numbers Buffer" := Rec;
    end;

    procedure Setrec(var "TDC Names & Numbers Buffer": Record "Phone Lookup Buffer")
    begin
        Rec := "TDC Names & Numbers Buffer" ;

        NewContact := "Create Contact" ;
        NewCust := "Create Customer";
        NewVendor :="Create Vendor" ;
    end;
}

