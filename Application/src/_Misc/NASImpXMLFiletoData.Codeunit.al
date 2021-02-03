codeunit 6014403 "NPR NAS Imp. XML File to Data"
{
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
        StartTime := CurrentDateTime;
        UpdateProgressWindow(0);

        ParseParentChildDocument(Rec);

        if WindowOpen then
            ProgressWindow.Close;
    end;

    var
        WindowOpen: Boolean;
        StartTime: DateTime;
        ProgressWindow: Dialog;
        ProgressMsg: Label 'Preparing line number #1#######';

    local procedure ParseParentChildDocument(DataExch: Record "Data Exch.")
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        XMLDOMManagement: Codeunit "XML DOM Management";
        Document: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        NodeList: XmlNodeList;
        Node: XmlNode;
        XmlStream: InStream;
        CurrentLineNo: Integer;
        I: Integer;
        NodeCount: Integer;
        NodeID: Text[250];
    begin
        DataExchDef.Get(DataExch."Data Exch. Def Code");
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.SetRange("Parent Code", '');
        if not DataExchLineDef.FindSet then
            exit;

        DataExch."File Content".CreateInStream(XmlStream);
        XmlDocument.ReadFrom(XmlStream, Document);
        ValidateAndAddNamespace(Document, DataExchLineDef, NamespaceManager);
        repeat
            Document.SelectNodes(
              EscapeMissingNamespacePrefix(DataExchLineDef."Data Line Tag"), NamespaceManager, NodeList);

            CurrentLineNo := 1;
            NodeCount := NodeList.Count;
            for I := 1 to NodeCount do begin
                NodeID := IncreaseNodeID('', CurrentLineNo);
                if NodeList.Get(I, Node) then
                    ParseParentChildLine(
                      Node, NodeID, '', CurrentLineNo, DataExchLineDef, DataExch."Entry No.", NamespaceManager);
                CurrentLineNo += 1;
            end;
        until DataExchLineDef.Next() = 0;
    end;

    local procedure ParseParentChildLine(CurrentXmlNode: XmlNode; NodeID: Text[250]; ParentNodeID: Text[250]; CurrentLineNo: Integer; CurrentDataExchLineDef: Record "Data Exch. Line Def"; EntryNo: Integer; NamespaceManager: XmlNamespaceManager)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchField: Record "Data Exch. Field";
        DataExchLineDef: Record "Data Exch. Line Def";
        XMLDOMManagement: Codeunit "XML DOM Management";
        NodeList: XmlNodeList;
        Node: XmlNode;
        Document: XmlDocument;
        CurrentIndex: Integer;
        I: Integer;
        LastLineNo: Integer;
        NodeCount: Integer;
        CurrentNodeID: Text[250];
        NodeValue: Text;
    begin
        DataExchField.InsertRecXMLFieldDefinition(EntryNo, CurrentLineNo, NodeID, ParentNodeID, '', CurrentDataExchLineDef.Code);

        // Insert Attributes and values
        DataExchColumnDef.SetRange("Data Exch. Def Code", CurrentDataExchLineDef."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", CurrentDataExchLineDef.Code);
        DataExchColumnDef.SetFilter(Path, '<>%1', '');

        CurrentIndex := 1;

        if DataExchColumnDef.FindSet() then
            repeat
                CurrentXmlNode.SelectNodes(
                    GetRelativePath(DataExchColumnDef.Path, CurrentDataExchLineDef."Data Line Tag"),
                    NamespaceManager, NodeList);

                NodeCount := NodeList.Count;
                for I := 1 to NodeCount do begin
                    CurrentNodeID := IncreaseNodeID(NodeID, CurrentIndex);
                    CurrentIndex += 1;
                    if NodeList.Get(I, Node) then begin
                        InsertColumn(
                          DataExchColumnDef.Path, CurrentLineNo, CurrentNodeID, ParentNodeID, Node.AsXmlElement().InnerText,
                          CurrentDataExchLineDef, EntryNo);
                    end;
                end;
            until DataExchColumnDef.Next() = 0;

        // insert Constant values
        DataExchColumnDef.SetFilter(Path, '%1', '');
        DataExchColumnDef.SetFilter(Constant, '<>%1', '');
        if DataExchColumnDef.FindSet then
            repeat
                CurrentNodeID := IncreaseNodeID(NodeID, CurrentIndex);
                CurrentIndex += 1;
                DataExchField.InsertRecXMLFieldWithParentNodeID(EntryNo, CurrentLineNo, DataExchColumnDef."Column No.",
                  CurrentNodeID, ParentNodeID, DataExchColumnDef.Constant, CurrentDataExchLineDef.Code);
            until DataExchColumnDef.Next = 0;

        // Insert Children
        DataExchLineDef.SetRange("Data Exch. Def Code", CurrentDataExchLineDef."Data Exch. Def Code");
        DataExchLineDef.SetRange("Parent Code", CurrentDataExchLineDef.Code);

        if DataExchLineDef.FindSet() then
            repeat
                Document.SelectNodes(
                  GetRelativePath(DataExchLineDef."Data Line Tag", CurrentDataExchLineDef."Data Line Tag"),
                  NamespaceManager,
                  NodeList);

                DataExchField.SetRange("Data Exch. No.", EntryNo);
                DataExchField.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                LastLineNo := 1;
                if DataExchField.FindLast() then
                    LastLineNo := DataExchField."Line No." + 1;

                NodeCount := NodeList.Count;
                for I := 1 to NodeCount do begin
                    CurrentNodeID := IncreaseNodeID(NodeID, CurrentIndex);
                    if NodeList.Get(I, Node) then
                        ParseParentChildLine(
                          Node, CurrentNodeID, NodeID, LastLineNo, DataExchLineDef, EntryNo, NamespaceManager);
                    CurrentIndex += 1;
                    LastLineNo += 1;
                end;
            until DataExchLineDef.Next() = 0;
    end;

    local procedure InsertColumn(Path: Text; LineNo: Integer; NodeId: Text[250]; ParentNodeId: Text[250]; Value: Text; var DataExchLineDef: Record "Data Exch. Line Def"; EntryNo: Integer)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchField: Record "Data Exch. Field";
    begin
        // Note: The Data Exch. variable is passed by reference only to improve performance.
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchColumnDef.SetRange(Path, Path);

        if DataExchColumnDef.FindFirst() then begin
            UpdateProgressWindow(LineNo);
            DataExchField.InsertRecXMLFieldWithParentNodeID(EntryNo, LineNo, DataExchColumnDef."Column No.", NodeId, ParentNodeId, Value,
              DataExchLineDef.Code);
        end;
    end;

    local procedure GetRelativePath(ChildPath: Text[250]; ParentPath: Text[250]): Text
    begin
        if StrPos(ChildPath, ParentPath) = 1 then
            exit(EscapeMissingNamespacePrefix('.' + DelStr(ChildPath, 1, StrLen(ParentPath))));
        exit(ChildPath)
    end;

    local procedure IncreaseNodeID(NodeID: Text[250]; Seed: Integer): Text[250]
    begin
        exit(NodeID + Format(Seed, 0, '<Integer,4><Filler Char,0>'))
    end;

    procedure EscapeMissingNamespacePrefix(XPath: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
        PositionOfFirstSlash: Integer;
        FirstXPathElement: Text;
        RestOfXPath: Text;
    begin
        // we will let the user define XPaths without the required namespace prefix
        // however, if he does that, we will only consider the XPath element as a local name
        // for example, we will turn XPath /Invoice/cac:InvoiceLine into /*[local-name() = 'Invoice']/cac:InvoiceLine
        PositionOfFirstSlash := StrPos(XPath, '/');
        case PositionOfFirstSlash of
            1:
                exit('/' + EscapeMissingNamespacePrefix(CopyStr(XPath, 2)));
            0:
                begin
                    if (XPath = '') or (not IsAlphanumeric(XPath)) then
                        exit(XPath);
                    exit(StrSubstNo('*[local-name() = ''%1'']', XPath));
                end;
            else begin
                    FirstXPathElement := DelStr(XPath, PositionOfFirstSlash);
                    RestOfXPath := CopyStr(XPath, PositionOfFirstSlash);
                    exit(EscapeMissingNamespacePrefix(FirstXPathElement) + EscapeMissingNamespacePrefix(RestOfXPath));
                end;
        end;
    end;

    local procedure UpdateProgressWindow(LineNo: Integer)
    var
        PopupDelay: Integer;
    begin
        if not GuiAllowed then
            exit;
        PopupDelay := 1000;
        if CurrentDateTime - StartTime < PopupDelay then
            exit;

        StartTime := CurrentDateTime;// only update every PopupDelay ms


        if not WindowOpen then begin
            ProgressWindow.Open(ProgressMsg);
            WindowOpen := true;
        end;

        ProgressWindow.Update(1, LineNo);
    end;

    procedure IsAlphanumeric(Input: Text): Boolean;
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        exit(RegEx.IsMatch(Input, '^[a-zA-Z0-9]*$'));
    end;

    local procedure ValidateAndAddNamespace(var Document: XmlDocument; DataExchLineDef: Record "Data Exch. Line Def"; var NamespaceManager: XmlNamespaceManager)
    var
        Element: XmlElement;
        NamespaceURI: Text;
        PrefixOfNamespace: Text;
        IncorrectNamespaceErr: Label 'The imported file contains unsupported namespace "%1". The supported namespace is ''%2''.', Comment = '%1 = file namespace, %2 = supported namespace';
    begin
        if not Document.GetRoot(Element) then
            exit;
        NamespaceURI := Element.NamespaceUri();
        if DataExchLineDef.Namespace <> '' then
            if NamespaceURI <> DataExchLineDef.Namespace then
                Error(IncorrectNamespaceErr, NamespaceURI, DataExchLineDef.Namespace);
        NamespaceManager.NameTable(Document.NameTable);
        Element.GetPrefixOfNamespace(NamespaceURI, PrefixOfNamespace);
        if NamespaceURI <> '' then
            NamespaceManager.AddNamespace(PrefixOfNamespace, NamespaceURI);
    end;
}