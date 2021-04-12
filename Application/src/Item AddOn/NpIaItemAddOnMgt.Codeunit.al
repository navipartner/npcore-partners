codeunit 6151125 "NPR NpIa Item AddOn Mgt."
{
    var
        ApproveLbl: Label 'Approve';
        CancelLbl: Label 'Cancel';
        ConfirmDeleteAllDependentLinesQst: Label 'There are one or more Item AddOn dependent lines, linked with the current line. Those will be deleted as well. Are you sure you want to continue?';
        FixedDependentLineCannotBeDeletedErr: Label 'You cannot delete this line because it is a dependent Item AddOn line. Please delete the main line, and this line will be deleted automatically by the system.';
        QtyIsFixedErr: Label 'The quantity of Item AddOn dependent line is fixed and cannot be changed in this way.';
        IncorrectFunctionCallMsg: Label '%1: incorrect function call. %2. This indicates a programming bug, not a user error.';
        MustBeTempMsg: Label 'Must be called with temporary record variable';
        IsAutoSplitKeyRecord: Boolean;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if Rec.IsTemporary() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(Rec, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Fixed Quantity", true);
        if SaleLinePOSAddOn.FindFirst then
            if SaleLinePOS.Get(
                SaleLinePOSAddOn."Register No.",
                SaleLinePOSAddOn."Sales Ticket No.",
                SaleLinePOSAddOn."Sale Date",
                SaleLinePOSAddOn."Sale Type",
                SaleLinePOSAddOn."Applies-to Line No.")
               and (Rec."Line No." <> SaleLinePOS."Line No.")
            then
                Error(FixedDependentLineCannotBeDeletedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150796, 'OnBeforeDeleteSaleLinePOS', '', true, false)]
    local procedure OnBeforeManualDeletePOSSaleLine(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", SaleLinePOS."Line No.");
        if not SaleLinePOSAddOn.IsEmpty() then
            if not Confirm(ConfirmDeleteAllDependentLinesQst, true) then
                Error('');
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        if Rec.IsTemporary() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(Rec, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.IsEmpty() then
            SaleLinePOSAddOn.DeleteAll();

        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", Rec."Line No.");
        if SaleLinePOSAddOn.FindSet() then
            repeat
                if SaleLinePOS.Get(
                    SaleLinePOSAddOn."Register No.",
                    SaleLinePOSAddOn."Sales Ticket No.",
                    SaleLinePOSAddOn."Sale Date",
                    SaleLinePOSAddOn."Sale Type",
                    SaleLinePOSAddOn."Sale Line No.")
                then
                    SaleLinePOS.Delete(true);
            until SaleLinePOSAddOn.Next() = 0;

        SaleLinePOSAddOn.DeleteAll();
        if Rec.Find() then;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
            exit;
        if not ItemAddOnEnabled() then
            exit;

        Extensions.Add('ItemAddOn');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> 'BUILTIN_SALELINE' then
            exit;
        if ExtensionName <> 'ItemAddOn' then
            exit;

        Handled := true;

        DataSource.AddColumn('ItemAddOn', 'Item AddOn', DataType::Boolean, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
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
    local procedure OnGetLineStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    local procedure InitScript(SalePOS: Record "NPR POS Sale"; AppliesToSaleLinePOS: Record "NPR POS Sale Line"; NpIaItemAddOn: Record "NPR NpIa Item AddOn") Script: Text
    var
        RetailModelScriptLibrary: Codeunit "NPR Retail Model Script Lib.";
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        Script += InitScriptData(SalePOS, AppliesToSaleLinePOS, NpIaItemAddOn);
    end;

    local procedure InitScriptData(SalePOS: Record "NPR POS Sale"; AppliesToSaleLinePOS: Record "NPR POS Sale Line"; NpIaItemAddOn: Record "NPR NpIa Item AddOn") Script: Text
    begin
        Script := '$(function () {' +
          'var appElement = document.querySelector(''[ng-app=navApp]'');' +
          'var $scope = angular.element(appElement).scope();' +
          '$scope.$apply(function() {';

        Script += InitScriptAddOnLines(SalePOS, AppliesToSaleLinePOS, NpIaItemAddOn);
        Script += InitScriptLabels(NpIaItemAddOn);

        Script += '});' +
          '});';
    end;

    local procedure InitScriptAddOnLines(SalePOS: Record "NPR POS Sale"; AppliesToSaleLinePOS: Record "NPR POS Sale Line"; NpIaItemAddOn: Record "NPR NpIa Item AddOn") Script: Text
    var
        NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        NpIaItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        BaseSaleLinePOS: Record "NPR POS Sale Line";
        AddOnLine: Text;
        SelectedVariant: Text;
        i: Integer;
        ShowEdit: Integer;
        Comment: Text;
    begin
        Script := '$scope.addon_lines = [';

        NpIaItemAddOnLine.SetRange("AddOn No.", NpIaItemAddOn."No.");
        if NpIaItemAddOnLine.FindSet() then
            repeat
                Comment := '';
                Clear(SaleLinePOS);
                if FindSaleLinePOS(SalePOS, AppliesToSaleLinePOS."Line No.", NpIaItemAddOnLine, SaleLinePOS) then
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
                        AddOnLine += ', qty: ' + Format(Round(NpIaItemAddOnLine.Quantity * AppliesToSaleLinePOS."Quantity (Base)", 0.00001), 0, 9);
                    end else
                        AddOnLine += ', qty: ' + Format(NpIaItemAddOnLine.Quantity, 0, 9);
                end else
                    AddOnLine += ', qty: ' + Format(SaleLinePOS.Quantity, 0, 9);
                AddOnLine += ', fixed: ' + Format(NpIaItemAddOnLine."Fixed Quantity", 0, 9);
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
            until NpIaItemAddOnLine.Next() = 0;

        Script += '];';
        exit(Script);
    end;

    local procedure InitScriptLabels(NpIaItemAddOn: Record "NPR NpIa Item AddOn") Script: Text
    var
        NPREWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        Script := '$scope.labels = ' +
          '{ ' +
            'title: "' + FormatJson(NpIaItemAddOn.Description) + '"' +
            ', approve: "' + ApproveLbl + '"' +
            ', cancel: "' + CancelLbl + '" ' +
          '}';

        exit(Script);
    end;

    local procedure FormatJson(Value: Text) JsonValue: Text
    var
        JsonVal: JsonValue;
    begin
        JsonVal.SetValue(JsonValue);
        JsonValue := Format(JsonVal);
        JsonValue := CopyStr(JsonValue, 2, StrLen(JsonValue) - 2);
        exit(JsonValue);
    end;

    local procedure WebDepCode(): Code[10]
    begin
        exit('ITEM_ADDON');
    end;

    local procedure InitCss() Css: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::CSS, WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
            WebClientDependency.CalcFields(BLOB);
            WebClientDependency.BLOB.CreateInStream(InStr);
            InStr.Read(Css);
        end;
    end;

    local procedure InitHtml() Html: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::HTML, WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
            WebClientDependency.CalcFields(BLOB);
            WebClientDependency.BLOB.CreateInStream(InStr);
            InStr.Read(Html);
        end;
    end;

    procedure UserInterfaceIsRequired(NpIaItemAddOn: Record "NPR NpIa Item AddOn"): Boolean
    var
        NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line";
    begin
        NpIaItemAddOnLine.SetRange("AddOn No.", NpIaItemAddOn."No.");
        NpIaItemAddOnLine.FilterGroup(-1);
        NpIaItemAddOnLine.SetRange("Fixed Quantity", false);
        NpIaItemAddOnLine.SetRange("Comment Enabled", true);
        NpIaItemAddOnLine.SetRange(Type, NpIaItemAddOnLine.Type::Select);
        NpIaItemAddOnLine.FilterGroup(0);
        exit(not NpIaItemAddOnLine.IsEmpty());
    end;

    procedure CreateUserInterface(var Model: DotNet NPRNetModel; SalePOS: Record "NPR POS Sale"; AppliesToSaleLinePOS: Record "NPR POS Sale Line"; NpIaItemAddOn: Record "NPR NpIa Item AddOn")
    begin
        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript(SalePOS, AppliesToSaleLinePOS, NpIaItemAddOn));
    end;

    procedure InsertPOSAddOnLines(NpIaItemAddOn: Record "NPR NpIa Item AddOn"; AddOnLines: JsonToken; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; OnlyFixedQtyLines: Boolean): Boolean
    var
        NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        NpIaItemAddOnLineTmp: Record "NPR NpIa Item AddOn Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NetConvHelper: Variant;
        JToken: JsonToken;
        JArray: JsonArray;
    begin
        JArray := AddOnLines.AsArray();

        NpIaItemAddOnLineTmp.Reset();
        NpIaItemAddOnLineTmp.DeleteAll();
        foreach JToken in JArray do begin
            ParsePOSAddOnLine(NpIaItemAddOn, JToken, NpIaItemAddOnLine);
            if not OnlyFixedQtyLines or NpIaItemAddOnLine."Fixed Quantity" then begin
                NpIaItemAddOnLineTmp := NpIaItemAddOnLine;
                NpIaItemAddOnLineTmp.Insert();
            end;
        end;

        if not AskForVariants(NpIaItemAddOnLineTmp) then begin
            RemoveBaseLine(POSSession, AppliesToLineNo);
            exit(false);
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        foreach JToken in JArray do begin
            ParsePOSAddOnLine(NpIaItemAddOn, JToken, NpIaItemAddOnLine);
            if not OnlyFixedQtyLines or NpIaItemAddOnLine."Fixed Quantity" then begin
                NpIaItemAddOnLineTmp := NpIaItemAddOnLine;
                NpIaItemAddOnLineTmp.Find();
                if InsertPOSAddOnLine(NpIaItemAddOnLineTmp, SalePOS, POSSaleLine, AppliesToLineNo, SaleLinePOS) then
                    InsertPOSAddOnLineComment(JToken, NpIaItemAddOn, SaleLinePOS);
            end;
        end;

        exit(true);
    end;

    procedure InsertFixedPOSAddOnLinesSilent(NpIaItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer): Boolean
    var
        NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        NpIaItemAddOnLineTmp: Record "NPR NpIa Item AddOn Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        NpIaItemAddOnLine.SetRange("AddOn No.", NpIaItemAddOn."No.");
        NpIaItemAddOnLine.SetRange("Fixed Quantity", true);
        NpIaItemAddOnLine.SetRange("Comment Enabled", false);
        NpIaItemAddOnLine.SetRange(Type, NpIaItemAddOnLine.Type::Quantity);
        if NpIaItemAddOnLine.IsEmpty() then
            exit(true);

        CopyItemAddOnLinesToTemp(NpIaItemAddOnLine, NpIaItemAddOnLineTmp);
        if not AskForVariants(NpIaItemAddOnLineTmp) then begin
            RemoveBaseLine(POSSession, AppliesToLineNo);
            exit(false);
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        if NpIaItemAddOnLineTmp.FindSet() then begin
            repeat
                InsertPOSAddOnLine(NpIaItemAddOnLineTmp, SalePOS, POSSaleLine, AppliesToLineNo, SaleLinePOS);
            until NpIaItemAddOnLineTmp.Next = 0;

            if SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo) then
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
        end;
        exit(true);
    end;

    local procedure InsertPOSAddOnLine(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; SalePOS: Record "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; AppliesToLineNo: Integer; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        LineNo: Integer;
        PrevRec: Text;
    begin
        if not FindSaleLinePOS(SalePOS, AppliesToLineNo, NpIaItemAddOnLine, SaleLinePOS) then begin
            if NpIaItemAddOnLine.Quantity <= 0 then
                exit(false);

            //Find last dependent line of current base line in order to insert new lines after it
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
            SaleLinePOSAddOn.SetRange("Sale Line No.");
            SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
            if SaleLinePOSAddOn.FindLast then begin
                SaleLinePOS.Get(
                  SaleLinePOSAddOn."Register No.",
                  SaleLinePOSAddOn."Sales Ticket No.",
                  SaleLinePOSAddOn."Sale Date",
                  SaleLinePOSAddOn."Sale Type",
                  SaleLinePOSAddOn."Sale Line No.");
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
            end;
            POSSaleLine.ForceInsertWithAutoSplitKey(true);
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            BeforeInsertPOSAddOnLine(SalePOS, AppliesToLineNo, NpIaItemAddOnLine);
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Variant Code" := NpIaItemAddOnLine."Variant Code";
            SaleLinePOS.Validate("No.", NpIaItemAddOnLine."Item No.");
            SaleLinePOS.Description := NpIaItemAddOnLine.Description;
            SaleLinePOS.Validate(Quantity, NpIaItemAddOnLine.Quantity);
            if (NpIaItemAddOnLine."Unit Price" <> 0) or (NpIaItemAddOnLine."Use Unit Price" = NpIaItemAddOnLine."Use Unit Price"::Always) then begin
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", NpIaItemAddOnLine."Unit Price");
            end;
            SaleLinePOS.Validate(Quantity, NpIaItemAddOnLine.Quantity);
            SaleLinePOS.Validate("Discount %", NpIaItemAddOnLine."Discount %");

            POSSaleLine.SetUsePresetLineNo(true);
            POSSaleLine.InsertLine(SaleLinePOS);
            POSSaleLine.SetUsePresetLineNo(false);
            if not IsAutoSplitKeyRecord then
                IsAutoSplitKeyRecord := POSSaleLine.InsertedWithAutoSplitKey();
            POSSaleLine.ForceInsertWithAutoSplitKey(false);

            FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
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
            exit(true);
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
        if (NpIaItemAddOnLine."Unit Price" <> 0) or (NpIaItemAddOnLine."Use Unit Price" = NpIaItemAddOnLine."Use Unit Price"::Always) then begin
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

    local procedure InsertPOSAddOnLineComment(AddOnLine: JsonToken; NpIaItemAddOn: Record "NPR NpIa Item AddOn"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
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

            POSInfoTransaction.Init();
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

    local procedure ParsePOSAddOnLine(NpIaItemAddOn: Record "NPR NpIa Item AddOn"; AddOnLine: JsonToken; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    var
        NpIaItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        AddOnLineVariant: JsonToken;
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

                    if not AddOnLine.SelectToken('variants[' + Format(SelectedVariant) + ']', AddOnLineVariant) then
                        exit;

                    LineNo := GetValueAsInt(AddOnLineVariant, 'line_no');
                    NpIaItemAddOnLineOption.Get(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.", LineNo);
                    NpIaItemAddOnLine."Item No." := NpIaItemAddOnLineOption."Item No.";
                    NpIaItemAddOnLine."Variant Code" := NpIaItemAddOnLineOption."Variant Code";
                    NpIaItemAddOnLine.Description := NpIaItemAddOnLineOption.Description;
                    NpIaItemAddOnLine.Quantity := GetValueAsDec(AddOnLine, 'qty');
                    if NpIaItemAddOnLine.Quantity = 0 then
                        NpIaItemAddOnLine.Quantity := NpIaItemAddOnLineOption.Quantity;
                    NpIaItemAddOnLine."Fixed Quantity" := NpIaItemAddOnLineOption."Fixed Quantity";
                    NpIaItemAddOnLine."Unit Price" := NpIaItemAddOnLineOption."Unit Price";
                    NpIaItemAddOnLine."Discount %" := NpIaItemAddOnLineOption."Discount %";
                    NpIaItemAddOnLine."Per Unit" := NpIaItemAddOnLineOption."Per Unit";
                    NpIaItemAddOnLine."Use Unit Price" := NpIaItemAddOnLineOption."Use Unit Price";
                end;
        end;
    end;

    local procedure RemoveBaseLine(POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if AppliesToLineNo <> 0 then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if SaleLinePOS."Line No." <> AppliesToLineNo then begin
                if not SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo) then
                    exit;
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition);
            end;
            POSSaleLine.DeleteLine();
            POSSession.GetSale(POSSale);
            POSSale.SetModified();
            POSSession.RequestRefreshData();
            Commit();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure BeforeInsertPOSAddOnLine(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure HasBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure RunBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var Handled: Boolean)
    begin
    end;

    local procedure GetValueAsString(JToken: JsonToken; JPath: Text): Text
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit;

        exit(JToken2.AsValue().AsText());
    end;

    local procedure GetValueAsInt(JToken: JsonToken; JPath: Text): Integer
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit(0);

        exit(JToken2.AsValue().AsInteger());
    end;

    local procedure GetValueAsDec(JToken: JsonToken; JPath: Text): Decimal
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit(0);
        exit(JToken2.AsValue().AsDecimal());
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

    local procedure GetItemAddOnComment(NpIaItemAddOn: Record "NPR NpIa Item AddOn"; SaleLinePOS: Record "NPR POS Sale Line") Comment: Text
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("POS Info Code", NpIaItemAddOn."Comment POS Info Code");
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if not POSInfoTransaction.FindSet() then
            exit('');

        repeat
            Comment += POSInfoTransaction."POS Info";
        until POSInfoTransaction.Next() = 0;

        Comment := Comment.Replace('"', '\"');
        Comment := Comment.Replace('/', '\/');
        Comment := Comment.Replace(CR, '');
        Comment := Comment.Replace(LF, '\n');

        exit(Comment);
    end;

    procedure FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        Clear(SaleLinePOSAddOn);

        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
    end;

    procedure FindItemAddOn(var SaleLinePOS: Record "NPR POS Sale Line"; var ItemAddOn: Record "NPR NpIa Item AddOn"): Boolean
    var
        Item: Record Item;
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
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
        if SaleLinePOSAddOn.FindSet() then
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
            until SaleLinePOSAddOn.Next() = 0;

        SaleLinePOS2 := SaleLinePOS;
        if SaleLinePOS.Accessory then begin
            if not SaleLinePOS2.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Main Line No.") then
                exit(false);
        end;

        if not Item.Get(SaleLinePOS2."No.") then
            exit(false);
        if Item."NPR Item AddOn No." = '' then
            exit(false);
        if not ItemAddOn.Get(Item."NPR Item AddOn No.") then
            exit(false);

        exit(ItemAddOn.Enabled);
    end;

    local procedure FindSaleLinePOS(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst() then
            exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Sale Line No."));
    end;

    procedure ItemAddOnEnabled(): Boolean
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        if ItemAddOn.IsEmpty() then
            exit(false);

        ItemAddOn.SetRange(Enabled, true);
        exit(ItemAddOn.FindFirst());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnBeforeInsertPOSSalesLine', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
        if POSSalesLine."Serial No." <> '' then
            exit;

        SetSerialNo(SaleLinePOS);
        POSSalesLine."Serial No." := SaleLinePOS."Serial No.";
    end;

    local procedure SetSerialNo(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        if SaleLinePOS."Serial No." <> '' then
            exit;

        if SaleLinePOSAddOn.IsEmpty() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.FindSet() then
            exit;

        repeat
            if SaleLinePOS2.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Applies-to Line No.") then
                SaleLinePOS."Serial No." := SaleLinePOS2."Serial No.";
        until (SaleLinePOS."Serial No." <> '') or (SaleLinePOSAddOn.Next() = 0);
    end;

    local procedure IsFixedQty(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Fixed Quantity", true);
        exit(not SaleLinePOSAddOn.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, false)]
    local procedure CheckFixedQtyOnBeforePOSSaleLineSetQty(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
        if IsFixedQty(SaleLinePOS) then
            Error(QtyIsFixedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterSetQuantity', '', true, false)]
    local procedure UpdateDependentLineQty(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SaleLinePOS2: Record "NPR POS Sale Line";
        xSaleLinePOS: Record "NPR POS Sale Line";
    begin
        Sender.GetxRec(xSaleLinePOS);
        if xSaleLinePOS."Quantity (Base)" = 0 then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("Per Unit", true);
        if SaleLinePOSAddOn.FindSet() then
            repeat
                if SaleLinePOS2.Get(
                    SaleLinePOSAddOn."Register No.",
                    SaleLinePOSAddOn."Sales Ticket No.",
                    SaleLinePOSAddOn."Sale Date",
                    SaleLinePOSAddOn."Sale Type",
                    SaleLinePOSAddOn."Sale Line No.")
                then begin
                    SaleLinePOS2.Validate(Quantity, Round(SaleLinePOS2.Quantity * SaleLinePOS."Quantity (Base)" / xSaleLinePOS."Quantity (Base)", 0.00001));
                    SaleLinePOS2.Modify();
                end;
            until SaleLinePOSAddOn.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150853, 'OnGetLineStyle', '', false, false)]
    local procedure FormatDependentSaleLine(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.IsEmpty() then
            Style := 'italic';
        POSSession.RequestRefreshData();
    end;

    [TryFunction]
    local procedure AskForVariants(var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    var
        ItemVariantRequestBuffer: Record "NPR NpIa Item AddOn Line" temporary;
    begin
        if NpIaItemAddOnLine.FindSet() then
            repeat
                if (NpIaItemAddOnLine."Item No." <> '') and
                   (NpIaItemAddOnLine."Variant Code" = '') and
                   (NpIaItemAddOnLine.Quantity > 0) and
                   ItemVariantIsRequired(NpIaItemAddOnLine."Item No.")
                then begin
                    ItemVariantRequestBuffer := NpIaItemAddOnLine;
                    ItemVariantRequestBuffer.Insert;
                end;
            until NpIaItemAddOnLine.Next() = 0;

        if ItemVariantRequestBuffer.IsEmpty() then
            exit;

        if PAGE.RunModal(PAGE::"NPR NpIa ItemAddOn Sel. Vars.", ItemVariantRequestBuffer) <> ACTION::LookupOK then
            Error('');

        if ItemVariantRequestBuffer.FindSet() then
            repeat
                ItemVariantRequestBuffer.TestField("Variant Code");
                NpIaItemAddOnLine.Get(ItemVariantRequestBuffer."AddOn No.", ItemVariantRequestBuffer."Line No.");
                if NpIaItemAddOnLine."Variant Code" <> ItemVariantRequestBuffer."Variant Code" then begin
                    NpIaItemAddOnLine."Variant Code" := ItemVariantRequestBuffer."Variant Code";
                    NpIaItemAddOnLine.Description := ItemVariantRequestBuffer."Description 2";
                    NpIaItemAddOnLine.Modify();
                end;
            until ItemVariantRequestBuffer.Next() = 0;
    end;

    local procedure ItemVariantIsRequired(ItemNo: Code[20]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
        ItemVariant.SetRange("NPR Blocked", false);
        exit(not ItemVariant.IsEmpty());
    end;

    local procedure CopyItemAddOnLinesToTemp(var FromNpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var ToNpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    begin
        if not ToNpIaItemAddOnLine.IsEmpty then
            Error(IncorrectFunctionCallMsg, 'CU6151125.CopyItemAddOnLinesToTemp', MustBeTempMsg);

        ToNpIaItemAddOnLine.Reset();
        ToNpIaItemAddOnLine.DeleteAll();

        if FromNpIaItemAddOnLine.FindSet() then
            repeat
                ToNpIaItemAddOnLine := FromNpIaItemAddOnLine;

                ToNpIaItemAddOnLine.Insert();
            until FromNpIaItemAddOnLine.Next() = 0;
    end;

    procedure InsertedWithAutoSplitKey(): Boolean
    begin
        exit(IsAutoSplitKeyRecord);
    end;
}