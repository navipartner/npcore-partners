page 6151553 "NPR NpXml Elements"
{
    AutoSplitKey = true;
    Caption = 'Xml Elements';
    DelayedInsert = true;
    DeleteAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Manage';
    SourceTable = "NPR NpXml Element";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Hidden;
                IndentationColumn = Rec.Level;
                IndentationControls = "Element Name";
                ShowAsTree = true;
                field("Element Name"; Rec."Element Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ContainerElement;
                    ToolTip = 'Specifies the value of the Element Name field';
                }
                field(Namespace; Rec.Namespace)
                {
                    ApplicationArea = All;
                    Visible = NamespacesEnabled;
                    ToolTip = 'Specifies the value of the Namespace field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field(Hidden; Rec.Hidden)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hidden field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                        InsertRelations();
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Template Version No."; Rec."Template Version No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Version No. field';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
                field(CDATA; Rec.CDATA)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CDATA field';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Type field';
                }
                field("Enum List (,)"; Rec."Enum List (,)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enum List field';
                }
                field("Custom Codeunit ID"; Rec."Custom Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Custom Codeunit ID field';
                }
                field("Custom Codeunit Name"; Rec."Custom Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Custom Codeunit Name field';
                }
                field("Xml Value Function"; Rec."Xml Value Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Xml Value Function field';
                }
                field("Xml Value Codeunit ID"; Rec."Xml Value Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Xml Value Codeunit ID field';
                }
                field("Xml Value Codeunit Name"; Rec."Xml Value Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Xml Value Codeunit Name field';
                }
                field("Generic Child Function"; Rec."Generic Child Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generic Child Function field';
                }
                field("Generic Child Codeunit ID"; Rec."Generic Child Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Generic Child Codeunit ID field';
                }
                field("Generic Child Codeunit Name"; Rec."Generic Child Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Generic Child Codeunit Name field';
                }
                field("Only with Value"; Rec."Only with Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only with Value field';
                }
                field("Iteration Type"; Rec."Iteration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Iteration Type field';
                }
                field("Reverse Sign"; Rec."Reverse Sign")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reverse Sign field';
                }
                field("Round Precision"; Rec."Round Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies rounding precision for number values. For example: 0.01 means that value will have 2 decimals; 100 means that it could be 100, 200, 300...';
                }
                field("Round Direction"; Rec."Round Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies rounding direction for number values. There are three options: ''<'' (rounds down), ''>'' (rounds up) and ''='' (rounds up or down to the nearest value (default). Values of 5 or greater are rounded up. Values less than 5 are rounded down)';
                }
                field("Lower Case"; Rec."Lower Case")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lower Case field';
                }
                field("Blank Zero"; Rec."Blank Zero")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                }
                field("Replace Inherited Filters"; Rec."Replace Inherited Filters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether it is allowed to replaces filters, inherited from parent Xml elements, if another filter has been set up for the same field for current Xml Element. If the option is not activated, both filters will be applied for the field at the same time (using different FilterGroups)';
                }
                field("Has Filter"; Rec."Has Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Has Filter field';
                }
                field("Has Attribute"; Rec."Has Attribute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Has Attribute field';
                }
            }
            part(PagePartMappingFilter; "NPR NpXml Filters")
            {
                ShowFilter = false;
                SubPageLink = "Xml Template Code" = FIELD("Xml Template Code"),
                              "Xml Element Line No." = FIELD("Line No.");
                ApplicationArea = All;
            }
            part(PagePartAttributes; "NPR NpXml Attributes")
            {
                ShowFilter = false;
                SubPageLink = "Xml Template Code" = FIELD("Xml Template Code"),
                              "Xml Element Line No." = FIELD("Line No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup6151400)
            {
                action("New Sibling")
                {
                    Caption = 'New Element (Sibling)';
                    Image = New;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Insert';
                    ApplicationArea = All;
                    ToolTip = 'Executes the New Element (Sibling) action';

                    trigger OnAction()
                    begin
                        InsertNewElement(0);
                    end;
                }
                action("New Child")
                {
                    Caption = 'New Element (Child)';
                    Image = New;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Insert';
                    ApplicationArea = All;
                    ToolTip = 'Executes the New Element (Child) action';

                    trigger OnAction()
                    begin
                        InsertNewElement(1);
                    end;
                }
                action("New Parent")
                {
                    Caption = 'New Element (Parent)';
                    Image = New;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+Insert';
                    ApplicationArea = All;
                    ToolTip = 'Executes the New Element (Parent) action';

                    trigger OnAction()
                    begin
                        InsertNewElement(2);
                    end;
                }
                action("Delete")
                {
                    Caption = 'Delete';
                    Image = Delete;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Delete';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete action';

                    trigger OnAction()
                    var
                        NpXmlElement: Record "NPR NpXml Element";
                    begin
                        if not Confirm(Text000, true) then
                            exit;

                        CurrPage.SetSelectionFilter(NpXmlElement);
                        NpXmlElement.DeleteAll(true);
                    end;
                }
            }
            group(ActionGroup6151404)
            {
                action("Copy from Xml Template")
                {
                    Caption = 'Copy from Xml Template';
                    Image = CopyWorksheet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy from Xml Template action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        NpXmlTemplateMgt.CopyXmlTemplate(Rec."Xml Template Code");
                        CurrPage.Update(false);
                    end;
                }
                action("Preview Xml")
                {
                    Caption = 'Preview Xml';
                    Image = XMLFile;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Preview Xml action';

                    trigger OnAction()
                    begin
                        PreviewXml();
                    end;
                }
                action(Normalize)
                {
                    Caption = 'Normalize';
                    Image = ExchProdBOMItem;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Normalize action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        NpXmlTemplateMgt.NormalizeNpXmlElementLineNo(Rec."Xml Template Code", Rec);
                        Rec.Find();
                    end;
                }
            }
            group(ActionGroup6150649)
            {
                action("Move Up")
                {
                    Caption = 'Move Up';
                    Image = MoveUp;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move Up action';

                    trigger OnAction()
                    begin
                        MoveUp();
                    end;
                }
                action("Move Down")
                {
                    Caption = 'Move Down';
                    Image = MoveDown;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move Down action';

                    trigger OnAction()
                    begin
                        MoveDown();
                    end;
                }
                action("Decrement Level")
                {
                    Caption = 'Decrement Level';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Decrement Level action';

                    trigger OnAction()
                    begin
                        UpdateLevel(-1);
                    end;
                }
                action("Increment Level")
                {
                    Caption = 'Increment Level';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Increment Level action';

                    trigger OnAction()
                    begin
                        UpdateLevel(1);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.PagePartAttributes.PAGE.SetTableNo(Rec."Table No.");
        CurrPage.PagePartMappingFilter.PAGE.SetTableNo(Rec."Table No.");
        CurrPage.PagePartMappingFilter.PAGE.SetParentTableNo(Rec."Parent Table No.");
    end;

    trigger OnAfterGetRecord()
    begin
        ContainerElement := Rec.IsContainer();
    end;

    trigger OnOpenPage()
    begin
        SetEnabledFilters();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
    end;

    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        ContainerElement: Boolean;
        NamespacesEnabled: Boolean;
        Text000: Label 'Do you want to delete the selected line or lines?';
        Text001: Label 'Add Table Link from table %1 %2?';

    local procedure InsertNewElement(ElementType: Option Sibling,Child,Parent)
    var
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
    begin
        if ElementType = ElementType::Parent then
            NpXmlTemplateMgt.InitNpXmlElementAbove(Rec."Xml Template Code", Rec."Line No.", NpXmlElement)
        else
            NpXmlTemplateMgt.InitNpXmlElementBelow(Rec."Xml Template Code", Rec."Line No.", NpXmlElement);

        case ElementType of
            ElementType::Sibling:
                NpXmlElement.Level := Rec.Level;
            ElementType::Child:
                NpXmlElement.Level := Rec.Level + 1;
            ElementType::Parent:
                begin
                    NpXmlElement.Level := Rec.Level - 1;
                    if NpXmlElement.Level < 0 then
                        NpXmlElement.Level := 0;
                end;
        end;
        NpXmlElement."Table No." := Rec."Table No.";
        NpXmlElement."Element Name" := 'new_element_' + LowerCase(Format(ElementType));
        NpXmlElement.Insert(true);
    end;

    local procedure InsertRelations()
    var
        "Field": Record "Field";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlFilter: Record "NPR NpXml Filter";
        TempField: Record "Field" temporary;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        LineNo: Integer;
        i: Integer;
    begin
        if not TableMetadata.Get(Rec."Table No.") then
            exit;

        NpXmlElement := Rec;
        NpXmlElement.SetRange("Xml Template Code", Rec."Xml Template Code");
        repeat
            if NpXmlElement.Next(-1) = 0 then
                exit;
        until NpXmlElement.Level + 1 = Rec.Level;

        if NpXmlElement."Table No." = Rec."Table No." then
            exit;
        if not TableMetadata.Get(NpXmlElement."Table No.") then
            exit;

        RecRef.Open(Rec."Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close();
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);

            Field.Get(Rec."Table No.", FieldRef.Number);
            if Field.RelationTableNo = NpXmlElement."Table No." then begin
                TempField.Init();
                TempField := Field;
                TempField.Insert();
            end;
        end;

        if not TempField.FindSet() then
            exit;

        NpXmlElement.CalcFields("Table Name");
        if not Confirm(StrSubstNo(Text001, NpXmlElement."Table No.", NpXmlElement."Table Name"), true) then
            exit;

        RecRef.Open(NpXmlElement."Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close();
        FieldRef := KeyRef.FieldIndex(1);

        NpXmlFilter.SetRange("Xml Template Code", Rec."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", Rec."Line No.");
        NpXmlFilter.DeleteAll();
        LineNo := 0;
        repeat
            LineNo += 10000;
            NpXmlFilter.Init();
            NpXmlFilter."Xml Template Code" := Rec."Xml Template Code";
            NpXmlFilter."Xml Element Line No." := Rec."Line No.";
            NpXmlFilter."Line No." := LineNo;
            NpXmlFilter."Filter Type" := NpXmlFilter."Filter Type"::TableLink;
            NpXmlFilter."Parent Table No." := TempField.RelationTableNo;
            NpXmlFilter."Parent Field No." := TempField.RelationFieldNo;
            if NpXmlFilter."Parent Field No." = 0 then
                NpXmlFilter."Parent Field No." := FieldRef.Number;
            NpXmlFilter."Table No." := TempField.TableNo;
            NpXmlFilter."Field No." := TempField."No.";
            NpXmlFilter.Insert(true);
        until TempField.Next() = 0;
    end;

    procedure MoveDown()
    var
        NpXmlElement: Record "NPR NpXml Element";
        TempNpXmlElement: Record "NPR NpXml Element" temporary;
    begin
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlElement);
        if not NpXmlElement.FindSet() then
            exit;

        if Rec.Next() = 0 then
            exit;

        TempNpXmlElement.DeleteAll();
        repeat
            TempNpXmlElement.Init();
            TempNpXmlElement := NpXmlElement;
            TempNpXmlElement.Insert();
        until NpXmlElement.Next() = 0;

        NpXmlElement.Reset();
        NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        NpXmlElement.SetRange("Xml Template Code", TempNpXmlElement."Xml Template Code");
        if NpXmlElement.Next() = 0 then
            exit;

        repeat
            NpXmlTemplateMgt.SwapNpXmlElementLineNo(TempNpXmlElement, NpXmlElement);
            NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        until TempNpXmlElement.Next(-1) = 0;
    end;

    procedure MoveUp()
    var
        NpXmlElement: Record "NPR NpXml Element";
        TempNpXmlElement: Record "NPR NpXml Element" temporary;
        LineNo: Integer;
    begin
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlElement);
        if not NpXmlElement.Find('+') then
            exit;

        if Rec.Next(-1) = 0 then
            exit;
        LineNo := Rec."Line No.";

        TempNpXmlElement.DeleteAll();
        repeat
            TempNpXmlElement.Init();
            TempNpXmlElement := NpXmlElement;
            TempNpXmlElement.Insert();
        until NpXmlElement.Next(-1) = 0;

        NpXmlElement.Reset();
        NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        NpXmlElement.SetRange("Xml Template Code", TempNpXmlElement."Xml Template Code");
        if NpXmlElement.Next(-1) = 0 then
            exit;

        repeat
            NpXmlTemplateMgt.SwapNpXmlElementLineNo(TempNpXmlElement, NpXmlElement);
            NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        until TempNpXmlElement.Next() = 0;

        Rec.FindFirst();
        Rec.Get(Rec."Xml Template Code", LineNo);
    end;

    local procedure PreviewXml()
    begin
        NpXmlMgt.PreviewXml(Rec."Xml Template Code");
    end;

    local procedure SetEnabledFilters()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if NpXmlTemplate.Get(Rec.GetFilter("Xml Template Code")) then;
        NamespacesEnabled := NpXmlTemplate."Namespaces Enabled";
        CurrPage.PagePartAttributes.PAGE.SetEnabledFilters(NpXmlTemplate);
    end;

    local procedure UpdateLevel(Steps: Integer)
    var
        NpXmlElement: Record "NPR NpXml Element";
    begin
        NpXmlElement.Reset();
        CurrPage.SetSelectionFilter(NpXmlElement);
        if NpXmlElement.FindSet() then
            repeat
                NpXmlElement.Level += Steps;
                if NpXmlElement.Level < 0 then
                    NpXmlElement.Level := 0;
                NpXmlElement.Modify(true);
            until NpXmlElement.Next() = 0;

        NpXmlElement.Reset();
        NpXmlElement.SetRange("Xml Template Code", Rec."Xml Template Code");
        if NpXmlElement.FindSet() then
            repeat
                NpXmlElement.UpdateParentInfo();
                NpXmlElement.Modify();
            until NpXmlElement.Next() = 0;

        CurrPage.Update(false);
    end;
}

