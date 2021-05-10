page 6014403 "NPR Retail ItemReclass.Journal"
{
    AutoSplitKey = true;
    Caption = 'Item Reclass. Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SaveValues = true;
    SourceTable = "Item Journal Line";

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the value of the Batch Name field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';

                    trigger OnValidate()
                    begin
                        RetailItemJnlMgt.GetItem(Rec."Item No.", ItemDescription);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        Rec.ShowNewShortcutDimCode(NewShortcutDimCode);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Cross-Reference No."; Rec."Item Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("New Shortcut Dimension 1 Code"; Rec."New Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("New Shortcut Dimension 2 Code"; Rec."New Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Shortcut Dimension 2 Code field';
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[3] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("NewShortcutDimCode[3]"; NewShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    CaptionClass = Text000;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[3] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(3, NewShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(3, NewShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[4] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("NewShortcutDimCode[4]"; NewShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    CaptionClass = Text001;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[4] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(4, NewShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(4, NewShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[5] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("NewShortcutDimCode[5]"; NewShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    CaptionClass = Text002;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[5] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(5, NewShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(5, NewShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[6] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("NewShortcutDimCode[6]"; NewShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    CaptionClass = Text003;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[6] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(6, NewShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(6, NewShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[7] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("NewShortcutDimCode[7]"; NewShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    CaptionClass = Text004;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[7] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(7, NewShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(7, NewShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[8] field';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("NewShortcutDimCode[8]"; NewShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    CaptionClass = Text005;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the NewShortcutDimCode[8] field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupNewShortcutDimCode(8, NewShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Entry Type", Rec."Entry Type"::Transfer);
                        Rec.ValidateNewShortcutDimCode(8, NewShortcutDimCode[8]);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Location Code field';

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec, xRec);
                    end;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bin Code field';
                }
                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Location Code field';

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec, xRec);
                    end;
                }
                field("New Bin Code"; Rec."New Bin Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Bin Code field';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Salespers./Purch. Code field';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Unit Amount"; Rec."Unit Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Amount field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Indirect Cost % field';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies-to Entry field';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
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
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ItemDescription field';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
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
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        Rec.ShowReclasDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item &Tracking Lines action';

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines(true);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Bin Contents action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Card action';
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ledger E&ntries action';
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("NPR Event")
                    {
                        Caption = 'Event';
                        Image = "Event";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Event action';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByEvent())
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Period action';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByPeriod())
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variant action';

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
                        ApplicationArea = All;
                        ToolTip = 'Executes the Location action';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByLocation())
                        end;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ApplicationArea = All;
                        ToolTip = 'Executes the BOM Level action';

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
                    RunObject = Codeunit "Item Jnl.-Explode BOM";
                    ApplicationArea = All;
                    ToolTip = 'Executes the E&xplode BOM action';
                }
                separator(Separator52)
                {
                }
                action("Get Bin Content")
                {
                    AccessByPermission = TableData "Bin Content" = R;
                    Caption = 'Get Bin Content';
                    Ellipsis = true;
                    Image = GetBinContent;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Get Bin Content action';

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                        GetBinContent: Report "Whse. Get Bin Content";
                    begin
                        BinContent.SetRange("Location Code", Rec."Location Code");
                        GetBinContent.SetTableView(BinContent);
                        GetBinContent.InitializeItemJournalLine(Rec);
                        GetBinContent.RunModal();
                        CurrPage.Update(false);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Test Report action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the P&ost action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post and &Print action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the &Print action';

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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.30 [267424]
        //ItemJnlMgt.GetItem("Item No.",ItemDescription);
        RetailItemJnlMgt.GetItem(Rec."Item No.", ItemDescription);
        //+NPR5.30 [267424]
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        Rec.ShowNewShortcutDimCode(NewShortcutDimCode);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
        Clear(NewShortcutDimCode);
        Rec."Entry Type" := Rec."Entry Type"::Transfer;
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
        //-NPR5.30 [266258]
        if not RetailItemJnlMgt.FindTemplate(PAGE::"NPR Retail ItemReclass.Journal") then
            RetailItemJnlMgt.CreateTemplate(PAGE::"NPR Retail ItemReclass.Journal", 1, false);
        //+NPR5.30 [266258]
        ItemJnlMgt.TemplateSelection(PAGE::"NPR Retail ItemReclass.Journal", 1, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        Text000: Label '1,2,3,New ';
        Text001: Label '1,2,4,New ';
        Text002: Label '1,2,5,New ';
        Text003: Label '1,2,6,New ';
        Text004: Label '1,2,7,New ';
        Text005: Label '1,2,8,New ';
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        CurrentJnlBatchName: Code[10];
        ItemDescription: Text[100];
        ShortcutDimCode: array[8] of Code[20];
        NewShortcutDimCode: array[8] of Code[20];
        RetailItemJnlMgt: Codeunit "NPR Retail Item Jnl. Mgt.";

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;
}

