codeunit 6014555 "NPR Attribute Management"
{
    // Guide for implementation on entity:
    // Shortcut Attributes: Example on item page/form
    //   Add Global textArray : NPRAttributeTextArray text 50 size 20
    //   Add Global codeunit  : NPRAttributeMgr #6014555
    //   Add OnAfterGetRecord : NPRAttributeMgr.GetMasterDataAttributeValue (NPRAttributeTextArray, database::item, "No.");
    //   Add shortcut field n
    //     Properties
    //      - SourceExpr      : NPRAttributeTextArray[n]
    //      - CaptionClass    : '6014555,<base table id>,[n],2'

    var
        Text000: Label 'Variant must be Record or RecordRef.';
        Text001: Label 'Attribute %1 is not defined';
        Text002: Label 'Attribute %1 does not have a value %2!';
        AlphabetText: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        TodayText: Label 'TODAY';
        WorkdateText: Label 'WORKDATE';
        NowText: Label 'NOW';

    procedure GetAttributeCaption(Language: Integer; CaptionRef: Text[80]) Caption: Text[100]
    var
        AttributeTableID: Integer;
        AttributeReference: Integer;
        AttributeFieldReference: Integer;
        AttributeID: Record "NPR Attribute ID";
        Attribute: Record "NPR Attribute";
        AttributeTranslation: Record "NPR Attribute Translation";
        IllegalCaptionRefLbl: Label 'Illegal Caption Ref! [%1]', locked = true;
    begin
        if (not (Evaluate(AttributeTableID, SelectStr(1, CaptionRef)))) then
            exit(StrSubstNo(IllegalCaptionRefLbl, CaptionRef));

        if (not (Evaluate(AttributeReference, SelectStr(2, CaptionRef)))) then
            exit(StrSubstNo(IllegalCaptionRefLbl, CaptionRef));

        if (not (Evaluate(AttributeFieldReference, SelectStr(3, CaptionRef)))) then
            exit(StrSubstNo(IllegalCaptionRefLbl, CaptionRef));

        if (not GetAttributeShortcut(AttributeTableID, AttributeReference, AttributeID)) then
            exit(CopyStr(StrSubstNo(Text001, AttributeReference), 1, MaxStrLen(Caption)));

        if (not Attribute.Get(AttributeID."Attribute Code")) then
            exit;
        if (AttributeTranslation.Get(Attribute.Code, Language)) then
            case AttributeFieldReference of
                1:
                    Caption := AttributeTranslation.Name;
                2:
                    Caption := AttributeTranslation."Code Caption";
                3:
                    Caption := AttributeTranslation."Filter Caption";
            end;

        if (Caption = '') then
            case AttributeFieldReference of
                1:
                    Caption := Attribute.Name;
                2:
                    Caption := Attribute."Code Caption";
                3:
                    Caption := Attribute."Filter Caption";
            end;

        if (Caption = '') then Caption := CopyStr(StrSubstNo(Text001, AttributeReference), 1, MaxStrLen(Caption));

        exit(Caption);
    end;

    procedure GetAttributeVisibility(TableID: Integer; var vAttributeVisibility: array[40] of Boolean)
    var
        AttributeID: Record "NPR Attribute ID";
        Attribute: Record "NPR Attribute";
        i: Integer;
    begin
        for i := 1 to ArrayLen(vAttributeVisibility) do begin
            AttributeID.SetRange("Table ID", TableID);
            AttributeID.SetRange("Shortcut Attribute ID", i);
            vAttributeVisibility[i] := AttributeID.FindFirst();

            if (vAttributeVisibility[i]) then begin
                Attribute.Get(AttributeID."Attribute Code");
                vAttributeVisibility[i] := not Attribute.Blocked;
            end;
        end;
    end;

    procedure SetEntryAttributeValue(TableID: Integer; AttributeReference: Integer; PKCode: Integer; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::MASTERDATA, Format(PKCode, 0, '<integer>'), 0, 0, '', 0, TextValue);
    end;

    procedure SetMasterDataAttributeValue(TableID: Integer; AttributeReference: Integer; PKCode: Code[20]; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::MASTERDATA, PKCode, 0, 0, '', 0, TextValue);
    end;

    procedure SetDocumentAttributeValue(TableID: Integer; AttributeReference: Integer; PKOption: Option; PKCode: Code[20]; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::DOCUMENT, PKCode, 0, PKOption, '', 0, TextValue);
    end;

    procedure SetDocumentLineAttributeValue(TableID: Integer; AttributeReference: Integer; PKOption: Option; PKCode: Code[20]; PKLine: Integer; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::DOCUMENTLINE, PKCode, PKLine, PKOption, '', 0, TextValue);
    end;

    procedure SetWorksheetLineAttributeValue(TableID: Integer; AttributeReference: Integer; PKTemplate: Code[20]; PKBatch: Code[20]; PKLine: Integer; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::WORKSHEETLINE, PKTemplate, PKLine, 0, PKBatch, 0, TextValue);
    end;

    procedure SetWorksheetSubLineAttributeValue(TableID: Integer; AttributeReference: Integer; PKTemplate: Code[20]; PKBatch: Code[20]; PKLine: Integer; PKSubLine: Integer; var TextValue: Text[250])
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        SetGenericAttributeValueWorker(TableID, AttributeReference, AttributeID."Key Layout"::WORKSHEETSUBLINE, PKTemplate, PKLine, 0, PKBatch, PKSubLine, TextValue);
    end;

    local procedure SetGenericAttributeValueWorker(TableID: Integer; AttributeReference: Integer; KeyLayout: Option; PKCode: Code[20]; PKLine: Integer; PKOption: Option; PKBatch: Code[20]; PKSubLine: Integer; var TextValue: Text[250])
    var
        Attribute: Record "NPR Attribute";
        AttributeKey: Record "NPR Attribute Key";
        AttributeID: Record "NPR Attribute ID";
        AttributeValue: Record "NPR Attribute Value Set";
        NewValue: Boolean;
    begin

        if (not GetAttributeShortcut(TableID, AttributeReference, AttributeID)) then
            Error('Attribute %1 has not been activated for table %2', AttributeReference, TableID);

        Attribute.Get(AttributeID."Attribute Code");
        Attribute.TestField(Blocked, false);

        // New values, will have a 0 setid
        GetAttributeKey(TableID, PKCode, PKLine, PKOption, PKBatch, PKSubLine, AttributeKey, false);
        NewValue := SetAttributeValue(AttributeKey."Attribute Set ID", Attribute.Code, TextValue, AttributeValue);

        if (NewValue) then begin
            if (AttributeValue."Attribute Set ID" = 0) then begin
                GetAttributeKey(TableID, PKCode, PKLine, PKOption, PKBatch, PKSubLine, AttributeKey, true);
                SetKeyLayout(TableID, Attribute.Code, KeyLayout);
                AttributeValue."Attribute Set ID" := AttributeKey."Attribute Set ID";
                AttributeValue.Insert();
            end else begin
                AttributeValue.Modify();
            end;

            case KeyLayout of
                AttributeID."Key Layout"::MASTERDATA:
                    OnAfterSetMasterDataAttributeNewValue(AttributeKey, AttributeValue); // Should be depricated!!
            end;

            OnAfterClientAttributeNewValue(AttributeKey, AttributeValue);
        end;
    end;

    procedure SetAttributeValue(SetID: Integer; AttributeCode: Code[20]; var TextValue: Text[1024]; var vAttributeValue: Record "NPR Attribute Value Set"): Boolean
    var
        Attribute: Record "NPR Attribute";
        myDate: Date;
        myInt: Integer;
        HaveAttributeSet: Boolean;
    begin

        Attribute.Get(AttributeCode);
        HaveAttributeSet := vAttributeValue.Get(SetID, AttributeCode);

        if (not (HaveAttributeSet)) then begin
            if (TextValue = '') then
                exit(false);
            vAttributeValue.Init();
            vAttributeValue."Attribute Set ID" := 0;
            vAttributeValue."Attribute Code" := AttributeCode;
        end;

        if (TextValue = GetTextValue(Attribute, vAttributeValue)) then
            exit(false);

        vAttributeValue.Init();
        vAttributeValue."Text Value" := TextValue;

        case Attribute."Value Datatype" of
            Attribute."Value Datatype"::DT_TEXT:
                begin
                    if GuiAllowed then
                        MakeText(TextValue);
                    vAttributeValue."Text Value" := CopyStr(TextValue, 1, MaxStrLen(TextValue));
                end;
            Attribute."Value Datatype"::DT_CODE:
                begin
                    if (Attribute."On Validate" = Attribute."On Validate"::VALUE_LOOKUP) then
                        if (DoAttributeValueCodeLookup(Attribute.Code, TextValue) = false) then
                            Error(Text002, Attribute.Code, TextValue);
                    vAttributeValue."Text Value" := CopyStr(UpperCase(TextValue), 1, 20);
                end;
            Attribute."Value Datatype"::DT_DATE:
                begin
                    MakeDateText(TextValue);
                    Evaluate(myDate, TextValue);
                    vAttributeValue."Datetime Value" := CreateDateTime(myDate, 0T);
                    vAttributeValue."Text Value" := Format(myDate, 0, 9);
                end;
            Attribute."Value Datatype"::DT_DATETIME:
                begin
                    MakeDateTimeText(TextValue);
                    Evaluate(vAttributeValue."Datetime Value", TextValue);
                    vAttributeValue."Text Value" := Format(vAttributeValue."Datetime Value", 0, 9);
                end;
            Attribute."Value Datatype"::DT_DECIMAL:
                begin
                    Evaluate(vAttributeValue."Numeric Value", TextValue);
                    vAttributeValue."Text Value" := Format(vAttributeValue."Numeric Value", 0, 9);
                end;
            Attribute."Value Datatype"::DT_INTEGER:
                begin
                    Evaluate(myInt, TextValue);
                    vAttributeValue."Numeric Value" := myInt;
                    vAttributeValue."Text Value" := Format(myInt, 0, 9);
                end;
            Attribute."Value Datatype"::DT_BOOLEAN:
                begin
                    Evaluate(vAttributeValue."Boolean Value", TextValue);
                    vAttributeValue."Text Value" := Format(vAttributeValue."Boolean Value", 0, 9);
                end;
        end;

        TextValue := GetTextValue(Attribute, vAttributeValue);
        exit(true);
    end;

    procedure GetEntryAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKCode: Integer)
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, Format(PKCode, 0, '<integer>'), 0, 0, '', 0);
    end;

    procedure GetMasterDataAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKCode: Code[20])
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, PKCode, 0, 0, '', 0);
    end;

    procedure GetDocumentAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKOption: Option; PKCode: Code[20])
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, PKCode, 0, PKOption, '', 0);
    end;

    procedure GetDocumentLineAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKOption: Option; PKCode: Code[20]; PKLine: Integer)
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, PKCode, PKLine, PKOption, '', 0);
    end;

    procedure GetWorksheetLineAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKTemplate: Code[20]; PKBatch: Code[20]; PKLine: Integer)
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, PKTemplate, PKLine, 0, PKBatch, 0);
    end;

    procedure GetWorksheetSublineaAttributeValue(var TextArray: array[40] of Text[250]; TableID: Integer; PKTemplate: Code[20]; PKBatch: Code[20]; PKLine: Integer; PKSubline: Integer)
    begin

        GetGenericAttributeValueWorker(TextArray, TableID, PKTemplate, PKLine, 0, PKBatch, PKSubline);
    end;

    local procedure GetGenericAttributeValueWorker(var TextArray: array[40] of Text[250]; TableID: Integer; PKCode: Code[20]; PKLine: Integer; PkOption: Option; PKBatch: Code[20]; PKSubline: Integer)
    var
        AttributeKey: Record "NPR Attribute Key";
    begin
        Clear(TextArray);

        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', TableID);
        AttributeKey.SetFilter("MDR Code PK", '=%1', PKCode);
        AttributeKey.SetFilter("MDR Line PK", '=%1', PKLine);
        AttributeKey.SetFilter("MDR Option PK", '=%1', PkOption);
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', PKBatch);
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', PKSubline);

        // Fill array
        if (AttributeKey.FindFirst()) then begin
            FillValueArray(TextArray, AttributeKey."Attribute Set ID", TableID);
        end;
    end;

    procedure GetAssignedAttributeList(TableID: Integer; var AttributeCodeArray: array[40] of Code[20])
    var
        AttributeID: Record "NPR Attribute ID";
    begin
        Clear(AttributeCodeArray);

        AttributeID.SetCurrentKey("Table ID");
        AttributeID.SetFilter("Table ID", '=%1', TableID);
        AttributeID.SetFilter("Shortcut Attribute ID", '>%1', 0);
        if (AttributeID.FindSet()) then begin
            repeat
                AttributeCodeArray[AttributeID."Shortcut Attribute ID"] := AttributeID."Attribute Code";
            until (AttributeID.Next() = 0);
        end;
    end;

    procedure CopyEntryAttributeValue(TableID: Integer; SourcePKCode: Integer; TargetPKCode: Integer)
    var
        TextArray: array[40] of Text[250];
        N: Integer;
        AttributeID: Record "NPR Attribute ID";
    begin
        Clear(TextArray);

        GetEntryAttributeValue(TextArray, TableID, SourcePKCode);
        for N := 1 to ArrayLen(TextArray) do
            if (GetAttributeShortcut(TableID, N, AttributeID)) then
                SetEntryAttributeValue(TableID, N, TargetPKCode, TextArray[N]);

    end;

    procedure ShowMasterDataAttributeValues(TableID: Integer; "MDR Code PK": Code[20]) AttributeCode: Code[20]
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "page": Page "NPR Attribute Values";
    begin
        GetAttributeKey(TableID, "MDR Code PK", 0, 0, '', 0, AttributeKey, false);
        AttributeValue.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");

        page.SetTableView(AttributeValue);
        page.Run();
    end;

    procedure ShowDocumentAttributeValues(TableID: Integer; "MDR Option PK": Option; "MDR Code PK": Code[20]) AttributeCode: Code[20]
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "page": Page "NPR Attribute Values";
    begin
        GetAttributeKey(TableID, "MDR Code PK", 0, "MDR Option PK", '', 0, AttributeKey, false);
        AttributeValue.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");

        page.SetTableView(AttributeValue);
        page.Run();
    end;

    procedure ShowDocumentLineAttributeValues(TableID: Integer; "MDR Option PK": Option; "MDR Code PK": Code[20]; "MDR Line PK": Integer) AttributeCode: Code[20]
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "page": Page "NPR Attribute Values";
    begin
        GetAttributeKey(TableID, "MDR Code PK", "MDR Line PK", "MDR Option PK", '', 0, AttributeKey, false);
        AttributeValue.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");

        page.SetTableView(AttributeValue);
        page.Run();
    end;

    procedure ShowWorksheetLineAttributeValues(TableID: Integer; "MDR Code PK": Code[20]; "MDR Code 2 PK": Code[20]; "MDR Line PK": Integer) AttributeCode: Code[20]
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "page": Page "NPR Attribute Values";
    begin
        GetAttributeKey(TableID, "MDR Code PK", "MDR Line PK", 0, "MDR Code 2 PK", 0, AttributeKey, false);
        AttributeValue.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");

        page.SetTableView(AttributeValue);
        page.Run();
    end;

    procedure ShowWorksheetSublineAttributeValues(TableID: Integer; "MDR Code PK": Code[20]; "MDR Code 2 PK": Code[20]; "MDR Line PK": Integer; "MDR Line 2 PK": Integer) AttributeCode: Code[20]
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValue: Record "NPR Attribute Value Set";
        "page": Page "NPR Attribute Values";
    begin
        GetAttributeKey(TableID, "MDR Code PK", "MDR Line PK", 0, "MDR Code 2 PK", "MDR Line 2 PK", AttributeKey, false);
        AttributeValue.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");

        page.SetTableView(AttributeValue);
        page.Run();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCaptionClassTranslate', '', false, false)]
    local procedure C1_OnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text[1024]; var Caption: Text[1024])
    var
        CaptionArea: Text[80];
        CaptionRef: Text[1024];
        CommaPosition: Integer;
        AttributeManagement: Codeunit "NPR Attribute Management";
    begin
        CommaPosition := StrPos(CaptionExpression, ',');
        if (CommaPosition > 0) and (CommaPosition < 80) then begin
            CaptionArea := CopyStr(CaptionExpression, 1, CommaPosition - 1);
            CaptionRef := CopyStr(CaptionExpression, CommaPosition + 1);
            case CaptionArea of
                '6014555':
                    Caption := AttributeManagement.GetAttributeCaption(Language, CopyStr(CaptionRef, 1, 80));
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseDelete', '', true, true)]
    local procedure C1_OnAfterOnDatabaseDelete(RecRef: RecordRef)
    var
        KeyLayout: Option;
        AttributeID: Record "NPR Attribute ID";
        CodePrimaryKey: Code[20];
        OptionPrimaryKey: Option;
        LinePrimaryKey: Integer;
        Code2PrimaryKey: Code[20];
        Line2PrimaryKey: Integer;
    begin
        if (RecRef.IsTemporary) then
            exit;

        if (not IsAttributeTableActive(RecRef.Number, KeyLayout)) then
            exit;

        case KeyLayout of
            AttributeID."Key Layout"::NOT_SET:
                ;
            AttributeID."Key Layout"::MASTERDATA:
                if (GetMDRKeyValue(RecRef.KeyIndex(1), CodePrimaryKey)) then
                    DeleteAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, 0, 0, '', 0);

            AttributeID."Key Layout"::DOCUMENT:
                if (GetDocumentKeyValue(RecRef.KeyIndex(1), OptionPrimaryKey, CodePrimaryKey)) then
                    DeleteAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, OptionPrimaryKey, 0, '', 0);

            AttributeID."Key Layout"::DOCUMENTLINE:
                if (GetDocumentLineKeyValue(RecRef.KeyIndex(1), OptionPrimaryKey, CodePrimaryKey, LinePrimaryKey)) then
                    DeleteAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, OptionPrimaryKey, LinePrimaryKey, '', 0);

            AttributeID."Key Layout"::WORKSHEETLINE:
                if (GetWorksheetLineKeyValue(RecRef.KeyIndex(1), CodePrimaryKey, Code2PrimaryKey, LinePrimaryKey)) then
                    DeleteAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, 0, LinePrimaryKey, Code2PrimaryKey, 0);
            AttributeID."Key Layout"::WORKSHEETSUBLINE:
                if (GetWorksheetSubLineKeyValue(RecRef.KeyIndex(1), CodePrimaryKey, Code2PrimaryKey, LinePrimaryKey, Line2PrimaryKey)) then
                    DeleteAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, 0, LinePrimaryKey, Code2PrimaryKey, Line2PrimaryKey);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseRename', '', true, true)]
    local procedure C1_OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    var
        KeyLayout: Option;
        AttributeID: Record "NPR Attribute ID";
        DoRename: Boolean;
        CodePrimaryKey: Code[20];
        OptionPrimaryKey: Option;
        LinePrimaryKey: Integer;
        Code2PrimaryKey: Code[20];
        Line2PrimaryKey: Integer;
        xCodePrimaryKey: Code[20];
        xOptionPrimaryKey: Option;
        xLinePrimaryKey: Integer;
        xCode2PrimaryKey: Code[20];
        xLine2PrimaryKey: Integer;
    begin
        if (RecRef.IsTemporary) then
            exit;

        if (not IsAttributeTableActive(RecRef.Number, KeyLayout)) then
            exit;

        case KeyLayout of
            AttributeID."Key Layout"::NOT_SET:
                DoRename := false;

            AttributeID."Key Layout"::MASTERDATA:
                DoRename := ((GetMDRKeyValue(RecRef.KeyIndex(1), CodePrimaryKey) and
                             (GetMDRKeyValue(xRecRef.KeyIndex(1), xCodePrimaryKey))));

            AttributeID."Key Layout"::DOCUMENT:
                DoRename := ((GetDocumentKeyValue(RecRef.KeyIndex(1), OptionPrimaryKey, CodePrimaryKey) and
                             (GetDocumentKeyValue(xRecRef.KeyIndex(1), xOptionPrimaryKey, xCodePrimaryKey))));

            AttributeID."Key Layout"::DOCUMENTLINE:
                DoRename := ((GetDocumentLineKeyValue(RecRef.KeyIndex(1), OptionPrimaryKey, CodePrimaryKey, LinePrimaryKey) and
                             (GetDocumentLineKeyValue(xRecRef.KeyIndex(1), xOptionPrimaryKey, xCodePrimaryKey, xLinePrimaryKey))));

            AttributeID."Key Layout"::WORKSHEETLINE:
                DoRename := ((GetWorksheetLineKeyValue(RecRef.KeyIndex(1), CodePrimaryKey, Code2PrimaryKey, LinePrimaryKey) and
                             (GetWorksheetLineKeyValue(xRecRef.KeyIndex(1), xCodePrimaryKey, xCode2PrimaryKey, xLinePrimaryKey))));

            AttributeID."Key Layout"::WORKSHEETSUBLINE:
                DoRename := ((GetWorksheetSubLineKeyValue(RecRef.KeyIndex(1), CodePrimaryKey, Code2PrimaryKey, LinePrimaryKey, Line2PrimaryKey) and
                             (GetWorksheetSubLineKeyValue(xRecRef.KeyIndex(1), xCodePrimaryKey, xCode2PrimaryKey, xLinePrimaryKey, xLine2PrimaryKey))));
            else
                DoRename := false;
        end;

        if (DoRename) then
            RenameAttributeOwnerRecord(RecRef.Number, CodePrimaryKey, OptionPrimaryKey, LinePrimaryKey, Code2PrimaryKey, Line2PrimaryKey,
                                                       xCodePrimaryKey, xOptionPrimaryKey, xLinePrimaryKey, xCode2PrimaryKey, xLine2PrimaryKey);

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSetMasterDataAttributeNewValue(NPRAttributeKey: Record "NPR Attribute Key"; NPRAttributeValueSet: Record "NPR Attribute Value Set")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterClientAttributeNewValue(NPRAttributeKey: Record "NPR Attribute Key"; NPRAttributeValueSet: Record "NPR Attribute Value Set")
    begin
    end;

    procedure DeleteAttributeOwnerRecord(TableID: Integer; CodePK: Code[20]; LinePK: Integer; OptionPK: Option; Code2PK: Code[20]; Line2PK: Integer)
    var
        AttributeKey: Record "NPR Attribute Key";
    begin
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', TableID);
        AttributeKey.SetFilter("MDR Code PK", '=%1', CodePK);

        AttributeKey.SetFilter("MDR Option PK", '=%1', OptionPK);
        AttributeKey.SetFilter("MDR Line PK", '=%1', LinePK);
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', Code2PK);
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', Line2PK);

        if (not AttributeKey.IsEmpty()) then
            AttributeKey.DeleteAll();
    end;

    procedure RenameAttributeOwnerRecord(TableID: Integer; CodePK: Code[20]; LinePK: Integer; OptionPK: Option; Code2PK: Code[20]; Line2PK: Integer; xCodePK: Code[20]; xLinePK: Integer; xOptionPK: Option; xCode2PK: Code[20]; xLine2PK: Integer)
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeKeyNew: Record "NPR Attribute Key";
    begin
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', TableID);
        AttributeKey.SetFilter("MDR Code PK", '=%1', xCodePK);

        AttributeKey.SetFilter("MDR Option PK", '=%1', xOptionPK);
        AttributeKey.SetFilter("MDR Line PK", '=%1', xLinePK);
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', xCode2PK);
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', xLine2PK);

        if (AttributeKey.FindSet()) then begin
            repeat
                AttributeKeyNew.Get(AttributeKey."Attribute Set ID");
                AttributeKeyNew."MDR Code PK" := CodePK;
                AttributeKeyNew."MDR Line PK" := LinePK;
                AttributeKeyNew."MDR Option PK" := OptionPK;
                AttributeKeyNew."MDR Code 2 PK" := Code2PK;
                AttributeKeyNew."MDR Line 2 PK" := Line2PK;

                AttributeKeyNew.Modify();
            until (AttributeKey.Next() = 0);
        end;
    end;

    local procedure GetMDRKeyValue(KeyRef: KeyRef; var PrimaryKeyValue: Code[20]): Boolean
    begin
        if (KeyRef.FieldCount <> 1) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(1), PrimaryKeyValue)) then
            exit(false);

        exit(true);
    end;

    local procedure GetDocumentKeyValue(KeyRef: KeyRef; var OptionKeyValue: Option; var PrimaryKeyValue: Code[20]): Boolean
    begin
        if (KeyRef.FieldCount <> 2) then
            exit(false);

        if (not GetValueAsOption(KeyRef.FieldIndex(1), OptionKeyValue)) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(2), PrimaryKeyValue)) then
            exit(false);

        exit(true);
    end;

    local procedure GetDocumentLineKeyValue(KeyRef: KeyRef; var OptionKeyValue: Option; var PrimaryKeyValue: Code[20]; var IntegerKeyValue: Integer): Boolean
    begin
        if (KeyRef.FieldCount <> 3) then
            exit(false);

        if (not GetValueAsOption(KeyRef.FieldIndex(1), OptionKeyValue)) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(2), PrimaryKeyValue)) then
            exit(false);

        if (not GetValueAsInteger(KeyRef.FieldIndex(3), IntegerKeyValue)) then
            exit(false);

        exit(true);
    end;

    local procedure GetWorksheetLineKeyValue(KeyRef: KeyRef; var PrimaryKeyValue: Code[20]; var Primary2KeyValue: Code[20]; var IntegerKeyValue: Integer): Boolean
    begin
        if (KeyRef.FieldCount <> 3) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(1), PrimaryKeyValue)) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(2), Primary2KeyValue)) then
            exit(false);

        if (not GetValueAsInteger(KeyRef.FieldIndex(3), IntegerKeyValue)) then
            exit(false);

        exit(true);
    end;

    local procedure GetWorksheetSubLineKeyValue(KeyRef: KeyRef; var PrimaryKeyValue: Code[20]; var Primary2KeyValue: Code[20]; var IntegerKeyValue: Integer; var Integer2KeyValue: Integer): Boolean
    begin
        if (KeyRef.FieldCount <> 4) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(1), PrimaryKeyValue)) then
            exit(false);

        if (not GetValueAsCode(KeyRef.FieldIndex(2), Primary2KeyValue)) then
            exit(false);

        if (not GetValueAsInteger(KeyRef.FieldIndex(3), IntegerKeyValue)) then
            exit(false);

        if (not GetValueAsInteger(KeyRef.FieldIndex(4), Integer2KeyValue)) then
            exit(false);

        exit(true);
    end;

    local procedure SetKeyLayout(TableID: Integer; AttributeCode: Code[20]; KeyLayout: Option)
    var
        AttributeID: Record "NPR Attribute ID";
    begin
        if (AttributeID.Get(TableID, AttributeCode)) then begin
            if (AttributeID."Key Layout" <> KeyLayout) then begin
                AttributeID."Key Layout" := KeyLayout;
                AttributeID.Modify();
            end;
        end;
    end;

    local procedure GetValueAsOption(KeyFldRef: FieldRef; var OptionKeyValue: Option): Boolean
    var
        "Field": Record "Field";
    begin
        Evaluate(Field.Type, Format(KeyFldRef.Type));
        if (Field.Type = Field.Type::Option) then begin
            OptionKeyValue := KeyFldRef.Value;
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetValueAsCode(KeyFldRef: FieldRef; var PrimaryKeyValue: Code[20]): Boolean
    var
        "Field": Record "Field";
    begin
        Evaluate(Field.Type, Format(KeyFldRef.Type));
        if (Field.Type = Field.Type::Code) and (KeyFldRef.Length <= MaxStrLen(PrimaryKeyValue)) then begin
            PrimaryKeyValue := KeyFldRef.Value;
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetValueAsInteger(KeyFldRef: FieldRef; var IntegerKeyValue: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        Evaluate(Field.Type, Format(KeyFldRef.Type));
        if (Field.Type = Field.Type::Integer) then begin
            IntegerKeyValue := KeyFldRef.Value;
            exit(true);
        end;

        exit(false);
    end;

    procedure GetAttributeFilterView(var NPRAttributeValueSet: Record "NPR Attribute Value Set"; "Record": Variant) FilterView: Text
    var
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttributeKeys: Query "NPR Attribute Keys";
        RecRef: RecordRef;
        KeyLayout: Integer;
    begin
        if not Record2RecRef(Record, RecRef) then
            exit('');

        NPRAttributeKeys.SetRange(Table_ID, RecRef.Number);
        NPRAttributeKeys.SetFilter(Attribute_Set_ID, NPRAttributeValueSet.GetFilter("Attribute Set ID"));
        NPRAttributeKeys.SetFilter(Attribute_Code, NPRAttributeValueSet.GetFilter("Attribute Code"));
        NPRAttributeKeys.SetFilter(Text_Value, NPRAttributeValueSet.GetFilter("Text Value"));
        NPRAttributeKeys.SetFilter(Datetime_Value, NPRAttributeValueSet.GetFilter("Datetime Value"));
        NPRAttributeKeys.SetFilter(Numeric_Value, NPRAttributeValueSet.GetFilter("Numeric Value"));
        NPRAttributeKeys.SetFilter(Boolean_Value, NPRAttributeValueSet.GetFilter("Boolean Value"));
        if not NPRAttributeKeys.Open() then
            exit('');

        KeyLayout := GetRecordKeyLayout(Record);
        case KeyLayout of
            NPRAttributeID."Key Layout"::MASTERDATA:
                FilterView := GetAttributeFilterViewMDR(NPRAttributeKeys, RecRef);
            NPRAttributeID."Key Layout"::DOCUMENT:
                FilterView := GetAttributeFilterViewDocument(NPRAttributeKeys, RecRef);
            NPRAttributeID."Key Layout"::DOCUMENTLINE:
                FilterView := GetAttributeFilterViewDocumentLine(NPRAttributeKeys, RecRef);
            NPRAttributeID."Key Layout"::WORKSHEETLINE:
                FilterView := GetAttributeFilterViewWorksheetLine(NPRAttributeKeys, RecRef);
            NPRAttributeID."Key Layout"::WORKSHEETSUBLINE:
                FilterView := GetAttributeFilterViewWorksheetSubLine(NPRAttributeKeys, RecRef);
        end;

        NPRAttributeKeys.Close();

        exit(FilterView);
    end;

    local procedure GetAttributeFilterViewMDR(var NPRAttributeKeys: Query "NPR Attribute Keys"; var RecRef: RecordRef): Text
    var
        FieldRefCode: FieldRef;
        KeyRef: KeyRef;
        KeyFilterCode: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRefCode := KeyRef.FieldIndex(1);

        while NPRAttributeKeys.Read() do begin
            if KeyFilterCode <> '' then
                KeyFilterCode += '|';
            KeyFilterCode += NPRAttributeKeys.MDR_Code_PK;
        end;

        FieldRefCode.SetFilter(KeyFilterCode);
        exit(RecRef.GetView());
    end;

    local procedure GetAttributeFilterViewDocument(var NPRAttributeKeys: Query "NPR Attribute Keys"; var RecRef: RecordRef): Text
    var
        FieldRefCode: FieldRef;
        FieldRefOption: FieldRef;
        KeyRef: KeyRef;
        KeyFilterCode: Text;
        KeyFilterOption: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRefOption := KeyRef.FieldIndex(1);
        FieldRefCode := KeyRef.FieldIndex(2);

        while NPRAttributeKeys.Read() do begin
            if KeyFilterOption <> '' then
                KeyFilterOption += '|';
            KeyFilterOption += Format(NPRAttributeKeys.MDR_Option_PK, 0, 2);

            if KeyFilterCode <> '' then
                KeyFilterCode += '|';
            KeyFilterCode += NPRAttributeKeys.MDR_Code_PK;
        end;

        FieldRefOption.SetFilter(KeyFilterOption);
        FieldRefCode.SetFilter(KeyFilterCode);
        exit(RecRef.GetView());
    end;

    local procedure GetAttributeFilterViewDocumentLine(var NPRAttributeKeys: Query "NPR Attribute Keys"; var RecRef: RecordRef): Text
    var
        FieldRefCode: FieldRef;
        FieldRefLine: FieldRef;
        FieldRefOption: FieldRef;
        KeyRef: KeyRef;
        KeyFilterCode: Text;
        KeyFilterLine: Text;
        KeyFilterOption: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRefOption := KeyRef.FieldIndex(1);
        FieldRefCode := KeyRef.FieldIndex(2);
        FieldRefLine := KeyRef.FieldIndex(3);

        while NPRAttributeKeys.Read() do begin
            if KeyFilterOption <> '' then
                KeyFilterOption += '|';
            KeyFilterOption += Format(NPRAttributeKeys.MDR_Option_PK, 0, 2);

            if KeyFilterCode <> '' then
                KeyFilterCode += '|';
            KeyFilterCode += NPRAttributeKeys.MDR_Code_PK;

            if KeyFilterLine <> '' then
                KeyFilterLine += '|';
            KeyFilterLine += Format(NPRAttributeKeys.MDR_Line_PK);
        end;

        FieldRefOption.SetFilter(KeyFilterOption);
        FieldRefCode.SetFilter(KeyFilterCode);
        FieldRefLine.SetFilter(KeyFilterLine);
        exit(RecRef.GetView());
    end;

    local procedure GetAttributeFilterViewWorksheetLine(var NPRAttributeKeys: Query "NPR Attribute Keys"; var RecRef: RecordRef): Text
    var
        FieldRefCode: FieldRef;
        FieldRefCode2: FieldRef;
        FieldRefLine: FieldRef;
        KeyRef: KeyRef;
        KeyFilterCode: Text;
        KeyFilterCode2: Text;
        KeyFilterLine: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRefCode := KeyRef.FieldIndex(1);
        FieldRefCode2 := KeyRef.FieldIndex(2);
        FieldRefLine := KeyRef.FieldIndex(3);

        while NPRAttributeKeys.Read() do begin
            if KeyFilterCode <> '' then
                KeyFilterCode += '|';
            KeyFilterCode += NPRAttributeKeys.MDR_Code_PK;

            if KeyFilterCode2 <> '' then
                KeyFilterCode2 += '|';
            KeyFilterCode2 += NPRAttributeKeys.MDR_Code_2_PK;

            if KeyFilterLine <> '' then
                KeyFilterLine += '|';
            KeyFilterLine += Format(NPRAttributeKeys.MDR_Line_PK);
        end;

        FieldRefCode.SetFilter(KeyFilterCode);
        FieldRefCode2.SetFilter(KeyFilterCode2);
        FieldRefLine.SetFilter(KeyFilterLine);
        exit(RecRef.GetView());
    end;

    local procedure GetAttributeFilterViewWorksheetSubLine(var NPRAttributeKeys: Query "NPR Attribute Keys"; var RecRef: RecordRef): Text
    var
        FieldRefCode: FieldRef;
        FieldRefCode2: FieldRef;
        FieldRefLine: FieldRef;
        FieldRefLine2: FieldRef;
        KeyRef: KeyRef;
        KeyFilterCode: Text;
        KeyFilterCode2: Text;
        KeyFilterLine: Text;
        KeyFilterLine2: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRefCode := KeyRef.FieldIndex(1);
        FieldRefCode2 := KeyRef.FieldIndex(2);
        FieldRefLine := KeyRef.FieldIndex(3);
        FieldRefLine2 := KeyRef.FieldIndex(4);

        while NPRAttributeKeys.Read() do begin
            if KeyFilterCode <> '' then
                KeyFilterCode += '|';
            KeyFilterCode += NPRAttributeKeys.MDR_Code_PK;

            if KeyFilterCode2 <> '' then
                KeyFilterCode2 += '|';
            KeyFilterCode2 += NPRAttributeKeys.MDR_Code_2_PK;

            if KeyFilterLine <> '' then
                KeyFilterLine += '|';
            KeyFilterLine += Format(NPRAttributeKeys.MDR_Line_PK);

            if KeyFilterLine2 <> '' then
                KeyFilterLine2 += '|';
            KeyFilterLine2 += Format(NPRAttributeKeys.MDR_Line_2_PK);
        end;

        FieldRefCode.SetFilter(KeyFilterCode);
        FieldRefCode2.SetFilter(KeyFilterCode2);
        FieldRefLine.SetFilter(KeyFilterLine);
        FieldRefLine2.SetFilter(KeyFilterLine2);
        exit(RecRef.GetView());
    end;

    local procedure GetRecordKeyLayout("Record": Variant): Integer
    var
        NPRAttributeID: Record "NPR Attribute ID";
        FieldRef: array[5] of FieldRef;
        KeyRef: KeyRef;
        RecRef: RecordRef;
        i: Integer;
        DataType: array[5] of Variant;
    begin
        if not Record2RecRef(Record, RecRef) then
            exit(-1);
        KeyRef := RecRef.KeyIndex(1);
        if KeyRef.FieldCount > 5 then
            exit(NPRAttributeID."Key Layout"::MASTERDATA);

        for i := 1 to KeyRef.FieldCount do begin
            FieldRef[i] := KeyRef.FieldIndex(i);
            DataType[i] := FieldRef[i].Value;
        end;

        KeyRef := RecRef.KeyIndex(1);
        case KeyRef.FieldCount of
            2:
                begin
                    if DataType[1].IsOption and DataType[2].IsCode then
                        exit(NPRAttributeID."Key Layout"::DOCUMENT);
                end;
            3:
                begin
                    if DataType[1].IsOption and DataType[2].IsCode and DataType[3].IsInteger then
                        exit(NPRAttributeID."Key Layout"::DOCUMENTLINE);
                    if DataType[1].IsCode and DataType[2].IsCode and DataType[3].IsInteger then
                        exit(NPRAttributeID."Key Layout"::WORKSHEETLINE);
                end;
            4:
                begin
                    if DataType[1].IsCode and DataType[2].IsCode and DataType[3].IsInteger and DataType[4].IsInteger then
                        exit(NPRAttributeID."Key Layout"::DOCUMENTLINE);
                end;
        end;

        exit(NPRAttributeID."Key Layout"::MASTERDATA);
    end;

    local procedure Record2RecRef("Record": Variant; var RecRef: RecordRef): Boolean
    begin
        case true of
            Record.IsRecord:
                RecRef.GetTable(Record);
            Record.IsRecordRef:
                RecRef := Record;
            else
                exit(false);
        end;

        exit(true);
    end;

    procedure SetAttributeFilter(var NPRAttributeValueSet: Record "NPR Attribute Value Set"): Boolean
    var
        NPRAttributeFilter: Report "NPR Attribute Filter";
        Document: XmlDocument;
        Node: XmlNode;
        NodeList: XmlNodeList;
        AttributeColletion: XmlAttributeCollection;
        Attribute: XmlAttribute;
        Parameters: Text;
        IsNPRAttributeValueSet: Boolean;
    begin
        Clear(NPRAttributeFilter);

        Parameters := NPRAttributeFilter.RunRequestPage();
        if Parameters = '' then
            exit(false);

        XmlDocument.ReadFrom(Parameters, Document);

        if not Document.SelectNodes('/ReportParameters/DataItems/DataItem', NodeList) then
            exit(false);

        if NodeList.Count() = 0 then
            exit(false);

        foreach Node in NodeList do begin
            AttributeColletion := Node.AsXmlElement().Attributes();
            if AttributeColletion.Get('name', Attribute) then
                IsNPRAttributeValueSet := Attribute.Value() = 'NPR Attribute Value Set';

            if IsNPRAttributeValueSet then begin
                NPRAttributeValueSet.SetView(Node.AsXmlElement().InnerText());
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure GetAttributeShortcut(TableID: Integer; AttributeReference: Integer; var vAttributeID: Record "NPR Attribute ID") bOK: Boolean
    begin

        vAttributeID.SetCurrentKey("Table ID");
        vAttributeID.SetFilter("Table ID", '=%1', TableID);
        vAttributeID.SetFilter("Shortcut Attribute ID", '=%1', AttributeReference);
        if (vAttributeID.IsEmpty()) then begin
            vAttributeID.Reset();
            vAttributeID.SetFilter("Table ID", '=%1', TableID);
            vAttributeID.SetFilter(vAttributeID."Entity Attribute ID", '=%1', AttributeReference);
            if (vAttributeID.IsEmpty()) then
                exit(false);
        end;

        exit(vAttributeID.FindFirst());
    end;

    procedure GetAttributeKey(TableID: Integer; "MDR Code PK": Code[20]; "MDR Line PK": Integer; "MDR Option PK": Option; "MDR Code 2 PK": Code[20]; "MDR Line 2 PK": Integer; var vAttributeKey: Record "NPR Attribute Key"; WithInsert: Boolean) bOK: Boolean
    begin

        vAttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        vAttributeKey.SetFilter("Table ID", '=%1', TableID);
        vAttributeKey.SetFilter("MDR Code PK", '=%1', "MDR Code PK");
        vAttributeKey.SetFilter("MDR Option PK", '=%1', "MDR Option PK");
        vAttributeKey.SetFilter("MDR Line PK", '=%1', "MDR Line PK");
        vAttributeKey.SetFilter("MDR Code 2 PK", '=%1', "MDR Code 2 PK");
        vAttributeKey.SetFilter("MDR Line 2 PK", '=%1', "MDR Line 2 PK");

        if (vAttributeKey.IsEmpty()) then begin
            vAttributeKey.Init();
            vAttributeKey."Attribute Set ID" := 0;
            vAttributeKey."Table ID" := TableID;
            vAttributeKey."MDR Code PK" := "MDR Code PK";
            vAttributeKey."MDR Option PK" := "MDR Option PK";
            vAttributeKey."MDR Line PK" := "MDR Line PK";
            vAttributeKey."MDR Code 2 PK" := "MDR Code 2 PK";
            vAttributeKey."MDR Line 2 PK" := "MDR Line 2 PK";

            if (WithInsert) then
                vAttributeKey.Insert();
        end;

        exit(vAttributeKey.FindFirst());
    end;

    procedure DoAttributeValueCodeLookup(AttributeCode: Code[20]; var Text: Text[250]) Found: Boolean
    var
        AttrLookupValue: Record "NPR Attribute Lookup Value";
        PartOfText: Text[132];
        Length: Integer;
        Attribute: Record "NPR Attribute";
        RecRef: RecordRef;
        FieldRefValue: FieldRef;
    begin
        Attribute.Get(AttributeCode);
        if ((Attribute."On Validate" = Attribute."On Validate"::VALUE_LOOKUP) and (Attribute."LookUp Table")) then begin
            RecRef.Open(Attribute."LookUp Table Id");
            FieldRefValue := RecRef.Field(Attribute."LookUp Value Field Id");
            FieldRefValue.SetFilter('=%1', Text);
            if RecRef.FindFirst() then begin
                exit(true);
            end else begin
                exit(false);
            end;
        end;

        PartOfText := DelChr(Text, '<>', ' ');
        Length := StrLen(Text);
        if (Length = 0) then exit(true);

        if ('?' = CopyStr(PartOfText, 1, 1)) then
            PartOfText := CopyStr(PartOfText, 2);

        AttrLookupValue.SetFilter("Attribute Code", '=%1', AttributeCode);
        if (PartOfText = '') then begin
            if (PAGE.RunModal(0, AttrLookupValue) = ACTION::LookupOK) then
                Text := AttrLookupValue."Attribute Value Code";
            exit(true);
        end;

        AttrLookupValue.SetFilter("Attribute Value Code", '=%1', CopyStr(PartOfText, 1, MaxStrLen(AttrLookupValue."Attribute Value Code")));
        if (not AttrLookupValue.FindFirst()) then begin
            AttrLookupValue.SetFilter("Attribute Value Code", '%1*', CopyStr(PartOfText, 1, MaxStrLen(AttrLookupValue."Attribute Value Code")));
            if (not AttrLookupValue.FindFirst()) then
                exit(false);
        end;

        Text := AttrLookupValue."Attribute Value Code";
        exit(true);
    end;

    procedure FillValueArray(var TextArray: array[40] of Text[250]; SetID: Integer; TableID: Integer)
    var
        AttributeValueSet: Record "NPR Attribute Value Set";
        Attribute: Record "NPR Attribute";
        AttributeID: Record "NPR Attribute ID";
    begin
        AttributeValueSet.SetFilter("Attribute Set ID", '=%1', SetID);
        if (AttributeValueSet.FindSet()) then begin
            repeat

                if (Attribute.Get(AttributeValueSet."Attribute Code")) then begin
                    if (Attribute.Blocked = false) then begin
                        if (AttributeID.Get(TableID, AttributeValueSet."Attribute Code")) then begin

                            if (AttributeID."Shortcut Attribute ID" > 0) then
                                TextArray[AttributeID."Shortcut Attribute ID"] :=
                                  CopyStr(GetTextValue(Attribute, AttributeValueSet), 1, MaxStrLen(TextArray[1]));

                        end;
                    end;
                end;

            until (AttributeValueSet.Next() = 0);
        end;
    end;

    procedure GetTextValue(Attribute: Record "NPR Attribute"; AttributeValueSet: Record "NPR Attribute Value Set") TextValue: Text[250]
    var
        AttributeCodeValue: Record "NPR Attribute Lookup Value";
        myInt: BigInteger;
        Pct1Lbl: Label '[%1] - %2', locked = true;
    begin

        case (Attribute."Value Datatype") of
            Attribute."Value Datatype"::DT_TEXT:
                exit(AttributeValueSet."Text Value");
            Attribute."Value Datatype"::DT_CODE:
                begin
                    if (Attribute."On Format" = Attribute."On Format"::CUSTOM) then begin
                        if (AttributeCodeValue.Get(Attribute.Code, CopyStr(AttributeValueSet."Text Value", 1, 20))) then
                            exit(StrSubstNo(Pct1Lbl, AttributeCodeValue."Attribute Value Code", AttributeCodeValue."Attribute Value Name"));
                    end;
                    exit(UpperCase(AttributeValueSet."Text Value"));
                end;
            Attribute."Value Datatype"::DT_DATE:
                exit(FormatToText(Attribute."On Format", DT2Date(AttributeValueSet."Datetime Value")));
            Attribute."Value Datatype"::DT_DATETIME:
                exit(FormatToText(Attribute."On Format", AttributeValueSet."Datetime Value"));
            Attribute."Value Datatype"::DT_DECIMAL:
                exit(FormatToText(Attribute."On Format", AttributeValueSet."Numeric Value"));
            Attribute."Value Datatype"::DT_INTEGER:
                begin
                    myInt := Round(AttributeValueSet."Numeric Value", 1);
                    exit(FormatToText(Attribute."On Format", myInt));
                end;
            Attribute."Value Datatype"::DT_BOOLEAN:
                exit(FormatToText(Attribute."On Format", AttributeValueSet."Boolean Value"));
        end;
    end;

    procedure FormatToText(FormatOption: Option; AttributeValue: Variant) TextValue: Text[250]
    var
        Attribute: Record "NPR Attribute";
    begin

        case FormatOption of
            Attribute."On Format"::NATIVE:
                exit(Format(AttributeValue, 0, 9));
            Attribute."On Format"::USER:
                exit(Format(AttributeValue));
        end;
    end;

    local procedure IsAttributeTableActive(TableNumber: Integer; var KeyLayout: Option): Boolean
    var
        AttributeID: Record "NPR Attribute ID";
    begin
        AttributeID.SetCurrentKey("Table ID");
        AttributeID.SetFilter("Table ID", '=%1', TableNumber);
        AttributeID.SetFilter("Key Layout", '<>%1', AttributeID."Key Layout"::NOT_SET);

        if (not AttributeID.FindFirst()) then
            exit(false);

        KeyLayout := AttributeID."Key Layout";
        exit(true);
    end;

    procedure IGGetAttributeValue("Record": Variant; AttributeCode: Code[20]; Silent: Boolean) AttributeTextValue: Text
    var
        RecRef: RecordRef;
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        TableId: Integer;
        KeyRef: KeyRef;
        MDRCodePK: Code[20];
        MDRLinePK: Integer;
        MDROptionPK: Option;
        MDRCode2PK: Code[20];
        MDRLine2PK: Integer;
        AttributeKey: Record "NPR Attribute Key";
    begin
        if (AttributeCode = '') then exit('');

        if not Record2RecRef(Record, RecRef) then begin
            if Silent then
                exit('');

            Error(Text000);
        end;

        TableId := RecRef.Number;
        KeyRef := RecRef.KeyIndex(1);

        if (KeyRef.FieldCount <> 1) then begin
            if not Silent then begin
                Error('Only one keyvalue allowed in function IGGetAttributeValue.');
            end else begin
                exit('');
            end;
        end;

        GetMDRKeyValue(KeyRef, MDRCodePK);
        //WIP - to handle when needed in case
        MDRLinePK := 0;
        MDROptionPK := 0;
        MDRCode2PK := '';
        MDRLine2PK := 0;

        if not GetAttributeKey(TableId, MDRCodePK, MDRLinePK, MDROptionPK, MDRCode2PK, MDRLine2PK, AttributeKey, false) then begin
            if not Silent then begin
                Error('Attribute key can not be found in function IGGetAttributeValue.');
            end else begin
                exit('');
            end;
        end;

        if not Silent then begin
            NPRAttribute.Get(AttributeCode);
        end else begin
            if not NPRAttribute.Get(AttributeCode) then exit('');
        end;

        if not Silent then begin
            NPRAttributeValueSet.Get(AttributeKey."Attribute Set ID", NPRAttribute.Code);
        end else begin
            if not NPRAttributeValueSet.Get(AttributeKey."Attribute Set ID", NPRAttribute.Code) then exit('');
        end;


        AttributeTextValue := GetTextValue(NPRAttribute, NPRAttributeValueSet);
        exit(AttributeTextValue);
    end;

    procedure IGSetAttributeValue("Record": Variant; AttributeCode: Code[20]; AttributeValue: Text)
    var
        RecRef: RecordRef;
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        TableId: Integer;
        KeyRef: KeyRef;
        MDRCodePK: Code[20];
        MDRLinePK: Integer;
        MDROptionPK: Option;
        MDRCode2PK: Code[20];
        MDRLine2PK: Integer;
        NPRAttributeKey: Record "NPR Attribute Key";
        WithInsert: Boolean;
        NPRAttributeID: Record "NPR Attribute ID";
    begin
        if (AttributeCode = '') then Error('AttributeCode must be set in function IGSetAttributeValue');

        if not Record2RecRef(Record, RecRef) then
            Error(Text000);

        TableId := RecRef.Number;
        KeyRef := RecRef.KeyIndex(1);

        if (KeyRef.FieldCount <> 1) then Error('Only one keyvalue allowed in function IGSetAttributeValue.');

        GetMDRKeyValue(KeyRef, MDRCodePK);
        //WIP - to handle when needed in case
        MDRLinePK := 0;
        MDROptionPK := 0;
        MDRCode2PK := '';
        MDRLine2PK := 0;


        //Lets see if there is an attribute setup to use
        NPRAttribute.Reset();
        NPRAttribute.SetFilter(Blocked, '=%1', false);
        NPRAttribute.SetFilter(Code, '=%1', AttributeCode);
        NPRAttribute.FindFirst();

        NPRAttributeID.Reset();
        NPRAttributeID.SetFilter("Attribute Code", '=%1', NPRAttribute.Code);
        NPRAttributeID.SetFilter("Table ID", '=%1', TableId);
        NPRAttributeID.FindFirst();

        //Attribute exists in setup, lets see if value exist or else create it
        WithInsert := true;
        if not GetAttributeKey(TableId, MDRCodePK, MDRLinePK, MDROptionPK, MDRCode2PK, MDRLine2PK, NPRAttributeKey, WithInsert) then Error('Attribute key can not be found or created in function IGSetAttributeValue.');

        SetAttributeValue(NPRAttributeKey."Attribute Set ID", NPRAttribute.Code, AttributeValue, NPRAttributeValueSet);
    end;

    procedure OnPageLookUp(TableID: Integer; AttributeReference: Integer; PKCode: Code[20]; var Value: Text)
    var
        Attribute: Record "NPR Attribute";
        AttributeID: Record "NPR Attribute ID";
        NPRAttributeLookupValue: Record "NPR Attribute Lookup Value";
        RecRef: RecordRef;
        FieldRefValue: FieldRef;
        FieldRefDescription: FieldRef;
        TEMPNPRAttributeLookupValue: Record "NPR Attribute Lookup Value" temporary;
        OrgValue: Text;
    begin
        OrgValue := Value;

        if (not GetAttributeShortcut(TableID, AttributeReference, AttributeID)) then
            Error('Attribute %1 has not been activated for table %2', AttributeReference, TableID);

        Attribute.Get(AttributeID."Attribute Code");
        Attribute.TestField(Blocked, false);

        if not (Attribute."On Validate" = Attribute."On Validate"::VALUE_LOOKUP) then exit;

        if not Attribute."LookUp Table" then begin
            NPRAttributeLookupValue.Reset();
            NPRAttributeLookupValue.SetFilter("Attribute Code", Attribute.Code);
            if PAGE.RunModal(PAGE::"NPR Attribute Value Lookup", NPRAttributeLookupValue) = ACTION::LookupOK then begin
                Value := NPRAttributeLookupValue."Attribute Value Code";
            end;
        end else begin
            RecRef.Open(Attribute."LookUp Table Id");
            FieldRefValue := RecRef.Field(Attribute."LookUp Value Field Id");
            FieldRefDescription := RecRef.Field(Attribute."LookUp Description Field Id");
            if RecRef.FindSet() then
                repeat
                    TEMPNPRAttributeLookupValue.Init();
                    TEMPNPRAttributeLookupValue."Attribute Code" := Attribute.Code;
                    TEMPNPRAttributeLookupValue."Attribute Value Code" := FieldRefValue.Value;
                    TEMPNPRAttributeLookupValue."Attribute Value Description" := FieldRefDescription.Value;
                    TEMPNPRAttributeLookupValue.Insert();
                until (0 = RecRef.Next());
            if PAGE.RunModal(PAGE::"NPR Attribute Value Lookup", TEMPNPRAttributeLookupValue) = ACTION::LookupOK then begin
                Value := TEMPNPRAttributeLookupValue."Attribute Value Code";
            end;
        end;

        if (Value <> OrgValue) then begin
            SetMasterDataAttributeValue(TableID, AttributeReference, PKCode, Value);
        end;
    end;

    procedure MakeText(VAR Text: Text): Integer;
    VAR
        StandardText: Record "Standard Text";
        PartOfText: Text[132];
        Position: Integer;
        Length: Integer;
    BEGIN
        Position := 1;
        Length := STRLEN(Text);
        ReadCharacter(' ', Text, Position, Length);
        if not ReadSymbol('?', Text, Position, Length) then
            exit(0);
        PartOfText := COPYSTR(Text, Position);
        if PartOfText = '' then begin
            if PAGE.RUNMODAL(0, StandardText) = ACTION::LookupOK then
                Text := StandardText.Description;
            exit(0);
        end;
        StandardText.Code := COPYSTR(Text, Position, MAXSTRLEN(StandardText.Code));
        if not StandardText.FIND('=>') or
           (UPPERCASE(PartOfText) <> COPYSTR(StandardText.Code, 1, STRLEN(PartOfText)))
        then
            exit(Position);
        Text := StandardText.Description;
        exit(0);
    end;

    local procedure ReadCharacter(Character: Text[50]; Text: Text; VAR Position: Integer; Length: Integer);
    begin
        while (Position <= Length) and (STRPOS(Character, UPPERCASE(COPYSTR(Text, Position, 1))) <> 0) do
            Position := Position + 1;
    end;

    local procedure ReadSymbol(Token: Text[30]; Text: Text; VAR Position: Integer; Length: Integer): Boolean;
    begin
        if Token <> COPYSTR(Text, Position, STRLEN(Token)) then
            exit(false);
        Position := Position + STRLEN(Token);
        ReadCharacter(' ', Text, Position, Length);
        exit(true);
    end;

    procedure MakeDateText(VAR DateText: Text): Integer;
    VAR
        Date: Date;
        PartOfText: Text;
        Position: Integer;
        Length: Integer;
    BEGIN
        Position := 1;
        Length := STRLEN(DateText);
        ReadCharacter(' ', DateText, Position, Length);
        if not FindText(PartOfText, DateText, Position, Length) then
            exit(0);
        case PartOfText of
            COPYSTR('TODAY', 1, STRLEN(PartOfText)), COPYSTR(TodayText, 1, STRLEN(PartOfText)):
                Date := Today();
            COPYSTR('WORKDATE', 1, STRLEN(PartOfText)), COPYSTR(WorkdateText, 1, STRLEN(PartOfText)):
                Date := WorkDate();
            else
                exit(0);
        end;
        Position := Position + STRLEN(PartOfText);
        ReadCharacter(' ', DateText, Position, Length);
        if Position > Length then begin
            DateText := FORMAT(Date);
            exit(0);
        end;
        exit(Position);
    END;

    LOCAL PROCEDURE FindText(VAR PartOfText: Text; Text: Text; Position: Integer; Length: Integer): Boolean;
    VAR
        Position2: Integer;
    BEGIN
        Position2 := Position;
        ReadCharacter(AlphabetText, Text, Position, Length);
        if Position = Position2 then
            exit(false);
        PartOfText := UPPERCASE(COPYSTR(Text, Position2, Position - Position2));
        exit(true);
    END;

    PROCEDURE MakeDateTimeText(VAR DateTimeText: Text): Integer;
    VAR
        Date: Date;
        Time: Time;
    BEGIN
        if GetSeparateDateTime(DateTimeText, Date, Time) then begin
            if Date = 0D then
                exit(0);
            if Time = 000000T then
                Time := 000000T;
            DateTimeText := FORMAT(CREATEDATETIME(Date, Time));
        end;
        exit(0);
    END;

    PROCEDURE GetSeparateDateTime(DateTimeText: Text; VAR Date: Date; VAR Time: Time): Boolean;
    VAR
        DateText: Text[250];
        TimeText: Text[250];
        Position: Integer;
        Length: Integer;
    BEGIN
        if DateTimeText in [NowText, 'NOW'] then
            DateTimeText := FORMAT(CURRENTDATETIME);
        Date := 0D;
        Time := 000000T;
        Position := 1;
        Length := STRLEN(DateTimeText);
        ReadCharacter(' ', DateTimeText, Position, Length);
        ReadUntilCharacter(' ', DateTimeText, Position, Length);
        DateText := DELCHR(COPYSTR(DateTimeText, 1, Position - 1), '<>');
        TimeText := DELCHR(COPYSTR(DateTimeText, Position), '<>');
        if DateText = '' then
            exit(true);

        if MakeDateText(DateText) = 0 then;
        if not EVALUATE(Date, DateText) then
            exit(false);

        if TimeText = '' then
            exit(true);

        if MakeTimeText(TimeText) = 0 then;
        if EVALUATE(Time, TimeText) then
            exit(true);
    END;

    LOCAL PROCEDURE ReadUntilCharacter(Character: Text[50]; Text: Text; VAR Position: Integer; Length: Integer);
    BEGIN
        while (Position <= Length) and (STRPOS(Character, UPPERCASE(COPYSTR(Text, Position, 1))) = 0) do
            Position := Position + 1;
    END;

    PROCEDURE MakeTimeText(VAR TimeText: Text): Integer;
    VAR
        PartOfText: Text[132];
        Position: Integer;
        Length: Integer;
    BEGIN
        Position := 1;
        Length := STRLEN(TimeText);
        ReadCharacter(' ', TimeText, Position, Length);
        if not FindText(PartOfText, TimeText, Position, Length) then
            exit(0);
        if PartOfText <> COPYSTR(TimeText, 1, STRLEN(PartOfText)) then
            exit(0);
        Position := Position + STRLEN(PartOfText);
        ReadCharacter(' ', TimeText, Position, Length);
        if Position <= Length then
            exit(Position);
        TimeText := FORMAT(000000T + ROUND(TIME - 000000T, 1000));
        exit(0);
    END;
}

