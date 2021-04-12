xmlport 6014485 "NPR Pacsoft Response"
{
    // PS1.00/BHR/20140714  Updated Version List.
    // PS1.01/RA/20160809  CASE 228449 Changed Encoding to UTF-8

    Caption = 'Pacsoft Response';
    Direction = Import;
    Encoding = UTF8;

    schema
    {
        tableelement(tempshipmentdocument; "NPR Pacsoft Shipment Document")
        {
            XmlName = 'response';
            SourceTableView = SORTING("Entry No.");
            UseTemporary = true;
            textelement(value)
            {
                XmlName = 'val';
                textattribute(attribute)
                {
                    XmlName = 'n';
                }

                trigger OnAfterAssignVariable()
                begin
                    case Attribute of
                        'session':
                            ShipmentDocument.Session := CopyStr(Value, 1, MaxStrLen(ShipmentDocument.Session));
                        'status':
                            ShipmentDocument.Status := CopyStr(Value, 1, MaxStrLen(ShipmentDocument.Status));
                        'message':
                            ShipmentDocument."Return Message" := CopyStr(Value, 1, MaxStrLen(ShipmentDocument."Return Message"));
                    end;
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Pacsoft Response';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        ShipmentDocument.Modify();
    end;

    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";

    procedure SetShipmentDocument(pShipmentDocument: Record "NPR Pacsoft Shipment Document")
    begin
        ShipmentDocument := pShipmentDocument;
    end;

    procedure GetShipmentDocument(var pShipmentDocument: Record "NPR Pacsoft Shipment Document")
    begin
        pShipmentDocument := ShipmentDocument;
    end;
}

