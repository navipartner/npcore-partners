codeunit 6059823 "NPR TransferOrder-Post + Print"
{
    Access = Internal;
    TableNo = "Transfer Header";

    trigger OnRun()
    begin
        TransHeader.Copy(Rec);
        Code();
        Rec := TransHeader;
    end;

    var
        TransHeader: Record "Transfer Header";
        TransferRecHdr: Record "Transfer Shipment Header";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        POSFlagG: Boolean;
        ShipReceiveLbl: Label '&Ship,&Receive';
        TemplateName: Text[20];

    local procedure "Code"()
    var
        TransLine: Record "Transfer Line";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        DefaultNumber: Integer;
        Selection: Option " ",Shipment,Receipt;
    begin
        TransLine.SetRange("Document No.", TransHeader."No.");
        if TransLine.Find('-') then
            repeat
                if (TransLine."Quantity Shipped" < TransLine.Quantity) and
                   (DefaultNumber = 0)
                then
                    DefaultNumber := Selection::Shipment;
                if (TransLine."Quantity Received" < TransLine.Quantity) and
                   (DefaultNumber = 0)
                then
                    DefaultNumber := Selection::Receipt;
            until (TransLine.Next() = 0) or (DefaultNumber > 0);
        if TransHeader."Direct Transfer" then begin
            TransferPostShipment.Run(TransHeader);
            TransferPostReceipt.Run(TransHeader);
            PrintReport(TransHeader, Selection::Receipt);
        end else begin
            if DefaultNumber = 0 then
                DefaultNumber := Selection::Shipment;
            Selection := StrMenu(ShipReceiveLbl, DefaultNumber);
            case Selection of
                0:
                    exit;
                Selection::Shipment:
                    begin
                        TransferPostShipment.Run(TransHeader);
                        TransferRecHdr.Reset();
                        if TransferRecHdr.FindLast() then
                            if TemplateName <> '' then
                                TemplateMgt.PrintTemplate(TemplateName, TransferRecHdr, 0)
                    end;
                Selection::Receipt:
                    TransferPostReceipt.Run(TransHeader);
            end;
        end;
    end;

    procedure PrintReport(TransHeaderSource: Record "Transfer Header"; Selection: Option " ",Shipment,Receipt)
    begin
        case Selection of
            Selection::Shipment:
                PrintShipment(TransHeaderSource."Last Shipment No.");
            Selection::Receipt:
                PrintReceipt(TransHeaderSource."Last Receipt No.");
        end;
    end;

    local procedure PrintShipment(DocNo: Code[20])
    var
        TransShptHeader: Record "Transfer Shipment Header";
    begin
        if TransShptHeader.Get(DocNo) then begin
            TransShptHeader.SetRecFilter();
            TransShptHeader.PrintRecords(false);
        end;
    end;

    local procedure PrintReceipt(DocNo: Code[20])
    var
        TransRcptHeader: Record "Transfer Receipt Header";
    begin
        if TransRcptHeader.Get(DocNo) then begin
            TransRcptHeader.SetRecFilter();
            TransRcptHeader.PrintRecords(false);
        end;
    end;

    procedure SetParameter(Template: Text[20]; Rec: Record "Transfer Header")
    begin
        TemplateName := Template;
    end;

    procedure SetValues(POSFlag: Boolean)
    begin
        POSFlagG := POSFlag;
    end;

    procedure GetValues(): Boolean
    begin
        exit(POSFlagG);
    end;
}

