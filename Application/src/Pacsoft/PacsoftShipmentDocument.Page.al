page 6014486 "NPR Pacsoft Shipment Document"
{

    Caption = 'Pacsoft Shipment Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pacsoft Shipment Document";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Receiver ID"; Rec."Receiver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Receiver ID field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Fax No."; Rec."Fax No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fax No. field';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("SMS No."; Rec."SMS No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS No. field';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Free Text"; Rec."Free Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Free Text field';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Package Code"; Rec."Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Code field';
                }
                field("Parcel Qty."; Rec."Parcel Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parcel Qty. field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Parcel Weight"; Rec."Parcel Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parcel Weight field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field(TotalWeight; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    Editable = TotalWeightEditable;
                    ToolTip = 'Specifies the value of the Total Weight field';

                    trigger OnValidate()
                    begin
                        ValidateWeights(true);
                    end;
                }
                field("Print Return Label"; Rec."Print Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Return Label field';
                }
                field("Return Shipping Agent Code"; Rec."Return Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Shipping Agent Code field';
                }
                field(Undeliverable; Rec.Undeliverable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the If Nondeliverable field';
                }
                field("Send Link To Print"; Rec."Send Link To Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Link To Print field';
                }
                field("Request XML Name"; Rec."Request XML Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Name field';
                }
                field("Delivery Location"; Rec."Delivery Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Location field';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to County field';
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                }
                field(Marking; Rec.Marking)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Marking field';
                }
                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Volume field';
                }
                field(Contents; Rec.Contents)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contents field';
                }
                field("Return Label Both"; Rec."Return Label Both")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Label Both field';
                }
                field("Return Label"; Rec."Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Label field';
                }
            }
            group("Customs Documentation")
            {
                field("Customs Document"; Rec."Customs Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Document field';
                }
                field("Customs Currency"; Rec."Customs Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Currency field';
                }
                field("Sender VAT Reg. No"; Rec."Sender VAT Reg. No")
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

