page 6151559 "NPR NpXml Templ. Trigger List"
{
    // NC1.01/MH/20150201  CASE 199932 Object created
    // NC1.11/MH/20150330  CASE 210171 Added multi level triggers
    // NC1.21/MHA/20151023 CASE 225088 Added Coloring based on HasNoLinks()
    // CASE224528/MHA/20151023 CASE 224528 Deleted function SetXmlTemplateTableNo() and Action "Trigger Links" as the page is non editable
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.08/TS  /20180108  CASE 300893 Changed Page type to ListPart as it is a part on Page 6151552

    AutoSplitKey = true;
    Caption = 'Xml Template Triggers';
    CardPageID = "NPR NpXml Template Card";
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR NpXml Template Trigger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "Table Name";
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Insert Trigger"; "Insert Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Trigger field';
                }
                field("Modify Trigger"; "Modify Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Trigger field';
                }
                field("Delete Trigger"; "Delete Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Trigger field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Comment field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-CASE224528
        //"Parent Table No." := XmlTemplateTableNo;
        //+CASE224528
    end;

    var
        [InDataSet]
        HasNoLinks: Boolean;

    local procedure SetHasNoLinks()
    var
        NpXmlTemplateTriggerLinks: Record "NPR NpXml Templ.Trigger Link";
    begin
        //-NC1.21
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlTemplateTriggerLinks.SetRange("Xml Template Trigger Line No.", "Line No.");
        HasNoLinks := ("Parent Table No." <> "Table No.") and NpXmlTemplateTriggerLinks.IsEmpty;
        //+NC1.21
    end;
}

