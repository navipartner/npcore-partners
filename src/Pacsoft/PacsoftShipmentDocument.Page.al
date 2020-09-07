page 6014486 "NPR Pacsoft Shipment Document"
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
    SourceTable = "NPR Pacsoft Shipment Document";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Receiver ID"; "Receiver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Fax No."; "Fax No.")
                {
                    ApplicationArea = All;
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                }
                field("SMS No."; "SMS No.")
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Free Text"; "Free Text")
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Package Code"; "Package Code")
                {
                    ApplicationArea = All;
                }
                field("Parcel Qty."; "Parcel Qty.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Parcel Weight"; "Parcel Weight")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field(TotalWeight; "Total Weight")
                {
                    ApplicationArea = All;
                    Editable = TotalWeightEditable;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Print Return Label"; "Print Return Label")
                {
                    ApplicationArea = All;
                }
                field("Return Shipping Agent Code"; "Return Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field(Undeliverable; Undeliverable)
                {
                    ApplicationArea = All;
                }
                field("Send Link To Print"; "Send Link To Print")
                {
                    ApplicationArea = All;
                }
                field("Request XML"; "Request XML")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Request XML Name"; "Request XML Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(Marking; Marking)
                {
                    ApplicationArea = All;
                }
                field(Volume; Volume)
                {
                    ApplicationArea = All;
                }
                field(Contents; Contents)
                {
                    ApplicationArea = All;
                }
                field("Return Label Both"; "Return Label Both")
                {
                    ApplicationArea = All;
                }
                field("Return Label"; "Return Label")
                {
                    ApplicationArea = All;
                }
            }
            group("Customs Documentation")
            {
                field("Customs Document"; "Customs Document")
                {
                    ApplicationArea = All;
                }
                field("Customs Currency"; "Customs Currency")
                {
                    ApplicationArea = All;
                }
                field("Sender VAT Reg. No"; "Sender VAT Reg. No")
                {
                    ApplicationArea = All;
                }
                part(Control6150661; "NPR Pacsoft Customs Item Rows")
                {
                    SubPageLink = "Shipment Document Entry No." = FIELD("Entry No.");
                    SubPageView = SORTING("Shipment Document Entry No.", "Entry No.");
                    ApplicationArea=All;
                }
            }
            group(Control6150659)
            {
                ShowCaption = false;
                part(Control6150660; "NPR Pacsoft Shipm. Doc. Serv.")
                {
                    SubPageLink = "Entry No." = FIELD("Entry No."),
                                  "Shipping Agent Code" = FIELD("Shipping Agent Code");
                    SubPageView = SORTING("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
                    ApplicationArea=All;
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "NPR Pacsoft Management";
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

