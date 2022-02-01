pageextension 6014403 "NPR Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the additinal name of the customer that will appear on the new sales document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the additional name of the customer that you shipped the items on the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Contact")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {

                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the number of packages';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {

                Editable = false;
                ToolTip = 'Specifies where items from the document are shipped to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the additinal name of the customer that the invoice was sent to.';
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

                ToolTip = 'Prints Consignor Label.';
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

                    ToolTip = 'Enable creation of the Pacsoft Shipment document.';
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

                    ToolTip = 'View and print shipment document for the sale shipment.';
                    Image = Print;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ShippingProviderSetup: record "NPR Shipping Provider Setup";
                    begin
                        if ShippingProviderSetup.Get() then
                            PrintShipmentDocument(ShippingProviderSetup."Shipping Provider");
                    end;
                }
            }
        }
    }
    local procedure PrintShipmentDocument(IShippingProvider: Interface "NPR IShipping Provider Interface")
    begin
        IShippingProvider.PrintShipmentDocument(Rec);
    end;
}