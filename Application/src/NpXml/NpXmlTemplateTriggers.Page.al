page 6151558 "NPR NpXml Template Triggers"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Xml Template Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR NpXml Template Trigger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; Rec."Table No.")
                {

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Insert Trigger"; Rec."Insert Trigger")
                {

                    ToolTip = 'Specifies the value of the Insert Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Modify Trigger"; Rec."Modify Trigger")
                {

                    ToolTip = 'Specifies the value of the Modify Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Trigger"; Rec."Delete Trigger")
                {

                    ToolTip = 'Specifies the value of the Delete Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Generic Parent Function"; Rec."Generic Parent Function")
                {

                    ToolTip = 'Specifies the value of the Generic Parent Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Generic Parent Codeunit ID"; Rec."Generic Parent Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Generic Parent Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Generic Parent Codeunit Name"; Rec."Generic Parent Codeunit Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Generic Parent Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Trigger Links")
            {
                Caption = 'Trigger Links';
                Image = Links;

                ToolTip = 'Executes the Trigger Links action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpXmlTemplateTriggerLinks: Page "NPR NpXml Templ. Trigger Links";
                begin
                    Clear(NpXmlTemplateTriggerLinks);
                    NpXmlTemplateTriggerLinks.SetTemplateTriggerView(Rec);
                    NpXmlTemplateTriggerLinks.Run();
                end;
            }
            action("Move Up")
            {
                Caption = 'Move Up';
                Image = MoveUp;

                ToolTip = 'Executes the Move Up action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    MoveUp();
                end;
            }
            action("Move Down")
            {
                Caption = 'Move Down';
                Image = MoveDown;

                ToolTip = 'Executes the Move Down action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    MoveDown();
                end;
            }
            group("Multi Level Trigger")
            {
                Caption = 'Multi Level';
                action("Decrement Level")
                {
                    Caption = 'Decrement Level';
                    Image = PreviousRecord;

                    ToolTip = 'Executes the Decrement Level action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateLevel(-1);
                    end;
                }
                action("Increment Level")
                {
                    Caption = 'Increment Level';
                    Image = NextRecord;

                    ToolTip = 'Executes the Increment Level action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateLevel(1);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IndentTableName();
        SetHasNoLinks();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Parent Line No." := Rec.GetParentLineNo();
    end;

    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        [InDataSet]
        HasNoLinks: Boolean;

    local procedure IndentTableName()
    begin
        if Rec.Level > 0 then
            Rec."Table Name" := PadStr('', Rec.Level * 3, ' ') + Rec."Table Name";
    end;

    procedure MoveDown()
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        TempNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger" temporary;
    begin
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if not NpXmlTemplateTrigger.FindSet() then
            exit;

        if Rec.Next() = 0 then
            exit;

        TempNpXmlTemplateTrigger.DeleteAll();
        repeat
            TempNpXmlTemplateTrigger.Init();
            TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
            TempNpXmlTemplateTrigger.Insert();
        until NpXmlTemplateTrigger.Next() = 0;

        NpXmlTemplateTrigger.Reset();
        NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code", TempNpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger.SetRange("Xml Template Code", TempNpXmlTemplateTrigger."Xml Template Code");
        if NpXmlTemplateTrigger.Next() = 0 then
            exit;

        repeat
            NpXmlTemplateMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger, NpXmlTemplateTrigger);
            NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code", TempNpXmlTemplateTrigger."Line No.");
        until TempNpXmlTemplateTrigger.Next(-1) = 0;
    end;

    procedure MoveUp()
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        TempNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger" temporary;
        LineNo: Integer;
    begin
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if not NpXmlTemplateTrigger.Find('+') then
            exit;

        if Rec.Next(-1) = 0 then
            exit;
        LineNo := Rec."Line No.";

        TempNpXmlTemplateTrigger.DeleteAll();
        repeat
            TempNpXmlTemplateTrigger.Init();
            TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
            TempNpXmlTemplateTrigger.Insert();
        until NpXmlTemplateTrigger.Next(-1) = 0;

        NpXmlTemplateTrigger.Reset();
        NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code", TempNpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger.SetRange("Xml Template Code", TempNpXmlTemplateTrigger."Xml Template Code");
        if NpXmlTemplateTrigger.Next(-1) = 0 then
            exit;

        repeat
            NpXmlTemplateMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger, NpXmlTemplateTrigger);
            NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code", TempNpXmlTemplateTrigger."Line No.");
        until TempNpXmlTemplateTrigger.Next() = 0;

        Rec.FindFirst();
        Rec.Get(Rec."Xml Template Code", LineNo);
    end;

    local procedure UpdateLevel(Steps: Integer)
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
    begin
        NpXmlTemplateTrigger.Reset();
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if NpXmlTemplateTrigger.FindSet() then
            repeat
                NpXmlTemplateTrigger.Level += Steps;
                if NpXmlTemplateTrigger.Level < 0 then
                    NpXmlTemplateTrigger.Level := 0;
                NpXmlTemplateTrigger.Modify(true);
            until NpXmlTemplateTrigger.Next() = 0;

        NpXmlTemplateTrigger.Reset();
        NpXmlTemplateTrigger.SetRange("Xml Template Code", Rec."Xml Template Code");
        if NpXmlTemplateTrigger.FindSet() then
            repeat
                NpXmlTemplateTrigger.UpdateParentInfo();
                NpXmlTemplateTrigger.Modify();
            until NpXmlTemplateTrigger.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure SetHasNoLinks()
    var
        NpXmlTemplateTriggerLinks: Record "NPR NpXml Templ.Trigger Link";
    begin
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Code", Rec."Xml Template Code");
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Trigger Line No.", Rec."Line No.");
        HasNoLinks := (Rec."Parent Table No." <> Rec."Table No.") and NpXmlTemplateTriggerLinks.IsEmpty();
    end;
}

