page 6014486 "NPR Pacsoft Shipment Document"
{

    Caption = 'Pacsoft Shipment Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Pacsoft Shipment Document";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Receiver ID"; Rec."Receiver ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Receiver ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Address 2"; Rec."Address 2")
                {

                    ToolTip = 'Specifies the value of the Address 2 field';
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
                field(County; Rec.County)
                {

                    ToolTip = 'Specifies the value of the County field';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Contact; Rec.Contact)
                {

                    ToolTip = 'Specifies the value of the Contact field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Fax No."; Rec."Fax No.")
                {

                    ToolTip = 'Specifies the value of the Fax No. field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {

                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS No."; Rec."SMS No.")
                {

                    ToolTip = 'Specifies the value of the SMS No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Reference; Rec.Reference)
                {

                    ToolTip = 'Specifies the value of the Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Free Text"; Rec."Free Text")
                {

                    ToolTip = 'Specifies the value of the Free Text field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {

                    ToolTip = 'Specifies the value of the Shipment Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Method Code"; Rec."Shipping Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Code"; Rec."Package Code")
                {

                    ToolTip = 'Specifies the value of the Package Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Parcel Qty."; Rec."Parcel Qty.")
                {

                    ToolTip = 'Specifies the value of the Parcel Qty. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Parcel Weight"; Rec."Parcel Weight")
                {

                    ToolTip = 'Specifies the value of the Parcel Weight field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field(TotalWeight; Rec."Total Weight")
                {

                    Editable = TotalWeightEditable;
                    ToolTip = 'Specifies the value of the Total Weight field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Print Return Label"; Rec."Print Return Label")
                {

                    ToolTip = 'Specifies the value of the Print Return Label field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Shipping Agent Code"; Rec."Return Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Return Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Undeliverable; Rec.Undeliverable)
                {

                    ToolTip = 'Specifies the value of the If Nondeliverable field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Link To Print"; Rec."Send Link To Print")
                {

                    ToolTip = 'Specifies the value of the Send Link To Print field';
                    ApplicationArea = NPRRetail;
                }
                field("Request XML Name"; Rec."Request XML Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Location"; Rec."Delivery Location")
                {

                    ToolTip = 'Specifies the value of the Delivery Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {

                    ToolTip = 'Specifies the value of the Ship-to Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {

                    ToolTip = 'Specifies the value of the Ship-to Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {

                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {

                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {

                    ToolTip = 'Specifies the value of the Ship-to City field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {

                    ToolTip = 'Specifies the value of the Ship-to County field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Marking; Rec.Marking)
                {

                    ToolTip = 'Specifies the value of the Marking field';
                    ApplicationArea = NPRRetail;
                }
                field(Volume; Rec.Volume)
                {

                    ToolTip = 'Specifies the value of the Volume field';
                    ApplicationArea = NPRRetail;
                }
                field(Contents; Rec.Contents)
                {

                    ToolTip = 'Specifies the value of the Contents field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Label Both"; Rec."Return Label Both")
                {

                    ToolTip = 'Specifies the value of the Return Label Both field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Label"; Rec."Return Label")
                {

                    ToolTip = 'Specifies the value of the Return Label field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Customs Documentation")
            {
                field("Customs Document"; Rec."Customs Document")
                {

                    ToolTip = 'Specifies the value of the Customs Document field';
                    ApplicationArea = NPRRetail;
                }
                field("Customs Currency"; Rec."Customs Currency")
                {

                    ToolTip = 'Specifies the value of the Customs Currency field';
                    ApplicationArea = NPRRetail;
                }
                field("Sender VAT Reg. No"; Rec."Sender VAT Reg. No")
                {

                    ToolTip = 'Specifies the value of the Sender VAT Reg. No field';
                    ApplicationArea = NPRRetail;
                }
                part(Control6150661; "NPR Pacsoft Customs Item Rows")
                {
                    SubPageLink = "Shipment Document Entry No." = FIELD("Entry No.");
                    SubPageView = SORTING("Shipment Document Entry No.", "Entry No.");
                    ApplicationArea = NPRRetail;

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
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the &OK action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "NPR Pacsoft Management";
                begin
                    if PacsoftMgt.CheckDocument(Rec) then begin
                        OKButtonPressed := true;
                        CurrPage.Close();
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
        TotalWeightEditable := (Rec."Parcel Qty." > 1);
        if Update then
            CurrPage.Update(true);
    end;
}

