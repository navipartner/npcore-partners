codeunit 6151125 "NpIa Item AddOn Mgt."
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181113  CASE 334922 Added Web Client Dependency functionality
    // NPR5.50/MHA /20190521  CASE 355080 Added function FormatJson() and "Unit Price" = 0 should result in default price


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Approve';
        Text001: Label 'Cancel';

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        SaleLinePOSAddOn2: Record "NpIa Sale Line POS AddOn";
        POSSaleLine: Codeunit "POS Sale Line";
        DeleteLine: Boolean;
    begin
        if Rec.IsTemporary then
          exit;

        SaleLinePOSAddOn.SetRange("Register No.",Rec."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type",Rec."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date",Rec.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.",Rec."Line No.");
        if SaleLinePOSAddOn.IsEmpty then
          exit;

        SaleLinePOSAddOn.FindSet;
        repeat
          SaleLinePOSAddOn2.SetRange("Register No.",SaleLinePOSAddOn."Register No.");
          SaleLinePOSAddOn2.SetRange("Sales Ticket No.",SaleLinePOSAddOn."Sales Ticket No.");
          SaleLinePOSAddOn2.SetRange("Sale Type",SaleLinePOSAddOn."Sale Type");
          SaleLinePOSAddOn2.SetRange("Sale Date",SaleLinePOSAddOn."Sale Date");
          SaleLinePOSAddOn2.SetFilter("Sale Line No.",'<>%1',SaleLinePOSAddOn."Sale Line No.");
          SaleLinePOSAddOn2.SetRange("Applies-to Line No.",SaleLinePOSAddOn."Sale Line No.");
          if SaleLinePOSAddOn2.FindSet then
            repeat
              DeleteLine := SaleLinePOS.Get(
                SaleLinePOSAddOn2."Register No.",
                SaleLinePOSAddOn2."Sales Ticket No.",
                SaleLinePOSAddOn2."Sale Date",
                SaleLinePOSAddOn2."Sale Type",
                SaleLinePOSAddOn2."Sale Line No.");

              SaleLinePOSAddOn2.Delete(true);

              if DeleteLine then
                SaleLinePOS.Delete(true);
            until SaleLinePOSAddOn2.Next = 0;
        until SaleLinePOSAddOn.Next = 0;

        SaleLinePOSAddOn.DeleteAll;
        if (Rec.Find ()) then ;
    end;

    local procedure "--- POS Data Source"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text;Extensions: DotNet List_Of_T)
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
          exit;
        if not ItemAddOnEnabled() then
          exit;

        Extensions.Add('ItemAddOn');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet DataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet DataType;
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
          exit;
        if ExtensionName <> 'ItemAddOn' then
          exit;

        Handled := true;

        DataSource.AddColumn('ItemAddOn','Item AddOn',DataType.Boolean,false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet DataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        ItemAddOn: Record "NpIa Item AddOn";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        Color: Text;
        Weight: Text;
        Style: Text;
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
          exit;
        if ExtensionName <> 'ItemAddOn' then
          exit;

        Handled := true;

        RecRef.SetTable(SaleLinePOS);
        DataRow.Fields.Add('ItemAddOn',FindItemAddOn(SaleLinePOS,ItemAddOn));
    end;

    [BusinessEvent(false)]
    local procedure OnGetLineStyle(var Color: Text;var Weight: Text;var Style: Text;SaleLinePOS: Record "Sale Line POS";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    local procedure "--- Init Script"()
    begin
    end;

    procedure InitScriptAddOnLines(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
        SaleLinePOS: Record "Sale Line POS";
        AddOnLine: Text;
        SelectedVariant: Text;
        i: Integer;
        ShowEdit: Integer;
        Comment: Text;
    begin
        //-NPR5.48 [334922]
        Script := '$scope.addon_lines = [';

        NpIaItemAddOnLine.SetRange("AddOn No.",NpIaItemAddOn."No.");
        if NpIaItemAddOnLine.FindSet then
          repeat
            Comment := '';
            Clear(SaleLinePOS);
            if FindSaleLinePOS(SalePOS,AppliesToLineNo,NpIaItemAddOnLine,SaleLinePOS) then
              Comment := GetItemAddOnComment(NpIaItemAddOn,SaleLinePOS);

            AddOnLine := '{ line_no: ' + Format(NpIaItemAddOnLine."Line No.");
            ShowEdit := -1;
            if (NpIaItemAddOn."Comment POS Info Code" <> '') and NpIaItemAddOnLine."Comment Enabled" then
              ShowEdit := 0;
            AddOnLine += ', show_edit: ' + Format(ShowEdit);
            //-NPR5.50 [355080]
            //AddOnLine += ', description: "' + NpIaItemAddOnLine.Description + '"';
            AddOnLine += ', description: "' + FormatJson(NpIaItemAddOnLine.Description) + '"';
            //+NPR5.50 [355080]
            AddOnLine += ', qty: ' + Format(SaleLinePOS.Quantity);
            AddOnLine += ', comment: "' + Comment + '"';
            case NpIaItemAddOnLine.Type of
              NpIaItemAddOnLine.Type::Quantity:
                begin
                  AddOnLine += ', type: "qty-holder"';
                end;
              NpIaItemAddOnLine.Type::Select:
                begin
                  AddOnLine += ', type: "trigger"';
                  AddOnLine += ', show_variants: 0';
                  SelectedVariant := '"null"';
                  AddOnLine += ', variants: [';
                  NpIaItemAddOnLineOption.SetRange("AddOn No.",NpIaItemAddOnLine."AddOn No.");
                  NpIaItemAddOnLineOption.SetRange("AddOn Line No.",NpIaItemAddOnLine."Line No.");
                  if NpIaItemAddOnLineOption.FindSet then
                    repeat
                      AddOnLine += '{ line_no: ' + Format(NpIaItemAddOnLineOption."Line No.");
                      //-NPR5.50 [355080]
                      //AddOnLine += ', description: "' + FORMAT(NpIaItemAddOnLineOption.Description) + '"},';
                      AddOnLine += ', description: "' + FormatJson(NpIaItemAddOnLineOption.Description) + '"},';
                      //+NPR5.50 [355080]
                      if (NpIaItemAddOnLineOption.Description = SaleLinePOS.Description) and (NpIaItemAddOnLineOption."Item No." = SaleLinePOS."No.") and
                        (NpIaItemAddOnLineOption."Variant Code" = SaleLinePOS."Variant Code")
                      then
                        SelectedVariant := Format(i);
                      i += 1;
                    until NpIaItemAddOnLineOption.Next = 0;
                  AddOnLine += ']';
                  AddOnLine += ', selected_variant: ' + SelectedVariant;
                end;
            end;
            AddOnLine += '},';
            Script += AddOnLine;
          until NpIaItemAddOnLine.Next = 0;

        Script += '];';
        exit(Script);
        //+NPR5.48 [334922]
    end;

    procedure InitScriptLabels(NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NPREWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        //-NPR5.48 [334922]
        Script := '$scope.labels = ' +
          '{ ' +
            //-NPR5.50 [355080]
            //'title: "' + NpIaItemAddOn.Description + '"' +
            'title: "' + FormatJson(NpIaItemAddOn.Description) + '"' +
            //+NPR5.50 [355080]
            ', approve: "' + Text000 + '"' +
            ', cancel: "' + Text001 + '" ' +
          '}';

        exit(Script);
        //+NPR5.48 [334922]
    end;

    local procedure FormatJson(Value: Text) JsonValue: Text
    var
        JsonConvert: DotNet JsonConvert;
        Formatting: DotNet Formatting;
    begin
        //-NPR5.50 [355080]
        JsonValue := JsonConvert.SerializeObject(Value,Formatting.None);
        JsonValue := CopyStr(JsonValue,2);
        JsonValue := DelStr(JsonValue,StrLen(JsonValue));
        exit(JsonValue);
        //+NPR5.50 [355080]
    end;

    local procedure "--- Insert POS Lines"()
    begin
    end;

    procedure InsertPOSAddOnLines(NpIaItemAddOn: Record "NpIa Item AddOn";AddOnLines: DotNet JToken;POSSession: Codeunit "POS Session";AppliesToLineNo: Integer)
    var
        SaleLinePOS: Record "Sale Line POS";
        AddOnLine: DotNet JToken;
        AddOnLineList: DotNet IList;
    begin
        //-NPR5.48 [334922]
        AddOnLineList := AddOnLines.SelectTokens('$[?(@[''line_no''] > 0)]');
        foreach AddOnLine in AddOnLineList do begin
          if InsertPOSAddOnLine(NpIaItemAddOn,AddOnLine,POSSession,AppliesToLineNo,SaleLinePOS) then
            InsertPOSAddOnLineComment(AddOnLine,NpIaItemAddOn,SaleLinePOS);
        end;
        //+NPR5.48 [334922]
    end;

    procedure InsertPOSAddOnLine(NpIaItemAddOn: Record "NpIa Item AddOn";AddOnLine: DotNet JToken;POSSession: Codeunit "POS Session";AppliesToLineNo: Integer;var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        LineNo: Integer;
        PrevRec: Text;
    begin
        //-NPR5.48 [334922]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        ParsePOSAddOnLine(NpIaItemAddOn,AddOnLine,NpIaItemAddOnLine);
        if not FindSaleLinePOS(SalePOS,AppliesToLineNo,NpIaItemAddOnLine,SaleLinePOS) then begin
          if NpIaItemAddOnLine.Quantity <= 0 then
            exit(false);

          POSSession.GetSaleLine(POSSaleLine);
          POSSaleLine.GetNewSaleLine(SaleLinePOS);
          SaleLinePOS.Type := SaleLinePOS.Type::Item;
          SaleLinePOS."Variant Code" := NpIaItemAddOnLine."Variant Code";
          SaleLinePOS.Validate("No.",NpIaItemAddOnLine."Item No.");
          SaleLinePOS.Description := NpIaItemAddOnLine.Description;
          SaleLinePOS.Validate(Quantity,NpIaItemAddOnLine.Quantity);
          //-NPR5.50 [355080]
          // SaleLinePOS."Manual Item Sales Price" := TRUE;
          // SaleLinePOS.VALIDATE("Unit Price",NpIaItemAddOnLine."Unit Price");
          if NpIaItemAddOnLine."Unit Price" <> 0 then begin
            SaleLinePOS."Manual Item Sales Price" := true;
            SaleLinePOS.Validate("Unit Price",NpIaItemAddOnLine."Unit Price");
          end;
          //+NPR5.50 [355080]
          SaleLinePOS.Validate(Quantity,NpIaItemAddOnLine.Quantity);
          SaleLinePOS.Validate("Discount %",NpIaItemAddOnLine."Discount %");
          POSSaleLine.InsertLine(SaleLinePOS);


          if SaleLinePOSAddOn.FindLast then;
          LineNo := SaleLinePOSAddOn."Line No." + 10000;
          SaleLinePOSAddOn.Init;
          SaleLinePOSAddOn."Register No." := SaleLinePOS."Register No.";
          SaleLinePOSAddOn."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          SaleLinePOSAddOn."Sale Type" := SaleLinePOS."Sale Type";
          SaleLinePOSAddOn."Sale Date" := SaleLinePOS.Date;
          SaleLinePOSAddOn."Sale Line No." := SaleLinePOS."Line No.";
          SaleLinePOSAddOn."Line No." := LineNo;
          SaleLinePOSAddOn."Applies-to Line No." := AppliesToLineNo;
          SaleLinePOSAddOn."AddOn No." := NpIaItemAddOnLine."AddOn No.";
          SaleLinePOSAddOn."AddOn Line No." := NpIaItemAddOnLine."Line No.";
          SaleLinePOSAddOn.Insert(true);
        end;

        if NpIaItemAddOnLine.Quantity <= 0 then begin
          SaleLinePOS.Delete(true);
          exit(false);
        end;

        PrevRec := Format(SaleLinePOS);

        BeforeInsertPOSAddOnLine(SalePOS,AppliesToLineNo,NpIaItemAddOnLine);
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."Variant Code" := NpIaItemAddOnLine."Variant Code";
        SaleLinePOS.Validate("No.",NpIaItemAddOnLine."Item No.");
        SaleLinePOS.Description := NpIaItemAddOnLine.Description;
        //-NPR5.50 [355080]
        // SaleLinePOS."Manual Item Sales Price" := TRUE;
        // SaleLinePOS.VALIDATE("Unit Price",NpIaItemAddOnLine."Unit Price");
        if NpIaItemAddOnLine."Unit Price" <> 0 then begin
          SaleLinePOS."Manual Item Sales Price" := true;
          SaleLinePOS.Validate("Unit Price",NpIaItemAddOnLine."Unit Price");
        end;
        //+NPR5.50 [355080]
        SaleLinePOS.Validate(Quantity,NpIaItemAddOnLine.Quantity);
        SaleLinePOS.Validate("Discount %",NpIaItemAddOnLine."Discount %");
        if PrevRec <> Format(SaleLinePOS) then begin
          SaleLinePOS.Modify(true);
          POSSaleLine.RefreshCurrent();
        end;

        exit(true);
        //+NPR5.48 [334922]
    end;

    local procedure InsertPOSAddOnLineComment(AddOnLine: DotNet JToken;NpIaItemAddOn: Record "NpIa Item AddOn";var SaleLinePOS: Record "Sale Line POS")
    var
        POSInfo: Record "POS Info";
        POSInfoTransaction: Record "POS Info Transaction";
        Comment: Text;
        EntryNo: Integer;
    begin
        //-NPR5.48 [334922]
        if NpIaItemAddOn."Comment POS Info Code" = '' then
          exit;
        if not POSInfo.Get(NpIaItemAddOn."Comment POS Info Code") then
          exit;

        POSInfoTransaction.SetCurrentKey("Entry No.");
        POSInfoTransaction.SetRange("POS Info Code",POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.",SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        if POSInfoTransaction.FindLast then;
        EntryNo := POSInfoTransaction."Entry No.";

        Clear(POSInfoTransaction);
        POSInfoTransaction.SetRange("POS Info Code",POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.",SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.",SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date",SaleLinePOS.Date);
        if POSInfoTransaction.FindFirst then
          POSInfoTransaction.DeleteAll;

        Comment := GetValueAsString(AddOnLine,'comment');
        if Comment = '' then
          exit;

        while Comment <> '' do begin
          EntryNo += 1;

          POSInfoTransaction.Init;
          POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
          POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
          POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
          POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
          POSInfoTransaction."Entry No." := EntryNo;
          POSInfoTransaction."POS Info Code" := POSInfo.Code;
          POSInfoTransaction."POS Info" := CopyStr(Comment,1,MaxStrLen(POSInfoTransaction."POS Info"));
          POSInfoTransaction.Insert(true);

          Comment := DelStr(Comment,1,StrLen(POSInfoTransaction."POS Info"));
        end;
        //+NPR5.48 [334922]
    end;

    local procedure ParsePOSAddOnLine(NpIaItemAddOn: Record "NpIa Item AddOn";AddOnLine: DotNet JToken;var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    var
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
        AddOnLineVariant: DotNet JToken;
        LineNo: Integer;
        SelectedVariant: Integer;
    begin
        //-NPR5.48 [334922]
        LineNo := GetValueAsInt(AddOnLine,'line_no');
        NpIaItemAddOnLine.Get(NpIaItemAddOn."No.",LineNo);
        case NpIaItemAddOnLine.Type of
          NpIaItemAddOnLine.Type::Quantity:
            begin
              NpIaItemAddOnLine.Quantity := GetValueAsDec(AddOnLine,'qty');
            end;
          NpIaItemAddOnLine.Type::Select:
            begin
              NpIaItemAddOnLine.Quantity := 0;
              if not Evaluate(SelectedVariant,GetValueAsString(AddOnLine,'selected_variant'),9) then
                exit;

              AddOnLineVariant := AddOnLine.SelectToken('variants[' + Format(SelectedVariant) + ']');
              if IsNull(AddOnLineVariant) then
                exit;

              LineNo := GetValueAsInt(AddOnLineVariant,'line_no');
              NpIaItemAddOnLineOption.Get(NpIaItemAddOnLine."AddOn No.",NpIaItemAddOnLine."Line No.",LineNo);
              NpIaItemAddOnLine."Item No." := NpIaItemAddOnLineOption."Item No.";
              NpIaItemAddOnLine."Variant Code" := NpIaItemAddOnLineOption."Variant Code";
              NpIaItemAddOnLine.Description := NpIaItemAddOnLineOption.Description;
              NpIaItemAddOnLine.Quantity := NpIaItemAddOnLineOption.Quantity;
            end;
        end;
        //+NPR5.48 [334922]
    end;

    [IntegrationEvent(false, false)]
    local procedure BeforeInsertPOSAddOnLine(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    begin
        //-NPR5.48 [334922]
        //+NPR5.48 [334922]
    end;

    [IntegrationEvent(false, false)]
    procedure HasBeforeInsertSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line";var HasSetup: Boolean)
    begin
        //-NPR5.48 [334922]
        //+NPR5.48 [334922]
    end;

    [IntegrationEvent(false, false)]
    procedure RunBeforeInsertSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line";var Handled: Boolean)
    begin
        //-NPR5.48 [334922]
        //+NPR5.48 [334922]
    end;

    local procedure "--- Json Mgt"()
    begin
    end;

    local procedure GetValueAsString(JToken: DotNet JToken;JPath: Text): Text
    var
        JToken2: DotNet JToken;
    begin
        //-NPR5.48 [334922]
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit('');

        exit(Format(JToken2));
        //+NPR5.48 [334922]
    end;

    local procedure GetValueAsInt(JToken: DotNet JToken;JPath: Text) IntValue: Integer
    var
        JToken2: DotNet JToken;
    begin
        //-NPR5.48 [334922]
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit(0);

        if not Evaluate(IntValue,Format(JToken2),9) then
          exit(0);

        exit(IntValue);
        //+NPR5.48 [334922]
    end;

    local procedure GetValueAsDec(JToken: DotNet JToken;JPath: Text) DecValue: Decimal
    var
        JToken2: DotNet JToken;
    begin
        //-NPR5.48 [334922]
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit(0);

        if not Evaluate(DecValue,Format(JToken2),9) then
          exit(0);

        exit(DecValue);
        //+NPR5.48 [334922]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CR() ChrCR: Text
    begin
        //-NPR5.48 [334922]
        ChrCR[1] := 13;
        exit(ChrCR);
        //+NPR5.48 [334922]
    end;

    local procedure LF() ChrLF: Text
    begin
        //-NPR5.48 [334922]
        ChrLF[1] := 10;
        exit(ChrLF);
        //+NPR5.48 [334922]
    end;

    local procedure GetItemAddOnComment(NpIaItemAddOn: Record "NpIa Item AddOn";SaleLinePOS: Record "Sale Line POS") Comment: Text
    var
        POSInfoTransaction: Record "POS Info Transaction";
        NavContent: DotNet String;
    begin
        //-NPR5.48 [334922]
        POSInfoTransaction.SetRange("POS Info Code",NpIaItemAddOn."Comment POS Info Code");
        POSInfoTransaction.SetRange("Register No.",SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.",SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date",SaleLinePOS.Date);
        if not POSInfoTransaction.FindSet then
          exit('');

        repeat
          Comment += POSInfoTransaction."POS Info";
        until POSInfoTransaction.Next = 0;

        NavContent := Comment;
        NavContent := NavContent.Replace('"','\"');
        NavContent := NavContent.Replace('/','\/');
        NavContent := NavContent.Replace(CR,'');
        NavContent := NavContent.Replace(LF,'\n');
        Comment := NavContent;

        exit(Comment);
        //+NPR5.48 [334922]
    end;

    procedure FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "Sale Line POS";var SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn")
    begin
        Clear(SaleLinePOSAddOn);

        SaleLinePOSAddOn.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.",SaleLinePOS."Line No.");
    end;

    procedure FindItemAddOn(var SaleLinePOS: Record "Sale Line POS";var ItemAddOn: Record "NpIa Item AddOn"): Boolean
    var
        Item: Record Item;
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        Clear(ItemAddOn);

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit(false);

        //-NPR5.48 [334922]
        if SaleLinePOS."No." in ['','*'] then
          exit(false);
        //+NPR5.48 [334922]

        SaleLinePOSAddOn.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.",'>%1',0);
        if SaleLinePOSAddOn.FindSet then
          repeat
            if SaleLinePOS2.Get(
                SaleLinePOSAddOn."Register No.",
                SaleLinePOSAddOn."Sales Ticket No.",
                SaleLinePOSAddOn."Sale Date",
                SaleLinePOSAddOn."Sale Type",
                SaleLinePOSAddOn."Applies-to Line No.")
            then begin
              SaleLinePOS := SaleLinePOS2;
              if ItemAddOn.Get(SaleLinePOS2."No.") and ItemAddOn.Enabled then
                exit(true);
            end;
          until SaleLinePOSAddOn.Next = 0;

        //-NPR5.48 [334922]
        // IF NOT ItemAddOn.GET(SaleLinePOS."No.") THEN
        //  EXIT(FALSE);
        SaleLinePOS2 := SaleLinePOS;
        if SaleLinePOS.Accessory then begin
          if not SaleLinePOS2.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS.Date,SaleLinePOS."Sale Type",SaleLinePOS."Main Line No.") then
            exit(false);
        end;

        if not Item.Get(SaleLinePOS2."No.") then
          exit(false);
        if Item."Item AddOn No." = '' then
          exit(false);
        if not ItemAddOn.Get(Item."Item AddOn No.") then
          exit(false);
        //+NPR5.48 [334922]

        exit(ItemAddOn.Enabled);
    end;

    local procedure FindSaleLinePOS(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;NpIaItemAddOnLine: Record "NpIa Item AddOn Line";var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        //-NPR5.48 [334922]
        SaleLinePOSAddOn.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.",NpIaItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.",NpIaItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.",AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst then
          exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.",SaleLinePOSAddOn."Sales Ticket No.",SaleLinePOSAddOn."Sale Date",SaleLinePOSAddOn."Sale Type",SaleLinePOSAddOn."Sale Line No."));
        //+NPR5.48 [334922]
    end;

    procedure ItemAddOnEnabled(): Boolean
    var
        ItemAddOn: Record "NpIa Item AddOn";
    begin
        if ItemAddOn.IsEmpty then
          exit(false);

        ItemAddOn.SetRange(Enabled,true);
        exit(ItemAddOn.FindFirst);
    end;
}

