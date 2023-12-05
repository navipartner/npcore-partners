codeunit 6150844 "NPR EFT Planet PAX Req."
{
    Access = Internal;

    var
        MsgType: Option "EftSettlementEmv","EftData","Cancel";
        EftSettlementType: Option "Sale-Terminal","Refund-Terminal","Sale-Reversal","Refund-Reversal";
        EmvScenarioId: Option "DT","DU";
        Util: Codeunit "NPR EFT Planet PAX Util.";


    procedure PaymentRequest(PaxRec: Record "NPR EFT Planet PAX Config"; Amount: Decimal; Currency: Text; EFTEntryNo: Integer): Text
    var
        Txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
        XmlE: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');

        XmlRequestElement.SetAttribute('Type', Format(MsgType::EftSettlementEmv));
        XmlRequestElement.SetAttribute('SequenceNumber', Format(EFTEntryNo));
        XmlRequestElement.SetAttribute('RequesterTransRefNum', Format(EFTEntryNo));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");

        XmlE := XmlElement.Create('EftSettlementType');
        XmlE.Add(XmlText.Create(Format(EftSettlementType::"Sale-Terminal")));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('Amount');
        XmlE.Add(XmlText.Create(Format(Amount)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvTerminalId');
        XmlE.Add(XmlText.Create(PaxRec."Terminal ID"));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvScenarioId');
        XmlE.Add(XmlText.Create(Format(EmvScenarioId::DT)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('TimeStamp');
        XmlE.Add(XmlText.Create(Util.GenTimeStamp()));
        XmlRequestElement.Add(XmlE);

        Xml.Add(XmlRequestElement);
        Xml.WriteTo(Txt);
        exit(Txt);
    end;

    procedure RefundRequest(PaxRec: Record "NPR EFT Planet PAX Config"; Amount: Decimal; Currency: Text; EFTEntryNo: Integer; Token: Text): Text
    var
        Txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
        XmlE: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');
        XmlRequestElement.SetAttribute('Type', Format(MsgType::EftSettlementEmv));
        XmlRequestElement.SetAttribute('SequenceNumber', Format(EFTEntryNo));
        XmlRequestElement.SetAttribute('RequesterTransRefNum', Format(EFTEntryNo));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");

        XmlE := XmlElement.Create('EftSettlementType');
        XmlE.Add(XmlText.Create(Format(EftSettlementType::"Refund-Terminal")));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('Amount');
        XmlE.Add(XmlText.Create(Format(Amount)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvTerminalId');
        XmlE.Add(XmlText.Create(PaxRec."Terminal ID"));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvScenarioId');
        XmlE.Add(XmlText.Create(Format(EmvScenarioId::DT)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('TimeStamp');
        XmlE.Add(XmlText.Create(Util.GenTimeStamp()));
        XmlRequestElement.Add(XmlE);

        Xml.Add(XmlRequestElement);
        Xml.WriteTo(Txt);
        exit(Txt);
    end;

    procedure PaymentReversalRequest(PaxRec: Record "NPR EFT Planet PAX Config"; EFTEntry: Integer; OldEFTEntry: Integer; OldAmount: Decimal; OldCurrency: Text; Token: Text): Text
    var
        Txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
        XmlE: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');
        XmlRequestElement.SetAttribute('Type', Format(MsgType::EftSettlementEmv));
        XmlRequestElement.SetAttribute('SequenceNumber', Format(EFTEntry));
        XmlRequestElement.SetAttribute('RequesterTransRefNum', Format(OldEFTEntry));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");

        XmlE := XmlElement.Create('EftSettlementType');
        XmlE.Add(XmlText.Create(Format(EftSettlementType::"Sale-Reversal")));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('Amount');
        XmlE.Add(XmlText.Create(Format(OldAmount)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvTerminalId');
        XmlE.Add(XmlText.Create(PaxRec."Terminal ID"));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvScenarioId');
        XmlE.Add(XmlText.Create(Format(EmvScenarioId::DT)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('TimeStamp');
        XmlE.Add(XmlText.Create(Util.GenTimeStamp()));
        XmlRequestElement.Add(XmlE);

        Xml.Add(XmlRequestElement);
        Xml.WriteTo(Txt);
        exit(Txt);
    end;

    procedure RefundReversalRequest(PaxRec: Record "NPR EFT Planet PAX Config"; EFTEntry: Integer; OldEFTEntry: Integer; OldAmount: Decimal; OldCurrency: Text; Token: Text): Text
    var
        txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
        XmlE: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');
        XmlRequestElement.SetAttribute('Type', Format(MsgType::EftSettlementEmv));
        XmlRequestElement.SetAttribute('SequenceNumber', Format(EFTEntry));
        XmlRequestElement.SetAttribute('RequesterTransRefNum', Format(OldEFTEntry));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");

        XmlE := XmlElement.Create('EftSettlementType');
        XmlE.Add(XmlText.Create(Format(EftSettlementType::"Refund-Reversal")));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('Amount');
        XmlE.Add(XmlText.Create(Format(OldAmount)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvTerminalId');
        XmlE.Add(XmlText.Create(PaxRec."Terminal ID"));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('EmvScenarioId');
        XmlE.Add(XmlText.Create(Format(EmvScenarioId::DT)));
        XmlRequestElement.Add(XmlE);

        XmlE := XmlElement.Create('TimeStamp');
        XmlE.Add(XmlText.Create(Util.GenTimeStamp()));
        XmlRequestElement.Add(XmlE);

        Xml.Add(XmlRequestElement);
        Xml.WriteTo(txt);
        exit(txt);
    end;

    procedure LookupRequest(PaxRec: Record "NPR EFT Planet PAX Config"; EFTEntry: Integer; ProcessedEFTEntry: Integer): Text
    var
        Txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');
        XmlRequestElement.SetAttribute('Type', Format(MsgType::EftData));
        XmlRequestElement.SetAttribute('SequenceNumber', Format(EFTEntry));
        XmlRequestElement.SetAttribute('RequesterTransRefNum', Format(ProcessedEFTEntry));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");
        Xml.Add(XmlRequestElement);
        Xml.WriteTo(Txt);
        exit(Txt);
    end;

    procedure CancelRequest(PaxRec: Record "NPR EFT Planet PAX Config"; EFTEntry: Integer; AbortCount: Integer): Text
    var
        Txt: Text;
        Xml: XmlDocument;
        XmlRequestElement: XmlElement;
        XmlE: XmlElement;
    begin
        Xml := XmlDocument.Create();
        Xml.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlRequestElement := XmlElement.Create('Request');
        XmlRequestElement.SetAttribute('Type', Format(MsgType::Cancel));
        XmlRequestElement.SetAttribute('SequenceNumber', Util.AbortId(EFTEntry, AbortCount));
        XmlRequestElement.SetAttribute('RequesterLocationId', PaxRec."Location ID");
        XmlRequestElement.SetAttribute('SequenceNumberToCancel', Format(EFTEntry));

        XmlE := XmlElement.Create('TimeStamp');
        XmlE.Add(XmlText.Create(Util.GenTimeStamp()));
        XmlRequestElement.Add(XmlE);

        Xml.Add(XmlRequestElement);
        Xml.WriteTo(Txt);
        exit(Txt);
    end;
}