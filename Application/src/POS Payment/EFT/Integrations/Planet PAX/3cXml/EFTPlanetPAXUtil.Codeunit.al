codeunit 6150949 "NPR EFT Planet PAX Util."
{
    Access = Internal;
    procedure BigTextToText(bigTxt: BigText): Text
    var
        res: Text;
    begin
        res := '';
        bigTxt.GetSubText(res, 1, bigTxt.Length());
        exit(res);
    end;

    procedure GenTimeStamp(): Text
    begin
        exit(Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'));
    end;


    [TryFunction]
    procedure SelectSingleElement(xml: XmlDocument; XPath: Text; var element: XmlElement)
    var
        node: XmlNode;
    begin
        if (xml.SelectSingleNode(XPath, node)) then
            element := node.AsXmlElement();
    end;

    [TryFunction]
    procedure GetTextValue(xml: XmlDocument; XPath: Text; var val: Text)
    var
        node: XmlNode;
    begin
        val := '';
        if (xml.SelectSingleNode(XPath, node)) then begin
            if (node.IsXmlAttribute()) then
                val := node.AsXmlAttribute().Value();
            if (node.IsXmlElement()) then
                val := node.AsXmlElement().InnerText();
        end;
    end;

    procedure GetXmlNodeTxtValueOrDefault(xml: XmlDocument; XPath: Text; Default: Text): Text
    var
        value: Text;
    begin
        if (not GetTextValue(xml, XPath, value)) then
            exit(Default)
        else
            exit(value)
    end;

    procedure GetXmlNodeTxtValueOrDefault(xml: XmlDocument; XPath: Text; Default: Text; MaxLength: Integer): Text
    var
        value: Text;
    begin
        if (GetTextValue(xml, XPath, value)) then begin
            if (StrLen(value) < MaxLength) then
                exit(CopyStr(value, 1, StrLen(value)))
            else
                exit(CopyStr(value, 1, MaxLength))
        end;
        exit(Default);
    end;

    procedure GetXmlNodeTxtValueOrDefault(xml: XmlDocument; XPath: Text; Default: Decimal): Decimal
    var
        value: Text;
        deci: Decimal;
    begin
        if (not GetTextValue(xml, XPath, value)) then begin
            exit(Default);
        end else begin
            if (Evaluate(deci, value, 9)) then
                exit(deci)
            else
                exit(Default);
        end;
    end;

    procedure GetXmlNodeTxtValueOrDefault(xml: XmlDocument; XPath: Text; Default: Boolean): Boolean
    var
        value: Text;
        bool: Boolean;
    begin
        if (not GetTextValue(xml, XPath, value)) then begin
            exit(Default);
        end else begin
            if (Evaluate(bool, value)) then
                exit(bool)
            else
                exit(Default);
        end;
    end;

    procedure AbortId(EftEntryNo: Integer; AbortCount: Integer): Text
    begin
        exit(Format(EftEntryNo) + 'C' + Format(AbortCount));
    end;

    procedure GetLabelText(ReasonCode: Text): Text
    var
        response: Text;
    begin
        response := '';
        case ReasonCode of
            'XA':
                response := msgXA;
            'XB':
                response := msgXB;
            'XD':
                response := msgXD;
            'XE':
                response := msgXE;
            'XF':
                response := msgXF;
            'XG':
                response := msgXG;
            'XH':
                response := msgXH;
            'XI':
                response := msgXI;
            'XJ':
                response := msgXJ;
            'XK':
                response := msgXK;
            'XO':
                response := msgXO;
            'XR':
                response := msgXR;
            'XS':
                response := msgXS;
            'XU':
                response := msgXU;
            'XX':
                response := msgXX;
            'XZ':
                response := msgXZ;
            'PF':
                response := msgPF;
            'RD':
                response := msgRD;
            'SC':
                response := msgSC;
            'TB':
                response := msgTB;
            'TC':
                response := msgTC;
            'TE':
                response := msgTE;
            'TF':
                response := msgTF;
            'TO':
                response := msgTO;
            'TR':
                response := msgTR;
            'TX':
                response := msgTX;
        end;
        exit(response);
    end;

    var
        msgXA: Label 'Rejected as an transaction has already been uploaded and cannot be cancelled';
        msgXB: Label 'Rejected as bad card type';
        msgXD: Label 'Rejected as duplicate transaction request';
        msgXE: Label 'Rejected as internal error in the application. This might be due to a wrong configuration';
        msgXF: Label 'Rejected as wrong card function requested';
        msgXG: Label 'Rejected in case we don''t find a DCC request when we search it in Database';
        msgXH: Label 'Rejected as hot card';
        msgXI: Label 'Rejected as invalid card number';
        msgXJ: Label 'Rejected DCC request';
        msgXK: Label 'Rejected if the card number in top-up is different to card number in pre-auth';
        msgXO: Label 'Accepted, locally approved (floor limit)';
        msgXR: Label 'Rejected for other reason';
        msgXS: Label 'Rejected as settlement failed shift is closed (Open shift and retry)';
        msgXU: Label 'Rejected as tried to call out for authorization but host unavailable (connection problem, protocol problem)';
        msgXX: Label 'Rejected as card expired';
        msgXZ: Label 'Might be locally rejected or accepted. If rejected then amount was above floor limit, and not allowed to call or no auth path existing. If accepted for a completion request it was above floor limit but an authorization exists.';
        msgPF: Label 'Generated when transaction request pending not found';
        msgRD: Label 'duplicate request';
        msgSC: Label 'Generated in case DCC selection is requested';
        msgTB: Label 'Rejected Terminal Busy';
        msgTC: Label 'Rejected as cancelled on terminal';
        msgTE: Label 'Rejected as error on terminal';
        msgTF: Label 'Rejected Terminal Not Found';
        msgTO: Label 'Locally accepted by terminal (EMV terminal)';
        msgTR: Label 'Rejected by terminal';
        msgTX: Label 'Rejected Terminal not configured';
}