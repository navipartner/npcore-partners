codeunit 6151400 "NPR Magento Gen. Setup Mgt."
{
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";


    #region Edit
    local procedure AddGenericBufferElement(var XmlElement: XmlElement; var LineNo: Integer; Level: Integer; ParentNodePath: Text[250]; var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    var
        XElement2: XmlElement;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
    begin
        LineNo += 10000;
        TempGenericSetupBuffer.Init();
        TempGenericSetupBuffer."Line No." := LineNo;
        TempGenericSetupBuffer.Name := CopyStr(XmlElement.Name, 1, MaxStrLen(TempGenericSetupBuffer.Name));
        TempGenericSetupBuffer."Node Path" := TempGenericSetupBuffer.Name;
        if ParentNodePath <> '' then
            TempGenericSetupBuffer."Node Path" := CopyStr(ParentNodePath + '/' + TempGenericSetupBuffer."Node Path", 1, MaxStrLen(TempGenericSetupBuffer."Node Path"));
        TempGenericSetupBuffer.Container := NpXmlDomMgt.GetXmlAttributeText(XmlElement, "AttributeName.ElementType"(), false) = "ElementType.Container"();
        if not TempGenericSetupBuffer.Container then begin
            TempGenericSetupBuffer."Data Type" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, "AttributeName.FieldType"(), false), 1, MaxStrLen(TempGenericSetupBuffer."Data Type"));
            TempGenericSetupBuffer.Value := CopyStr(XmlElement.InnerText, 1, MaxStrLen(TempGenericSetupBuffer.Value));
        end;

        TempGenericSetupBuffer.Level := Level;
        TempGenericSetupBuffer.Insert();

        ParentNodePath := TempGenericSetupBuffer."Node Path";
        if TempGenericSetupBuffer.Container then begin
            XmlElement.SelectNodes('child::*', XNodeList);
            foreach XNode in XNodeList do begin
                XElement2 := XNode.AsXmlElement();
                if XElement2.Name <> '#text' then
                    AddGenericBufferElement(XElement2, LineNo, Level + 1, ParentNodePath, TempGenericSetupBuffer);
            end;
        end;
    end;
    #endregion

    internal procedure ValidateValue(DataType: Text[50]; NewValue: Text[250]) Value: Text[250]
    var
        Decimal: Decimal;
        "Integer": Integer;
    begin
        if NewValue = '' then
            exit('');

        case DataType of
            'System.Int32':
                begin
                    Evaluate(Integer, NewValue, 9);
                    exit(Format(Integer, 0, 9));
                end;
            'System.Decimal':
                begin
                    Evaluate(Decimal, NewValue, 9);
                    exit(Format(Decimal, 0, 9));
                end;
        end;

        exit(Format(NewValue, 0, 9));
    end;

    #region Enum

# pragma warning disable AA0228
    local procedure "AttributeName.ElementType"(): Text
    begin
        exit('element_type');
    end;

    local procedure "AttributeName.FieldType"(): Text
    begin
        exit('field_type');
    end;

    local procedure "ElementType.Container"(): Text
    begin
        exit('container');
    end;
# pragma warning restore

    #endregion
}
