page 6014460 "Inventory Pick Scan"
{
    // NPR5.33/NPKNAV/20170630  CASE 268412 Transport NPR5.33 - 30 June 2017
    // NPR5.41/TS  /20180105 CASE 300893 Added an s to Source Document

    Caption = 'Inventory Pick';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Warehouse Activity Header";
    SourceTableView = WHERE(Type = CONST("Invt. Pick"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    QuickEntry = false;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    QuickEntry = false;
                }
                field("Source Document"; "Source Document")
                {
                    DrillDown = false;
                    Lookup = false;
                    QuickEntry = false;
                }
                field("Source No."; "Source No.")
                {
                    QuickEntry = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CreateInvtPick: Codeunit "Create Inventory Pick/Movement";
                    begin
                        CreateInvtPick.Run(Rec);
                        CurrPage.Update;
                        CurrPage.WhseActivityLines.PAGE.UpdateForm;
                    end;

                    trigger OnValidate()
                    begin
                        SourceNoOnAfterValidate;
                    end;
                }
                field("Destination No."; "Destination No.")
                {
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 0));
                    Editable = false;
                    QuickEntry = false;
                }
                field("WMSMgt.GetDestinationName(""Destination Type"",""Destination No."")"; WMSMgt.GetDestinationName("Destination Type", "Destination No."))
                {
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 1));
                    Caption = 'Name';
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    QuickEntry = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    Editable = false;
                    QuickEntry = false;
                }
                field("External Document No."; "External Document No.")
                {
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 2));
                    QuickEntry = false;
                }
                field("External Document No.2"; "External Document No.2")
                {
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 3));
                    QuickEntry = false;
                }
            }
            group(Scan)
            {
                Caption = 'Scan';
                field(QtyToHandleGlobal; QtyToHandleGlobal)
                {
                    CaptionClass = QtyToHandleCaption;
                    QuickEntry = false;
                }
                field(Barcode; Barcode)
                {
                    Caption = 'Barcode';

                    trigger OnValidate()
                    var
                        ItemCrossReference: Record "Item Cross Reference";
                        WhseActivityLine: Record "Warehouse Activity Line";
                        LastErrorText: Text;
                    begin
                        if Barcode = '' then
                            exit;
                        /*
                        IF FromLotNo OR FromSerialNo THEN BEGIN
                          FromLotNo := FALSE;
                          FromSerialNo := FALSE;
                          EXIT;
                        END;
                        
                        LastErrorText := GETLASTERRORTEXT;
                        IF LastErrorText <> '' THEN BEGIN
                          CLEARLASTERROR;
                          EXIT;
                        END;
                        */
                        if not GetItemCrossReference(ItemCrossReference) then
                            Error(NoItemWithBarcode, Barcode);
                        if not CheckIfLineExists(ItemCrossReference) then
                            Error(LineDoesntExist, WhseActivityLine.FieldCaption("Item No."), ItemCrossReference."Item No.",
                                                  WhseActivityLine.FieldCaption("Variant Code"), ItemCrossReference."Variant Code",
                                                  WhseActivityLine.FieldCaption("Unit of Measure Code"), ItemCrossReference."Unit of Measure");
                        HasItemTracking(ItemCrossReference."Item No."); //potential split, if same Lot/Serial No from same Bin is used then no need for splitting
                        CheckQtyIsAvailable(ItemCrossReference);
                        AssignQtyToHandle(ItemCrossReference);
                        //after Barcode has been validated, reset all the scanning fields
                        /*
                        Barcode := '';
                        QtyToHandleGlobal := 1;
                        SerialNo := '';
                        LotNo := '';
                        */
                        CurrPage.Update;

                    end;
                }
                field(SerialNo; SerialNo)
                {
                    CaptionClass = SerialNoCaption;
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        FromSerialNo := true;
                    end;
                }
                field(LotNo; LotNo)
                {
                    CaptionClass = LotNoCaption;
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        FromLotNo := true;
                    end;
                }
            }
            part(Control6014405; "Invt. Pick Subform Scan 2")
            {
                Editable = false;
                SubPageLink = "Activity Type" = FIELD(Type),
                              "No." = FIELD("No.");
                SubPageView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                              WHERE(Breakbulk = CONST(false));
            }
            part(WhseActivityLines; "Invt. Pick Subform Scan")
            {
                SubPageLink = "Activity Type" = FIELD(Type),
                              "No." = FIELD("No.");
                SubPageView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                              WHERE(Breakbulk = CONST(false));
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
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
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

                    trigger OnAction()
                    begin
                        LookupActivityHeader("Location Code", Rec);
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
                }
                action("Posted Picks")
                {
                    Caption = 'Posted Picks';
                    Image = PostedInventoryPick;
                    RunObject = Page "Posted Invt. Pick List";
                    RunPageLink = "Invt Pick No." = FIELD("No.");
                    RunPageView = SORTING("Invt Pick No.");
                }
                action("Source Documents")
                {
                    Caption = 'Source Documents';
                    Image = "Order";

                    trigger OnAction()
                    var
                        WMSMgt: Codeunit "WMS Management";
                    begin
                        WMSMgt.ShowSourceDocCard("Source Type", "Source Subtype", "Source No.");
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
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    var
                        CreateInvtPick: Codeunit "Create Inventory Pick/Movement";
                    begin
                        CreateInvtPick.Run(Rec);
                        UpdateRemQtyToPick(Rec);
                    end;
                }
                action(DoAutofillQtyToHandle)
                {
                    Caption = 'Autofill Qty. to Handle';
                    Image = AutofillQtyToHandle;

                    trigger OnAction()
                    begin
                        AutofillQtyToHandle;
                    end;
                }
                action("Delete Qty. to Handle")
                {
                    Caption = 'Delete Qty. to Handle';
                    Image = DeleteQtyToHandle;

                    trigger OnAction()
                    begin
                        DeleteQtyToHandle;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        PostPickYesNo;
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        PostAndPrint;
                    end;
                }
            }
            action("&Print")
            {
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

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
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Picking List";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Barcode := '';
        QtyToHandleGlobal := 1;
        SerialNo := '';
        LotNo := '';
        FromLotNo := false;
        FromSerialNo := false;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindFirstAllowedRec(Which));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Location Code" := GetUserLocation;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(FindNextAllowedRec(Steps));
    end;

    trigger OnOpenPage()
    begin
        ErrorIfUserIsNotWhseEmployee;
        UpdateRemQtyToPick(Rec);
        QtyToHandleGlobal := 1;
    end;

    var
        WhseActPrint: Codeunit "Warehouse Document-Print";
        WMSMgt: Codeunit "WMS Management";
        NoItemWithBarcode: Label 'There are no items with cross reference: %1';
        LineDoesntExist: Label 'Line with %1: %2, %3: %4 and %5: %6 doesn''t exist.';
        SNRequired: Boolean;
        LNRequired: Boolean;
        CantDistributeQty: Label 'Available quantity for distribution is %1. You''ve set %2. Please change %3 and try again.';
        QtyToHandleError: Label '%1 must not be %2.';
        Barcode: Code[20];
        QtyToHandleGlobal: Decimal;
        SerialNo: Code[20];
        LotNo: Code[20];
        QtyToHandleCaption: Label 'Qty. to Handle';
        LotNoCaption: Label 'Lot No.';
        SerialNoCaption: Label 'Serial No.';
        FromLotNo: Boolean;
        FromSerialNo: Boolean;

    local procedure AutofillQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.AutofillQtyToHandle;
    end;

    local procedure DeleteQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.DeleteQtyToHandle;
    end;

    local procedure PostPickYesNo()
    begin
        CurrPage.WhseActivityLines.PAGE.PostPickYesNo;
    end;

    local procedure PostAndPrint()
    begin
        CurrPage.WhseActivityLines.PAGE.PostAndPrint;
    end;

    local procedure SourceNoOnAfterValidate()
    begin
        CurrPage.Update;
        CurrPage.WhseActivityLines.PAGE.UpdateForm;
    end;

    local procedure GetItemCrossReference(var ItemCrossReference: Record "Item Cross Reference"): Boolean
    begin
        Clear(ItemCrossReference);
        with ItemCrossReference do begin
            SetCurrentKey("Cross-Reference No.", "Cross-Reference Type", "Cross-Reference Type No.", "Discontinue Bar Code");
            SetRange("Cross-Reference No.", Barcode);
            SetRange("Discontinue Bar Code", false);
            SetFilter("Cross-Reference Type No.", '%1', '');
            SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            exit(FindFirst);
        end;
    end;

    local procedure CheckIfLineExists(ItemCrossReference: Record "Item Cross Reference"): Boolean
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        SetWhseActivityLineFilterFromItemCrossReference(WhseActivityLine, ItemCrossReference);
        exit(not WhseActivityLine.IsEmpty);
    end;

    local procedure HasItemTracking(ItemNo: Code[20]): Boolean
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemTrackingError: Label 'Item has item tracking enabled so you need to set %1 before scanning.';
        ItemTrackingNotEnabledError: Label 'Item doesn''t have item tracking enabled so you need to remove %1 before scanning.';
    begin
        ItemTrackingMgt.CheckWhseItemTrkgSetup(ItemNo, SNRequired, LNRequired, false);
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

    local procedure CheckQtyIsAvailable(ItemCrossReference: Record "Item Cross Reference")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        TotalQty: Decimal;
        QtyToHandleError: Label '%1 needs to be set before scanning.';
    begin
        if QtyToHandleGlobal = 0 then
            Error(QtyToHandleError, QtyToHandleCaption);
        SetWhseActivityLineFilterFromItemCrossReference(WhseActivityLine, ItemCrossReference);
        with WhseActivityLine do
            if FindSet then
                repeat
                    TotalQty += "Qty. (Base)" - "Qty. to Handle (Base)";
                until Next = 0;
        if QtyToHandleGlobal > TotalQty then
            Error(CantDistributeQty, TotalQty, QtyToHandleGlobal, QtyToHandleCaption);
    end;

    local procedure SetWhseActivityLineFilterFromItemCrossReference(var WhseActivityLine: Record "Warehouse Activity Line"; ItemCrossReference: Record "Item Cross Reference")
    begin
        with WhseActivityLine do begin
            Reset;
            SetRange("Activity Type", Rec.Type);
            SetRange("No.", Rec."No.");
            SetRange("Item No.", ItemCrossReference."Item No.");
            if ItemCrossReference."Variant Code" <> '' then
                SetRange("Variant Code", ItemCrossReference."Variant Code");
            if ItemCrossReference."Unit of Measure" <> '' then
                SetRange("Unit of Measure Code", ItemCrossReference."Unit of Measure");
        end;
    end;

    local procedure AssignQtyToHandle(ItemCrossReference: Record "Item Cross Reference")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        TotalQtyToHandle: Decimal;
        OutstandingQty: Decimal;
    begin
        SetWhseActivityLineFilterFromItemCrossReference(WhseActivityLine, ItemCrossReference);
        TotalQtyToHandle := QtyToHandleGlobal;
        OutstandingQty := TotalQtyToHandle;
        with WhseActivityLine do begin
            SetFilter("Qty. Outstanding (Base)", '<>0');
            //if there are predefined Lot/Serial No. we first use those
            if SNRequired then
                SetRange("Serial No.", SerialNo);
            if LNRequired then
                SetRange("Lot No.", LotNo);
            DistributeQty(WhseActivityLine, OutstandingQty, false);
            if (OutstandingQty > 0) and (SNRequired or LNRequired) then begin
                //next, other lines and we assign Lot/No. if set
                SetRange("Serial No.", '');
                SetRange("Lot No.", '');
                DistributeQty(WhseActivityLine, OutstandingQty, SNRequired or LNRequired);
                //if still missing lines , we start splitting
                while OutstandingQty > 0 do begin
                    SetRange("Serial No.");
                    SetRange("Lot No.");
                    SplitLineAndAssignValue(WhseActivityLine, OutstandingQty);
                end;
            end;
        end;
    end;

    local procedure DistributeQty(var WhseActivityLine: Record "Warehouse Activity Line"; var QtyToHandle: Decimal; AssignTracking: Boolean)
    var
        QtyToAssign: Decimal;
    begin
        with WhseActivityLine do begin
            if FindSet then
                repeat
                    QtyToAssign := 0;
                    if QtyToHandle <= ("Qty. (Base)" - "Qty. to Handle (Base)") then
                        QtyToAssign := "Qty. to Handle (Base)" + QtyToHandle
                    else
                        QtyToAssign := "Qty. (Base)";
                    QtyToHandle -= QtyToAssign - "Qty. to Handle (Base)";
                    Validate("Qty. to Handle (Base)", QtyToAssign);
                    "Rem. Qty. to Pick (Base)" := "Qty. (Base)" - "Qty. to Handle (Base)";
                    Modify(true);
                    if AssignTracking then begin
                        if SNRequired then
                            Validate("Serial No.", SerialNo);
                        if LNRequired then
                            Validate("Lot No.", LotNo);
                        Modify(true);
                    end;
                until (Next = 0) or (QtyToHandle = 0);
        end;
    end;

    local procedure SplitLineAndAssignValue(var WhseActivityLine: Record "Warehouse Activity Line"; var QtyToHandle: Decimal)
    var
        Splitted: Boolean;
        FoundNewLine: Boolean;
        SourceWhseActivityLine: Record "Warehouse Activity Line";
        NewWhseActivityLine: Record "Warehouse Activity Line";
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        QtyToWork: Decimal;
        NoLinesToHandle: Label 'There aren''t any more available lines to be handled.';
    begin
        with WhseActivityLine do begin
            //since we've no idea what is the line that will be created in SplitLine, we first remember every line before splitting
            if FindSet then begin
                repeat
                    TempWhseActivLine := WhseActivityLine;
                    TempWhseActivLine.Insert;
                until Next = 0;
            end;
            //splitting occurs here. first we remember old values and reset tracking and assign new quantity for splitting
            if FindSet then
                repeat
                    //Splitted := "Qty. (Base)" > "Qty. to Handle (Base)";
                    Splitted := ("Qty. (Base)" > "Qty. to Handle (Base)") and ("Qty. (Base)" > 1) and ("Qty. Outstanding (Base)" > 0);
                    if Splitted then begin
                        SourceWhseActivityLine.Copy(WhseActivityLine);
                        Validate("Serial No.", '');
                        Validate("Lot No.", '');
                        QtyToWork := QtyToHandle;
                        if QtyToHandle > "Qty. (Base)" - "Qty. to Handle (Base)" then
                            QtyToWork := "Qty. (Base)" - "Qty. to Handle (Base)";
                        Validate("Qty. to Handle (Base)", QtyToWork);
                        "Rem. Qty. to Pick (Base)" := "Qty. (Base)" - "Qty. to Handle (Base)";
                        QtyToHandle -= QtyToWork;
                        Modify(true);
                        SplitLine(WhseActivityLine);
                        //WhseActivityLine has now become "new" line with good quantity and need to apply new tracking
                        if SNRequired then
                            Validate("Serial No.", SerialNo);
                        if LNRequired then
                            Validate("Lot No.", LotNo);
                        Modify(true);
                    end;
                until (Next = 0) or Splitted;
            if not Splitted then
                Error(NoLinesToHandle);
            //now we search for new line, which is in fact "old" with values we backed-up earlier
            if FindSet then
                repeat
                    FoundNewLine := not TempWhseActivLine.Get("Activity Type", "No.", "Line No.");
                    if FoundNewLine then
                        TempWhseActivLine := WhseActivityLine;
                until (Next = 0) or FoundNewLine;
        end;
        // and update it
        with NewWhseActivityLine do begin
            Get(TempWhseActivLine."Activity Type", TempWhseActivLine."No.", TempWhseActivLine."Line No.");
            Validate("Qty. to Handle (Base)", SourceWhseActivityLine."Qty. to Handle (Base)");
            "Rem. Qty. to Pick (Base)" := "Qty. (Base)" - "Qty. to Handle (Base)";
            Validate("Serial No.", SourceWhseActivityLine."Serial No.");
            Validate("Lot No.", SourceWhseActivityLine."Lot No.");
            Modify(true);
        end;
    end;

    procedure UpdateRemQtyToPick(WhseActivityHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WhseActivityLine.SetRange("No.", WhseActivityHeader."No.");
        if WhseActivityLine.FindSet then
            repeat
                WhseActivityLine."Rem. Qty. to Pick (Base)" := WhseActivityLine."Qty. (Base)" - WhseActivityLine."Qty. to Handle (Base)";
                WhseActivityLine.Modify;
            until WhseActivityLine.Next = 0;
    end;
}

