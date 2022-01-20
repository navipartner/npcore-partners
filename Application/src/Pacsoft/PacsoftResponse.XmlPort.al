xmlport 6014485 "NPR Pacsoft Response"
{
    Caption = 'Pacsoft Response';
    Direction = Import;
    Encoding = UTF8;

    schema
    {
        tableelement(tempshipmentdocument; "NPR Shipping Provider Document")
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
        ShipmentDocument: Record "NPR Shipping Provider Document";

    procedure SetShipmentDocument(pShipmentDocument: Record "NPR Shipping Provider Document")
    begin
        ShipmentDocument := pShipmentDocument;
    end;

    procedure GetShipmentDocument(var pShipmentDocument: Record "NPR Shipping Provider Document")
    begin
        pShipmentDocument := ShipmentDocument;
    end;
}

