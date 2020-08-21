page 6151553 "NpXml Elements"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01 /MHA /20150115  CASE 204467 Added Custom Codeunit ID for Customized Field Values
    // NC1.04 /MHA /20150209  CASE 199932 Added 300 field Comment
    // NC1.07 /MHA /20150309  CASE 206395 Added Field 1010 Hidden
    // NC1.08 /MHA /20150310  CASE 206395 Added CurrPage.Update on "Table No.".OnValidate in order to Update Parent Info and function PreviewXml()
    // NC1.11 /MHA /20150330  CASE 210171 Added functions MoveDown() and MoveUp()
    // NC1.13 /MHA /20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.20 /TTH /20151005  CASE 218023 Adding Preffix to the XML Tags and attributes
    // NC1.21 /TTH /20151104  CASE 224528 Added control <Template Version>
    // NC1.21 /MHA /20151105  CASE 226655 Added Normalization if Line No. cannot be split during insert
    // NC1.22 /MHA /20151203  CASE 224528 Changed Page to only be editable if NpXml Template is not Archived
    // NC1.22 /MHA /20160429  CASE 237658 NpXml extended with Namespaces
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.01 /MHA /20161018  CASE 2425550 Added Generic Table fields for enabling Temporary Table Exports
    // NC2.01 /MHA /20161018  CASE 2425550 Added Xml Value fields for enabling Value generation by Subscription
    // NC2.03 /MHA /20170404  CASE 267094 Added SetEnabledFilter() to Attribute SubPage

    AutoSplitKey = true;
    Caption = 'Xml Elements';
    DelayedInsert = true;
    DeleteAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Manage';
    SourceTable = "NpXml Element";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Hidden;
                IndentationColumn = Level;
                IndentationControls = "Element Name";
                ShowAsTree = true;
                field("Element Name"; "Element Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ContainerElement;
                }
                field(Namespace; Namespace)
                {
                    ApplicationArea = All;
                    Visible = NamespacesEnabled;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field(Hidden; Hidden)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NC1.08
                        CurrPage.Update(true);
                        //+NC1.08
                        //-NC2.00
                        InsertRelations();
                        //+NC2.00
                    end;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Template Version No."; "Template Version No.")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                }
                field(CDATA; CDATA)
                {
                    ApplicationArea = All;
                }
                field("Field Type"; "Field Type")
                {
                    ApplicationArea = All;
                }
                field("Enum List (,)"; "Enum List (,)")
                {
                    ApplicationArea = All;
                }
                field("Custom Codeunit ID"; "Custom Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Custom Codeunit Name"; "Custom Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Xml Value Function"; "Xml Value Function")
                {
                    ApplicationArea = All;
                }
                field("Xml Value Codeunit ID"; "Xml Value Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Xml Value Codeunit Name"; "Xml Value Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Generic Child Function"; "Generic Child Function")
                {
                    ApplicationArea = All;
                }
                field("Generic Child Codeunit ID"; "Generic Child Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Generic Child Codeunit Name"; "Generic Child Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Only with Value"; "Only with Value")
                {
                    ApplicationArea = All;
                }
                field("Iteration Type"; "Iteration Type")
                {
                    ApplicationArea = All;
                }
                field("Reverse Sign"; "Reverse Sign")
                {
                    ApplicationArea = All;
                }
                field("Lower Case"; "Lower Case")
                {
                    ApplicationArea = All;
                }
                field("Blank Zero"; "Blank Zero")
                {
                    ApplicationArea = All;
                }
                field("Has Filter"; "Has Filter")
                {
                    ApplicationArea = All;
                }
                field("Has Attribute"; "Has Attribute")
                {
                    ApplicationArea = All;
                }
            }
            part(PagePartMappingFilter; "NpXml Filters")
            {
                ShowFilter = false;
                SubPageLink = "Xml Template Code" = FIELD("Xml Template Code"),
                              "Xml Element Line No." = FIELD("Line No.");
            }
            part(PagePartAttributes; "NpXml Attributes")
            {
                ShowFilter = false;
                SubPageLink = "Xml Template Code" = FIELD("Xml Template Code"),
                              "Xml Element Line No." = FIELD("Line No.");
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
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Insert';

                    trigger OnAction()
                    begin
                        //-NC2.00
                        InsertNewElement(0);
                        //+NC2.00
                    end;
                }
                action("New Child")
                {
                    Caption = 'New Element (Child)';
                    Image = New;
                    Promoted = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Insert';

                    trigger OnAction()
                    begin
                        //-NC2.00
                        InsertNewElement(1);
                        //+NC2.00
                    end;
                }
                action("New Parent")
                {
                    Caption = 'New Element (Parent)';
                    Image = New;
                    Promoted = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+Insert';

                    trigger OnAction()
                    begin
                        //-NC2.00
                        InsertNewElement(2);
                        //+NC2.00
                    end;
                }
                action(Delete)
                {
                    Caption = 'Delete';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Delete';

                    trigger OnAction()
                    var
                        NpXmlElement: Record "NpXml Element";
                    begin
                        //-NC2.00
                        if not Confirm(Text000, true) then
                            exit;

                        CurrPage.SetSelectionFilter(NpXmlElement);
                        NpXmlElement.DeleteAll(true);
                        //+NC2.00
                    end;
                }
            }
            group(ActionGroup6151404)
            {
                action("Copy from Xml Template")
                {
                    Caption = 'Copy from Xml Template';
                    Image = CopyWorksheet;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        //-NC1.13
                        //XMLMgt.CopyXmlTemplate("Xml Template Code");
                        NpXmlTemplateMgt.CopyXmlTemplate("Xml Template Code");
                        //+NC1.13
                        CurrPage.Update(false);
                    end;
                }
                action("Preview Xml")
                {
                    Caption = 'Preview Xml';
                    Image = XMLFile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //-NC1.08
                        PreviewXml();
                        //+NC1.08
                    end;
                }
                action(Normalize)
                {
                    Caption = 'Normalize';
                    Image = ExchProdBOMItem;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        //-NC1.21
                        //-NC2.00
                        //NpXmlTemplateMgt.NormalizeNpXmlElementLineNo("Xml Template Code");
                        NpXmlTemplateMgt.NormalizeNpXmlElementLineNo("Xml Template Code", Rec);
                        Find;
                        //+NC2.00
                        //+NC1.21
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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //-NC1.11
                        MoveUp();
                        //+NC1.11
                    end;
                }
                action("Move Down")
                {
                    Caption = 'Move Down';
                    Image = MoveDown;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //-NC1.11
                        MoveDown();
                        //+NC1.11
                    end;
                }
                action("Decrement Level")
                {
                    Caption = 'Decrement Level';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

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
        CurrPage.PagePartAttributes.PAGE.SetTableNo("Table No.");
        CurrPage.PagePartMappingFilter.PAGE.SetTableNo("Table No.");
        CurrPage.PagePartMappingFilter.PAGE.SetParentTableNo("Parent Table No.");
    end;

    trigger OnAfterGetRecord()
    begin
        ContainerElement := IsContainer();
    end;

    trigger OnOpenPage()
    begin
        //-NC1.22
        ////-NC1.22
        //SetIsArchived();
        ////+NC1.22
        SetEnabledFilters();
        //+NC1.22
        //-NC2.00
        ToggleTreeView();
        //+NC2.00
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpXmlTemplate: Record "NpXml Template";
        TemplateCode: Code[10];
    begin
    end;

    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
        ContainerElement: Boolean;
        NamespacesEnabled: Boolean;
        Text000: Label 'Do you want to delete the selected line or lines?';
        Text001: Label 'Add Table Link from table %1 %2?';

    local procedure ToggleTreeView()
    var
        ActiveSession: Record "Active Session";
        [RunOnClient]
        SendKeys: DotNet npNetSendKeys;
    begin
        //-NC2.00
        if not ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit;

        if ActiveSession."Client Type" <> ActiveSession."Client Type"::"Windows Client" then
            exit;

        SendKeys.Send('^+Q');
        //+NC2.00
    end;

    local procedure InsertNewElement(ElementType: Option Sibling,Child,Parent)
    var
        NpXmlElement: Record "NpXml Element";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
    begin
        //-NC2.00
        if ElementType = ElementType::Parent then
            NpXmlTemplateMgt.InitNpXmlElementAbove("Xml Template Code", "Line No.", NpXmlElement)
        else
            NpXmlTemplateMgt.InitNpXmlElementBelow("Xml Template Code", "Line No.", NpXmlElement);

        case ElementType of
            ElementType::Sibling:
                NpXmlElement.Level := Level;
            ElementType::Child:
                NpXmlElement.Level := Level + 1;
            ElementType::Parent:
                begin
                    NpXmlElement.Level := Level - 1;
                    if NpXmlElement.Level < 0 then
                        NpXmlElement.Level := 0;
                end;
        end;
        NpXmlElement."Table No." := "Table No.";
        NpXmlElement."Element Name" := 'new_element_' + LowerCase(Format(ElementType));
        NpXmlElement.Insert(true);
        Get(NpXmlElement."Xml Template Code", NpXmlElement."Line No.");

        ToggleTreeView();
        //+NC2.00
    end;

    local procedure InsertRelations()
    var
        "Field": Record "Field";
        ObjectMetadata: Record "Object Metadata";
        NpXmlElement: Record "NpXml Element";
        NpXmlFilter: Record "NpXml Filter";
        TempField: Record "Field" temporary;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        LineNo: Integer;
        i: Integer;
    begin
        //-NC2.00
        if not TableMetadata.Get("Table No.") then
            exit;

        NpXmlElement := Rec;
        NpXmlElement.SetRange("Xml Template Code", "Xml Template Code");
        repeat
            if NpXmlElement.Next(-1) = 0 then
                exit;
        until NpXmlElement.Level + 1 = Level;

        if NpXmlElement."Table No." = "Table No." then
            exit;
        if not TableMetadata.Get(NpXmlElement."Table No.") then
            exit;

        RecRef.Open("Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close;
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);

            Field.Get("Table No.", FieldRef.Number);
            if Field.RelationTableNo = NpXmlElement."Table No." then begin
                TempField.Init;
                TempField := Field;
                TempField.Insert;
            end;
        end;

        if not TempField.FindSet then
            exit;

        NpXmlElement.CalcFields("Table Name");
        if not Confirm(StrSubstNo(Text001, NpXmlElement."Table No.", NpXmlElement."Table Name"), true) then
            exit;

        RecRef.Open(NpXmlElement."Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close;
        FieldRef := KeyRef.FieldIndex(1);

        NpXmlFilter.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", "Line No.");
        NpXmlFilter.DeleteAll;
        LineNo := 0;
        repeat
            LineNo += 10000;
            NpXmlFilter.Init;
            NpXmlFilter."Xml Template Code" := "Xml Template Code";
            NpXmlFilter."Xml Element Line No." := "Line No.";
            NpXmlFilter."Line No." := LineNo;
            NpXmlFilter."Filter Type" := NpXmlFilter."Filter Type"::TableLink;
            NpXmlFilter."Parent Table No." := TempField.RelationTableNo;
            NpXmlFilter."Parent Field No." := TempField.RelationFieldNo;
            if NpXmlFilter."Parent Field No." = 0 then
                NpXmlFilter."Parent Field No." := FieldRef.Number;
            NpXmlFilter."Table No." := TempField.TableNo;
            NpXmlFilter."Field No." := TempField."No.";
            NpXmlFilter.Insert(true);
        until TempField.Next = 0;
        //+NC2.00
    end;

    procedure MoveDown()
    var
        NpXmlElement: Record "NpXml Element";
        TempNpXmlElement: Record "NpXml Element" temporary;
    begin
        //-NC1.11
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlElement);
        if not NpXmlElement.FindSet then
            exit;

        if Next = 0 then
            exit;

        TempNpXmlElement.DeleteAll;
        repeat
            TempNpXmlElement.Init;
            TempNpXmlElement := NpXmlElement;
            TempNpXmlElement.Insert;
        until NpXmlElement.Next = 0;

        NpXmlElement.Reset;
        NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        NpXmlElement.SetRange("Xml Template Code", TempNpXmlElement."Xml Template Code");
        if NpXmlElement.Next = 0 then
            exit;

        repeat
            //-NC1.13
            //NpXmlMgt.SwapNpXmlElementLineNo(TempNpXmlElement,NpXmlElement);
            NpXmlTemplateMgt.SwapNpXmlElementLineNo(TempNpXmlElement, NpXmlElement);
            //+NC1.13
            NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        until TempNpXmlElement.Next(-1) = 0;
        //+NC1.11
    end;

    procedure MoveUp()
    var
        NpXmlElement: Record "NpXml Element";
        TempNpXmlElement: Record "NpXml Element" temporary;
        LineNo: Integer;
    begin
        //-NC1.11
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlElement);
        if not NpXmlElement.FindLast then
            exit;

        if Next(-1) = 0 then
            exit;
        LineNo := "Line No.";

        TempNpXmlElement.DeleteAll;
        repeat
            TempNpXmlElement.Init;
            TempNpXmlElement := NpXmlElement;
            TempNpXmlElement.Insert;
        until NpXmlElement.Next(-1) = 0;

        NpXmlElement.Reset;
        NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        NpXmlElement.SetRange("Xml Template Code", TempNpXmlElement."Xml Template Code");
        if NpXmlElement.Next(-1) = 0 then
            exit;

        repeat
            //-NC1.13
            //NpXmlMgt.SwapNpXmlElementLineNo(TempNpXmlElement,NpXmlElement);
            NpXmlTemplateMgt.SwapNpXmlElementLineNo(TempNpXmlElement, NpXmlElement);
            //+NC1.13
            NpXmlElement.Get(TempNpXmlElement."Xml Template Code", TempNpXmlElement."Line No.");
        until TempNpXmlElement.Next = 0;

        FindFirst;
        Get("Xml Template Code", LineNo);
        //+NC1.11
    end;

    local procedure PreviewXml()
    begin
        //-NC1.08
        NpXmlMgt.PreviewXml("Xml Template Code");
        //+NC1.08
    end;

    local procedure SetEnabledFilters()
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NC1.22
        if NpXmlTemplate.Get(GetFilter("Xml Template Code")) then;
        //-NC2.00
        //IsArchived := NpXmlTemplate.Archived;
        //+NC2.20
        //+NC1.22
        //-NC1.22
        NamespacesEnabled := NpXmlTemplate."Namespaces Enabled";
        //+NC1.22
        //-NC2.03 [267094]
        CurrPage.PagePartAttributes.PAGE.SetEnabledFilters(NpXmlTemplate);
        //+NC2.03 [267094]
    end;

    local procedure UpdateLevel(Steps: Integer)
    var
        XMLElement: Record "NpXml Element";
    begin
        XMLElement.Reset;
        CurrPage.SetSelectionFilter(XMLElement);
        if XMLElement.FindSet then
            repeat
                XMLElement.Level += Steps;
                if XMLElement.Level < 0 then
                    XMLElement.Level := 0;
                XMLElement.Modify(true);
            until XMLElement.Next = 0;

        XMLElement.Reset;
        XMLElement.SetRange("Xml Template Code", "Xml Template Code");
        //-NC1.11
        //XMLElement.SETFILTER("Line No.",'<>%1',"Line No.");
        //+NC1.11
        if XMLElement.FindSet then
            repeat
                XMLElement.UpdateParentInfo();
                XMLElement.Modify;
            until XMLElement.Next = 0;

        CurrPage.Update(false);
    end;
}

