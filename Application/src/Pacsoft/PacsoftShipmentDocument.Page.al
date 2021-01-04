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
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Receiver ID"; "Receiver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receiver ID field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
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
                field(County; County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Fax No."; "Fax No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fax No. field';
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("SMS No."; "SMS No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS No. field';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Free Text"; "Free Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Free Text field';
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Package Code"; "Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Code field';
                }
                field("Parcel Qty."; "Parcel Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parcel Qty. field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Parcel Weight"; "Parcel Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parcel Weight field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field(TotalWeight; "Total Weight")
                {
                    ApplicationArea = All;
                    Editable = TotalWeightEditable;
                    ToolTip = 'Specifies the value of the Total Weight field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Print Return Label"; "Print Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Return Label field';
                }
                field("Return Shipping Agent Code"; "Return Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Shipping Agent Code field';
                }
                field(Undeliverable; Undeliverable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the If Nondeliverable field';
                }
                field("Send Link To Print"; "Send Link To Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Link To Print field';
                }
                field("Request XML"; "Request XML")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Source field';
                }
                field("Request XML Name"; "Request XML Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Name field';
                }
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Location field';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to County field';
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                }
                field(Marking; Marking)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Marking field';
                }
                field(Volume; Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Volume field';
                }
                field(Contents; Contents)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contents field';
                }
                field("Return Label Both"; "Return Label Both")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Label Both field';
                }
                field("Return Label"; "Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Label field';
                }
            }
            group("Customs Documentation")
            {
                field("Customs Document"; "Customs Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Document field';
                }
                field("Customs Currency"; "Customs Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Currency field';
                }
                field("Sender VAT Reg. No"; "Sender VAT Reg. No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender VAT Reg. No field';
                }
                part(Control6150661; "NPR Pacsoft Customs Item Rows")
                {
                    SubPageLink = "Shipment Document Entry No." = FIELD("Entry No.");
                    SubPageView = SORTING("Shipment Document Entry No.", "Entry No.");
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the &OK action';

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

