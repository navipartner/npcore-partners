﻿page 6014460 "NPR Inventory Pick Scan"
{
    Extensible = False;
    Caption = 'Inventory Pick';
    PageType = Document;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SourceTable = "Warehouse Activity Header";
    SourceTableView = WHERE(Type = CONST("Invt. Pick"));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document"; Rec."Source Document")
                {

                    DrillDown = false;
                    Lookup = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Source Document field';
                    ApplicationArea = NPRRetail;
                }
                field("Source No."; Rec."Source No.")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Source No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CreateInvtPick: Codeunit "Create Inventory Pick/Movement";
                    begin
                        CreateInvtPick.Run(Rec);
                        CurrPage.Update();
                        CurrPage.WhseActivityLines.PAGE.UpdateForm();
                    end;

                    trigger OnValidate()
                    begin
                        SourceNoOnAfterValidate();
                    end;
                }
                field("Destination No."; Rec."Destination No.")
                {

                    CaptionClass = Format(WMSMgt.GetCaption(Rec."Destination Type".AsInteger(), Rec."Source Document".AsInteger(), 0));
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Destination No. field';
                    ApplicationArea = NPRRetail;
                }
                field(DestinationEntityName; WMSMgt.GetDestinationEntityName(Rec."Destination Type", Rec."Destination No."))
                {

                    CaptionClass = Format(WMSMgt.GetCaption(Rec."Destination Type".AsInteger(), Rec."Source Document".AsInteger(), 1));
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {

                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    CaptionClass = Format(WMSMgt.GetCaption(Rec."Destination Type".AsInteger(), Rec."Source Document".AsInteger(), 2));
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No.2"; Rec."External Document No.2")
                {

                    CaptionClass = Format(WMSMgt.GetCaption(Rec."Destination Type".AsInteger(), Rec."Source Document".AsInteger(), 3));
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the External Document No.2 field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Scan)
            {
                Caption = 'Scan';
                field(QtyToHandleGlobal; QtyToHandleGlobal)
                {

                    CaptionClass = QtyToHandleCaption;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the QtyToHandleGlobal field';
                    ApplicationArea = NPRRetail;
                }
                field(Barcode; Barcode)
                {

                    Caption = 'Barcode';
                    ToolTip = 'Specifies the value of the Barcode field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        ItemReference: Record "Item Reference";
                        WhseActivityLine: Record "Warehouse Activity Line";
                    begin
                        if Barcode = '' then
                            exit;
                        if not GetItemReference(ItemReference) then
                            Error(NoItemWithBarcodeErr, Barcode);
                        if not CheckIfLineExists(ItemReference) then
                            Error(LineDoesntExist, WhseActivityLine.FieldCaption("Item No."), ItemReference."Item No.",
                                                  WhseActivityLine.FieldCaption("Variant Code"), ItemReference."Variant Code",
                                                  WhseActivityLine.FieldCaption("Unit of Measure Code"), ItemReference."Unit of Measure");
                        HasItemTracking(ItemReference."Item No.");
                        CheckQtyIsAvailable(ItemReference);
                        AssignQtyToHandle(ItemReference);
                        CurrPage.Update();

                    end;
                }
                field(SerialNo; SerialNo)
                {

                    CaptionClass = SerialNoCaption;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the SerialNo field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                    end;
                }
                field(LotNo; LotNo)
                {

                    CaptionClass = LotNoCaption;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the LotNo field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                    end;
                }
            }
            part(WhseActivityLines; "NPR Invt. Pick Subform Scan")
            {
                SubPageLink = "Activity Type" = FIELD(Type),
                              "No." = FIELD("No.");
                SubPageView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                              WHERE(Breakbulk = CONST(false));
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            part(Control4; "Lot Numbers by Bin FactBox")
            {
                Provider = WhseActivityLines;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Location Code" = FIELD("Location Code");
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("P&ick")
            {
                Caption = 'P&ick';
                Image = CreateInventoryPickup;
                action(List)
                {
                    Caption = 'List';
                    Image = OpportunitiesList;
                    ShortCutKey = 'Shift+Ctrl+L';

                    ToolTip = 'Executes the List action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.LookupActivityHeader(Rec."Location Code", Rec);
                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Warehouse Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Whse. Activity Header"),
                                  Type = FIELD(Type),
                                  "No." = FIELD("No.");

                    ToolTip = 'Executes the Co&mments action';
                    ApplicationArea = NPRRetail;
                }
                action("Posted Picks")
                {
                    Caption = 'Posted Picks';
                    Image = PostedInventoryPick;
                    RunObject = Page "Posted Invt. Pick List";
                    RunPageLink = "Invt Pick No." = FIELD("No.");
                    RunPageView = SORTING("Invt Pick No.");

                    ToolTip = 'Executes the Posted Picks action';
                    ApplicationArea = NPRRetail;
                }
                action("Source Documents")
                {
                    Caption = 'Source Documents';
                    Image = "Order";

                    ToolTip = 'Executes the Source Documents action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        WMSMgt: Codeunit "WMS Management";
                    begin
                        WMSMgt.ShowSourceDocCard(Rec."Source Type", Rec."Source Subtype", Rec."Source No.");
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Get Source Document")
                {
                    Caption = '&Get Source Document';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the &Get Source Document action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CreateInvtPick: Codeunit "Create Inventory Pick/Movement";
                    begin
                        CreateInvtPick.Run(Rec);
                    end;
                }
                action(DoAutofillQtyToHandle)
                {
                    Caption = 'Autofill Qty. to Handle';
                    Image = AutofillQtyToHandle;

                    ToolTip = 'Executes the Autofill Qty. to Handle action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        AutofillQtyToHandle();
                    end;
                }
                action("Delete Qty. to Handle")
                {
                    Caption = 'Delete Qty. to Handle';
                    Image = DeleteQtyToHandle;

                    ToolTip = 'Executes the Delete Qty. to Handle action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        DeleteQtyToHandle();
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("P&ost")
                {
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    ToolTip = 'Executes the P&ost action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PostPickYesNo();
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    ToolTip = 'Executes the Post and &Print action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PostAndPrint();
                    end;
                }
            }
            action("&Print")
            {
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the &Print action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    WhseActPrint.PrintInvtPickHeader(Rec, false);
                end;
            }
        }
        area(reporting)
        {
            action("Picking List")
            {
                Caption = 'Picking List';
                Image = "Report";
                Promoted = false;
                RunObject = Report "Picking List";

                ToolTip = 'Executes the Picking List action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Barcode := '';
        QtyToHandleGlobal := 1;
        SerialNo := '';
        LotNo := '';
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        TempWhich: Text[1024];
    begin
        TempWhich := CopyStr(Which, 1, MaxStrLen(TempWhich));
        exit(Rec.FindFirstAllowedRec(TempWhich));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Location Code" := Rec.GetUserLocation();
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(Rec.FindNextAllowedRec(Steps));
    end;

    trigger OnOpenPage()
    begin
        Rec.ErrorIfUserIsNotWhseEmployee();
        QtyToHandleGlobal := 1;
    end;

    var
        WhseActPrint: Codeunit "Warehouse Document-Print";
        WMSMgt: Codeunit "WMS Management";
        NoItemWithBarcodeErr: Label 'There are no items with reference: %1';
        LineDoesntExist: Label 'Line with %1: %2, %3: %4 and %5: %6 doesn''t exist.';
        LNRequired: Boolean;
        SNRequired: Boolean;
        Barcode: Code[20];
        LotNo: Code[20];
        SerialNo: Code[20];
        QtyToHandleGlobal: Decimal;
        CantDistributeQtyErr: Label 'Available quantity for distribution is %1. You''ve set %2. Please change %3 and try again.';
        LotNoCaption: Label 'Lot No.';
        QtyToHandleCaption: Label 'Qty. to Handle';
        SerialNoCaption: Label 'Serial No.';

    local procedure AutofillQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.AutofillQtyToHandle();
    end;

    local procedure DeleteQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.DeleteQtyToHandle();
    end;

    local procedure PostPickYesNo()
    begin
        CurrPage.WhseActivityLines.PAGE.PostPickYesNo();
    end;

    local procedure PostAndPrint()
    begin
        CurrPage.WhseActivityLines.PAGE.PostAndPrint();
    end;

    local procedure SourceNoOnAfterValidate()
    begin
        CurrPage.Update();
        CurrPage.WhseActivityLines.PAGE.UpdateForm();
    end;

    local procedure GetItemReference(var ItemReference: Record "Item Reference"): Boolean
    begin
        Clear(ItemReference);
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.");
        ItemReference.SetRange("Reference No.", Barcode);
        ItemReference.SetFilter("Reference Type No.", '%1', '');
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        exit(ItemReference.FindFirst());
    end;

    local procedure CheckIfLineExists(ItemReference: Record "Item Reference"): Boolean
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        SetWhseActivityLineFilterFromItemReference(WhseActivityLine, ItemReference);
        exit(not WhseActivityLine.IsEmpty());
    end;

    local procedure HasItemTracking(ItemNo: Code[20]): Boolean
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemTrackingNotEnabledError: Label 'Item doesn''t have item tracking enabled so you need to remove %1 before scanning.';
        ItemTrackingError: Label 'Item has item tracking enabled so you need to set %1 before scanning.';
    begin
        ItemTrackingMgt.GetWhseItemTrkgSetup(ItemNo, WhseItemTrackingSetup);
        SNRequired := WhseItemTrackingSetup."Serial No. Required";
        LNRequired := WhseItemTrackingSetup."Lot No. Required";
        if SNRequired then begin
            if SerialNo = '' then
                Error(ItemTrackingError, SerialNoCaption);
        end else
            if SerialNo <> '' then
                Error(ItemTrackingNotEnabledError, SerialNoCaption);
        if LNRequired then begin
            if LotNo = '' then
                Error(ItemTrackingError, LotNoCaption);
        end else
            if LotNo <> '' then
                Error(ItemTrackingNotEnabledError, LotNoCaption);
        exit(SNRequired or LNRequired);
    end;

    local procedure CheckQtyIsAvailable(ItemReference: Record "Item Reference")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        TotalQty: Decimal;
        QtyToHandleErr: Label '%1 needs to be set before scanning.';
    begin
        if QtyToHandleGlobal = 0 then
            Error(QtyToHandleErr, QtyToHandleCaption);
        SetWhseActivityLineFilterFromItemReference(WhseActivityLine, ItemReference);
        if WhseActivityLine.FindSet() then
            repeat
                TotalQty += WhseActivityLine."Qty. (Base)" - WhseActivityLine."Qty. to Handle (Base)";
            until WhseActivityLine.Next() = 0;
        if QtyToHandleGlobal > TotalQty then
            Error(CantDistributeQtyErr, TotalQty, QtyToHandleGlobal, QtyToHandleCaption);
    end;

    local procedure SetWhseActivityLineFilterFromItemReference(var WhseActivityLine: Record "Warehouse Activity Line"; ItemReference: Record "Item Reference")
    begin
        WhseActivityLine.Reset();
        WhseActivityLine.SetRange("Activity Type", Rec.Type);
        WhseActivityLine.SetRange("No.", Rec."No.");
        WhseActivityLine.SetRange("Item No.", ItemReference."Item No.");
        if ItemReference."Variant Code" <> '' then
            WhseActivityLine.SetRange("Variant Code", ItemReference."Variant Code");
        if ItemReference."Unit of Measure" <> '' then
            WhseActivityLine.SetRange("Unit of Measure Code", ItemReference."Unit of Measure");
    end;

    local procedure AssignQtyToHandle(ItemReference: Record "Item Reference")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        OutstandingQty: Decimal;
        TotalQtyToHandle: Decimal;
    begin
        SetWhseActivityLineFilterFromItemReference(WhseActivityLine, ItemReference);
        TotalQtyToHandle := QtyToHandleGlobal;
        OutstandingQty := TotalQtyToHandle;
        WhseActivityLine.SetFilter(WhseActivityLine."Qty. Outstanding (Base)", '<>0');
        if SNRequired then
            WhseActivityLine.SetRange(WhseActivityLine."Serial No.", SerialNo);
        if LNRequired then
            WhseActivityLine.SetRange(WhseActivityLine."Lot No.", LotNo);
        DistributeQty(WhseActivityLine, OutstandingQty, false);
        if (OutstandingQty > 0) and (SNRequired or LNRequired) then begin
            WhseActivityLine.SetRange(WhseActivityLine."Serial No.", '');
            WhseActivityLine.SetRange(WhseActivityLine."Lot No.", '');
            DistributeQty(WhseActivityLine, OutstandingQty, SNRequired or LNRequired);
            while OutstandingQty > 0 do begin
                WhseActivityLine.SetRange(WhseActivityLine."Serial No.");
                WhseActivityLine.SetRange(WhseActivityLine."Lot No.");
                SplitLineAndAssignValue(WhseActivityLine, OutstandingQty);
            end;
        end;

    end;

    local procedure DistributeQty(var WhseActivityLine: Record "Warehouse Activity Line"; var QtyToHandle: Decimal; AssignTracking: Boolean)
    var
        QtyToAssign: Decimal;
    begin
        if WhseActivityLine.FindSet() then
            repeat
                QtyToAssign := 0;
                if QtyToHandle <= (WhseActivityLine."Qty. (Base)" - WhseActivityLine."Qty. to Handle (Base)") then
                    QtyToAssign := WhseActivityLine."Qty. to Handle (Base)" + QtyToHandle
                else
                    QtyToAssign := WhseActivityLine."Qty. (Base)";
                QtyToHandle -= QtyToAssign - WhseActivityLine."Qty. to Handle (Base)";
                WhseActivityLine.Validate("Qty. to Handle (Base)", QtyToAssign);
                WhseActivityLine.Modify(true);
                if AssignTracking then begin
                    if SNRequired then
                        WhseActivityLine.Validate("Serial No.", SerialNo);
                    if LNRequired then
                        WhseActivityLine.Validate("Lot No.", LotNo);
                    WhseActivityLine.Modify(true);
                end;
            until (WhseActivityLine.Next() = 0) or (QtyToHandle = 0);
    end;

    local procedure SplitLineAndAssignValue(var WhseActivityLine: Record "Warehouse Activity Line"; var QtyToHandle: Decimal)
    var
        NewWhseActivityLine: Record "Warehouse Activity Line";
        SourceWhseActivityLine: Record "Warehouse Activity Line";
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        FoundNewLine: Boolean;
        Splitted: Boolean;
        QtyToWork: Decimal;
        NoLinesToHandle: Label 'There aren''t any more available lines to be handled.';
    begin
        if WhseActivityLine.FindSet() then begin
            repeat
                TempWhseActivLine := WhseActivityLine;
                TempWhseActivLine.Insert();
            until WhseActivityLine.Next() = 0;
        end;
        if WhseActivityLine.FindSet() then
            repeat
                Splitted := (WhseActivityLine."Qty. (Base)" > WhseActivityLine."Qty. to Handle (Base)") and (WhseActivityLine."Qty. (Base)" > 1) and (WhseActivityLine."Qty. Outstanding (Base)" > 0);
                if Splitted then begin
                    SourceWhseActivityLine.Copy(WhseActivityLine);
                    WhseActivityLine.Validate(WhseActivityLine."Serial No.", '');
                    WhseActivityLine.Validate(WhseActivityLine."Lot No.", '');
                    QtyToWork := QtyToHandle;
                    if QtyToHandle > WhseActivityLine."Qty. (Base)" - WhseActivityLine."Qty. to Handle (Base)" then
                        QtyToWork := WhseActivityLine."Qty. (Base)" - WhseActivityLine."Qty. to Handle (Base)";
                    WhseActivityLine.Validate(WhseActivityLine."Qty. to Handle (Base)", QtyToWork);
                    QtyToHandle -= QtyToWork;
                    WhseActivityLine.Modify(true);
                    WhseActivityLine.SplitLine(WhseActivityLine);
                    if SNRequired then
                        WhseActivityLine.Validate(WhseActivityLine."Serial No.", SerialNo);
                    if LNRequired then
                        WhseActivityLine.Validate(WhseActivityLine."Lot No.", LotNo);
                    WhseActivityLine.Modify(true);
                end;
            until (WhseActivityLine.Next() = 0) or Splitted;
        if not Splitted then
            Error(NoLinesToHandle);
        if WhseActivityLine.FindSet() then
            repeat
                FoundNewLine := not TempWhseActivLine.Get(WhseActivityLine."Activity Type", WhseActivityLine."No.", WhseActivityLine."Line No.");
                if FoundNewLine then
                    TempWhseActivLine := WhseActivityLine;
            until (WhseActivityLine.Next() = 0) or FoundNewLine;

        NewWhseActivityLine.Get(TempWhseActivLine."Activity Type", TempWhseActivLine."No.", TempWhseActivLine."Line No.");
        NewWhseActivityLine.Validate(NewWhseActivityLine."Qty. to Handle (Base)", SourceWhseActivityLine."Qty. to Handle (Base)");
        NewWhseActivityLine.Validate(NewWhseActivityLine."Serial No.", SourceWhseActivityLine."Serial No.");
        NewWhseActivityLine.Validate(NewWhseActivityLine."Lot No.", SourceWhseActivityLine."Lot No.");
        NewWhseActivityLine.Modify(true);

    end;
}
