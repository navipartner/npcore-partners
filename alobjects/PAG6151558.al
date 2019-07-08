page 6151558 "NpXml Template Triggers"
{
    // NC1.01/MH/20150201  CASE 199932 Object created
    // NC1.11/MH/20150330  CASE 210171 Added multi level triggers and functions MoveDown() and MoveUp()
    // NC1.13/MH/20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.21/TS/20151014 CASE 225088 Added to Coloring based on (Parent Table No.<>Table No.) AND (Has no Trigger Links)
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161018 CASE 2425550 Added Generic Table fields for enabling Temporary Table Exports

    AutoSplitKey = true;
    Caption = 'Xml Template Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NpXml Template Trigger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No.";"Table No.")
                {
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                }
                field("Table Name";"Table Name")
                {
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                }
                field("Insert Trigger";"Insert Trigger")
                {
                }
                field("Modify Trigger";"Modify Trigger")
                {
                }
                field("Delete Trigger";"Delete Trigger")
                {
                }
                field(Comment;Comment)
                {
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                }
                field("Generic Parent Function";"Generic Parent Function")
                {
                }
                field("Generic Parent Codeunit ID";"Generic Parent Codeunit ID")
                {
                    Visible = false;
                }
                field("Generic Parent Codeunit Name";"Generic Parent Codeunit Name")
                {
                    Visible = false;
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

                trigger OnAction()
                var
                    NpXmlTemplateTriggerLinks: Page "NpXml Template Trigger Links";
                begin
                    Clear(NpXmlTemplateTriggerLinks);
                    NpXmlTemplateTriggerLinks.SetTemplateTriggerView(Rec);
                    NpXmlTemplateTriggerLinks.Run;
                end;
            }
            action("Move Up")
            {
                Caption = 'Move Up';
                Image = MoveUp;

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

                trigger OnAction()
                begin
                    //-NC1.11
                    MoveDown();
                    //+NC1.11
                end;
            }
            group("Multi Level Trigger")
            {
                Caption = 'Multi Level';
                action("Decrement Level")
                {
                    Caption = 'Decrement Level';
                    Image = PreviousRecord;

                    trigger OnAction()
                    begin
                        UpdateLevel(-1);
                    end;
                }
                action("Increment Level")
                {
                    Caption = 'Increment Level';
                    Image = NextRecord;

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
        //-NC2.00
        IndentTableName();
        //+NC2.00
        //-NC1.21
        SetHasNoLinks();
        //+NC1.21
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NC1.11
        //"Xml Template Table No." := XmlTemplateTableNo;
        "Parent Line No." := GetParentLineNo();
        //+NC1.11
    end;

    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
        [InDataSet]
        HasNoLinks: Boolean;

    local procedure IndentTableName()
    begin
        //-NC2.00
        if Level > 0 then
          "Table Name" := PadStr('',Level * 3,' ') + "Table Name";
        //+NC2.00
    end;

    procedure MoveDown()
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        TempNpXmlTemplateTrigger: Record "NpXml Template Trigger" temporary;
    begin
        //-NC1.11
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if not NpXmlTemplateTrigger.FindSet then
          exit;

        if Next = 0 then
          exit;

        TempNpXmlTemplateTrigger.DeleteAll;
        repeat
          TempNpXmlTemplateTrigger.Init;
          TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
          TempNpXmlTemplateTrigger.Insert;
        until NpXmlTemplateTrigger.Next = 0;

        NpXmlTemplateTrigger.Reset;
        NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code",TempNpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger.SetRange("Xml Template Code",TempNpXmlTemplateTrigger."Xml Template Code");
        if NpXmlTemplateTrigger.Next = 0 then
          exit;

        repeat
          //-NC1.13
          //NpXmlMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger,NpXmlTemplateTrigger);
          NpXmlTemplateMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger,NpXmlTemplateTrigger);
          //+NC1.13
          NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code",TempNpXmlTemplateTrigger."Line No.");
        until TempNpXmlTemplateTrigger.Next(-1) = 0;
        //+NC1.11
    end;

    procedure MoveUp()
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        TempNpXmlTemplateTrigger: Record "NpXml Template Trigger" temporary;
        LineNo: Integer;
    begin
        //-NC1.11
        CurrPage.Update(true);
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if not NpXmlTemplateTrigger.FindLast then
          exit;

        if Next(-1) = 0 then
          exit;
        LineNo := "Line No.";

        TempNpXmlTemplateTrigger.DeleteAll;
        repeat
          TempNpXmlTemplateTrigger.Init;
          TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
          TempNpXmlTemplateTrigger.Insert;
        until NpXmlTemplateTrigger.Next(-1) = 0;

        NpXmlTemplateTrigger.Reset;
        NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code",TempNpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger.SetRange("Xml Template Code",TempNpXmlTemplateTrigger."Xml Template Code");
        if NpXmlTemplateTrigger.Next(-1) = 0 then
          exit;

        repeat
          //-NC1.13
          //NpXmlMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger,NpXmlTemplateTrigger);
          NpXmlTemplateMgt.SwapNpXmlTriggerLineNo(TempNpXmlTemplateTrigger,NpXmlTemplateTrigger);
          //+NC1.13
          NpXmlTemplateTrigger.Get(TempNpXmlTemplateTrigger."Xml Template Code",TempNpXmlTemplateTrigger."Line No.");
        until TempNpXmlTemplateTrigger.Next = 0;

        FindFirst;
        Get("Xml Template Code",LineNo);
        //+NC1.11
    end;

    local procedure UpdateLevel(Steps: Integer)
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
    begin
        //-NC1.11
        NpXmlTemplateTrigger.Reset;
        CurrPage.SetSelectionFilter(NpXmlTemplateTrigger);
        if NpXmlTemplateTrigger.FindSet then
          repeat
            NpXmlTemplateTrigger.Level += Steps;
            if NpXmlTemplateTrigger.Level < 0 then
              NpXmlTemplateTrigger.Level := 0;
            NpXmlTemplateTrigger.Modify(true);
          until NpXmlTemplateTrigger.Next = 0;

        NpXmlTemplateTrigger.Reset;
        NpXmlTemplateTrigger.SetRange("Xml Template Code","Xml Template Code");
        if NpXmlTemplateTrigger.FindSet then
          repeat
            NpXmlTemplateTrigger.UpdateParentInfo();
            NpXmlTemplateTrigger.Modify;
          until NpXmlTemplateTrigger.Next = 0;

        CurrPage.Update(false);
        //+NC1.11
    end;

    local procedure SetHasNoLinks()
    var
        NpXmlTemplateTriggerLinks: Record "NpXml Template Trigger Link";
    begin
        //-NC1.21
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Code","Xml Template Code");
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Trigger Line No.","Line No.");
        HasNoLinks := ("Parent Table No." <> "Table No.") and NpXmlTemplateTriggerLinks.IsEmpty;
        //+NC1.21
    end;
}

