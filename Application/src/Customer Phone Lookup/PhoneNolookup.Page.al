page 6014412 "NPR Phone No lookup"
{
    // NPR5.41/TS  /20180105 CASE 300893 Change Name of Action LookupPhone to Lookup Phone

    Caption = 'Phone No lookup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Phone Lookup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PhoneNo; PhoneNo)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the PhoneNo field';

                    trigger OnValidate()
                    begin
                        DeleteAll;
                        CheckifExist;
                    end;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Home Page"; "Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Home Page field';
                }
                field(NewContact; NewContact)
                {
                    ApplicationArea = All;
                    Caption = 'Create Contact';
                    ToolTip = 'Specifies the value of the Create Contact field';

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
                field(NewCust; NewCust)
                {
                    ApplicationArea = All;
                    Caption = 'Create Customer';
                    ToolTip = 'Specifies the value of the Create Customer field';

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
                field(NewVendor; NewVendor)
                {
                    ApplicationArea = All;
                    Caption = 'Create Vendor';
                    ToolTip = 'Specifies the value of the Create Vendor field';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F6';
                ApplicationArea = All;
                ToolTip = 'Executes the Lookup Phone action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F3';
                ApplicationArea = All;
                ToolTip = 'Executes the Create action';

                trigger OnAction()
                begin
                    CreateDetails;
                end;
            }
        }
    }

    var
        ID: Code[10];
        PhoneNo: Text[100];
        TDCNamesNumbersBuffer: Record "NPR Phone Lookup Buffer" temporary;
        NewCust: Boolean;
        NewVendor: Boolean;
        NewContact: Boolean;
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Icomm: Record "NPR I-Comm";
        NameandNumberslookup: Codeunit "NPR Phone Lookup";

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
        "Create Vendor" := NewVendor;
        "No. Info Functions" := 'CREATE';

        NameandNumberslookup.Creation(Rec);
    end;

    local procedure RunCodeunit()
    begin
        Icomm.Get;
        CODEUNIT.Run(Icomm."Number Info Codeunit ID", Rec);
    end;

    local procedure CheckifExist()
    var
        Text000: Label 'Contact already exists.';
        Text001: Label 'Vendor already exists.';
        Text002: Label 'Customer already exists.';
    begin
        if NewContact then begin
            if Contact.Get(PhoneNo) then begin
                NewContact := false;
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

    procedure Getrec(var "TDC Names & Numbers Buffer": Record "NPR Phone Lookup Buffer")
    begin
        "TDC Names & Numbers Buffer" := Rec;
    end;

    procedure Setrec(var "TDC Names & Numbers Buffer": Record "NPR Phone Lookup Buffer")
    begin
        Rec := "TDC Names & Numbers Buffer";

        NewContact := "Create Contact";
        NewCust := "Create Customer";
        NewVendor := "Create Vendor";
    end;
}

