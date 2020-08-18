codeunit 6151125 "NpIa Item AddOn Mgt."
{
    // NPR5.44/MHA /20180629 CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181113 CASE 334922 Added Web Client Dependency functionality
    // NPR5.50/MHA /20190521 CASE 355080 Added function FormatJson() and "Unit Price" = 0 should result in default price
    // NPR5.51/MHA /20190725 CASE 355186 Serial No. functions added
    // NPR5.52/ALPO/20190912 CASE 354309 Possibility to predefine unit price and line discount % for Item AddOn entries set as select options
    //                                   Possibility to fix the quantity so user would not be able to change it on sale line
    //                                   Use Item AddOn quantity as default
    //                                   Prevent deletion of fixed quantity dependent lines; Delete all dependent lines on main line deletion
    // NPR5.54/ALPO/20200205 CASE 388951 Changed publisher object/event for [EventSubscriber] OnBeforeManualDeletePOSSaleLine: from CU "POS Sale Line" to CU "POS Action - Delete POS Line"
    // NPR5.54/ALPO/20200219 CASE 374666 Item AddOns: auto-insert fixed quantity lines; ask for missing variants
    //                                     - Functions InitScript(), InitScriptData(), CreateUserInterface(), WebDepCode(), InitCss(), InitHtml()
    //                                       moved out from CU 6151127 and CU 6151128 to avoid excessive code dublication
    //                                     - Functions InitScriptAddOnLines(), InitScriptLabels(), InsertPOSAddOnLine() marked as local
    //                                   (+deleted old commented lines)
    // NPR5.55/ALPO/20200506 CASE 402585 Define whether "Unit Price" should always be applied or only when it is not equal 0
    // NPR5.55/ALPO/20200803 CASE 417118 Related entries in "NpIa Sale Line POS AddOn" table were not removed, if an Item Add-on dependent Sale POS line was deleted


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Approve';
        Text001: Label 'Cancel';
        ConfirmDeleteAllDependentLines: Label 'There are one or more Item AddOn dependent lines, linked with the current line. Those will be deleted as well. Are you sure you want to continue?';
        FixedDependentLineCannotBeDeletedErr: Label 'You cannot delete this line because it is a dependent Item AddOn line. Please delete the main line, and this line will be deleted automatically by the system.';
        QtyIsFixedErr: Label 'The quantity of Item AddOn dependent line is fixed and cannot be changed in this way.';
        POSWindowTitle: Label 'Item configuration';
        IncorrectFunctionCallMsg: Label '%1: incorrect function call. %2. This indicates a programming bug, not a user error.';
        MustBeTempMsg: Label 'Must be called with temporary record variable';
        IsAutoSplitKeyRecord: Boolean;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "Sale Line POS"; RunTrigger: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        if Rec.IsTemporary then
            exit;

        //AddOn (dependent) lines cannot be deleted other than together with main line
        FilterSaleLinePOS2ItemAddOnPOSLine(Rec,SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Fixed Quantity",true);
        if SaleLinePOSAddOn.FindFirst then
          if SaleLinePOS.Get(
              SaleLinePOSAddOn."Register No.",
              SaleLinePOSAddOn."Sales Ticket No.",
              SaleLinePOSAddOn."Sale Date",
              SaleLinePOSAddOn."Sale Type",
              SaleLinePOSAddOn."Applies-to Line No.")
             and (Rec."Line No." <> SaleLinePOS."Line No.")  //NPR5.54 [374666]
          then
            Error(FixedDependentLineCannotBeDeletedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150796, 'OnBeforeDeleteSaleLinePOS', '', true, false)]
    local procedure OnBeforeManualDeletePOSSaleLine(POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        //Confirm deletion of AddOn (dependent) lines
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);  //NPR5.54 [388951]
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS,SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.",SaleLinePOS."Line No.");
        if not SaleLinePOSAddOn.IsEmpty then
          if not Confirm(ConfirmDeleteAllDependentLines,true) then
            Error('');
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        if Rec.IsTemporary then
          exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(Rec,SaleLinePOSAddOn);
        //-NPR5.55 [417118]
        if not SaleLinePOSAddOn.IsEmpty then  //Is dependent line
          SaleLinePOSAddOn.DeleteAll;
        //+NPR5.55 [417118]

        //Find and delete all dependent POS sales lines
        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.",Rec."Line No.");
        if SaleLinePOSAddOn.FindSet then
          repeat
            if SaleLinePOS.Get(
                SaleLinePOSAddOn."Register No.",
                SaleLinePOSAddOn."Sales Ticket No.",
                SaleLinePOSAddOn."Sale Date",
                SaleLinePOSAddOn."Sale Type",
                SaleLinePOSAddOn."Sale Line No.")
            then
              SaleLinePOS.Delete(true);
          until SaleLinePOSAddOn.Next = 0;

        SaleLinePOSAddOn.DeleteAll;
        if Rec.Find() then;
    end;

    local procedure "--- POS Data Source"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: DotNet npNetList_Of_T)
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
            exit;
        if not ItemAddOnEnabled() then
            exit;

        Extensions.Add('ItemAddOn');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    var
        DataType: DotNet npNetDataType;
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
            exit;
        if ExtensionName <> 'ItemAddOn' then
            exit;

        Handled := true;

        DataSource.AddColumn('ItemAddOn', 'Item AddOn', DataType.Boolean, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
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
        DataRow.Fields.Add('ItemAddOn', FindItemAddOn(SaleLinePOS, ItemAddOn));
    end;

    [BusinessEvent(false)]
    local procedure OnGetLineStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "Sale Line POS"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    local procedure "--- Init Script"()
    begin
    end;

    local procedure InitScript(SalePOS: Record "Sale POS";AppliesToSaleLinePOS: Record "Sale Line POS";NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
    begin
        //-NPR5.54 [374666]
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        //Script += RetailModelScriptLibrary.InitEscClose();  //Replaced by script in HTML web dependency
        Script += InitScriptData(SalePOS,AppliesToSaleLinePOS,NpIaItemAddOn);
        //+NPR5.54 [374666]
    end;

    local procedure InitScriptData(SalePOS: Record "Sale POS";AppliesToSaleLinePOS: Record "Sale Line POS";NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    begin
        //-NPR5.54 [374666]
        Script := '$(function () {' +
          'var appElement = document.querySelector(''[ng-app=navApp]'');' +
          'var $scope = angular.element(appElement).scope();' +
          '$scope.$apply(function() {';

        Script += InitScriptAddOnLines(SalePOS,AppliesToSaleLinePOS,NpIaItemAddOn);
        Script += InitScriptLabels(NpIaItemAddOn);

        Script += '});' +
          '});';
        //+NPR5.54 [374666]
    end;

    local procedure InitScriptAddOnLines(SalePOS: Record "Sale POS";AppliesToSaleLinePOS: Record "Sale Line POS";NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
        SaleLinePOS: Record "Sale Line POS";
        BaseSaleLinePOS: Record "Sale Line POS";
        AddOnLine: Text;
        SelectedVariant: Text;
        i: Integer;
        ShowEdit: Integer;
        Comment: Text;
    begin
        Script := '$scope.addon_lines = [';

        NpIaItemAddOnLine.SetRange("AddOn No.", NpIaItemAddOn."No.");
        if NpIaItemAddOnLine.FindSet then
            repeat
                Comment := '';
                Clear(SaleLinePOS);
            if FindSaleLinePOS(SalePOS,AppliesToSaleLinePOS."Line No.",NpIaItemAddOnLine,SaleLinePOS) then
                    Comment := GetItemAddOnComment(NpIaItemAddOn, SaleLinePOS);

                AddOnLine := '{ line_no: ' + Format(NpIaItemAddOnLine."Line No.");
                ShowEdit := -1;
                if (NpIaItemAddOn."Comment POS Info Code" <> '') and NpIaItemAddOnLine."Comment Enabled" then
                    ShowEdit := 0;
                AddOnLine += ', show_edit: ' + Format(ShowEdit);
                AddOnLine += ', description: "' + FormatJson(NpIaItemAddOnLine.Description) + '"';
            if SaleLinePOS.Quantity = 0 then begin
              if NpIaItemAddOnLine."Per Unit" then begin
                if AppliesToSaleLinePOS."Quantity (Base)" = 0 then
                  AppliesToSaleLinePOS."Quantity (Base)" := 1;
                AddOnLine += ', qty: ' + Format(Round(NpIaItemAddOnLine.Quantity * AppliesToSaleLinePOS."Quantity (Base)",0.00001),0,9);
              end else
                AddOnLine += ', qty: ' + Format(NpIaItemAddOnLine.Quantity,0,9);
            end else
              AddOnLine += ', qty: ' + Format(SaleLinePOS.Quantity,0,9);
            AddOnLine += ', fixed: ' + Format(NpIaItemAddOnLine."Fixed Quantity",0,9);
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
                            NpIaItemAddOnLineOption.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
                            NpIaItemAddOnLineOption.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
                            if NpIaItemAddOnLineOption.FindSet then
                                repeat
                                    AddOnLine += '{ line_no: ' + Format(NpIaItemAddOnLineOption."Line No.");
                                    AddOnLine += ', description: "' + FormatJson(NpIaItemAddOnLineOption.Description) + '"},';
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
    end;

    local procedure InitScriptLabels(NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NPREWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        Script := '$scope.labels = ' +
          '{ ' +
            'title: "' + FormatJson(NpIaItemAddOn.Description) + '"' +
            ', approve: "' + Text000 + '"' +
            ', cancel: "' + Text001 + '" ' +
          '}';

        exit(Script);
    end;

    local procedure FormatJson(Value: Text) JsonValue: Text
    var
        JsonConvert: DotNet JsonConvert;
        Formatting: DotNet npNetFormatting;
    begin
        JsonValue := JsonConvert.SerializeObject(Value, Formatting.None);
        JsonValue := CopyStr(JsonValue, 2);
        JsonValue := DelStr(JsonValue, StrLen(JsonValue));
        exit(JsonValue);
    end;

    local procedure WebDepCode(): Code[10]
    begin
        //-NPR5.54 [374666]
        exit('ITEM_ADDON');
        //+NPR5.54 [374666]
    end;

    local procedure InitCss() Css: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        //-NPR5.54 [374666]
        if WebClientDependency.Get(WebClientDependency.Type::CSS,WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
          WebClientDependency.CalcFields(BLOB);
          WebClientDependency.BLOB.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          Css := StreamReader.ReadToEnd;
        end;
        //+NPR5.54 [374666]
    end;

    local procedure InitHtml() Html: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        //-NPR5.54 [374666]
        if WebClientDependency.Get(WebClientDependency.Type::HTML,WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
          WebClientDependency.CalcFields(BLOB);
          WebClientDependency.BLOB.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          Html := StreamReader.ReadToEnd;
        end;
        //+NPR5.54 [374666]
    end;

    procedure UserInterfaceIsRequired(NpIaItemAddOn: Record "NpIa Item AddOn"): Boolean
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
    begin
        //-NPR5.54 [374666]
        NpIaItemAddOnLine.SetRange("AddOn No.",NpIaItemAddOn."No.");
        NpIaItemAddOnLine.FilterGroup(-1);
        NpIaItemAddOnLine.SetRange("Fixed Quantity",false);
        NpIaItemAddOnLine.SetRange("Comment Enabled",true);
        NpIaItemAddOnLine.SetRange(Type,NpIaItemAddOnLine.Type::Select);
        NpIaItemAddOnLine.FilterGroup(0);
        exit(not NpIaItemAddOnLine.IsEmpty);
        //+NPR5.54 [374666]
    end;

    procedure CreateUserInterface(var Model: DotNet npNetModel;SalePOS: Record "Sale POS";AppliesToSaleLinePOS: Record "Sale Line POS";NpIaItemAddOn: Record "NpIa Item AddOn")
    begin
        //-NPR5.54 [374666]
        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript(SalePOS,AppliesToSaleLinePOS,NpIaItemAddOn));
        //+NPR5.54 [374666]
    end;

    local procedure "--- Insert POS Lines"()
    begin
    end;

    procedure InsertPOSAddOnLines(NpIaItemAddOn: Record "NpIa Item AddOn";AddOnLines: DotNet npNetJToken;POSSession: Codeunit "POS Session";AppliesToLineNo: Integer;OnlyFixedQtyLines: Boolean): Boolean
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        NpIaItemAddOnLineTmp: Record "NpIa Item AddOn Line" temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        AddOnLine: DotNet JToken;
        AddOnLineList: DotNet npNetIList;
        NetConvHelper: Variant;
    begin
        NetConvHelper := AddOnLines.SelectTokens('$[?(@[''line_no''] > 0)]');
        //-NPR5.54 [374666]

        NpIaItemAddOnLineTmp.Reset;
        NpIaItemAddOnLineTmp.DeleteAll;
        foreach AddOnLine in AddOnLineList do begin
          ParsePOSAddOnLine(NpIaItemAddOn,AddOnLine,NpIaItemAddOnLine);
          if not OnlyFixedQtyLines or NpIaItemAddOnLine."Fixed Quantity" then begin
            NpIaItemAddOnLineTmp := NpIaItemAddOnLine;
            NpIaItemAddOnLineTmp.Insert;
          end;
        end;

        if not AskForVariants(NpIaItemAddOnLineTmp) then begin
          RemoveBaseLine(POSSession,AppliesToLineNo);
          exit(false);
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        //+NPR5.54 [374666]
        foreach AddOnLine in AddOnLineList do begin
          //IF InsertPOSAddOnLine(NpIaItemAddOn,AddOnLine,POSSession,AppliesToLineNo,SaleLinePOS) THEN  //NPR5.54 [374666]-revoked
          //-NPR5.54 [374666]
          ParsePOSAddOnLine(NpIaItemAddOn,AddOnLine,NpIaItemAddOnLine);
          if not OnlyFixedQtyLines or NpIaItemAddOnLine."Fixed Quantity" then begin
            NpIaItemAddOnLineTmp := NpIaItemAddOnLine;
            NpIaItemAddOnLineTmp.Find;
            if InsertPOSAddOnLine(NpIaItemAddOnLineTmp,SalePOS,POSSaleLine,AppliesToLineNo,SaleLinePOS) then
          //+NPR5.54 [374666]
              InsertPOSAddOnLineComment(AddOnLine,NpIaItemAddOn,SaleLinePOS);
          end;  //NPR5.54 [374666]
        end;

        exit(true);  //NPR5.54 [374666]
    end;

    procedure InsertFixedPOSAddOnLinesSilent(NpIaItemAddOn: Record "NpIa Item AddOn";POSSession: Codeunit "POS Session";AppliesToLineNo: Integer): Boolean
    var
        NpIaItemAddOnLine: Record "NpIa Item AddOn Line";
        NpIaItemAddOnLineTmp: Record "NpIa Item AddOn Line" temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        //-NPR5.54 [374666]
        NpIaItemAddOnLine.SetRange("AddOn No.",NpIaItemAddOn."No.");
        NpIaItemAddOnLine.SetRange("Fixed Quantity",true);
        NpIaItemAddOnLine.SetRange("Comment Enabled",false);
        NpIaItemAddOnLine.SetRange(Type,NpIaItemAddOnLine.Type::Quantity);
        if NpIaItemAddOnLine.IsEmpty then
          exit(true);

        CopyItemAddOnLinesToTemp(NpIaItemAddOnLine,NpIaItemAddOnLineTmp);
        if not AskForVariants(NpIaItemAddOnLineTmp) then begin
          RemoveBaseLine(POSSession,AppliesToLineNo);
          exit(false);
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        if NpIaItemAddOnLineTmp.FindSet then begin
          repeat
            InsertPOSAddOnLine(NpIaItemAddOnLineTmp,SalePOS,POSSaleLine,AppliesToLineNo,SaleLinePOS);
          until NpIaItemAddOnLineTmp.Next = 0;

          if SaleLinePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS.Date,SaleLinePOS."Sale Type",AppliesToLineNo) then
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition);
        end;
        exit(true);
        //+NPR5.54 [374666]
    end;

    local procedure InsertPOSAddOnLine(NpIaItemAddOnLine: Record "NpIa Item AddOn Line";SalePOS: Record "Sale POS";POSSaleLine: Codeunit "POS Sale Line";AppliesToLineNo: Integer;var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        LineNo: Integer;
        PrevRec: Text;
    begin
        //-NPR5.54 [374666]-revoked
        //POSSession.GetSale(POSSale);
        //POSSale.GetCurrentSale(SalePOS);

        //ParsePOSAddOnLine(NpIaItemAddOn,AddOnLine,NpIaItemAddOnLine);
        //+NPR5.54 [374666]-revoked
        if not FindSaleLinePOS(SalePOS, AppliesToLineNo, NpIaItemAddOnLine, SaleLinePOS) then begin
            if NpIaItemAddOnLine.Quantity <= 0 then
                exit(false);

          //-NPR5.55 [417118]
          //Find last dependent line of current base line in order to insert new lines after it
          POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
          FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
          SaleLinePOSAddOn.SetRange("Sale Line No.");
          SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
          if SaleLinePOSAddOn.FindLast then
            SaleLinePOS.Get(
              SaleLinePOSAddOn."Register No.",
              SaleLinePOSAddOn."Sales Ticket No.",
              SaleLinePOSAddOn."Sale Date",
              SaleLinePOSAddOn."Sale Type",
              SaleLinePOSAddOn."Sale Line No.");
          LineNo := SaleLinePOS."Line No.";
          POSSaleLine.ForceInsertWithAutoSplitKey(true);
          //+NPR5.55 [417118]
          //POSSession.GetSaleLine(POSSaleLine);  //NPR5.54 [374666]-revoked
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

          BeforeInsertPOSAddOnLine(SalePOS,AppliesToLineNo,NpIaItemAddOnLine);  //NPR5.54 [374666]
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Variant Code" := NpIaItemAddOnLine."Variant Code";
            SaleLinePOS.Validate("No.", NpIaItemAddOnLine."Item No.");
            SaleLinePOS.Description := NpIaItemAddOnLine.Description;
            SaleLinePOS.Validate(Quantity, NpIaItemAddOnLine.Quantity);
          //IF NpIaItemAddOnLine."Unit Price" <> 0 THEN BEGIN  //NPR5.55 [402585]-revoked
          if (NpIaItemAddOnLine."Unit Price" <> 0) or (NpIaItemAddOnLine."Use Unit Price" = NpIaItemAddOnLine."Use Unit Price"::Always) then begin  //NPR5.55 [402585]
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", NpIaItemAddOnLine."Unit Price");
            end;
            SaleLinePOS.Validate(Quantity, NpIaItemAddOnLine.Quantity);
            SaleLinePOS.Validate("Discount %", NpIaItemAddOnLine."Discount %");
          SaleLinePOS."Line No." := LineNo;  //NPR5.55 [417118] (we'll get incorrect AutoSplitLineNo result otherwise, because of double run)
            POSSaleLine.InsertLine(SaleLinePOS);
          //-NPR5.55 [417118]
          if not IsAutoSplitKeyRecord then
            IsAutoSplitKeyRecord := POSSaleLine.InsertedWithAutoSplitKey();
          POSSaleLine.ForceInsertWithAutoSplitKey(false);
          //+NPR5.55 [417118]

          //-NPR5.55 [417118]-revoked
          //SaleLinePOSAddOn.SETRANGE("Register No.",SaleLinePOS."Register No.");
          //SaleLinePOSAddOn.SETRANGE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
          //SaleLinePOSAddOn.SETRANGE("Sale Type",SaleLinePOS."Sale Type");
          //SaleLinePOSAddOn.SETRANGE("Sale Date",SaleLinePOS.Date);
          //SaleLinePOSAddOn.SETRANGE("Sale Line No.",SaleLinePOS."Line No.");
          //+NPR5.55 [417118]-revoked
          FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);  //NPR5.55 [417118]
          if not SaleLinePOSAddOn.FindLast then
            SaleLinePOSAddOn."Line No." := 0;
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
          SaleLinePOSAddOn."Fixed Quantity" := NpIaItemAddOnLine."Fixed Quantity";
          SaleLinePOSAddOn."Per Unit" := NpIaItemAddOnLine."Per Unit";
            SaleLinePOSAddOn.Insert(true);
          exit(true);  //NPR5.54 [374666]
        end;

        if NpIaItemAddOnLine.Quantity <= 0 then begin
            SaleLinePOS.Delete(true);
            exit(false);
        end;

        PrevRec := Format(SaleLinePOS);

        BeforeInsertPOSAddOnLine(SalePOS, AppliesToLineNo, NpIaItemAddOnLine);
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."Variant Code" := NpIaItemAddOnLine."Variant Code";
        SaleLinePOS.Validate("No.", NpIaItemAddOnLine."Item No.");
        SaleLinePOS.Description := NpIaItemAddOnLine.Description;
        //IF NpIaItemAddOnLine."Unit Price" <> 0 THEN BEGIN  //NPR5.55 [402585]-revoked
        if (NpIaItemAddOnLine."Unit Price" <> 0) or (NpIaItemAddOnLine."Use Unit Price" = NpIaItemAddOnLine."Use Unit Price"::Always) then begin  //NPR5.55 [402585]
            SaleLinePOS."Manual Item Sales Price" := true;
            SaleLinePOS.Validate("Unit Price", NpIaItemAddOnLine."Unit Price");
        end;
        SaleLinePOS.Validate(Quantity, NpIaItemAddOnLine.Quantity);
        SaleLinePOS.Validate("Discount %", NpIaItemAddOnLine."Discount %");
        if PrevRec <> Format(SaleLinePOS) then begin
            SaleLinePOS.Modify(true);
            POSSaleLine.RefreshCurrent();
        end;

        exit(true);
    end;

    local procedure InsertPOSAddOnLineComment(AddOnLine: DotNet JToken; NpIaItemAddOn: Record "NpIa Item AddOn"; var SaleLinePOS: Record "Sale Line POS")
    var
        POSInfo: Record "POS Info";
        POSInfoTransaction: Record "POS Info Transaction";
        Comment: Text;
        EntryNo: Integer;
    begin
        if NpIaItemAddOn."Comment POS Info Code" = '' then
            exit;
        if not POSInfo.Get(NpIaItemAddOn."Comment POS Info Code") then
            exit;

        POSInfoTransaction.SetCurrentKey("Entry No.");
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        if POSInfoTransaction.FindLast then;
        EntryNo := POSInfoTransaction."Entry No.";

        Clear(POSInfoTransaction);
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if POSInfoTransaction.FindFirst then
            POSInfoTransaction.DeleteAll;

        Comment := GetValueAsString(AddOnLine, 'comment');
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
            POSInfoTransaction."POS Info" := CopyStr(Comment, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);

            Comment := DelStr(Comment, 1, StrLen(POSInfoTransaction."POS Info"));
        end;
    end;

    local procedure ParsePOSAddOnLine(NpIaItemAddOn: Record "NpIa Item AddOn"; AddOnLine: DotNet JToken; var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    var
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
        AddOnLineVariant: DotNet JToken;
        LineNo: Integer;
        SelectedVariant: Integer;
    begin
        LineNo := GetValueAsInt(AddOnLine, 'line_no');
        NpIaItemAddOnLine.Get(NpIaItemAddOn."No.", LineNo);
        case NpIaItemAddOnLine.Type of
            NpIaItemAddOnLine.Type::Quantity:
                begin
                    NpIaItemAddOnLine.Quantity := GetValueAsDec(AddOnLine, 'qty');
                end;
            NpIaItemAddOnLine.Type::Select:
                begin
                    NpIaItemAddOnLine.Quantity := 0;
                    if not Evaluate(SelectedVariant, GetValueAsString(AddOnLine, 'selected_variant'), 9) then
                        exit;

                    AddOnLineVariant := AddOnLine.SelectToken('variants[' + Format(SelectedVariant) + ']');
                    if IsNull(AddOnLineVariant) then
                        exit;

                    LineNo := GetValueAsInt(AddOnLineVariant, 'line_no');
                    NpIaItemAddOnLineOption.Get(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.", LineNo);
                    NpIaItemAddOnLine."Item No." := NpIaItemAddOnLineOption."Item No.";
                    NpIaItemAddOnLine."Variant Code" := NpIaItemAddOnLineOption."Variant Code";
                    NpIaItemAddOnLine.Description := NpIaItemAddOnLineOption.Description;
              //-NPR5.54 [374666]
              NpIaItemAddOnLine.Quantity := GetValueAsDec(AddOnLine,'qty');
              if NpIaItemAddOnLine.Quantity = 0 then
              //+NPR5.54 [374666]
                NpIaItemAddOnLine.Quantity := NpIaItemAddOnLineOption.Quantity;
              NpIaItemAddOnLine."Fixed Quantity" := NpIaItemAddOnLineOption."Fixed Quantity";
              NpIaItemAddOnLine."Unit Price" := NpIaItemAddOnLineOption."Unit Price";
              NpIaItemAddOnLine."Discount %" := NpIaItemAddOnLineOption."Discount %";
              NpIaItemAddOnLine."Per Unit" := NpIaItemAddOnLineOption."Per Unit";
              NpIaItemAddOnLine."Use Unit Price" := NpIaItemAddOnLineOption."Use Unit Price";  //NPR5.55 [402585]
                end;
        end;
    end;

    local procedure RemoveBaseLine(POSSession: Codeunit "POS Session";AppliesToLineNo: Integer)
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        if AppliesToLineNo <> 0 then begin
          POSSession.GetSaleLine(POSSaleLine);
          POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
          if SaleLinePOS."Line No." <> AppliesToLineNo then begin
            if not SaleLinePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS.Date,SaleLinePOS."Sale Type",AppliesToLineNo) then
              exit;
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition);
          end;
          POSSaleLine.DeleteLine();
          POSSession.GetSale(POSSale);
          POSSale.SetModified();
          POSSession.RequestRefreshData();
          Commit;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure BeforeInsertPOSAddOnLine(SalePOS: Record "Sale POS"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure HasBeforeInsertSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure RunBeforeInsertSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line"; var Handled: Boolean)
    begin
    end;

    local procedure "--- Json Mgt"()
    begin
    end;

    local procedure GetValueAsString(JToken: DotNet JToken; JPath: Text): Text
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit('');

        exit(Format(JToken2));
    end;

    local procedure GetValueAsInt(JToken: DotNet JToken; JPath: Text) IntValue: Integer
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit(0);

        if not Evaluate(IntValue, Format(JToken2), 9) then
            exit(0);

        exit(IntValue);
    end;

    local procedure GetValueAsDec(JToken: DotNet JToken; JPath: Text) DecValue: Decimal
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit(0);

        if not Evaluate(DecValue, Format(JToken2), 9) then
            exit(0);

        exit(DecValue);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CR() ChrCR: Text
    begin
        ChrCR[1] := 13;
        exit(ChrCR);
    end;

    local procedure LF() ChrLF: Text
    begin
        ChrLF[1] := 10;
        exit(ChrLF);
    end;

    local procedure GetItemAddOnComment(NpIaItemAddOn: Record "NpIa Item AddOn"; SaleLinePOS: Record "Sale Line POS") Comment: Text
    var
        POSInfoTransaction: Record "POS Info Transaction";
        NavContent: DotNet npNetString;
    begin
        POSInfoTransaction.SetRange("POS Info Code", NpIaItemAddOn."Comment POS Info Code");
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if not POSInfoTransaction.FindSet then
            exit('');

        repeat
            Comment += POSInfoTransaction."POS Info";
        until POSInfoTransaction.Next = 0;

        NavContent := Comment;
        NavContent := NavContent.Replace('"', '\"');
        NavContent := NavContent.Replace('/', '\/');
        NavContent := NavContent.Replace(CR, '');
        NavContent := NavContent.Replace(LF, '\n');
        Comment := NavContent;

        exit(Comment);
    end;

    procedure FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "Sale Line POS"; var SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn")
    begin
        Clear(SaleLinePOSAddOn);

        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
    end;

    procedure FindItemAddOn(var SaleLinePOS: Record "Sale Line POS"; var ItemAddOn: Record "NpIa Item AddOn"): Boolean
    var
        Item: Record Item;
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        Clear(ItemAddOn);

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit(false);

        if SaleLinePOS."No." in ['', '*'] then
            exit(false);

        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '>%1', 0);
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

        SaleLinePOS2 := SaleLinePOS;
        if SaleLinePOS.Accessory then begin
            if not SaleLinePOS2.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Main Line No.") then
                exit(false);
        end;

        if not Item.Get(SaleLinePOS2."No.") then
            exit(false);
        if Item."Item AddOn No." = '' then
            exit(false);
        if not ItemAddOn.Get(Item."Item AddOn No.") then
            exit(false);

        exit(ItemAddOn.Enabled);
    end;

    local procedure FindSaleLinePOS(SalePOS: Record "Sale POS"; AppliesToLineNo: Integer; NpIaItemAddOnLine: Record "NpIa Item AddOn Line"; var SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst then
            exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Sale Line No."));
    end;

    procedure ItemAddOnEnabled(): Boolean
    var
        ItemAddOn: Record "NpIa Item AddOn";
    begin
        if ItemAddOn.IsEmpty then
            exit(false);

        ItemAddOn.SetRange(Enabled, true);
        exit(ItemAddOn.FindFirst);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnBeforeInsertPOSSalesLine', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";var POSSalesLine: Record "POS Sales Line")
    begin
        if POSSalesLine."Serial No." <> '' then
          exit;

        SetSerialNo(SaleLinePOS);
        POSSalesLine."Serial No." := SaleLinePOS."Serial No.";
    end;

    local procedure SetSerialNo(var SaleLinePOS: Record "Sale Line POS")
    var
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        if SaleLinePOS."Serial No." <> '' then
          exit;

        if SaleLinePOSAddOn.IsEmpty then
          exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS,SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.FindSet then
          exit;

        repeat
          if SaleLinePOS2.Get(SaleLinePOSAddOn."Register No.",SaleLinePOSAddOn."Sales Ticket No.",SaleLinePOSAddOn."Sale Date",SaleLinePOSAddOn."Sale Type",SaleLinePOSAddOn."Applies-to Line No.") then
            SaleLinePOS."Serial No." := SaleLinePOS2."Serial No.";
        until (SaleLinePOS."Serial No." <> '') or (SaleLinePOSAddOn.Next = 0);
    end;

    local procedure IsFixedQty(SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS,SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Fixed Quantity",true);
        exit(not SaleLinePOSAddOn.IsEmpty);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, false)]
    local procedure CheckFixedQtyOnBeforePOSSaleLineSetQty(var Sender: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS";var NewQuantity: Decimal)
    begin
        if IsFixedQty(SaleLinePOS) then
          Error(QtyIsFixedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterSetQuantity', '', true, false)]
    local procedure UpdateDependentLineQty(var Sender: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS")
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        SaleLinePOS2: Record "Sale Line POS";
        xSaleLinePOS: Record "Sale Line POS";
    begin
        Sender.GetxRec(xSaleLinePOS);
        if xSaleLinePOS."Quantity (Base)" = 0 then
          exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS,SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.",SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("Per Unit",true);
        if SaleLinePOSAddOn.FindSet then
          repeat
            if SaleLinePOS2.Get(
                SaleLinePOSAddOn."Register No.",
                SaleLinePOSAddOn."Sales Ticket No.",
                SaleLinePOSAddOn."Sale Date",
                SaleLinePOSAddOn."Sale Type",
                SaleLinePOSAddOn."Sale Line No.")
            then begin
              SaleLinePOS2.Validate(Quantity, Round(SaleLinePOS2.Quantity * SaleLinePOS."Quantity (Base)" / xSaleLinePOS."Quantity (Base)", 0.00001));
              SaleLinePOS2.Modify;
            end;
          until SaleLinePOSAddOn.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150853, 'OnGetLineStyle', '', false, false)]
    local procedure FormatDependentSaleLine(var Color: Text;var Weight: Text;var Style: Text;SaleLinePOS: Record "Sale Line POS";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS,SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.IsEmpty then
          Style := 'italic';
        POSSession.RequestRefreshData();
    end;

    [TryFunction]
    local procedure AskForVariants(var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    var
        ItemVariantRequestBuffer: Record "NpIa Item AddOn Line" temporary;
    begin
        //-NPR5.54 [374666]
        if NpIaItemAddOnLine.FindSet then
          repeat
            if (NpIaItemAddOnLine."Item No." <> '') and
               (NpIaItemAddOnLine."Variant Code" = '') and
               (NpIaItemAddOnLine.Quantity > 0) and
               ItemVariantIsRequired(NpIaItemAddOnLine."Item No.")
            then begin
              ItemVariantRequestBuffer := NpIaItemAddOnLine;
              ItemVariantRequestBuffer.Insert;
            end;
          until NpIaItemAddOnLine.Next = 0;

        if ItemVariantRequestBuffer.IsEmpty then
          exit;

        if PAGE.RunModal(PAGE::"NpIa Item AddOn Sel. Variants",ItemVariantRequestBuffer) <> ACTION::LookupOK then
          Error('');

        if ItemVariantRequestBuffer.FindSet then
          repeat
            ItemVariantRequestBuffer.TestField("Variant Code");
            NpIaItemAddOnLine.Get(ItemVariantRequestBuffer."AddOn No.",ItemVariantRequestBuffer."Line No.");
            if NpIaItemAddOnLine."Variant Code" <> ItemVariantRequestBuffer."Variant Code" then begin
              NpIaItemAddOnLine."Variant Code" := ItemVariantRequestBuffer."Variant Code";
              NpIaItemAddOnLine.Description := ItemVariantRequestBuffer."Description 2";
              NpIaItemAddOnLine.Modify;
            end;
          until ItemVariantRequestBuffer.Next = 0;
        //+NPR5.54 [374666]
    end;

    local procedure ItemVariantIsRequired(ItemNo: Code[20]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.54 [374666]
        ItemVariant.SetRange("Item No.",ItemNo);
        ItemVariant.SetRange(Blocked,false);
        exit(not ItemVariant.IsEmpty);
        //+NPR5.54 [374666]
    end;

    local procedure CopyItemAddOnLinesToTemp(var FromNpIaItemAddOnLine: Record "NpIa Item AddOn Line";var ToNpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    begin
        //-NPR5.54 [374666]
        if not ToNpIaItemAddOnLine.IsEmpty then
          Error(IncorrectFunctionCallMsg,'CU6151125.CopyItemAddOnLinesToTemp',MustBeTempMsg);

        ToNpIaItemAddOnLine.Reset;
        ToNpIaItemAddOnLine.DeleteAll;

        if FromNpIaItemAddOnLine.FindSet then
          repeat
            ToNpIaItemAddOnLine := FromNpIaItemAddOnLine;

            ToNpIaItemAddOnLine.Insert;
          until FromNpIaItemAddOnLine.Next = 0;
        //+NPR5.54 [374666]
    end;

    procedure InsertedWithAutoSplitKey(): Boolean
    begin
        //-NPR5.55 [417118]
        exit(IsAutoSplitKeyRecord);
        //+NPR5.55 [417118]
    end;
}

