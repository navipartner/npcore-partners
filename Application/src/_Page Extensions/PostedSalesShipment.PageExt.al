pageextension 6014403 "NPR Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
            }
        }
        addafter("Ship-to Contact")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the value of the NPR Kolli field';
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Delivery Location field';
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ApplicationArea = All;
                ToolTip = 'Executes the Consignor Label action';
                Image = Print;

                trigger OnAction()
                var
                    ConsignorEntry: Record "NPR Consignor Entry";
                begin
                    ConsignorEntry.InsertFromShipmentHeader(Rec."No.");
                end;
            }
            group("NPR Pacsoft")
            {
                Caption = 'Pacsoft';
                action("NPR CreatePacsoftDocument")
                {
                    Caption = 'Create Pacsoft Shipment Document';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Pacsoft Shipment Document action';
                    Image = CreateDocument;

                    trigger OnAction()
                    var
                        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        ShipmentDocument.AddEntry(RecRef, true);
                    end;
                }
                action("NPR PrintShipmentDocument")
                {
                    Caption = 'Print Shipment Document';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Shipment Document action';
                    Image = Print;
                }
            }
        }
    }
}