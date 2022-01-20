pageextension 6014403 "NPR Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Contact")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {

                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the value of the NPR Kolli field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {

                Editable = false;
                ToolTip = 'Specifies the value of the NPR Delivery Location field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Consignor Label action';
                Image = Print;
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Create Pacsoft Shipment Document action';
                    Image = CreateDocument;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ShipmentDocument: Record "NPR shipping Provider Document";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        ShipmentDocument.AddEntry(RecRef, true);
                    end;
                }
                action("NPR PrintShipmentDocument")
                {
                    Caption = 'Print Shipment Document';

                    ToolTip = 'Executes the Print Shipment Document action';
                    Image = Print;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ShipmondoMgnt: Codeunit "NPR Shipmondo Mgnt.";
                    begin
                        ShipmondoMgnt.PrintShipmentDocument(Rec);
                    end;
                }
            }
        }
    }
}