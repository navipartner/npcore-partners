page 6014402 "NPR Retail Item Journal"
{

    AutoSplitKey = true;
    Caption = 'Retail Item Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    QueryCategory = '#Basic,#Suite';
    SaveValues = true;
    SourceTable = "Item Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {

                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the value of the Batch Name field';
                ApplicationArea = NPRRetail;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Date"; Rec."Document Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RetailItemJnlMgt.GetItem(Rec."Item No.", ItemDescription);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Cross-Reference No."; Rec."Item Reference No.")
                {

                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {

                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[3] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {

                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[4] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {

                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[5] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {

                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[6] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {

                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[7] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {

                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[8] field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec, xRec);
                    end;
                }
                field("Bin Code"; Rec."Bin Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Salespers./Purch. Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Amount"; Rec."Unit Amount")
                {

                    ToolTip = 'Specifies the value of the Unit Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Indirect Cost % field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {

                    ToolTip = 'Specifies the value of the Unit Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {

                    ToolTip = 'Specifies the value of the Applies-to Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Applies-from Entry"; Rec."Applies-from Entry")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Applies-from Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Transaction Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Transport Method"; Rec."Transport Method")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Transport Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Reason Code"; Rec."Reason Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control22)
            {
                ShowCaption = false;
                fixed(Control1900669001)
                {
                    ShowCaption = false;
                    group("Item Description")
                    {
                        Caption = 'Item Description';
                        field(ItemDescription; ItemDescription)
                        {

                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ItemDescription field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1903326807; "Item Replenishment FactBox")
            {
                SubPageLink = "No." = FIELD("Item No.");
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
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'Executes the Dimensions action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action(ItemTrackingLines)
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+I';

                    ToolTip = 'Executes the Item &Tracking Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines(false);
                    end;
                }
                action("Bin Contents")
                {
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    RunPageView = SORTING("Location Code", "Item No.", "Variant Code");

                    ToolTip = 'Executes the Bin Contents action';
                    ApplicationArea = NPRRetail;
                }
                separator("-")
                {
                    Caption = '-';
                }
                action("&Recalculate Unit Amount")
                {
                    Caption = '&Recalculate Unit Amount';
                    Image = UpdateUnitCost;

                    ToolTip = 'Executes the &Recalculate Unit Amount action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RecalculateUnitAmount();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';

                    ToolTip = 'Executes the Card action';
                    ApplicationArea = NPRRetail;
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    Promoted = false;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Ledger E&ntries action';
                    ApplicationArea = NPRRetail;
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("NPR Event")
                    {
                        Caption = 'Event';
                        Image = "Event";

                        ToolTip = 'Executes the Event action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByEvent())
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;

                        ToolTip = 'Executes the Period action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByPeriod())
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;

                        ToolTip = 'Executes the Variant action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByVariant())
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        Caption = 'Location';
                        Image = Warehouse;

                        ToolTip = 'Executes the Location action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByLocation())
                        end;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        ToolTip = 'Executes the BOM Level action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByBOM())
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("E&xplode BOM")
                {
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Codeunit "Item Jnl.-Explode BOM";

                    ToolTip = 'Executes the E&xplode BOM action';
                    ApplicationArea = NPRRetail;
                }
                action("&Calculate Whse. Adjustment")
                {
                    Caption = '&Calculate Whse. Adjustment';
                    Ellipsis = true;
                    Image = CalculateWarehouseAdjustment;

                    ToolTip = 'Executes the &Calculate Whse. Adjustment action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        CalcWhseAdjmt.SetItemJnlLine(Rec);
                        CalcWhseAdjmt.RunModal();
                        Clear(CalcWhseAdjmt);
                    end;
                }
                separator(Separator73)
                {
                    Caption = '-';
                }
                action("&Get Standard Journals")
                {
                    Caption = '&Get Standard Journals';
                    Ellipsis = true;
                    Image = GetStandardJournal;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Executes the &Get Standard Journals action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        StdItemJnl: Record "Standard Item Journal";
                    begin
                        StdItemJnl.FilterGroup := 2;
                        StdItemJnl.SetRange("Journal Template Name", Rec."Journal Template Name");
                        StdItemJnl.FilterGroup := 0;
                        if PAGE.RunModal(PAGE::"Standard Item Journals", StdItemJnl) = ACTION::LookupOK then begin
                            StdItemJnl.CreateItemJnlFromStdJnl(StdItemJnl, CurrentJnlBatchName);
                            Message(Text001, StdItemJnl.Code);
                        end
                    end;
                }
                action("&Save as Standard Journal")
                {
                    Caption = '&Save as Standard Journal';
                    Ellipsis = true;
                    Image = SaveasStandardJournal;

                    ToolTip = 'Executes the &Save as Standard Journal action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemJnlBatch: Record "Item Journal Batch";
                        ItemJnlLines: Record "Item Journal Line";
                        StdItemJnl: Record "Standard Item Journal";
                        SaveAsStdItemJnl: Report "Save as Standard Item Journal";
                    begin
                        ItemJnlLines.SetFilter("Journal Template Name", Rec."Journal Template Name");
                        ItemJnlLines.SetFilter("Journal Batch Name", CurrentJnlBatchName);
                        CurrPage.SetSelectionFilter(ItemJnlLines);
                        ItemJnlLines.CopyFilters(Rec);

                        ItemJnlBatch.Get(Rec."Journal Template Name", CurrentJnlBatchName);
                        SaveAsStdItemJnl.Initialise(ItemJnlLines, ItemJnlBatch);
                        SaveAsStdItemJnl.RunModal();
                        if not SaveAsStdItemJnl.GetStdItemJournal(StdItemJnl) then
                            exit;

                        Message(Text002, StdItemJnl.Code);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    ToolTip = 'Executes the Test Report action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintItemJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    Caption = 'P&ost';
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
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
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
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
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
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    REPORT.RunModal(REPORT::"Inventory Movement", true, true, ItemJnlLine);
                end;
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;

                ToolTip = 'Executes the Price Label action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RetailItemJnlMgt.GetItem(Rec."Item No.", ItemDescription);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
    begin
        Commit();
        if not ReserveItemJnlLine.DeleteLineConfirm(Rec) then
            exit(false);
        ReserveItemJnlLine.DeleteLine(Rec);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."Entry Type".AsInteger() > Rec."Entry Type"::"Negative Adjmt.".AsInteger() then
            Error(Text000, Rec."Entry Type");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        if Rec.IsOpenedFromBatch() then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        if not RetailItemJnlMgt.FindTemplate(PAGE::"NPR Retail Item Journal") then
            RetailItemJnlMgt.CreateTemplate(PAGE::"NPR Retail Item Journal", 0, false);
        ItemJnlMgt.TemplateSelection(PAGE::"NPR Retail Item Journal", 0, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        Text000: Label 'You cannot use entry type %1 in this journal.';
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        CalcWhseAdjmt: Report "Calculate Whse. Adjustment";
        CurrentJnlBatchName: Code[10];
        ItemDescription: Text[100];
        ShortcutDimCode: array[8] of Code[20];
        Text001: Label 'Item Journal lines have been successfully inserted from Standard Item Journal %1.';
        Text002: Label 'Standard Item Journal %1 has been successfully created.';
        RetailItemJnlMgt: Codeunit "NPR Retail Item Jnl. Mgt.";

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;
}
