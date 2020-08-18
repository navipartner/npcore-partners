codeunit 6059823 "NPR TransferOrder-Post + Print"
{
    // NPR5.55/YAHA/20191127 CASE 362312 Codeunit created and added Functionality to use template for printing

    TableNo = "Transfer Header";

    trigger OnRun()
    begin
        TransHeader.Copy(Rec);
        Code;
        Rec := TransHeader;
    end;

    var
        Text000: Label '&Ship,&Receive';
        TransHeader: Record "Transfer Header";
        TemplateName: Text;
        TemplateMgt: Codeunit "RP Template Mgt.";
        TransferRecHdr: Record "Transfer Shipment Header";
        POSFlagG: Boolean;

    local procedure "Code"()
    var
        TransLine: Record "Transfer Line";
        DefaultNumber: Integer;
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        Selection: Option " ",Shipment,Receipt;
    begin
        with TransHeader do begin
          TransLine.SetRange("Document No.","No.");
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
            until (TransLine.Next = 0) or (DefaultNumber > 0);
            if "Direct Transfer" then begin
              TransferPostShipment.Run(TransHeader);
              TransferPostReceipt.Run(TransHeader);
              PrintReport(TransHeader,Selection::Receipt);
            end else begin
              if DefaultNumber = 0 then
                DefaultNumber := Selection::Shipment;
              Selection := StrMenu(Text000,DefaultNumber);
              case Selection of
                0:
                  exit;
                //-NPR5.55 [362312]
                //Selection::Shipment:
                Selection::Shipment: begin
                  TransferPostShipment.Run(TransHeader);
                  TransferRecHdr.Reset;
                   if TransferRecHdr.FindLast then
                    if TemplateName <> '' then
                      TemplateMgt.PrintTemplate(TemplateName, TransferRecHdr, 0)
                end;
              //+NPR5.55 [362312]
              Selection::Receipt:
                TransferPostReceipt.Run(TransHeader);
            end;
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure PrintReport(TransHeaderSource: Record "Transfer Header";Selection: Option " ",Shipment,Receipt)
    begin
        with TransHeaderSource do
          case Selection of
            Selection::Shipment:
              PrintShipment("Last Shipment No.");
            Selection::Receipt:
              PrintReceipt("Last Receipt No.");
          end;
    end;

    local procedure PrintShipment(DocNo: Code[20])
    var
        TransShptHeader: Record "Transfer Shipment Header";
    begin
        if TransShptHeader.Get(DocNo) then begin
          TransShptHeader.SetRecFilter;
          TransShptHeader.PrintRecords(false);
        end;
    end;

    local procedure PrintReceipt(DocNo: Code[20])
    var
        TransRcptHeader: Record "Transfer Receipt Header";
    begin
        if TransRcptHeader.Get(DocNo) then begin
          TransRcptHeader.SetRecFilter;
          TransRcptHeader.PrintRecords(false);
        end;
    end;

    procedure SetParameter(Template: Text;Rec: Record "Transfer Header")
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

