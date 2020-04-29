page 6014486 "Pacsoft Shipment Document"
{
    // PS1.00/LS/20140509  CASE 190533 Pacsoft module Creation of Page
    // PS1.02/RA/20150121  CASE 190533 Added field "Document Source" and "Document Name"
    // NPR5.29/BHR/20161209 CASE 258936 Set field None Editable
    // NPR5.43/BHR/20180508 CASE 304453 Added Return label fields
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Pacsoft Shipment Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = "Pacsoft Shipment Document";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                }
                field("Receiver ID";"Receiver ID")
                {
                    Editable = false;
                }
                field(Name;Name)
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field(County;County)
                {
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field(Contact;Contact)
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("Fax No.";"Fax No.")
                {
                }
                field("VAT Registration No.";"VAT Registration No.")
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("SMS No.";"SMS No.")
                {
                }
                field(Reference;Reference)
                {
                }
                field("Free Text";"Free Text")
                {
                }
                field("Shipment Date";"Shipment Date")
                {
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Package Code";"Package Code")
                {
                }
                field("Parcel Qty.";"Parcel Qty.")
                {

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Parcel Weight";"Parcel Weight")
                {

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field(TotalWeight;"Total Weight")
                {
                    Editable = TotalWeightEditable;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Print Return Label";"Print Return Label")
                {
                }
                field("Return Shipping Agent Code";"Return Shipping Agent Code")
                {
                }
                field(Undeliverable;Undeliverable)
                {
                }
                field("Send Link To Print";"Send Link To Print")
                {
                }
                field("Request XML";"Request XML")
                {
                    Editable = false;
                }
                field("Request XML Name";"Request XML Name")
                {
                    Editable = false;
                }
                field("Delivery Location";"Delivery Location")
                {
                }
                field("Ship-to Name";"Ship-to Name")
                {
                }
                field("Ship-to Address";"Ship-to Address")
                {
                }
                field("Ship-to Address 2";"Ship-to Address 2")
                {
                }
                field("Ship-to Post Code";"Ship-to Post Code")
                {
                }
                field("Ship-to City";"Ship-to City")
                {
                }
                field("Ship-to County";"Ship-to County")
                {
                }
                field("Ship-to Country/Region Code";"Ship-to Country/Region Code")
                {
                }
                field(Marking;Marking)
                {
                }
                field(Volume;Volume)
                {
                }
                field(Contents;Contents)
                {
                }
                field("Return Label Both";"Return Label Both")
                {
                }
                field("Return Label";"Return Label")
                {
                }
            }
            group("Customs Documentation")
            {
                field("Customs Document";"Customs Document")
                {
                }
                field("Customs Currency";"Customs Currency")
                {
                }
                field("Sender VAT Reg. No";"Sender VAT Reg. No")
                {
                }
                part(Control6150661;"Pacsoft Customs Item Rows")
                {
                    SubPageLink = "Shipment Document Entry No."=FIELD("Entry No.");
                    SubPageView = SORTING("Shipment Document Entry No.","Entry No.");
                }
            }
            group(Control6150659)
            {
                ShowCaption = false;
                part(Control6150660;"Pacsoft Shipment Doc. Services")
                {
                    SubPageLink = "Entry No."=FIELD("Entry No."),
                                  "Shipping Agent Code"=FIELD("Shipping Agent Code");
                    SubPageView = SORTING("Entry No.","Shipping Agent Code","Shipping Agent Service Code");
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Ok)
            {
                Caption = '&OK';
                Image = Approve;

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "Pacsoft Management";
                begin
                    if PacsoftMgt.CheckDocument(Rec) then begin
                      OKButtonPressed := true;
                      CurrPage.Close;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ValidateWeights(false);
    end;

    trigger OnOpenPage()
    begin
        OKButtonPressed := false;
    end;

    var
        OKButtonPressed: Boolean;
        [InDataSet]
        TotalWeightEditable: Boolean;

    procedure OKButtonWasPressed(): Boolean
    begin
        exit(OKButtonPressed);
    end;

    procedure ValidateWeights(Update: Boolean)
    begin
        TotalWeightEditable := ("Parcel Qty." > 1);
        if Update then
          CurrPage.Update(true);
    end;
}

