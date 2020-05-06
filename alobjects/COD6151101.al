codeunit 6151101 "NpRi Data Collection Mgt."
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.54/JKL /20191213 CASE 382066  Added code to omit deactivated reinbursments

    TableNo = "NpRi Reimbursement";

    trigger OnRun()
    begin
        RunDataCollection(Rec);
    end;

    var
        Text000: Label 'Parameters for Data Collection of %1';
        Text001: Label 'Invalid Data Collection module %1';
        Window: Dialog;
        WindowOpened: Boolean;

    local procedure "--- Setup Filters"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var HasFilters: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template")
    begin
    end;

    procedure AddRequestField(RecRef: RecordRef;RequestFieldNo: Integer;var TempField: Record "Field" temporary)
    begin
        if not TempField.IsTemporary then
          exit;

        if TempField.Get(RecRef.Number,RequestFieldNo) then
          exit;

        TempField.Init;
        TempField.TableNo := RecRef.Number;
        TempField."No." := RequestFieldNo;
        TempField.Insert;
    end;

    procedure RunRequestPage(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var RecRef: RecordRef;var RecRef2: RecordRef;var TempField: Record "Field" temporary): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not GuiAllowed then
          exit(false);

        InitRequestPage(NpRiReimbursementTemplate,RecRef,RecRef2,TempField,FilterPageBuilder);
        if not FilterPageBuilder.RunModal then
          exit(false);

        SaveTableView(RecRef,RecRef2,NpRiReimbursementTemplate,FilterPageBuilder);
        exit(true);
    end;

    local procedure InitRequestPage(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var RecRef: RecordRef;var RecRef2: RecordRef;var TempField: Record "Field" temporary;var FilterPageBuilder: FilterPageBuilder)
    begin
        Clear(FilterPageBuilder);
        FilterPageBuilder.PageCaption := StrSubstNo(Text000,RecRef.Caption);

        if RecRef.Number > 0 then
          InitRequestPageView(NpRiReimbursementTemplate,RecRef,TempField,FilterPageBuilder);
        if RecRef2.Number > 0 then
          InitRequestPageView(NpRiReimbursementTemplate,RecRef2,TempField,FilterPageBuilder);
    end;

    local procedure InitRequestPageView(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var RecRef: RecordRef;var TempField: Record "Field" temporary;var FilterPageBuilder: FilterPageBuilder)
    var
        TableViewName: Text;
        TableView: Text;
    begin
        TableViewName := GetTableViewName(RecRef);
        FilterPageBuilder.AddTable(TableViewName,RecRef.Number);
        if GetTableView(TableViewName,NpRiReimbursementTemplate,TableView) then begin
          RecRef.SetView(TableView);
          FilterPageBuilder.SetView(TableViewName,TableView);
        end;

        FilterPageBuilder.AddRecordRef(TableViewName,RecRef);
        Clear(TempField);
        TempField.SetRange(TableNo,RecRef.Number);
        if TempField.FindSet then
          repeat
            FilterPageBuilder.AddFieldNo(TableViewName,TempField."No.");
          until TempField.Next = 0;
    end;

    procedure GetTableViewName(RecVariant: Variant): Text
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        RecID: RecordID;
    begin
        case true of
          RecVariant.IsRecordRef:
            RecRef := RecVariant;
          RecVariant.IsRecord:
            RecRef.GetTable(RecVariant);
          RecVariant.IsRecordId:
            begin
              RecID := RecVariant;
              RecRef := RecID.GetRecord;
            end;
          RecVariant.IsInteger:
            RecRef.Open(RecVariant,true);
          else
            exit('');
        end;

        TableMetadata.Get(RecRef.Number);
        exit(CopyStr(TableMetadata.Name,1,20));
    end;

    procedure GetTableView(TableViewName: Text;var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var TableView: Text): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        InStream: InStream;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
    begin
        if not NpRiReimbursementTemplate."Data Collection Filters".HasValue then
          exit(false);

        NpRiReimbursementTemplate.CalcFields("Data Collection Filters");
        NpRiReimbursementTemplate."Data Collection Filters".CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);

        if not XMLDOMMgt.FindNode(XmlDoc.DocumentElement,'DataItems/DataItem[@name="' + TableViewName + '"]',XmlElement) then
          exit(false);
        TableView := XmlElement.InnerText;

        exit(true);
    end;

    local procedure SaveTableView(RecRef: RecordRef;RecRef2: RecordRef;var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var FilterPageBuilder: FilterPageBuilder)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        DataItemXmlNode: DotNet npNetXmlNode;
        DataItemsXmlNode: DotNet npNetXmlNode;
        XmlDoc: DotNet npNetXmlDocument;
        ReportParametersXmlNode: DotNet npNetXmlNode;
        OutStream: OutStream;
        TableViewName: Text;
        Summary: Text;
    begin
        XmlDoc := XmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElement(XmlDoc,'ReportParameters',ReportParametersXmlNode);
        XMLDOMMgt.AddDeclaration(XmlDoc,'1.0','utf-8','yes');

        XMLDOMMgt.AddElement(ReportParametersXmlNode,'DataItems','','',DataItemsXmlNode);

        if RecRef.Number > 0 then begin
          TableViewName := GetTableViewName(RecRef);
          XMLDOMMgt.AddElement(DataItemsXmlNode,'DataItem',FilterPageBuilder.GetView(TableViewName,false),'',DataItemXmlNode);
          XMLDOMMgt.AddAttribute(DataItemXmlNode,'name',TableViewName);

          RecRef.SetView(FilterPageBuilder.GetView(TableViewName,false));
          Summary := RecRef.GetFilters;
        end;
        if RecRef2.Number > 0 then begin
          TableViewName := GetTableViewName(RecRef2);
          XMLDOMMgt.AddElement(DataItemsXmlNode,'DataItem',FilterPageBuilder.GetView(TableViewName,false),'',DataItemXmlNode);
          XMLDOMMgt.AddAttribute(DataItemXmlNode,'name',TableViewName);

          if Summary <> '' then
            Summary += ', ';
          RecRef2.SetView(FilterPageBuilder.GetView(TableViewName,false));
          Summary += RecRef2.GetFilters;
        end;

        Clear(NpRiReimbursementTemplate."Data Collection Filters");
        NpRiReimbursementTemplate."Data Collection Filters".CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        NpRiReimbursementTemplate."Data Collection Summary" := CopyStr(Summary,1,MaxStrLen(NpRiReimbursementTemplate."Data Collection Summary"));
        NpRiReimbursementTemplate.Modify(true);
    end;

    local procedure "--- Data Collect"()
    begin
    end;

    procedure RunDataCollections(var NpRiReimbursement: Record "NpRi Reimbursement")
    begin
        if NpRiReimbursement.FindSet then
          repeat
            //-NPR5.54 [382066]
            //RunDataCollection(NpRiReimbursement);
            //COMMIT;
            if not NpRiReimbursement.Deactivated then begin
              RunDataCollection(NpRiReimbursement);
              Commit;
            end;
            //+NPR5.54 [382066]
          until NpRiReimbursement.Next = 0;
    end;

    procedure RunDataCollection(var NpRiReimbursement: Record "NpRi Reimbursement")
    var
        NpRiReimbursement2: Record "NpRi Reimbursement";
        Handled: Boolean;
    begin
        NpRiReimbursement.CalcFields("Data Collection Module");
        OnRunDataCollection(NpRiReimbursement,Handled);
        if not Handled then
          Error(Text001,NpRiReimbursement."Data Collection Module");

        NpRiReimbursement2 := NpRiReimbursement;
        NpRiReimbursement.Find;
        NpRiReimbursement := NpRiReimbursement2;
        NpRiReimbursement."Last Data Collection at" := CurrentDateTime;
        NpRiReimbursement.Modify(true);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnRunDataCollection(var NpRiReimbursement: Record "NpRi Reimbursement";var Handled: Boolean)
    begin
    end;

    procedure InsertEntry(NpRiReimbursement: Record "NpRi Reimbursement";Amount: Decimal;RecVariant: Variant;var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry"): Boolean
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeMgt.GetRecordRef(RecVariant,RecRef) then
          exit(false);

        InitEntry(NpRiReimbursement,Amount,RecRef,NpRiReimbursementEntry);
        if EntryExists(NpRiReimbursementEntry) then
          exit(false);

        NpRiReimbursementEntry.Insert(true);

        if NpRiReimbursement."Last Data Collect Entry No." < NpRiReimbursementEntry."Source Entry No." then
          NpRiReimbursement."Last Data Collect Entry No." := NpRiReimbursementEntry."Source Entry No.";

        exit(true);
    end;

    procedure InitEntry(NpRiReimbursement: Record "NpRi Reimbursement";Amount: Decimal;var RecRef: RecordRef;var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        FieldRef: FieldRef;
    begin
        NpRiReimbursementEntry.Init;
        NpRiReimbursementEntry."Entry No." := 0;
        NpRiReimbursementEntry."Party Type" := NpRiReimbursement."Party Type";
        NpRiReimbursementEntry."Party No." := NpRiReimbursement."Party No.";
        NpRiReimbursementEntry."Template Code" := NpRiReimbursement."Template Code";
        if DataTypeMgt.FindFieldByName(RecRef,FieldRef,'Posting Date') then
          NpRiReimbursementEntry."Posting Date" := FieldRef.Value;
        NpRiReimbursementEntry."Entry Type" := NpRiReimbursementEntry."Entry Type"::"Data Collection";
        NpRiReimbursementEntry."Source Company Name" := NpRiReimbursement."Data Collection Company";
        if NpRiReimbursementEntry."Source Company Name" = '' then
          NpRiReimbursementEntry."Source Company Name" := CompanyName;
        NpRiReimbursementEntry."Source Record ID" := RecRef.RecordId;
        NpRiReimbursementEntry."Source Table No." := RecRef.Number;
        NpRiReimbursementEntry."Source Record Position" := RecRef.GetPosition(false);
        if DataTypeMgt.FindFieldByName(RecRef,FieldRef,'Entry No.') then
          NpRiReimbursementEntry."Source Entry No." := FieldRef.Value;
        if DataTypeMgt.FindFieldByName(RecRef,FieldRef,'Description') then
          NpRiReimbursementEntry.Description := FieldRef.Value;
        NpRiReimbursementEntry.Amount := Amount;
        NpRiReimbursementEntry.Positive := NpRiReimbursementEntry.Amount > 0;
        NpRiReimbursementEntry.Open := NpRiReimbursementEntry.Amount <> 0;
        NpRiReimbursementEntry."Remaining Amount" := NpRiReimbursementEntry.Amount;
        NpRiReimbursementEntry."Closed by Entry No." := 0;
        NpRiReimbursementEntry."Reimbursement Amount" := 0;
    end;

    local procedure EntryExists(NpRiReimbursementEntry: Record "NpRi Reimbursement Entry"): Boolean
    var
        NpRiReimbursementEntry2: Record "NpRi Reimbursement Entry";
    begin
        if NpRiReimbursementEntry."Entry No." > 0 then begin
          NpRiReimbursementEntry2.SetCurrentKey("Party Type","Party No.","Template Code","Posting Date","Entry Type","Source Company Name","Source Table No.","Source Entry No.","Source Record Position");
          NpRiReimbursementEntry2.SetRange("Party Type",NpRiReimbursementEntry."Party Type");
          NpRiReimbursementEntry2.SetRange("Party No.",NpRiReimbursementEntry."Party No.");
          NpRiReimbursementEntry2.SetRange("Template Code",NpRiReimbursementEntry."Template Code");
          NpRiReimbursementEntry2.SetRange("Posting Date",NpRiReimbursementEntry."Posting Date");
          NpRiReimbursementEntry2.SetRange("Entry Type",NpRiReimbursementEntry."Entry Type");
          NpRiReimbursementEntry2.SetRange("Source Table No.",NpRiReimbursementEntry."Source Table No.");
          NpRiReimbursementEntry2.SetRange("Source Entry No.",NpRiReimbursementEntry."Source Entry No.");
          exit(NpRiReimbursementEntry2.FindFirst);
        end;

        NpRiReimbursementEntry2.SetCurrentKey("Party Type","Party No.","Template Code","Posting Date","Entry Type","Source Company Name","Source Record ID");
        NpRiReimbursementEntry2.SetRange("Party Type",NpRiReimbursementEntry."Party Type");
        NpRiReimbursementEntry2.SetRange("Party No.",NpRiReimbursementEntry."Party No.");
        NpRiReimbursementEntry2.SetRange("Template Code",NpRiReimbursementEntry."Template Code");
        NpRiReimbursementEntry2.SetRange("Posting Date",NpRiReimbursementEntry."Posting Date");
        NpRiReimbursementEntry2.SetRange("Entry Type",NpRiReimbursementEntry."Entry Type");
        NpRiReimbursementEntry2.SetRange("Source Record ID",NpRiReimbursementEntry."Source Record ID");
        exit(NpRiReimbursementEntry2.FindFirst);
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure UseWindow(): Boolean
    begin
        exit(GuiAllowed);
    end;

    procedure OpenWindow(Title: Text)
    begin
        if not UseWindow() then
          exit;

        if WindowOpened then
          CloseWindow();

        Window.Open(Title);
        WindowOpened := true;
    end;

    procedure UpdateWindow(Ctrl: Integer;Progress: Integer)
    begin
        if not (UseWindow() and WindowOpened) then
          exit;

        Window.Update(Ctrl,Progress);
    end;

    procedure CloseWindow()
    begin
        if not (UseWindow() and WindowOpened) then
          exit;

        Window.Close;
        WindowOpened := false;
    end;
}

