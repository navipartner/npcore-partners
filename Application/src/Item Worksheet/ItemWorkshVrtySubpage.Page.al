page 6060043 "NPR Item Worksh. Vrty. Subpage"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160308  CASE 182391 Fixed update behaviour, expand/collapase on the web client
    // NPR5.22\BR\20160323  CASE 182391 Added field Recommended Retail Price
    // NPR5.33\BR\20170627  CASE 282211 Made Fields Variety value non-editable
    // NPR5.37/BR/20170922  CASE 268786 Made Variety Value Editable

    AutoSplitKey = true;
    Caption = 'Item Worksheet Variety Subpage';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Item Worksh. Variant Line";
    SourceTableView = SORTING("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                ShowAsTree = true;
                field(Level; Level)
                {
                    ApplicationArea = All;
                    AutoFormatType = 2;
                    BlankNumbers = BlankZeroAndPos;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Level field';
                }
                field("Heading Text"; "Heading Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Heading Text field';
                }
                field("Variety 1 Value"; "Variety 1 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[1];
                    Editable = true;
                    Visible = Variety1InUse;
                    ToolTip = 'Specifies the value of the Variety 1 Value field';

                    trigger OnValidate()
                    begin
                        if "Variety 1 Value" <> xRec."Variety 1 Value" then
                            Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText;
                        Commit;
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 2 Value"; "Variety 2 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[2];
                    Editable = true;
                    Visible = Variety2InUse;
                    ToolTip = 'Specifies the value of the Variety 2 Value field';

                    trigger OnValidate()
                    begin
                        if "Variety 2 Value" <> xRec."Variety 2 Value" then
                            Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText;
                        Commit;
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 3 Value"; "Variety 3 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[3];
                    Editable = true;
                    Visible = Variety3InUse;
                    ToolTip = 'Specifies the value of the Variety 3 Value field';

                    trigger OnValidate()
                    begin
                        if "Variety 3 Value" <> xRec."Variety 3 Value" then
                            Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText;
                        Commit;
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 4 Value"; "Variety 4 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[4];
                    Editable = true;
                    Visible = Variety4InUse;
                    ToolTip = 'Specifies the value of the Variety 4 Value field';

                    trigger OnValidate()
                    begin
                        if "Variety 4 Value" <> xRec."Variety 4 Value" then
                            Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText;
                        Commit;
                        CurrPage.Update(false);
                    end;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';

                    trigger OnValidate()
                    begin
                        if (Action <> xRec.Action) and ("Heading Text" = '') then begin
                            Modify(true);
                            ItemWorksheetLine.UpdateVarietyHeadingText;
                        end;
                        Commit;
                        CurrPage.Update(false);
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';

                    trigger OnValidate()
                    begin
                        if ("Variant Code" <> xRec."Variant Code") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Existing Variant Code"; "Existing Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Existing Variant Code field';

                    trigger OnValidate()
                    begin
                        if ("Existing Variant Code" <> xRec."Existing Variant Code") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Existing Variant Blocked"; "Existing Variant Blocked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Existing Variant Blocked field';
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                    Editable = AltNoEditable;
                    ToolTip = 'Specifies the value of the Internal Bar Code field';

                    trigger OnValidate()
                    begin
                        if ("Internal Bar Code" <> xRec."Internal Bar Code") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                    Editable = CrossRefEditable;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field';

                    trigger OnValidate()
                    begin
                        if ("Vendors Bar Code" <> xRec."Vendors Bar Code") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Recommended Retail Price"; "Recommended Retail Price")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field';

                    trigger OnValidate()
                    begin
                        //-NPR5.22
                        if ("Recommended Retail Price" <> xRec."Recommended Retail Price") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                        RefreshRRPText;
                        //+NPR5.22
                    end;
                }
                field(RRPText; RecommendedRetailPriceText)
                {
                    ApplicationArea = All;
                    Caption = 'Recommended Retail Price';
                    Style = StandardAccent;
                    StyleExpr = RecommendedRetailPriceBold;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field';

                    trigger OnValidate()
                    begin
                        //-NPR5.22
                        if RecommendedRetailPriceText = '' then
                            RecommendedRetailPriceText := '0';
                        Evaluate("Recommended Retail Price", RecommendedRetailPriceText);
                        if "Recommended Retail Price" <> ItemWorksheetLine."Recommended Retail Price" then
                            Validate("Recommended Retail Price")
                        else
                            Validate("Recommended Retail Price", 0);
                        Modify(true);
                        RefreshRRPText;
                        CurrPage.Update(false);
                        //+NPR5.22
                    end;
                }
                field("Sales Price"; "Sales Price")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Price field';

                    trigger OnValidate()
                    begin
                        if ("Sales Price" <> xRec."Sales Price") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                        RefreshSalesPriceText;
                    end;
                }
                field("Unit Price"; SalesPriceText)
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    StyleExpr = SalesPriceBold;
                    ToolTip = 'Specifies the value of the SalesPriceText field';

                    trigger OnValidate()
                    begin
                        if SalesPriceText = '' then
                            SalesPriceText := '0';
                        Evaluate("Sales Price", SalesPriceText);
                        if "Sales Price" <> ItemWorksheetLine."Sales Price" then
                            Validate("Sales Price")
                        else
                            Validate("Sales Price", 0);
                        Modify(true);
                        RefreshSalesPriceText;
                        CurrPage.Update(false);
                    end;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';

                    trigger OnValidate()
                    begin

                        if ("Direct Unit Cost" <> xRec."Direct Unit Cost") and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Unit Cost"; PurchasePriceText)
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    StyleExpr = PurchasePriceBold;
                    ToolTip = 'Specifies the value of the PurchasePriceText field';

                    trigger OnValidate()
                    begin
                        if PurchasePriceText = '' then
                            PurchasePriceText := '0';
                        Evaluate("Direct Unit Cost", PurchasePriceText);
                        if "Direct Unit Cost" <> ItemWorksheetLine."Direct Unit Cost" then
                            Validate("Direct Unit Cost")
                        else
                            Validate("Direct Unit Cost", 0);
                        Modify(true);
                        RefreshPurchasePriceText;
                        CurrPage.Update(false);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';

                    trigger OnValidate()
                    begin
                        if (Description <> xRec.Description) and ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';

                    trigger OnValidate()
                    begin
                        if ("Heading Text" = '') then
                            Modify(true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        RefreshSalesPriceText;
        RefreshPurchasePriceText;
        //-NPR5.22
        RefreshRRPText;
        //+NPR5.22
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Worksheet Template Name" := ItemWorksheetLine."Worksheet Template Name";
        "Worksheet Name" := ItemWorksheetLine."Worksheet Name";
        "Worksheet Line No." := ItemWorksheetLine."Line No.";
    end;

    trigger OnOpenPage()
    begin
        if not VarietySetup.Get then
            VarietySetup.Init;
        AltNoEditable := VarietySetup."Create Alt. No. automatic";
        CrossRefEditable := VarietySetup."Create Item Cross Ref. auto.";
    end;

    var
        FieldCaptionNew: array[4] of Text;
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        [InDataSet]
        Variety1InUse: Boolean;
        [InDataSet]
        Variety2InUse: Boolean;
        [InDataSet]
        Variety3InUse: Boolean;
        [InDataSet]
        Variety4InUse: Boolean;
        RecommendedRetailPriceText: Text[20];
        RecommendedRetailPriceBold: Boolean;
        SalesPriceText: Text[20];
        SalesPriceBold: Boolean;
        PurchasePriceText: Text[20];
        PurchasePriceBold: Boolean;
        AutoFormatManagement: Codeunit "Auto Format";
        VarietySetup: Record "NPR Variety Setup";
        AltNoEditable: Boolean;
        CrossRefEditable: Boolean;

    procedure SetRecFromIW(ItemWorksheetLineHere: Record "NPR Item Worksheet Line")
    var
        LocRecItemWorksheet: Record "NPR Item Worksheet";
    begin
        ItemWorksheetLine := ItemWorksheetLineHere;

        FilterGroup := 2;
        SetRange("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        SetRange("Worksheet Line No.", ItemWorksheetLine."Line No.");
        FilterGroup := 0;

        MakeCaptions();

        //-NPR4.19
        if CurrentClientType <> CLIENTTYPE::Windows then begin
            if LocRecItemWorksheet.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name") then begin
                case LocRecItemWorksheet."Show Variety Level" of
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2+3+4":
                        SetRange(Level, 0, 3);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2+3":
                        SetRange(Level, 0, 2);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2":
                        SetRange(Level, 0, 1);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1":
                        SetRange(Level, 0, 0);
                end;
            end;
        end;
        //+NPR4.19
    end;

    local procedure MakeCaptions()
    begin
        Variety1InUse := (ItemWorksheetLine."Variety 1" <> '') and (ItemWorksheetLine."Variety 1 Table (New)" <> '');
        if Variety1InUse then
            FieldCaptionNew[1] := ItemWorksheetLine."Variety 1" + '; ' + ItemWorksheetLine."Variety 1 Table (New)";

        Variety2InUse := (ItemWorksheetLine."Variety 2" <> '') and (ItemWorksheetLine."Variety 2 Table (New)" <> '');
        if Variety2InUse then
            FieldCaptionNew[2] := ItemWorksheetLine."Variety 2" + '; ' + ItemWorksheetLine."Variety 2 Table (New)";

        Variety3InUse := (ItemWorksheetLine."Variety 3" <> '') and (ItemWorksheetLine."Variety 3 Table (New)" <> '');
        if Variety3InUse then
            FieldCaptionNew[3] := ItemWorksheetLine."Variety 3" + '; ' + ItemWorksheetLine."Variety 3 Table (New)";

        Variety4InUse := (ItemWorksheetLine."Variety 4" <> '') and (ItemWorksheetLine."Variety 4 Table (New)" <> '');
        if Variety4InUse then
            FieldCaptionNew[4] := ItemWorksheetLine."Variety 4" + '; ' + ItemWorksheetLine."Variety 4 Table (New)";
    end;

    procedure UpdateSubPage()
    begin
        CurrPage.Update(false);
    end;

    local procedure RefreshSalesPriceText()
    begin
        GetLine;
        if "Heading Text" <> '' then
            SalesPriceText := ''
        else
            if "Sales Price" = 0 then
                SalesPriceText := StrSubstNo('( %1 )', Format(ItemWorksheetLine."Sales Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                SalesPriceText := StrSubstNo('%1', Format("Sales Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        SalesPriceBold := "Sales Price" > 0;
    end;

    local procedure RefreshPurchasePriceText()
    begin
        GetLine;
        if "Heading Text" <> '' then
            PurchasePriceText := ''
        else
            if "Direct Unit Cost" = 0 then
                PurchasePriceText := StrSubstNo('( %1 )', Format(ItemWorksheetLine."Direct Unit Cost", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                PurchasePriceText := StrSubstNo('%1', Format("Direct Unit Cost", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        PurchasePriceBold := "Direct Unit Cost" > 0;
    end;

    local procedure RefreshRRPText()
    begin
        //-NPR5.22
        GetLine;
        if "Heading Text" <> '' then
            RecommendedRetailPriceText := ''
        else
            if "Recommended Retail Price" = 0 then
                RecommendedRetailPriceText := StrSubstNo('( %1 )', Format(ItemWorksheetLine."Recommended Retail Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                RecommendedRetailPriceText := StrSubstNo('%1', Format("Recommended Retail Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        RecommendedRetailPriceBold := "Recommended Retail Price" > 0;
        //+NPR5.22
    end;
}

