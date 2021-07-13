page 6060043 "NPR Item Worksh. Vrty. Subpage"
{
    AutoSplitKey = true;
    Caption = 'Item Worksheet Variety Subpage';
    PageType = ListPart;
    SourceTable = "NPR Item Worksh. Variant Line";
    SourceTableView = SORTING("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                      ORDER(Ascending);
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Level;
                ShowAsTree = true;
                field(Level; Rec.Level)
                {

                    AutoFormatType = 2;
                    BlankNumbers = BlankZeroAndPos;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Level field.';
                    ApplicationArea = NPRRetail;
                }
                field("Heading Text"; Rec."Heading Text")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Heading Text field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Value"; Rec."Variety 1 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[1];
                    Editable = true;
                    ToolTip = 'Specifies the value of the Variety 1 Value field.';
                    Visible = Variety1InUse;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Variety 1 Value" <> xRec."Variety 1 Value" then
                            Rec.Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText();
                        Commit();
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 2 Value"; Rec."Variety 2 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[2];
                    Editable = true;
                    ToolTip = 'Specifies the value of the Variety 2 Value field.';
                    Visible = Variety2InUse;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Variety 2 Value" <> xRec."Variety 2 Value" then
                            Rec.Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText();
                        Commit();
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 3 Value"; Rec."Variety 3 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[3];
                    Editable = true;
                    ToolTip = 'Specifies the value of the Variety 3 Value field.';
                    Visible = Variety3InUse;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Variety 3 Value" <> xRec."Variety 3 Value" then
                            Rec.Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText();
                        Commit();
                        CurrPage.Update(false);
                    end;
                }
                field("Variety 4 Value"; Rec."Variety 4 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[4];
                    Editable = true;
                    ToolTip = 'Specifies the value of the Variety 4 Value field.';
                    Visible = Variety4InUse;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Variety 4 Value" <> xRec."Variety 4 Value" then
                            Rec.Modify(true);
                        ItemWorksheetLine.UpdateVarietyHeadingText();
                        Commit();
                        CurrPage.Update(false);
                    end;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec.Action <> xRec.Action) and (Rec."Heading Text" = '') then begin
                            Rec.Modify(true);
                            ItemWorksheetLine.UpdateVarietyHeadingText();
                        end;
                        Commit();
                        CurrPage.Update(false);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Variant Code" <> xRec."Variant Code") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Existing Variant Code"; Rec."Existing Variant Code")
                {

                    ToolTip = 'Specifies the value of the Existing Variant Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Existing Variant Code" <> xRec."Existing Variant Code") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Existing Variant Blocked"; Rec."Existing Variant Blocked")
                {

                    ToolTip = 'Specifies the value of the Existing Variant Blocked field.';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Internal Bar Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Internal Bar Code" <> xRec."Internal Bar Code") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {

                    Editable = CrossRefEditable;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Vendors Bar Code" <> xRec."Vendors Bar Code") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Recommended Retail Price"; Rec."Recommended Retail Price")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Recommended Retail Price" <> xRec."Recommended Retail Price") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                        RefreshRRPText();
                    end;
                }
                field(RRPText; RecommendedRetailPriceText)
                {

                    Caption = 'Recommended Retail Price';
                    Style = StandardAccent;
                    StyleExpr = RecommendedRetailPriceBold;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if RecommendedRetailPriceText = '' then
                            RecommendedRetailPriceText := '0';
                        Evaluate(Rec."Recommended Retail Price", RecommendedRetailPriceText);
                        if Rec."Recommended Retail Price" <> ItemWorksheetLine."Recommended Retail Price" then
                            Rec.Validate("Recommended Retail Price")
                        else
                            Rec.Validate("Recommended Retail Price", 0);
                        Rec.Modify(true);
                        RefreshRRPText();
                        CurrPage.Update(false);
                    end;
                }
                field("Sales Price"; Rec."Sales Price")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Sales Price field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Sales Price" <> xRec."Sales Price") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                        RefreshSalesPriceText();
                    end;
                }
                field("Unit Price"; SalesPriceText)
                {

                    Caption = 'Unit Price';
                    Style = StandardAccent;
                    StyleExpr = SalesPriceBold;
                    ToolTip = 'Specifies the value of the SalesPriceText field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if SalesPriceText = '' then
                            SalesPriceText := '0';
                        Evaluate(Rec."Sales Price", SalesPriceText);
                        if Rec."Sales Price" <> ItemWorksheetLine."Sales Price" then
                            Rec.Validate("Sales Price")
                        else
                            Rec.Validate("Sales Price", 0);
                        Rec.Modify(true);
                        RefreshSalesPriceText();
                        CurrPage.Update(false);
                    end;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        if (Rec."Direct Unit Cost" <> xRec."Direct Unit Cost") and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Unit Cost"; PurchasePriceText)
                {

                    Caption = 'Unit Cost';
                    Style = StandardAccent;
                    StyleExpr = PurchasePriceBold;
                    ToolTip = 'Specifies the value of the PurchasePriceText field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if PurchasePriceText = '' then
                            PurchasePriceText := '0';
                        Evaluate(Rec."Direct Unit Cost", PurchasePriceText);
                        if Rec."Direct Unit Cost" <> ItemWorksheetLine."Direct Unit Cost" then
                            Rec.Validate("Direct Unit Cost")
                        else
                            Rec.Validate("Direct Unit Cost", 0);
                        Rec.Modify(true);
                        RefreshPurchasePriceText();
                        CurrPage.Update(false);
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec.Description <> xRec.Description) and (Rec."Heading Text" = '') then
                            Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (Rec."Heading Text" = '') then
                            Rec.Modify(true);
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
        RefreshSalesPriceText();
        RefreshPurchasePriceText();
        RefreshRRPText();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Worksheet Template Name" := ItemWorksheetLine."Worksheet Template Name";
        Rec."Worksheet Name" := ItemWorksheetLine."Worksheet Name";
        Rec."Worksheet Line No." := ItemWorksheetLine."Line No.";
    end;

    trigger OnOpenPage()
    begin
        if not VarietySetup.Get() then
            VarietySetup.Init();
        CrossRefEditable := VarietySetup."Create Item Cross Ref. auto.";
    end;

    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        VarietySetup: Record "NPR Variety Setup";
        AutoFormatManagement: Codeunit "Auto Format";
        CrossRefEditable: Boolean;
        PurchasePriceBold: Boolean;
        RecommendedRetailPriceBold: Boolean;
        SalesPriceBold: Boolean;
        [InDataSet]
        Variety1InUse: Boolean;
        [InDataSet]
        Variety2InUse: Boolean;
        [InDataSet]
        Variety3InUse: Boolean;
        [InDataSet]
        Variety4InUse: Boolean;
        FieldCaptionNew: array[4] of Text;
        PurchasePriceText: Text[20];
        RecommendedRetailPriceText: Text[20];
        SalesPriceText: Text[20];
        PlaceHolder1ParenthesisLbl: Label '( %1 )', Locked = true;
        PlaceHolder1Lbl: Label '( %1 )', Locked = true;

    procedure SetRecFromIW(ItemWorksheetLineHere: Record "NPR Item Worksheet Line")
    var
        LocRecItemWorksheet: Record "NPR Item Worksheet";
    begin
        ItemWorksheetLine := ItemWorksheetLineHere;

        Rec.FilterGroup := 2;
        Rec.SetRange("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        Rec.SetRange("Worksheet Line No.", ItemWorksheetLine."Line No.");
        Rec.FilterGroup := 0;

        MakeCaptions();
        if CurrentClientType <> CLIENTTYPE::Windows then begin
            if LocRecItemWorksheet.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name") then begin
                case LocRecItemWorksheet."Show Variety Level" of
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2+3+4":
                        Rec.SetRange(Level, 0, 3);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2+3":
                        Rec.SetRange(Level, 0, 2);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1+2":
                        Rec.SetRange(Level, 0, 1);
                    LocRecItemWorksheet."Show Variety Level"::"Variety 1":
                        Rec.SetRange(Level, 0, 0);
                end;
            end;
        end;
    end;

    procedure UpdateSubPage()
    begin
        CurrPage.Update(false);
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


    local procedure RefreshSalesPriceText()
    begin
        Rec.GetLine();
        if Rec."Heading Text" <> '' then
            SalesPriceText := ''
        else
            if Rec."Sales Price" = 0 then
                SalesPriceText := StrSubstNo(PlaceHolder1ParenthesisLbl, Format(ItemWorksheetLine."Sales Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                SalesPriceText := StrSubstNo(PlaceHolder1Lbl, Format(Rec."Sales Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        SalesPriceBold := Rec."Sales Price" > 0;
    end;

    local procedure RefreshPurchasePriceText()
    begin
        Rec.GetLine();
        if Rec."Heading Text" <> '' then
            PurchasePriceText := ''
        else
            if Rec."Direct Unit Cost" = 0 then
                PurchasePriceText := StrSubstNo(PlaceHolder1ParenthesisLbl, Format(ItemWorksheetLine."Direct Unit Cost", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                PurchasePriceText := StrSubstNo(PlaceHolder1Lbl, Format(Rec."Direct Unit Cost", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        PurchasePriceBold := Rec."Direct Unit Cost" > 0;
    end;

    local procedure RefreshRRPText()
    begin
        Rec.GetLine();
        if Rec."Heading Text" <> '' then
            RecommendedRetailPriceText := ''
        else
            if Rec."Recommended Retail Price" = 0 then
                RecommendedRetailPriceText := StrSubstNo(PlaceHolder1ParenthesisLbl, Format(ItemWorksheetLine."Recommended Retail Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')))
            else
                RecommendedRetailPriceText := StrSubstNo(PlaceHolder1Lbl, Format(Rec."Recommended Retail Price", 0, AutoFormatManagement.ResolveAutoFormat(Enum::"Auto Format".FromInteger(2), '')));
        RecommendedRetailPriceBold := Rec."Recommended Retail Price" > 0;
    end;
}

