page 6014403 "Retail Item Reclass. Journal"
{
    // NPR5.23/THRO/20160509 CASE 240777 "Cross-Reference No." inserted
    // NPR5.30/TJ  /20170222 CASE 266258 Creating template for new page ID if it doesn't allready exist
    // NPR5.30/TJ  /20170227 CASE 267424 Using GetItem function from RetailItemJnlMgt

    AutoSplitKey = true;
    Caption = 'Item Reclass. Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Journal Line";

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName;CurrentJnlBatchName)
            {
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    ItemJnlMgt.LookupName(CurrentJnlBatchName,Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName,Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date";"Posting Date")
                {
                }
                field("Document Date";"Document Date")
                {
                    Visible = false;
                }
                field("Document No.";"Document No.")
                {
                }
                field("Item No.";"Item No.")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.30 [267424]
                        //ItemJnlMgt.GetItem("Item No.",ItemDescription);
                        RetailItemJnlMgt.GetItem("Item No.",ItemDescription);
                        //+NPR5.30 [267424]
                        ShowShortcutDimCode(ShortcutDimCode);
                        ShowNewShortcutDimCode(NewShortcutDimCode);
                    end;
                }
                field("Variant Code";"Variant Code")
                {
                    Visible = false;
                }
                field("Cross-Reference No.";"Cross-Reference No.")
                {
                    Visible = false;
                }
                field(Description;Description)
                {
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("New Shortcut Dimension 1 Code";"New Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    Visible = false;
                }
                field("New Shortcut Dimension 2 Code";"New Shortcut Dimension 2 Code")
                {
                    Visible = false;
                }
                field("ShortcutDimCode[3]";ShortcutDimCode[3])
                {
                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3,ShortcutDimCode[3]);
                    end;
                }
                field("NewShortcutDimCode[3]";NewShortcutDimCode[3])
                {
                    CaptionClass = Text000;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(3,NewShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(3,NewShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]";ShortcutDimCode[4])
                {
                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(4),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4,ShortcutDimCode[4]);
                    end;
                }
                field("NewShortcutDimCode[4]";NewShortcutDimCode[4])
                {
                    CaptionClass = Text001;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(4,NewShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(4,NewShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]";ShortcutDimCode[5])
                {
                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(5),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5,ShortcutDimCode[5]);
                    end;
                }
                field("NewShortcutDimCode[5]";NewShortcutDimCode[5])
                {
                    CaptionClass = Text002;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(5,NewShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(5,NewShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]";ShortcutDimCode[6])
                {
                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(6),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6,ShortcutDimCode[6]);
                    end;
                }
                field("NewShortcutDimCode[6]";NewShortcutDimCode[6])
                {
                    CaptionClass = Text003;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(6,NewShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(6,NewShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]";ShortcutDimCode[7])
                {
                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(7),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7,ShortcutDimCode[7]);
                    end;
                }
                field("NewShortcutDimCode[7]";NewShortcutDimCode[7])
                {
                    CaptionClass = Text004;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(7,NewShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(7,NewShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]";ShortcutDimCode[8])
                {
                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(8),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8,ShortcutDimCode[8]);
                    end;
                }
                field("NewShortcutDimCode[8]";NewShortcutDimCode[8])
                {
                    CaptionClass = Text005;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(8,NewShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type","Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(8,NewShortcutDimCode[8]);
                    end;
                }
                field("Location Code";"Location Code")
                {
                    Visible = true;

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec,xRec);
                    end;
                }
                field("Bin Code";"Bin Code")
                {
                    Visible = false;
                }
                field("New Location Code";"New Location Code")
                {
                    Visible = false;

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec,xRec);
                    end;
                }
                field("New Bin Code";"New Bin Code")
                {
                    Visible = false;
                }
                field("Salespers./Purch. Code";"Salespers./Purch. Code")
                {
                    Visible = false;
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                    Visible = false;
                }
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Unit Amount";"Unit Amount")
                {
                    Visible = false;
                }
                field(Amount;Amount)
                {
                    Visible = false;
                }
                field("Indirect Cost %";"Indirect Cost %")
                {
                    Visible = false;
                }
                field("Unit Cost";"Unit Cost")
                {
                    Visible = false;
                }
                field("Applies-to Entry";"Applies-to Entry")
                {
                }
                field("Reason Code";"Reason Code")
                {
                    Visible = false;
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
                        field(ItemDescription;ItemDescription)
                        {
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
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
                    AccessByPermission = TableData Dimension=R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowReclasDimensions;
                        CurrPage.SaveRecord;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines(true);
                    end;
                }
                action("Bin Contents")
                {
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code"=FIELD("Location Code"),
                                  "Item No."=FIELD("Item No."),
                                  "Variant Code"=FIELD("Variant Code");
                    RunPageView = SORTING("Location Code","Item No.","Variant Code");
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
                    RunPageLink = "No."=FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No."=FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        Caption = 'Event';
                        Image = "Event";

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec,ItemAvailFormsMgt.ByEvent)
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec,ItemAvailFormsMgt.ByPeriod)
                        end;
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec,ItemAvailFormsMgt.ByVariant)
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location=R;
                        Caption = 'Location';
                        Image = Warehouse;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec,ItemAvailFormsMgt.ByLocation)
                        end;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec,ItemAvailFormsMgt.ByBOM)
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
                }
                separator(Separator52)
                {
                }
                action("Get Bin Content")
                {
                    AccessByPermission = TableData "Bin Content"=R;
                    Caption = 'Get Bin Content';
                    Ellipsis = true;
                    Image = GetBinContent;

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                        GetBinContent: Report "Whse. Get Bin Content";
                    begin
                        BinContent.SetRange("Location Code","Location Code");
                        GetBinContent.SetTableView(BinContent);
                        GetBinContent.InitializeItemJournalLine(Rec);
                        GetBinContent.RunModal;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post",Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post+Print",Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
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
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name","Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name","Journal Batch Name");
                    REPORT.RunModal(REPORT::"Inventory Movement",true,true,ItemJnlLine);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.30 [267424]
        //ItemJnlMgt.GetItem("Item No.",ItemDescription);
        RetailItemJnlMgt.GetItem("Item No.",ItemDescription);
        //+NPR5.30 [267424]
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        ShowNewShortcutDimCode(NewShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
    begin
        Commit;
        if not ReserveItemJnlLine.DeleteLineConfirm(Rec) then
          exit(false);
        ReserveItemJnlLine.DeleteLine(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
        Clear(NewShortcutDimCode);
        "Entry Type" := "Entry Type"::Transfer;
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        if IsOpenedFromBatch then begin
          CurrentJnlBatchName := "Journal Batch Name";
          ItemJnlMgt.OpenJnl(CurrentJnlBatchName,Rec);
          exit;
        end;
        //-NPR5.30 [266258]
        if not RetailItemJnlMgt.FindTemplate(PAGE::"Retail Item Reclass. Journal") then
          RetailItemJnlMgt.CreateTemplate(PAGE::"Retail Item Reclass. Journal",1,false);
        //+NPR5.30 [266258]
        ItemJnlMgt.TemplateSelection(PAGE::"Retail Item Reclass. Journal",1,false,Rec,JnlSelected);
        if not JnlSelected then
          Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName,Rec);
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
        ItemDescription: Text[50];
        ShortcutDimCode: array [8] of Code[20];
        NewShortcutDimCode: array [8] of Code[20];
        RetailItemJnlMgt: Codeunit RetailItemJnlManagement;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        ItemJnlMgt.SetName(CurrentJnlBatchName,Rec);
        CurrPage.Update(false);
    end;
}

